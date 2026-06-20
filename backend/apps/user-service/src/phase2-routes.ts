import { createHmac } from "node:crypto";
import type { Db } from "./db.js";
import { z } from "zod";

const usernameSchema = z
  .string()
  .min(3)
  .max(32)
  .regex(/^[a-z0-9_]+$/, "Username must be lowercase letters, numbers, or underscore");

const defaultPrivacy = {
  requireMessageRequest: true,
  hidePhoneFromNonContacts: true,
  hidePhoneFromGroupMembers: true,
  allowDownload: true,
  readReceipts: true,
  typingIndicators: true,
  showOnlineStatus: true
};

function b64url(input: string | Buffer): string {
  return Buffer.from(input)
    .toString("base64")
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");
}

/** Centrifugo connection JWT (HS256). Optional channels = auto-subscribe on connect. */
export function signCentrifugoConnectionToken(
  sub: string,
  secret: string,
  channels: string[] = [],
  ttlSec = 86_400
): string {
  const header = b64url(JSON.stringify({ alg: "HS256", typ: "JWT" }));
  const payloadObj: Record<string, unknown> = {
    sub,
    exp: Math.floor(Date.now() / 1000) + ttlSec
  };
  if (channels.length > 0) payloadObj.channels = channels;
  const payload = b64url(JSON.stringify(payloadObj));
  const data = `${header}.${payload}`;
  const sig = createHmac("sha256", secret)
    .update(data)
    .digest("base64")
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");
  return `${data}.${sig}`;
}

// FastifyInstance generic varies with logger setup; keep registration loosely typed.
export function registerPhase2Routes(
  app: {
    get: (...args: any[]) => any;
    post: (...args: any[]) => any;
    put: (...args: any[]) => any;
    delete: (...args: any[]) => any;
  },
  db: Db,
  opts?: { centrifugoTokenSecret?: string }
) {
  app.get("/realtime/token", async (req: any) => {
    const userId = req.user.sub as string;
    const deviceId = req.user.deviceId as string;
    const secret = opts?.centrifugoTokenSecret ?? "dev-change-me";
    const channel = `user:${userId}:${deviceId}`;
    const token = signCentrifugoConnectionToken(userId, secret);
    return { ok: true, token, channel };
  });

  app.get("/users/username/:username/available", async (req: any, reply: any) => {
    const params = z.object({ username: z.string() }).parse(req.params);
    const parsed = usernameSchema.safeParse(params.username.toLowerCase());
    if (!parsed.success) {
      return reply.send({ ok: true, available: false, reason: "invalid_format" });
    }
    const res = await db.query(`SELECT 1 FROM users WHERE LOWER(username) = LOWER($1) LIMIT 1`, [
      parsed.data
    ]);
    return reply.send({ ok: true, available: res.rowCount === 0 });
  });

  app.get("/users/by-username/:username", async (req: any, reply: any) => {
    const params = z.object({ username: z.string() }).parse(req.params);
    const viewerId = req.user.sub as string;
    const res = await db.query(
      `SELECT id, username, display_name, avatar_url FROM users WHERE LOWER(username) = LOWER($1)`,
      [params.username]
    );
    const row = res.rows[0];
    if (!row) return reply.code(404).send({ ok: false, error: "Not found" });

    const contact = await isContact(db, viewerId, row.id);
    const privacy = await getPrivacyForUser(db, row.id);
    const showPhone = contact && !privacy.hidePhoneFromNonContacts;

    return reply.send({
      ok: true,
      user: {
        id: row.id,
        username: row.username,
        displayName: row.display_name,
        avatarUrl: row.avatar_url,
        phone: showPhone ? undefined : null
      }
    });
  });

  app.post("/me/onboarding", async (req: any, reply: any) => {
    const userId = req.user.sub as string;
    const body = z
      .object({
        username: usernameSchema,
        displayName: z.string().min(1).max(64)
      })
      .parse(req.body);

    const username = body.username.toLowerCase();
    try {
      await db.query(
        `
        UPDATE users
        SET username = $2, display_name = $3, onboarding_completed_at = now()
        WHERE id = $1 AND username IS NULL
        `,
        [userId, username, body.displayName]
      );
    } catch (err: any) {
      if (err?.code === "23505") {
        return reply.code(409).send({ ok: false, error: "Username already taken" });
      }
      throw err;
    }

    const check = await db.query(`SELECT username FROM users WHERE id = $1`, [userId]);
    if (!check.rows[0]?.username) {
      return reply.code(409).send({ ok: false, error: "Username already taken" });
    }

    return reply.send({ ok: true, username });
  });

  app.get("/me/privacy", async (req: any) => {
    const userId = req.user.sub as string;
    const privacy = await getPrivacyForUser(db, userId);
    return { ok: true, privacy };
  });

  app.put("/me/privacy", async (req: any, reply: any) => {
    const userId = req.user.sub as string;
    const body = z
      .object({
        requireMessageRequest: z.boolean().optional(),
        hidePhoneFromNonContacts: z.boolean().optional(),
        hidePhoneFromGroupMembers: z.boolean().optional(),
        allowDownload: z.boolean().optional(),
        readReceipts: z.boolean().optional(),
        typingIndicators: z.boolean().optional(),
        showOnlineStatus: z.boolean().optional()
      })
      .parse(req.body);

    const current = await getPrivacyForUser(db, userId);
    const merged = { ...current, ...body };
    await db.query(`UPDATE users SET privacy_settings = $2::jsonb WHERE id = $1`, [
      userId,
      JSON.stringify(merged)
    ]);
    return reply.send({ ok: true, privacy: merged });
  });

  app.get("/contacts", async (req: any) => {
    const userId = req.user.sub as string;
    const res = await db.query(
      `
      SELECT u.id, u.username, u.display_name, u.avatar_url, c.created_at
      FROM contacts c
      JOIN users u ON u.id = c.contact_user_id
      WHERE c.owner_user_id = $1
      ORDER BY c.created_at DESC
      `,
      [userId]
    );
    return { ok: true, contacts: res.rows };
  });

  app.post("/contacts", async (req: any, reply: any) => {
    const userId = req.user.sub as string;
    const body = z
      .object({
        userId: z.string().uuid().optional(),
        username: z.string().optional()
      })
      .refine((b) => b.userId || b.username, { message: "userId or username required" })
      .parse(req.body);

    const contactUserId = body.userId ?? (await resolveUserIdByUsername(db, body.username!));
    if (!contactUserId) return reply.code(404).send({ ok: false, error: "User not found" });
    if (contactUserId === userId) {
      return reply.code(400).send({ ok: false, error: "Cannot add yourself" });
    }

    await db.query(
      `
      INSERT INTO contacts (owner_user_id, contact_user_id)
      VALUES ($1, $2)
      ON CONFLICT (owner_user_id, contact_user_id) DO NOTHING
      `,
      [userId, contactUserId]
    );
    return reply.send({ ok: true });
  });

  app.delete("/contacts/:contactUserId", async (req: any, reply: any) => {
    const userId = req.user.sub as string;
    const params = z.object({ contactUserId: z.string().uuid() }).parse(req.params);
    await db.query(`DELETE FROM contacts WHERE owner_user_id = $1 AND contact_user_id = $2`, [
      userId,
      params.contactUserId
    ]);
    return reply.send({ ok: true });
  });

  app.get("/contacts/can-message/:targetUserId", async (req: any) => {
    const userId = req.user.sub as string;
    const params = z.object({ targetUserId: z.string().uuid() }).parse(req.params);
    const allowed = await canDirectMessage(db, userId, params.targetUserId);
    return { ok: true, canMessage: allowed };
  });

  app.post("/message-requests", async (req: any, reply: any) => {
    const fromUserId = req.user.sub as string;
    const body = z
      .object({
        toUserId: z.string().uuid().optional(),
        toUsername: z.string().optional(),
        introMessage: z.string().max(500).optional()
      })
      .refine((b) => b.toUserId || b.toUsername, { message: "toUserId or toUsername required" })
      .parse(req.body);

    const toUserId = body.toUserId ?? (await resolveUserIdByUsername(db, body.toUsername!));
    if (!toUserId) return reply.code(404).send({ ok: false, error: "User not found" });
    if (toUserId === fromUserId) {
      return reply.code(400).send({ ok: false, error: "Invalid target" });
    }

    if (await canDirectMessage(db, fromUserId, toUserId)) {
      return reply.code(400).send({ ok: false, error: "Already allowed to message directly" });
    }

    const res = await db.query<{ id: string }>(
      `
      INSERT INTO message_requests (from_user_id, to_user_id, intro_message)
      VALUES ($1, $2, $3)
      ON CONFLICT (from_user_id, to_user_id) DO UPDATE SET
        status = CASE
          WHEN message_requests.status IN ('declined', 'blocked') THEN 'pending'
          ELSE message_requests.status
        END,
        intro_message = COALESCE(EXCLUDED.intro_message, message_requests.intro_message),
        updated_at = now()
      RETURNING id
      `,
      [fromUserId, toUserId, body.introMessage ?? null]
    );

    return reply.send({ ok: true, requestId: res.rows[0]!.id });
  });

  app.get("/message-requests/incoming", async (req: any) => {
    const userId = req.user.sub as string;
    const query = z
      .object({ status: z.enum(["pending", "accepted", "declined", "blocked"]).default("pending") })
      .parse(req.query);

    const res = await db.query(
      `
      SELECT mr.id, mr.status, mr.intro_message, mr.created_at,
             u.id AS from_user_id, u.username, u.display_name, u.avatar_url
      FROM message_requests mr
      JOIN users u ON u.id = mr.from_user_id
      WHERE mr.to_user_id = $1 AND mr.status = $2
      ORDER BY mr.created_at DESC
      `,
      [userId, query.status]
    );
    return { ok: true, requests: res.rows };
  });

  app.post("/message-requests/:requestId/accept", async (req: any, reply: any) => {
    const userId = req.user.sub as string;
    const params = z.object({ requestId: z.string().uuid() }).parse(req.params);

    const updated = await db.query(
      `
      UPDATE message_requests
      SET status = 'accepted', updated_at = now()
      WHERE id = $1 AND to_user_id = $2 AND status = 'pending'
      RETURNING from_user_id
      `,
      [params.requestId, userId]
    );
    if (updated.rowCount === 0) {
      return reply.code(404).send({ ok: false, error: "Request not found" });
    }

    const fromUserId = updated.rows[0]!.from_user_id as string;
    await db.query(
      `
      INSERT INTO contacts (owner_user_id, contact_user_id) VALUES ($1, $2), ($2, $1)
      ON CONFLICT DO NOTHING
      `,
      [userId, fromUserId]
    );

    return reply.send({ ok: true });
  });

  app.post("/message-requests/:requestId/decline", async (req: any, reply: any) => {
    const userId = req.user.sub as string;
    const params = z.object({ requestId: z.string().uuid() }).parse(req.params);

    const updated = await db.query(
      `
      UPDATE message_requests
      SET status = 'declined', updated_at = now()
      WHERE id = $1 AND to_user_id = $2 AND status = 'pending'
      RETURNING id
      `,
      [params.requestId, userId]
    );
    if (updated.rowCount === 0) {
      return reply.code(404).send({ ok: false, error: "Request not found" });
    }
    return reply.send({ ok: true });
  });
}

async function resolveUserIdByUsername(db: Db, username: string): Promise<string | null> {
  const res = await db.query<{ id: string }>(
    `SELECT id FROM users WHERE LOWER(username) = LOWER($1)`,
    [username]
  );
  return res.rows[0]?.id ?? null;
}

async function getPrivacyForUser(db: Db, userId: string) {
  const res = await db.query<{ privacy_settings: Record<string, boolean> }>(
    `SELECT privacy_settings FROM users WHERE id = $1`,
    [userId]
  );
  return { ...defaultPrivacy, ...(res.rows[0]?.privacy_settings ?? {}) };
}

async function isContact(db: Db, ownerId: string, contactId: string): Promise<boolean> {
  const res = await db.query(
    `SELECT 1 FROM contacts WHERE owner_user_id = $1 AND contact_user_id = $2`,
    [ownerId, contactId]
  );
  return (res.rowCount ?? 0) > 0;
}

/** Direct message if sender has recipient in saved contacts and not blocked. */
export async function canDirectMessage(db: Db, fromUserId: string, toUserId: string): Promise<boolean> {
  if (fromUserId === toUserId) return false;
  const blocked = await db.query(
    `
    SELECT 1 FROM user_blocks
    WHERE (blocker_user_id = $1 AND blocked_user_id = $2)
       OR (blocker_user_id = $2 AND blocked_user_id = $1)
    LIMIT 1
    `,
    [fromUserId, toUserId]
  );
  if ((blocked.rowCount ?? 0) > 0) return false;
  return isContact(db, fromUserId, toUserId);
}
