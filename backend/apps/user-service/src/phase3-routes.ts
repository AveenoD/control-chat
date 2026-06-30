import type { Db } from "./db.js";
import { z } from "zod";
import { createHmac, randomBytes } from "node:crypto";

const usernameSchema = z
  .string()
  .min(3)
  .max(32)
  .regex(/^[a-z0-9_]+$/, "Username must be lowercase letters, numbers, or underscore");

async function resolveUserIdByUsername(db: Db, username: string): Promise<string | null> {
  const parsed = usernameSchema.safeParse(username.toLowerCase());
  if (!parsed.success) return null;
  const res = await db.query<{ id: string }>(
    `SELECT id FROM users WHERE LOWER(username) = LOWER($1) LIMIT 1`,
    [parsed.data]
  );
  return res.rows[0]?.id ?? null;
}

async function isBlocked(db: Db, userA: string, userB: string): Promise<boolean> {
  const res = await db.query(
    `
    SELECT 1 FROM user_blocks
    WHERE (blocker_user_id = $1 AND blocked_user_id = $2)
       OR (blocker_user_id = $2 AND blocked_user_id = $1)
    LIMIT 1
    `,
    [userA, userB]
  );
  return (res.rowCount ?? 0) > 0;
}

function b64url(input: string | Buffer): string {
  return Buffer.from(input)
    .toString("base64")
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");
}

/** Dev LiveKit access token (HS256) — matches livekit-server --dev defaults. */
function signLiveKitToken(opts: {
  apiKey: string;
  apiSecret: string;
  roomName: string;
  identity: string;
  ttlSec?: number;
}): string {
  const header = b64url(JSON.stringify({ alg: "HS256", typ: "JWT" }));
  const now = Math.floor(Date.now() / 1000);
  const payload = b64url(
    JSON.stringify({
      iss: opts.apiKey,
      sub: opts.identity,
      nbf: now,
      exp: now + (opts.ttlSec ?? 3600),
      video: {
        roomJoin: true,
        room: opts.roomName,
        canPublish: true,
        canSubscribe: true
      }
    })
  );
  const data = `${header}.${payload}`;
  const sig = createHmac("sha256", opts.apiSecret)
    .update(data)
    .digest("base64")
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");
  return `${data}.${sig}`;
}

async function listUserDevices(db: Db, userId: string): Promise<Array<{ userId: string; deviceId: string }>> {
  const res = await db.query<{ device_id: string }>(
    `SELECT device_id FROM device_keys WHERE user_id = $1 ORDER BY updated_at DESC`,
    [userId]
  );
  return res.rows.map((r) => ({ userId, deviceId: r.device_id }));
}

async function isGroupAdmin(db: Db, groupId: string, userId: string): Promise<boolean> {
  const res = await db.query(
    `SELECT 1 FROM group_members WHERE group_id = $1 AND user_id = $2 AND role = 'admin'`,
    [groupId, userId]
  );
  return (res.rowCount ?? 0) > 0;
}

async function getUserLabel(db: Db, userId: string): Promise<string> {
  const res = await db.query<{ display_name: string | null; username: string | null }>(
    `SELECT display_name, username FROM users WHERE id = $1 LIMIT 1`,
    [userId]
  );
  const r = res.rows[0];
  return r?.display_name || r?.username || "Someone";
}

/**
 * Records a group membership/lifecycle event as plaintext metadata and fans it
 * out to every current member device over Centrifugo so clients can render a
 * timeline system line ("X added Y") in real time. The stored row lets clients
 * back-fill the same lines on cold open via GET /groups/:id/events.
 */
async function emitGroupSystemEvent(
  db: Db,
  opts: { centrifugoApiUrl?: string; centrifugoApiKey?: string } | undefined,
  args: {
    groupId: string;
    type: string;
    actorUserId?: string | null;
    targetUserId?: string | null;
    actorName?: string | null;
    targetName?: string | null;
    meta?: Record<string, unknown> | null;
  }
): Promise<void> {
  const ins = await db.query<{ id: string; created_at: string }>(
    `INSERT INTO group_system_events (group_id, type, actor_user_id, target_user_id, meta)
     VALUES ($1, $2, $3, $4, $5)
     RETURNING id, created_at`,
    [
      args.groupId,
      args.type,
      args.actorUserId ?? null,
      args.targetUserId ?? null,
      args.meta ? JSON.stringify(args.meta) : null
    ]
  );
  const ev = ins.rows[0]!;

  const members = await db.query<{ user_id: string }>(
    `SELECT user_id FROM group_members WHERE group_id = $1`,
    [args.groupId]
  );
  const targets: Array<{ userId: string; deviceId: string }> = [];
  for (const m of members.rows) {
    targets.push(...(await listUserDevices(db, m.user_id)));
  }
  await publishCallEvent(
    { centrifugoApiUrl: opts?.centrifugoApiUrl, centrifugoApiKey: opts?.centrifugoApiKey },
    targets,
    {
      type: "group_event",
      eventId: ev.id,
      groupId: args.groupId,
      conversationId: `group:${args.groupId}`,
      eventType: args.type,
      actorUserId: args.actorUserId ?? null,
      targetUserId: args.targetUserId ?? null,
      actorName: args.actorName ?? null,
      targetName: args.targetName ?? null,
      meta: args.meta ?? null,
      ts: ev.created_at
    }
  );
}

async function publishCallEvent(
  opts: {
    centrifugoApiUrl?: string;
    centrifugoApiKey?: string;
  },
  targets: Array<{ userId: string; deviceId: string }>,
  data: Record<string, unknown>
): Promise<void> {
  if (!opts.centrifugoApiUrl || !opts.centrifugoApiKey || targets.length === 0) return;
  await Promise.allSettled(
    targets.map(async (t) => {
      const channel = `user:${t.userId}:${t.deviceId}`;
      await fetch(opts.centrifugoApiUrl!, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `apikey ${opts.centrifugoApiKey!}`
        },
        body: JSON.stringify({ method: "publish", params: { channel, data } })
      });
    })
  );
}

export function registerPhase3Routes(
  app: {
    get: (...args: any[]) => any;
    post: (...args: any[]) => any;
    delete: (...args: any[]) => any;
  },
  db: Db,
  opts?: {
    livekitApiKey?: string;
    livekitApiSecret?: string;
    livekitUrl?: string;
    centrifugoApiUrl?: string;
    centrifugoApiKey?: string;
  }
) {
  // --- Block ---
  app.post("/blocks", async (req: any, reply: any) => {
    const blockerId = req.user.sub as string;
    const body = z.object({ userId: z.string().uuid() }).parse(req.body);
    if (body.userId === blockerId) {
      return reply.code(400).send({ ok: false, error: "Cannot block yourself" });
    }

    await db.query(
      `
      INSERT INTO user_blocks (blocker_user_id, blocked_user_id)
      VALUES ($1, $2)
      ON CONFLICT (blocker_user_id, blocked_user_id) DO NOTHING
      `,
      [blockerId, body.userId]
    );

    await db.query(
      `DELETE FROM contacts WHERE (owner_user_id = $1 AND contact_user_id = $2) OR (owner_user_id = $2 AND contact_user_id = $1)`,
      [blockerId, body.userId]
    );

    await db.query(
      `
      UPDATE message_requests
      SET status = 'blocked', updated_at = now()
      WHERE (from_user_id = $1 AND to_user_id = $2) OR (from_user_id = $2 AND to_user_id = $1)
      `,
      [blockerId, body.userId]
    );

    return reply.send({ ok: true });
  });

  app.delete("/blocks/:userId", async (req: any, reply: any) => {
    const blockerId = req.user.sub as string;
    const params = z.object({ userId: z.string().uuid() }).parse(req.params);
    await db.query(`DELETE FROM user_blocks WHERE blocker_user_id = $1 AND blocked_user_id = $2`, [
      blockerId,
      params.userId
    ]);
    return reply.send({ ok: true });
  });

  app.get("/blocks", async (req: any) => {
    const userId = req.user.sub as string;
    const res = await db.query(
      `
      SELECT b.blocked_user_id AS user_id, u.username, u.display_name, u.avatar_url, b.created_at
      FROM user_blocks b
      JOIN users u ON u.id = b.blocked_user_id
      WHERE b.blocker_user_id = $1
      ORDER BY b.created_at DESC
      `,
      [userId]
    );
    return { ok: true, blocks: res.rows };
  });

  // --- Report ---
  app.post("/reports", async (req: any, reply: any) => {
    const reporterId = req.user.sub as string;
    const body = z
      .object({
        reportedUserId: z.string().uuid(),
        contextType: z.enum(["chat", "profile", "group"]),
        contextId: z.string().max(128).optional(),
        reason: z.string().min(3).max(200),
        details: z.string().max(2000).optional()
      })
      .parse(req.body);

    const res = await db.query<{ id: string }>(
      `
      INSERT INTO user_reports (reporter_user_id, reported_user_id, context_type, context_id, reason, details)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING id
      `,
      [
        reporterId,
        body.reportedUserId,
        body.contextType,
        body.contextId ?? null,
        body.reason,
        body.details ?? null
      ]
    );
    return reply.send({ ok: true, reportId: res.rows[0]!.id });
  });

  // --- Groups ---
  app.post("/groups", async (req: any, reply: any) => {
    const userId = req.user.sub as string;
    const body = z
      .object({
        title: z.string().min(1).max(64),
        memberUsernames: z.array(z.string()).min(1).max(50)
      })
      .parse(req.body);

    const memberIds = new Set<string>([userId]);
    for (const uname of body.memberUsernames) {
      const id = await resolveUserIdByUsername(db, uname);
      if (!id) return reply.code(404).send({ ok: false, error: `User not found: ${uname}` });
      if (await isBlocked(db, userId, id)) {
        return reply.code(403).send({ ok: false, error: "Cannot add blocked user" });
      }
      memberIds.add(id);
    }

    const client = await db.connect();
    try {
      await client.query("BEGIN");
      const g = await client.query<{ id: string }>(
        `INSERT INTO groups (title, created_by) VALUES ($1, $2) RETURNING id`,
        [body.title, userId]
      );
      const groupId = g.rows[0]!.id;
      for (const mid of memberIds) {
        await client.query(
          `INSERT INTO group_members (group_id, user_id, role) VALUES ($1, $2, $3)`,
          [groupId, mid, mid === userId ? "admin" : "member"]
        );
      }
      await client.query("COMMIT");
      return reply.send({ ok: true, groupId, conversationId: `group:${groupId}` });
    } catch (e) {
      await client.query("ROLLBACK");
      throw e;
    } finally {
      client.release();
    }
  });

  app.get("/groups", async (req: any) => {
    const userId = req.user.sub as string;
    const res = await db.query(
      `
      SELECT g.id, g.title, g.created_by, g.created_at, g.current_key_epoch, g.needs_rekey,
             g.avatar_blob_id, g.avatar_key,
             (SELECT COUNT(*)::int FROM group_members gm2 WHERE gm2.group_id = g.id) AS member_count
      FROM groups g
      JOIN group_members gm ON gm.group_id = g.id AND gm.user_id = $1
      ORDER BY g.created_at DESC
      `,
      [userId]
    );
    return {
      ok: true,
      groups: res.rows.map((r) => ({
        ...r,
        conversation_id: `group:${r.id}`
      }))
    };
  });

  app.get("/groups/:groupId", async (req: any, reply: any) => {
    const userId = req.user.sub as string;
    const params = z.object({ groupId: z.string().uuid() }).parse(req.params);
    const res = await db.query(
      `
      SELECT g.id, g.title, g.created_by, g.created_at, g.current_key_epoch, g.needs_rekey,
             g.avatar_blob_id, g.avatar_key,
             (SELECT COUNT(*)::int FROM group_members gm2 WHERE gm2.group_id = g.id) AS member_count,
             (SELECT role FROM group_members gm3 WHERE gm3.group_id = g.id AND gm3.user_id = $2) AS my_role
      FROM groups g
      WHERE g.id = $1
      `,
      [params.groupId, userId]
    );
    const row = res.rows[0] as any;
    if (!row || !row.my_role) return reply.code(403).send({ ok: false, error: "Not a member" });
    return reply.send({ ok: true, group: { ...row, conversation_id: `group:${row.id}` } });
  });

  app.post("/groups/:groupId/members", async (req: any, reply: any) => {
    const userId = req.user.sub as string;
    const params = z.object({ groupId: z.string().uuid() }).parse(req.params);
    const body = z
      .object({ memberUsernames: z.array(z.string()).min(1).max(50) })
      .parse(req.body);

    if (!(await isGroupAdmin(db, params.groupId, userId))) {
      return reply.code(403).send({ ok: false, error: "Admin only" });
    }

    const actorName = await getUserLabel(db, userId);
    const added: Array<{ userId: string; username: string }> = [];
    for (const uname of body.memberUsernames) {
      const id = await resolveUserIdByUsername(db, uname);
      if (!id) return reply.code(404).send({ ok: false, error: `User not found: ${uname}` });
      if (await isBlocked(db, userId, id)) {
        return reply.code(403).send({ ok: false, error: "Cannot add blocked user" });
      }
      const existing = await db.query(
        `SELECT 1 FROM group_members WHERE group_id = $1 AND user_id = $2`,
        [params.groupId, id]
      );
      if ((existing.rowCount ?? 0) > 0) continue;
      await db.query(
        `INSERT INTO group_members (group_id, user_id, role) VALUES ($1, $2, 'member') ON CONFLICT DO NOTHING`,
        [params.groupId, id]
      );
      const label = await getUserLabel(db, id);
      added.push({ userId: id, username: label });
      await emitGroupSystemEvent(db, opts, {
        groupId: params.groupId,
        type: "member_added",
        actorUserId: userId,
        targetUserId: id,
        actorName,
        targetName: label
      });
    }
    return reply.send({ ok: true, added });
  });

  app.delete("/groups/:groupId/members/:userId", async (req: any, reply: any) => {
    const requesterId = req.user.sub as string;
    const params = z
      .object({ groupId: z.string().uuid(), userId: z.string().uuid() })
      .parse(req.params);
    const isSelf = params.userId === requesterId;

    if (!isSelf && !(await isGroupAdmin(db, params.groupId, requesterId))) {
      return reply.code(403).send({ ok: false, error: "Admin only" });
    }

    const target = await db.query<{ role: string }>(
      `SELECT role FROM group_members WHERE group_id = $1 AND user_id = $2`,
      [params.groupId, params.userId]
    );
    if (target.rowCount === 0) return reply.code(404).send({ ok: false, error: "Not a member" });

    const actorName = await getUserLabel(db, requesterId);
    const targetName = await getUserLabel(db, params.userId);

    const client = await db.connect();
    let newEpoch = 1;
    let emptied = false;
    try {
      await client.query("BEGIN");
      await client.query(
        `DELETE FROM group_members WHERE group_id = $1 AND user_id = $2`,
        [params.groupId, params.userId]
      );
      // Removed member must lose access to all future keys.
      await client.query(
        `DELETE FROM group_key_envelopes WHERE group_id = $1 AND recipient_user_id = $2`,
        [params.groupId, params.userId]
      );
      const remaining = await client.query<{ user_id: string; role: string }>(
        `SELECT user_id, role FROM group_members WHERE group_id = $1 ORDER BY joined_at ASC`,
        [params.groupId]
      );
      if (remaining.rowCount === 0) {
        await client.query(`DELETE FROM groups WHERE id = $1`, [params.groupId]);
        emptied = true;
      } else {
        // Membership change → rotate the shared key: bump epoch + flag so an
        // admin re-seals a fresh key. The removed device keeps the old epoch key
        // but never receives the new one, so it can't read future messages.
        const up = await client.query<{ current_key_epoch: number }>(
          `UPDATE groups SET current_key_epoch = current_key_epoch + 1, needs_rekey = true, updated_at = now() WHERE id = $1 RETURNING current_key_epoch`,
          [params.groupId]
        );
        newEpoch = up.rows[0]!.current_key_epoch;
        if (!remaining.rows.some((r) => r.role === "admin")) {
          await client.query(
            `UPDATE group_members SET role = 'admin' WHERE group_id = $1 AND user_id = $2`,
            [params.groupId, remaining.rows[0]!.user_id]
          );
        }
      }
      await client.query("COMMIT");
    } catch (e) {
      await client.query("ROLLBACK");
      throw e;
    } finally {
      client.release();
    }

    if (!emptied) {
      await emitGroupSystemEvent(db, opts, {
        groupId: params.groupId,
        type: isSelf ? "member_left" : "member_removed",
        actorUserId: requesterId,
        targetUserId: params.userId,
        actorName,
        targetName
      });
    }
    return reply.send({ ok: true, currentKeyEpoch: newEpoch, emptied });
  });

  app.post("/groups/:groupId/rename", async (req: any, reply: any) => {
    const userId = req.user.sub as string;
    const params = z.object({ groupId: z.string().uuid() }).parse(req.params);
    const body = z.object({ title: z.string().min(1).max(64) }).parse(req.body);
    if (!(await isGroupAdmin(db, params.groupId, userId))) {
      return reply.code(403).send({ ok: false, error: "Admin only" });
    }
    await db.query(`UPDATE groups SET title = $2, updated_at = now() WHERE id = $1`, [
      params.groupId,
      body.title
    ]);
    const actorName = await getUserLabel(db, userId);
    await emitGroupSystemEvent(db, opts, {
      groupId: params.groupId,
      type: "group_renamed",
      actorUserId: userId,
      actorName,
      meta: { title: body.title }
    });
    return reply.send({ ok: true });
  });

  // Set/clear the group avatar (admin only). The image is an encrypted blob in
  // object storage; we just persist its id + AES key. Pass null to remove.
  app.post("/groups/:groupId/avatar", async (req: any, reply: any) => {
    const userId = req.user.sub as string;
    const params = z.object({ groupId: z.string().uuid() }).parse(req.params);
    const body = z
      .object({
        blobId: z.string().min(1).nullable().optional(),
        key: z.string().min(1).nullable().optional()
      })
      .parse(req.body);
    if (!(await isGroupAdmin(db, params.groupId, userId))) {
      return reply.code(403).send({ ok: false, error: "Admin only" });
    }
    await db.query(
      `UPDATE groups SET avatar_blob_id = $2, avatar_key = $3, updated_at = now() WHERE id = $1`,
      [params.groupId, body.blobId ?? null, body.key ?? null]
    );
    const actorName = await getUserLabel(db, userId);
    await emitGroupSystemEvent(db, opts, {
      groupId: params.groupId,
      type: "group_avatar",
      actorUserId: userId,
      actorName
    });
    return reply.send({ ok: true });
  });

  app.post("/groups/:groupId/members/:userId/role", async (req: any, reply: any) => {
    const requesterId = req.user.sub as string;
    const params = z
      .object({ groupId: z.string().uuid(), userId: z.string().uuid() })
      .parse(req.params);
    const body = z.object({ role: z.enum(["admin", "member"]) }).parse(req.body);
    if (!(await isGroupAdmin(db, params.groupId, requesterId))) {
      return reply.code(403).send({ ok: false, error: "Admin only" });
    }
    const target = await db.query(
      `SELECT 1 FROM group_members WHERE group_id = $1 AND user_id = $2`,
      [params.groupId, params.userId]
    );
    if (target.rowCount === 0) return reply.code(404).send({ ok: false, error: "Not a member" });

    await db.query(`UPDATE group_members SET role = $3 WHERE group_id = $1 AND user_id = $2`, [
      params.groupId,
      params.userId,
      body.role
    ]);
    const actorName = await getUserLabel(db, requesterId);
    const targetName = await getUserLabel(db, params.userId);
    await emitGroupSystemEvent(db, opts, {
      groupId: params.groupId,
      type: body.role === "admin" ? "member_promoted" : "member_demoted",
      actorUserId: requesterId,
      targetUserId: params.userId,
      actorName,
      targetName
    });
    return reply.send({ ok: true });
  });

  app.delete("/groups/:groupId", async (req: any, reply: any) => {
    const userId = req.user.sub as string;
    const params = z.object({ groupId: z.string().uuid() }).parse(req.params);
    if (!(await isGroupAdmin(db, params.groupId, userId))) {
      return reply.code(403).send({ ok: false, error: "Admin only" });
    }
    // Gather member devices BEFORE deleting (cascade removes membership rows).
    const members = await db.query<{ user_id: string }>(
      `SELECT user_id FROM group_members WHERE group_id = $1`,
      [params.groupId]
    );
    const targets: Array<{ userId: string; deviceId: string }> = [];
    for (const m of members.rows) {
      targets.push(...(await listUserDevices(db, m.user_id)));
    }
    const actorName = await getUserLabel(db, userId);
    await db.query(`DELETE FROM groups WHERE id = $1`, [params.groupId]);
    await publishCallEvent(
      { centrifugoApiUrl: opts?.centrifugoApiUrl, centrifugoApiKey: opts?.centrifugoApiKey },
      targets,
      {
        type: "group_event",
        eventType: "group_deleted",
        groupId: params.groupId,
        conversationId: `group:${params.groupId}`,
        actorUserId: userId,
        actorName,
        ts: new Date().toISOString()
      }
    );
    return reply.send({ ok: true });
  });

  app.post("/groups/:groupId/rekeyed", async (req: any, reply: any) => {
    const userId = req.user.sub as string;
    const params = z.object({ groupId: z.string().uuid() }).parse(req.params);
    if (!(await isGroupAdmin(db, params.groupId, userId))) {
      return reply.code(403).send({ ok: false, error: "Admin only" });
    }
    await db.query(`UPDATE groups SET needs_rekey = false, updated_at = now() WHERE id = $1`, [
      params.groupId
    ]);
    return reply.send({ ok: true });
  });

  app.get("/groups/:groupId/events", async (req: any, reply: any) => {
    const userId = req.user.sub as string;
    const params = z.object({ groupId: z.string().uuid() }).parse(req.params);
    const member = await db.query(
      `SELECT 1 FROM group_members WHERE group_id = $1 AND user_id = $2`,
      [params.groupId, userId]
    );
    if (member.rowCount === 0) return reply.code(403).send({ ok: false, error: "Not a member" });

    const res = await db.query(
      `
      SELECT e.id, e.type, e.actor_user_id, e.target_user_id, e.created_at, e.meta,
             ua.username AS actor_username, ua.display_name AS actor_display_name,
             ut.username AS target_username, ut.display_name AS target_display_name
      FROM group_system_events e
      LEFT JOIN users ua ON ua.id = e.actor_user_id
      LEFT JOIN users ut ON ut.id = e.target_user_id
      WHERE e.group_id = $1
      ORDER BY e.created_at ASC
      LIMIT 200
      `,
      [params.groupId]
    );
    return reply.send({ ok: true, events: res.rows });
  });

  app.get("/groups/:groupId/members", async (req: any, reply: any) => {
    const userId = req.user.sub as string;
    const params = z.object({ groupId: z.string().uuid() }).parse(req.params);
    const member = await db.query(
      `SELECT 1 FROM group_members WHERE group_id = $1 AND user_id = $2`,
      [params.groupId, userId]
    );
    if (member.rowCount === 0) return reply.code(403).send({ ok: false, error: "Not a member" });

    const res = await db.query(
      `
      SELECT gm.user_id, gm.role, u.username, u.display_name, u.avatar_url
      FROM group_members gm
      JOIN users u ON u.id = gm.user_id
      WHERE gm.group_id = $1
      ORDER BY gm.joined_at ASC
      `,
      [params.groupId]
    );
    return reply.send({ ok: true, members: res.rows });
  });

  app.post("/groups/:groupId/keys", async (req: any, reply: any) => {
    const userId = req.user.sub as string;
    const params = z.object({ groupId: z.string().uuid() }).parse(req.params);
    const body = z
      .object({
        recipientUserId: z.string().uuid(),
        recipientDeviceId: z.string().min(8).max(128),
        ciphertext: z.string().min(16).max(200_000),
        keyEpoch: z.number().int().min(1).default(1)
      })
      .parse(req.body);

    // Any group member who holds the key may seal it to another member's
    // device. This enables key recovery / distribution to new or reinstalled
    // devices without requiring the (single) admin to be online. The envelope
    // is opaque ciphertext, so a member can't learn anything they don't already
    // have (they already possess the group key to send/read).
    const member = await db.query(
      `SELECT 1 FROM group_members WHERE group_id = $1 AND user_id = $2`,
      [params.groupId, userId]
    );
    if (member.rowCount === 0) return reply.code(403).send({ ok: false, error: "Not a member" });

    await db.query(
      `
      INSERT INTO group_key_envelopes (group_id, recipient_user_id, recipient_device_id, ciphertext, key_epoch)
      VALUES ($1, $2, $3, $4, $5)
      ON CONFLICT (group_id, recipient_user_id, recipient_device_id, key_epoch)
      DO UPDATE SET ciphertext = EXCLUDED.ciphertext
      `,
      [
        params.groupId,
        body.recipientUserId,
        body.recipientDeviceId,
        body.ciphertext,
        body.keyEpoch
      ]
    );
    return reply.send({ ok: true });
  });

  app.get("/groups/:groupId/keys", async (req: any, reply: any) => {
    const userId = req.user.sub as string;
    const deviceId = req.user.deviceId as string;
    const params = z.object({ groupId: z.string().uuid() }).parse(req.params);

    const member = await db.query(
      `SELECT 1 FROM group_members WHERE group_id = $1 AND user_id = $2`,
      [params.groupId, userId]
    );
    if (member.rowCount === 0) return reply.code(403).send({ ok: false, error: "Not a member" });

    const res = await db.query(
      `
      SELECT ciphertext, key_epoch, created_at
      FROM group_key_envelopes
      WHERE group_id = $1 AND recipient_user_id = $2 AND recipient_device_id = $3
      ORDER BY key_epoch DESC
      `,
      [params.groupId, userId, deviceId]
    );
    return reply.send({ ok: true, envelope: res.rows[0] ?? null, envelopes: res.rows });
  });

  // --- Calls (LiveKit dev) ---
  app.post("/calls/start", async (req: any, reply: any) => {
    const userId = req.user.sub as string;
    const body = z
      .object({
        calleeUserId: z.string().uuid(),
        conversationId: z.string().min(8).max(128),
        callType: z.enum(["voice", "video"]).default("voice")
      })
      .parse(req.body);

    if (await isBlocked(db, userId, body.calleeUserId)) {
      return reply.code(403).send({ ok: false, error: "Blocked" });
    }

    const roomName = `call-${randomBytes(8).toString("hex")}`;
    const res = await db.query<{ id: string }>(
      `
      INSERT INTO call_sessions (conversation_id, initiator_user_id, callee_user_id, room_name, call_type)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING id
      `,
      [body.conversationId, userId, body.calleeUserId, roomName, body.callType]
    );

    const apiKey = opts?.livekitApiKey ?? "devkey";
    const apiSecret = opts?.livekitApiSecret ?? "secret";
    const token = signLiveKitToken({
      apiKey,
      apiSecret,
      roomName,
      identity: userId
    });

    const callId = res.rows[0]!.id;
    const calleeDevices = await listUserDevices(db, body.calleeUserId);
    void publishCallEvent(
      { centrifugoApiUrl: opts?.centrifugoApiUrl, centrifugoApiKey: opts?.centrifugoApiKey },
      calleeDevices,
      {
        type: "call",
        callId,
        conversationId: body.conversationId,
        roomName,
        callType: body.callType,
        initiatorUserId: userId
      }
    );

    return reply.send({
      ok: true,
      callId,
      roomName,
      token,
      livekitUrl: opts?.livekitUrl ?? "ws://10.0.2.2:7880"
    });
  });

  app.post("/calls/:callId/join", async (req: any, reply: any) => {
    const userId = req.user.sub as string;
    const params = z.object({ callId: z.string().uuid() }).parse(req.params);
    const row = await db.query<{ room_name: string; initiator_user_id: string; callee_user_id: string | null }>(
      `SELECT room_name, initiator_user_id, callee_user_id FROM call_sessions WHERE id = $1 AND status = 'active'`,
      [params.callId]
    );
    const call = row.rows[0];
    if (!call) return reply.code(404).send({ ok: false, error: "Call not found" });
    if (userId !== call.initiator_user_id && userId !== call.callee_user_id) {
      return reply.code(403).send({ ok: false, error: "Not a participant" });
    }

    const apiKey = opts?.livekitApiKey ?? "devkey";
    const apiSecret = opts?.livekitApiSecret ?? "secret";
    const token = signLiveKitToken({
      apiKey,
      apiSecret,
      roomName: call.room_name,
      identity: userId
    });

    return reply.send({
      ok: true,
      roomName: call.room_name,
      token,
      livekitUrl: opts?.livekitUrl ?? "ws://10.0.2.2:7880"
    });
  });

  app.get("/calls/history", async (req: any) => {
    const userId = req.user.sub as string;
    const res = await db.query(
      `
      SELECT cs.id, cs.conversation_id, cs.call_type, cs.status, cs.started_at, cs.ended_at,
             cs.initiator_user_id, cs.callee_user_id,
             u.username AS peer_username, u.display_name AS peer_display_name
      FROM call_sessions cs
      LEFT JOIN users u ON u.id = CASE
        WHEN cs.initiator_user_id = $1 THEN cs.callee_user_id
        ELSE cs.initiator_user_id
      END
      WHERE cs.initiator_user_id = $1 OR cs.callee_user_id = $1
      ORDER BY cs.started_at DESC
      LIMIT 50
      `,
      [userId]
    );
    return { ok: true, calls: res.rows };
  });
}
