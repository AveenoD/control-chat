import Fastify from "fastify";
import cors from "@fastify/cors";
import jwt from "@fastify/jwt";
import rateLimit from "@fastify/rate-limit";
import swagger from "@fastify/swagger";
import swaggerUi from "@fastify/swagger-ui";
import { createLogger, makeHealth } from "@auratalk/shared";
import { Redis } from "ioredis";
import "@fastify/rate-limit";
import { z } from "zod";
import { loadAuthConfig } from "./config.js";
import { createDb } from "./db.js";

const cfg = loadAuthConfig();
const logger = createLogger(cfg);
const db = createDb(cfg.DATABASE_URL);

const app = Fastify({ loggerInstance: logger });

await app.register(cors, { origin: true, credentials: true });
await app.register(jwt, { secret: cfg.JWT_SECRET });

// Rate limiting: protect OTP endpoints (Redis-backed for production-like behavior).
const redis = new Redis(cfg.REDIS_URL, {
  maxRetriesPerRequest: 2,
  enableReadyCheck: true
});
await app.register(rateLimit, {
  redis,
  global: false
});

await app.register(swagger, {
  openapi: {
    info: { title: "AuraTalk auth-service", version: "0.0.0" }
  }
});
await app.register(swaggerUi, { routePrefix: "/docs" });

app.get("/health", async () => makeHealth(cfg.SERVICE_NAME));

const requestOtpBody = z.object({ phone: z.string().min(6).max(32) });
app.post(
  "/auth/request-otp",
  {
    config: {
      rateLimit: {
        max: 5,
        timeWindow: "1 minute"
      }
    }
  },
  async (req, reply) => {
  const body = requestOtpBody.parse(req.body);

  // Phase-1 dev path: no SMS provider, fixed OTP.
  // Store only a derived hash later (phase 1.1). For now, return success.
  req.log.info({ phone: body.phone }, "otp_requested");
  return reply.send({ ok: true });
  }
);

const verifyOtpBody = z.object({
  phone: z.string().min(6).max(32),
  otp: z.string().min(4).max(12),
  deviceId: z.string().min(8).max(128)
});

app.post(
  "/auth/verify-otp",
  {
    config: {
      rateLimit: {
        max: 10,
        timeWindow: "1 minute"
      }
    }
  },
  async (req, reply) => {
  const body = verifyOtpBody.parse(req.body);

  if (!cfg.DEV_OTP_ENABLED) {
    return reply.code(501).send({ ok: false, error: "OTP provider not configured" });
  }
  if (body.otp !== cfg.DEV_OTP_CODE) {
    return reply.code(401).send({ ok: false, error: "Invalid OTP" });
  }

  // Phase 1 placeholder user model: create/find user + device.
  // Keep it simple but production-shaped: transactions + stable IDs.
  const client = await db.connect();
  try {
    await client.query("BEGIN");
    const userId = await upsertUserByPhone(client, body.phone);
    await upsertDevice(client, userId, body.deviceId);
    await client.query("COMMIT");

    const accessToken = await reply.jwtSign(
      { sub: userId, deviceId: body.deviceId, typ: "access" },
      { expiresIn: cfg.ACCESS_TOKEN_TTL_SECONDS }
    );
    const refreshToken = await reply.jwtSign(
      { sub: userId, deviceId: body.deviceId, typ: "refresh" },
      { expiresIn: cfg.REFRESH_TOKEN_TTL_SECONDS }
    );

    return reply.send({ ok: true, userId, accessToken, refreshToken });
  } catch (err) {
    await client.query("ROLLBACK");
    req.log.error({ err }, "verify_otp_failed");
    throw err;
  } finally {
    client.release();
  }
  }
);

app.post("/auth/refresh", async (req, reply) => {
  const body = z.object({ refreshToken: z.string().min(1) }).parse(req.body);
  const decoded = await app.jwt.verify<{ sub: string; deviceId: string; typ: string }>(body.refreshToken);
  if (decoded.typ !== "refresh") return reply.code(401).send({ ok: false, error: "Invalid token type" });

  const accessToken = await reply.jwtSign(
    { sub: decoded.sub, deviceId: decoded.deviceId, typ: "access" },
    { expiresIn: cfg.ACCESS_TOKEN_TTL_SECONDS }
  );
  return reply.send({ ok: true, accessToken });
});

async function upsertUserByPhone(client: import("pg").PoolClient, phone: string) {
  // NOTE: Phase 1 uses plaintext phone in DB for speed of scaffolding.
  // Phase 1.1 will migrate to phone_hash + optional encrypted phone.
  const res = await client.query<{ id: string }>(
    `
    INSERT INTO users (phone)
    VALUES ($1)
    ON CONFLICT (phone) DO UPDATE SET phone = EXCLUDED.phone
    RETURNING id
    `,
    [phone]
  );
  return res.rows[0]!.id;
}

async function upsertDevice(client: import("pg").PoolClient, userId: string, deviceId: string) {
  await client.query(
    `
    INSERT INTO devices (user_id, device_id)
    VALUES ($1, $2)
    ON CONFLICT (device_id) DO UPDATE SET user_id = EXCLUDED.user_id
    `,
    [userId, deviceId]
  );
}

const port = cfg.PORT;
const host = "0.0.0.0";

await app.listen({ port, host });

