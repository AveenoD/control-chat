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



const sendBody = z.object({

  conversationId: z.string().min(8).max(128),

  recipientUserId: z.string().uuid().optional(),

  recipientDeviceId: z.string().min(8).max(128).optional(),

  ciphertext: z.string().min(16).max(200_000),

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



  const res = await db.query(
    `
    SELECT id, conversation_id, sender_user_id, sender_device_id, ciphertext, created_at, client_message_id
    FROM message_envelopes
    WHERE conversation_id = $1
      AND (recipient_user_id = $2 OR sender_user_id = $2)
      AND (
        $4::uuid IS NULL
        OR created_at > COALESCE(
          (SELECT created_at FROM message_envelopes WHERE id = $4 AND conversation_id = $1 LIMIT 1),
          '-infinity'::timestamptz
        )
      )
    ORDER BY created_at ASC
    LIMIT $3
    `,
    [params.conversationId, userId, query.limit, query.after ?? null]
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

    if (!body.recipientUserId || !body.recipientDeviceId) {

      return reply.code(400).send({ ok: false, error: "recipientUserId and recipientDeviceId required" });

    }

    const expectedConversationId = directConversationId(senderUserId, body.recipientUserId);

    if (body.conversationId !== expectedConversationId) {

      return reply.code(400).send({ ok: false, error: "Invalid conversationId" });

    }

    const allowed = await canDirectMessage(db, senderUserId, body.recipientUserId);

    if (!allowed) {

      return reply.code(403).send({

        ok: false,

        error: "message_request_required",

        message: "Add contact or accept message request before sending"

      });

    }



    const deviceRes = await db.query(

      `SELECT 1 FROM device_keys WHERE user_id = $1 AND device_id = $2 LIMIT 1`,

      [body.recipientUserId, body.recipientDeviceId]

    );

    if (deviceRes.rowCount === 0) {

      return reply.code(400).send({ ok: false, error: "Recipient device not registered" });

    }



    const res = await db.query<{ id: string }>(

      `

      INSERT INTO message_envelopes (

        conversation_id, sender_user_id, sender_device_id,

        recipient_user_id, recipient_device_id, ciphertext, client_message_id

      ) VALUES ($1,$2,$3,$4,$5,$6,$7)

      RETURNING id

      `,

      [

        body.conversationId,

        senderUserId,

        senderDeviceId,

        body.recipientUserId,

        body.recipientDeviceId,

        body.ciphertext,

        body.clientMessageId ?? null

      ]

    );



    if (centrifugoCfg) {
      const recipientDevices = await listMemberDevices(db, [body.recipientUserId]);
      if (recipientDevices.length > 0) {
        void fanoutToDevices(centrifugoCfg, recipientDevices, {
          type: "message",
          envelopeId: res.rows[0]!.id,
          conversationId: body.conversationId,
          senderUserId,
          senderDeviceId,
          ciphertext: body.ciphertext,
          clientMessageId: body.clientMessageId ?? null
        }).catch((err) => req.log.warn({ err }, "centrifugo_publish_failed"));
      }
    }



    return reply.send({ ok: true, envelopeId: res.rows[0]!.id });

  }



  // Group message — fan-out to all member devices except sender

  const groupId = parsed.groupId!;

  if (!(await canAccessGroup(db, groupId, senderUserId))) {

    return reply.code(403).send({ ok: false, error: "Not a group member" });

  }



  const memberIds = await listGroupMemberUserIds(db, groupId);
  const allDevices = await listMemberDevices(db, memberIds);
  if (allDevices.length === 0) {
    return reply.code(400).send({ ok: false, error: "No member devices registered" });
  }

  const pushDevices = allDevices.filter((d) => d.userId !== senderUserId);

  const envelopeId = randomUUID();
  for (const d of allDevices) {

    await db.query(

      `

      INSERT INTO message_envelopes (

        conversation_id, sender_user_id, sender_device_id,

        recipient_user_id, recipient_device_id, ciphertext, client_message_id

      ) VALUES ($1,$2,$3,$4,$5,$6,$7)

      `,

      [

        body.conversationId,

        senderUserId,

        senderDeviceId,

        d.userId,

        d.deviceId,

        body.ciphertext,

        body.clientMessageId ?? envelopeId

      ]

    );

  }



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

    }).catch(() => {});

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

    `SELECT sender_user_id FROM message_envelopes WHERE id = $1 AND conversation_id = $2 LIMIT 1`,

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

    }).catch(() => {});

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

    `SELECT sender_user_id FROM message_envelopes WHERE id = $1 LIMIT 1`,

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

    }).catch(() => {});

  }



  return reply.send({ ok: true });

});



const port = cfg.PORT;

const host = "0.0.0.0";

await app.listen({ port, host });


