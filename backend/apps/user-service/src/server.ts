import Fastify from "fastify";
import cors from "@fastify/cors";
import jwt from "@fastify/jwt";
import swagger from "@fastify/swagger";
import swaggerUi from "@fastify/swagger-ui";
import { createLogger, makeHealth } from "@auratalk/shared";
import { z } from "zod";
import { loadUserConfig } from "./config.js";
import { createDb } from "./db.js";

const cfg = loadUserConfig();
const logger = createLogger(cfg);
const db = createDb(cfg.DATABASE_URL);

const app = Fastify({ loggerInstance: logger });

await app.register(cors, { origin: true, credentials: true });
await app.register(jwt, { secret: cfg.JWT_SECRET });

await app.register(swagger, {
  openapi: { info: { title: "AuraTalk user-service", version: "0.0.0" } }
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

app.get("/me", async (req) => {
  const userId = (req.user as any).sub as string;
  const res = await db.query(
    `SELECT id, phone, created_at FROM users WHERE id = $1`,
    [userId]
  );
  const row = res.rows[0];
  if (!row) return { ok: false, error: "Not found" };
  return { ok: true, user: row };
});

const updateProfileBody = z.object({
  displayName: z.string().min(1).max(64).optional(),
  avatarUrl: z.string().url().max(512).optional()
});

app.post("/me/profile", async (req, reply) => {
  const userId = (req.user as any).sub as string;
  const body = updateProfileBody.parse(req.body);

  await db.query(
    `
    UPDATE users
    SET
      display_name = COALESCE($2, display_name),
      avatar_url = COALESCE($3, avatar_url)
    WHERE id = $1
    `,
    [userId, body.displayName ?? null, body.avatarUrl ?? null]
  );

  return reply.send({ ok: true });
});

const upsertDeviceKeysBody = z.object({
  deviceId: z.string().min(8).max(128),
  identityKeyPublic: z.string().min(16).max(4096),
  registrationId: z.number().int().min(1).max(2_147_483_647),
  preKeyBundle: z.record(z.string(), z.any())
});

// Phase 1: store public key material only (safe to store).
app.post("/devices/keys", async (req, reply) => {
  const userId = (req.user as any).sub as string;
  const body = upsertDeviceKeysBody.parse(req.body);

  await db.query(
    `
    INSERT INTO device_keys (user_id, device_id, identity_key_public, registration_id, pre_key_bundle)
    VALUES ($1, $2, $3, $4, $5)
    ON CONFLICT (device_id) DO UPDATE SET
      user_id = EXCLUDED.user_id,
      identity_key_public = EXCLUDED.identity_key_public,
      registration_id = EXCLUDED.registration_id,
      pre_key_bundle = EXCLUDED.pre_key_bundle,
      updated_at = now()
    `,
    [userId, body.deviceId, body.identityKeyPublic, body.registrationId, body.preKeyBundle]
  );

  return reply.send({ ok: true });
});

app.get("/users/:userId/devices/keys", async (req, reply) => {
  const params = z.object({ userId: z.string().uuid() }).parse(req.params);
  const res = await db.query(
    `
    SELECT device_id, identity_key_public, registration_id, pre_key_bundle, updated_at
    FROM device_keys
    WHERE user_id = $1
    `,
    [params.userId]
  );
  return reply.send({ ok: true, devices: res.rows });
});

const port = cfg.PORT;
const host = "0.0.0.0";
await app.listen({ port, host });

