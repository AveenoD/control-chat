import Fastify from "fastify";
import cors from "@fastify/cors";
import jwt from "@fastify/jwt";
import swagger from "@fastify/swagger";
import swaggerUi from "@fastify/swagger-ui";
import { createLogger, makeHealth } from "@auratalk/shared";
import { z } from "zod";
import { loadChatRelayConfig } from "./config.js";
import { createDb } from "./db.js";

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

const sendBody = z.object({
  conversationId: z.string().min(8).max(128),
  recipientUserId: z.string().uuid(),
  recipientDeviceId: z.string().min(8).max(128),
  ciphertext: z.string().min(16).max(200_000),
  clientMessageId: z.string().min(8).max(128).optional()
});

// Encrypted envelope only. Server never inspects plaintext.
app.post("/messages", async (req, reply) => {
  const senderUserId = (req.user as any).sub as string;
  const senderDeviceId = (req.user as any).deviceId as string;
  const body = sendBody.parse(req.body);

  const res = await db.query<{ id: string }>(
    `
    INSERT INTO message_envelopes (
      conversation_id,
      sender_user_id,
      sender_device_id,
      recipient_user_id,
      recipient_device_id,
      ciphertext,
      client_message_id
    )
    VALUES ($1,$2,$3,$4,$5,$6,$7)
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

  // Phase 1: publishing to Centrifugo is stubbed; we persist and return.
  if (cfg.CENTRIFUGO_API_URL && cfg.CENTRIFUGO_API_KEY) {
    publishToCentrifugo({
      apiUrl: cfg.CENTRIFUGO_API_URL,
      apiKey: cfg.CENTRIFUGO_API_KEY,
      channel: `user:${body.recipientUserId}:${body.recipientDeviceId}`,
      data: {
        envelopeId: res.rows[0]!.id,
        conversationId: body.conversationId,
        senderUserId,
        senderDeviceId,
        ciphertext: body.ciphertext,
        clientMessageId: body.clientMessageId ?? null
      }
    }).catch((err) => req.log.warn({ err }, "centrifugo_publish_failed"));
  }
  return reply.send({ ok: true, envelopeId: res.rows[0]!.id });
});

async function publishToCentrifugo(opts: {
  apiUrl: string;
  apiKey: string;
  channel: string;
  data: unknown;
}) {
  const res = await fetch(opts.apiUrl, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `apikey ${opts.apiKey}`
    },
    body: JSON.stringify({
      method: "publish",
      params: { channel: opts.channel, data: opts.data }
    })
  });
  if (!res.ok) {
    const text = await res.text().catch(() => "");
    throw new Error(`Centrifugo publish failed: ${res.status} ${text}`);
  }
}

app.get("/conversations/:conversationId/messages", async (req) => {
  const userId = (req.user as any).sub as string;
  const deviceId = (req.user as any).deviceId as string;
  const params = z.object({ conversationId: z.string().min(8).max(128) }).parse(req.params);
  const query = z.object({ limit: z.coerce.number().int().min(1).max(200).default(50) }).parse(req.query);

  const res = await db.query(
    `
    SELECT id, conversation_id, sender_user_id, sender_device_id, ciphertext, created_at, client_message_id
    FROM message_envelopes
    WHERE conversation_id = $1
      AND recipient_user_id = $2
      AND recipient_device_id = $3
    ORDER BY created_at DESC
    LIMIT $4
    `,
    [params.conversationId, userId, deviceId, query.limit]
  );

  return { ok: true, messages: res.rows };
});

const port = cfg.PORT;
const host = "0.0.0.0";
await app.listen({ port, host });

