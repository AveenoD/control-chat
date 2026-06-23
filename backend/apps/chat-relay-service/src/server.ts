import Fastify from "fastify";

import cors from "@fastify/cors";

import jwt from "@fastify/jwt";

import swagger from "@fastify/swagger";

import swaggerUi from "@fastify/swagger-ui";

import { createLogger, makeHealth } from "@auratalk/shared";

import { z } from "zod";
import { randomUUID } from "node:crypto";

import { loadChatRelayConfig } from "./config.js";

import { createDb } from "./db.js";

import {

  canAccessConversation,

  canAccessGroup,

  canDirectMessage,

  directConversationId,

  groupConversationId,

  listGroupMemberUserIds,

  listMemberDevices,

  parseConversationId,

  peerUserIdFromConversation,

  userAllowsReadReceipts,

  userAllowsTyping

} from "./messaging-policy.js";

import { fanoutToDevices, publishToUserDevice } from "./publish-realtime.js";



const cfg = loadChatRelayConfig();

const logger = createLogger(cfg);

const db = createDb(cfg.DATABASE_URL);



const app = Fastify({ loggerInstance: logger });



await app.register(cors, { origin: true, credentials: true });

await app.register(jwt, { secret: cfg.JWT_SECRET });



await app.register(swagger, {

  openapi: { info: { title: "AuraTalk chat-relay-service", version: "0.0.0" } }

});

await app.register(swaggerUi, { routePrefix: "/docs" });



app.get("/health", async () => makeHealth(cfg.SERVICE_NAME));



app.addHook("onRequest", async (req, reply) => {

  if (req.url.startsWith("/health") || req.url.startsWith("/docs")) return;

  try {

    await req.jwtVerify();

  } catch {

    return reply.code(401).send({ ok: false, error: "Unauthorized" });

  }

});



const centrifugoCfg =

  cfg.CENTRIFUGO_API_URL && cfg.CENTRIFUGO_API_KEY

    ? { apiUrl: cfg.CENTRIFUGO_API_URL, apiKey: cfg.CENTRIFUGO_API_KEY }

    : null;



const envelopeItem = z.object({

  recipientUserId: z.string().uuid(),

  recipientDeviceId: z.string().min(8).max(128),

  ciphertext: z.string().min(16).max(200_000)

});

const sendBody = z.object({

  conversationId: z.string().min(8).max(128),

  // Legacy single-recipient form (still used by group sends, which carry one
  // shared-group-key ciphertext).
  recipientUserId: z.string().uuid().optional(),

  recipientDeviceId: z.string().min(8).max(128).optional(),

  ciphertext: z.string().min(16).max(200_000).optional(),

  // Multi-device DM form: one ciphertext per destination device.
  envelopes: z.array(envelopeItem).min(1).max(50).optional(),

  clientMessageId: z.string().min(8).max(128).optional()

});



app.get("/conversations", async (req: any) => {

  const userId = req.user.sub as string;



  const dmRes = await db.query(

    `

    WITH participant_rows AS (

      SELECT conversation_id, sender_user_id, recipient_user_id, ciphertext, created_at

      FROM message_envelopes

      WHERE sender_user_id = $1 OR recipient_user_id = $1

    ),

    ranked AS (

      SELECT DISTINCT ON (conversation_id)

        conversation_id, sender_user_id, recipient_user_id,

        ciphertext AS last_ciphertext, created_at AS last_at

      FROM participant_rows

      ORDER BY conversation_id, created_at DESC

    )

    SELECT r.conversation_id, r.last_ciphertext, r.last_at,

      CASE WHEN r.sender_user_id = $1 THEN r.recipient_user_id ELSE r.sender_user_id END AS peer_user_id,

      u.username AS peer_username, u.display_name AS peer_display_name, u.avatar_url AS peer_avatar_url,

      'dm' AS conv_type

    FROM ranked r

    JOIN users u ON u.id = CASE WHEN r.sender_user_id = $1 THEN r.recipient_user_id ELSE r.sender_user_id END

    `,

    [userId]

  );



  const groupRes = await db.query(

    `

    SELECT g.id AS group_id, g.title, g.created_at AS last_at,

           'group:' || g.id::text AS conversation_id,

           NULL::text AS last_ciphertext,

           NULL::uuid AS peer_user_id,

           NULL::text AS peer_username,

           g.title AS peer_display_name,

           NULL::text AS peer_avatar_url,

           'group' AS conv_type

    FROM groups g

    JOIN group_members gm ON gm.group_id = g.id AND gm.user_id = $1

    `,

    [userId]

  );



  const conversations = [...dmRes.rows, ...groupRes.rows].sort(

    (a, b) => new Date(b.last_at).getTime() - new Date(a.last_at).getTime()

  );



  return { ok: true, conversations };

});



app.get("/conversations/:conversationId/messages", async (req: any) => {

  const userId = req.user.sub as string;

  const deviceId = req.user.deviceId as string;

  const params = z.object({ conversationId: z.string().min(8).max(128) }).parse(req.params);

  const query = z
    .object({
      limit: z.coerce.number().int().min(1).max(200).default(50),
      after: z.string().uuid().optional()
    })
    .parse(req.query);



  const parsed = parseConversationId(params.conversationId);

  if (!parsed) return { ok: false, error: "Invalid conversation" };



  if (parsed.kind === "dm") {

    const peerId = peerUserIdFromConversation(params.conversationId, userId);

    if (!peerId) return { ok: false, error: "Invalid conversation" };

    const allowed = await canAccessConversation(db, userId, peerId);

    if (!allowed) return { ok: false, error: "Accept message request or add contact before chatting" };

  } else {

    const allowed = await canAccessGroup(db, parsed.groupId!, userId);

    if (!allowed) return { ok: false, error: "Not a group member" };

  }



  // Device-scoped read: each device pulls only the envelopes addressed to IT
  // (its own decryptable copy). This is what makes multi-device E2EE correct —
  // a device never sees copies meant for a different (or stale) device, so it
  // never shows spurious "unable to decrypt". `message_id` is the stable
  // logical id shared across a message's per-device copies.
  //
  // Return the NEWEST `limit` messages, then re-sort ASC for display.
  const res = await db.query(
    `
    SELECT * FROM (
      SELECT message_id AS id, conversation_id, sender_user_id, sender_device_id,
             ciphertext, created_at, client_message_id
      FROM message_envelopes
      WHERE conversation_id = $1
        AND recipient_user_id = $2
        AND recipient_device_id = $5
        AND (
          $4::uuid IS NULL
          OR created_at > COALESCE(
            (SELECT created_at FROM message_envelopes
             WHERE message_id = $4 AND conversation_id = $1 LIMIT 1),
            '-infinity'::timestamptz
          )
        )
      ORDER BY created_at DESC
      LIMIT $3
    ) recent
    ORDER BY created_at ASC
    `,
    [params.conversationId, userId, query.limit, query.after ?? null, deviceId]
  );



  return { ok: true, messages: res.rows };

});



app.post("/messages", async (req: any, reply: any) => {

  const senderUserId = req.user.sub as string;

  const senderDeviceId = req.user.deviceId as string;

  const body = sendBody.parse(req.body);



  const parsed = parseConversationId(body.conversationId);

  if (!parsed) return reply.code(400).send({ ok: false, error: "Invalid conversationId" });



  if (parsed.kind === "dm") {

    // Build the per-device envelope list. New clients send `envelopes[]`
    // (one ciphertext per destination device); fall back to the legacy single
    // form for older callers.
    const envelopes =
      body.envelopes ??
      (body.recipientUserId && body.recipientDeviceId && body.ciphertext
        ? [
            {
              recipientUserId: body.recipientUserId,
              recipientDeviceId: body.recipientDeviceId,
              ciphertext: body.ciphertext
            }
          ]
        : null);

    if (!envelopes || envelopes.length === 0) {

      return reply.code(400).send({ ok: false, error: "envelopes required" });

    }

    // The DM peer is the single non-sender recipient referenced by the
    // conversation id; self-copies (recipient == sender) are for multi-device.
    const peerUserId = peerUserIdFromConversation(body.conversationId, senderUserId);

    if (!peerUserId) {

      return reply.code(400).send({ ok: false, error: "Invalid conversationId" });

    }

    const expectedConversationId = directConversationId(senderUserId, peerUserId);

    if (body.conversationId !== expectedConversationId) {

      return reply.code(400).send({ ok: false, error: "Invalid conversationId" });

    }

    // Every envelope must target either the peer or the sender themselves.
    for (const e of envelopes) {

      if (e.recipientUserId !== peerUserId && e.recipientUserId !== senderUserId) {

        return reply.code(400).send({ ok: false, error: "Envelope recipient not in conversation" });

      }

    }

    const allowed = await canDirectMessage(db, senderUserId, peerUserId);

    if (!allowed) {

      return reply.code(403).send({

        ok: false,

        error: "message_request_required",

        message: "Add contact or accept message request before sending"

      });

    }



    // Idempotency: a retried send (same client_message_id) must not create a
    // duplicate. Return the already-stored logical message instead.
    if (body.clientMessageId) {
      const dup = await db.query<{ message_id: string }>(
        `SELECT message_id FROM message_envelopes
         WHERE conversation_id = $1 AND sender_user_id = $2 AND client_message_id = $3
         LIMIT 1`,
        [body.conversationId, senderUserId, body.clientMessageId]
      );
      if (dup.rows[0]) {
        return reply.send({ ok: true, envelopeId: dup.rows[0].message_id, deduped: true });
      }
    }

    // One logical message id shared across all per-device copies.
    const messageId = randomUUID();
    const clientMsgId = body.clientMessageId ?? messageId;

    const cols = 8;
    const valuesSql = envelopes
      .map((_, i) => {
        const b = i * cols;
        return `($${b + 1},$${b + 2},$${b + 3},$${b + 4},$${b + 5},$${b + 6},$${b + 7},$${b + 8})`;
      })
      .join(",");
    const params = envelopes.flatMap((e) => [
      body.conversationId,
      senderUserId,
      senderDeviceId,
      e.recipientUserId,
      e.recipientDeviceId,
      e.ciphertext,
      clientMsgId,
      messageId
    ]);

    await db.query(

      `

      INSERT INTO message_envelopes (

        conversation_id, sender_user_id, sender_device_id,

        recipient_user_id, recipient_device_id, ciphertext, client_message_id, message_id

      ) VALUES ${valuesSql}

      `,

      params

    );



    if (centrifugoCfg) {
      // Push each device ITS OWN ciphertext. Skip the sender's current device
      // (it already has the message); other sender devices get it for sync.
      for (const e of envelopes) {
        if (e.recipientUserId === senderUserId && e.recipientDeviceId === senderDeviceId) continue;
        void publishToUserDevice({
          apiUrl: centrifugoCfg.apiUrl,
          apiKey: centrifugoCfg.apiKey,
          userId: e.recipientUserId,
          deviceId: e.recipientDeviceId,
          data: {
            type: "message",
            envelopeId: messageId,
            conversationId: body.conversationId,
            senderUserId,
            senderDeviceId,
            ciphertext: e.ciphertext,
            clientMessageId: clientMsgId
          }
        }).catch((err) => req.log.warn({ err }, "centrifugo_publish_failed"));
      }
    }



    return reply.send({ ok: true, envelopeId: messageId });

  }



  // Group message — fan-out to all member devices except sender

  const groupId = parsed.groupId!;

  if (!(await canAccessGroup(db, groupId, senderUserId))) {

    return reply.code(403).send({ ok: false, error: "Not a group member" });

  }



  // Idempotency for group retries — same client_message_id was already fanned out.
  if (body.clientMessageId) {
    const dup = await db.query<{ message_id: string }>(
      `SELECT message_id FROM message_envelopes
       WHERE conversation_id = $1 AND sender_user_id = $2 AND client_message_id = $3
       LIMIT 1`,
      [body.conversationId, senderUserId, body.clientMessageId]
    );
    if (dup.rows[0]) {
      return reply.send({ ok: true, envelopeId: dup.rows[0].message_id, deduped: true });
    }
  }

  const memberIds = await listGroupMemberUserIds(db, groupId);
  const allDevices = await listMemberDevices(db, memberIds);
  if (allDevices.length === 0) {
    return reply.code(400).send({ ok: false, error: "No member devices registered" });
  }

  const pushDevices = allDevices.filter((d) => d.userId !== senderUserId);

  const envelopeId = randomUUID();
  const clientMsgId = body.clientMessageId ?? envelopeId;

  if (!body.ciphertext) {
    return reply.code(400).send({ ok: false, error: "ciphertext required" });
  }

  // Single multi-row INSERT — one DB round trip for the whole group fan-out
  // instead of one round trip per device (Culprit #1). All rows share the same
  // logical message_id (= envelopeId) so receipts/UI resolve one message.
  const cols = 8;
  const valuesSql = allDevices
    .map((_, i) => {
      const b = i * cols;
      return `($${b + 1},$${b + 2},$${b + 3},$${b + 4},$${b + 5},$${b + 6},$${b + 7},$${b + 8})`;
    })
    .join(",");
  const params = allDevices.flatMap((d) => [
    body.conversationId,
    senderUserId,
    senderDeviceId,
    d.userId,
    d.deviceId,
    body.ciphertext,
    clientMsgId,
    envelopeId
  ]);

  await db.query(
    `
    INSERT INTO message_envelopes (
      conversation_id, sender_user_id, sender_device_id,
      recipient_user_id, recipient_device_id, ciphertext, client_message_id, message_id
    ) VALUES ${valuesSql}
    `,
    params
  );



  if (centrifugoCfg && pushDevices.length > 0) {
    void fanoutToDevices(centrifugoCfg, pushDevices, {

      type: "message",

      envelopeId,

      conversationId: body.conversationId,

      senderUserId,

      senderDeviceId,

      ciphertext: body.ciphertext,

      clientMessageId: body.clientMessageId ?? null

    }).catch((err) => req.log.warn({ err }, "centrifugo_group_fanout_failed"));

  }



  return reply.send({ ok: true, envelopeId });

});



app.post("/conversations/:conversationId/typing", async (req: any, reply: any) => {

  const userId = req.user.sub as string;

  const params = z.object({ conversationId: z.string().min(8).max(128) }).parse(req.params);

  const body = z.object({ isTyping: z.boolean() }).parse(req.body);



  if (!(await userAllowsTyping(db, userId))) {

    return reply.send({ ok: true, skipped: true });

  }



  const parsed = parseConversationId(params.conversationId);

  if (!parsed) return reply.code(400).send({ ok: false, error: "Invalid conversation" });



  let targets: Array<{ userId: string; deviceId: string }> = [];



  if (parsed.kind === "dm") {

    const peerId = peerUserIdFromConversation(params.conversationId, userId);

    if (!peerId || !(await canAccessConversation(db, userId, peerId))) {

      return reply.code(403).send({ ok: false, error: "Forbidden" });

    }

    targets = await listMemberDevices(db, [peerId]);

  } else {

    if (!(await canAccessGroup(db, parsed.groupId!, userId))) {

      return reply.code(403).send({ ok: false, error: "Forbidden" });

    }

    const members = (await listGroupMemberUserIds(db, parsed.groupId!)).filter((id) => id !== userId);

    targets = await listMemberDevices(db, members);

  }



  if (centrifugoCfg && targets.length > 0) {

    void fanoutToDevices(centrifugoCfg, targets, {

      type: "typing",

      conversationId: params.conversationId,

      userId,

      isTyping: body.isTyping

    }, { skipHistory: true }).catch(() => {});

  }



  return reply.send({ ok: true });

});



app.post("/conversations/:conversationId/delivery", async (req: any, reply: any) => {

  const userId = req.user.sub as string;

  const params = z.object({ conversationId: z.string().min(8).max(128) }).parse(req.params);

  const body = z.object({ envelopeId: z.string().uuid() }).parse(req.body);



  const parsed = parseConversationId(params.conversationId);

  if (!parsed) return reply.code(400).send({ ok: false, error: "Invalid conversation" });



  if (parsed.kind === "dm") {

    const peerId = peerUserIdFromConversation(params.conversationId, userId);

    if (!peerId || !(await canAccessConversation(db, userId, peerId))) {

      return reply.code(403).send({ ok: false, error: "Forbidden" });

    }

  } else {

    if (!(await canAccessGroup(db, parsed.groupId!, userId))) {

      return reply.code(403).send({ ok: false, error: "Forbidden" });

    }

  }



  const envelope = await db.query<{ sender_user_id: string }>(

    `SELECT sender_user_id FROM message_envelopes WHERE message_id = $1 AND conversation_id = $2 LIMIT 1`,

    [body.envelopeId, params.conversationId]

  );

  const senderId = envelope.rows[0]?.sender_user_id;

  if (!senderId || senderId === userId) return reply.send({ ok: true });



  const targets = await listMemberDevices(db, [senderId]);

  const deliveredAt = new Date().toISOString();



  if (centrifugoCfg && targets.length > 0) {

    void fanoutToDevices(centrifugoCfg, targets, {

      type: "delivery",

      conversationId: params.conversationId,

      userId,

      envelopeId: body.envelopeId,

      deliveredAt

    }, { skipHistory: true }).catch(() => {});

  }



  return reply.send({ ok: true });

});



app.post("/conversations/:conversationId/receipts", async (req: any, reply: any) => {

  const userId = req.user.sub as string;

  const params = z.object({ conversationId: z.string().min(8).max(128) }).parse(req.params);

  const body = z.object({ envelopeId: z.string().uuid() }).parse(req.body);



  if (!(await userAllowsReadReceipts(db, userId))) {

    return reply.send({ ok: true, skipped: true });

  }



  const parsed = parseConversationId(params.conversationId);

  if (!parsed) return reply.code(400).send({ ok: false, error: "Invalid conversation" });



  await db.query(

    `

    INSERT INTO read_cursors (conversation_id, user_id, last_read_envelope_id, updated_at)

    VALUES ($1, $2, $3, now())

    ON CONFLICT (conversation_id, user_id)

    DO UPDATE SET last_read_envelope_id = EXCLUDED.last_read_envelope_id, updated_at = now()

    `,

    [params.conversationId, userId, body.envelopeId]

  );



  const envelope = await db.query<{ sender_user_id: string }>(

    `SELECT sender_user_id FROM message_envelopes WHERE message_id = $1 LIMIT 1`,

    [body.envelopeId]

  );

  const senderId = envelope.rows[0]?.sender_user_id;

  if (!senderId || senderId === userId) return reply.send({ ok: true });



  const targets = await listMemberDevices(db, [senderId]);

  const readAt = new Date().toISOString();



  if (centrifugoCfg && targets.length > 0) {

    void fanoutToDevices(centrifugoCfg, targets, {

      type: "receipt",

      conversationId: params.conversationId,

      userId,

      envelopeId: body.envelopeId,

      readAt

    }, { skipHistory: true }).catch(() => {});

  }



  return reply.send({ ok: true });

});



const port = cfg.PORT;

const host = "0.0.0.0";

await app.listen({ port, host });


