import Fastify from "fastify";
import cors from "@fastify/cors";
import httpProxy from "@fastify/http-proxy";
import swagger from "@fastify/swagger";
import swaggerUi from "@fastify/swagger-ui";
import { createLogger, makeHealth, loadBaseConfig, parseEnv } from "@auratalk/shared";
import { z } from "zod";

const envSchema = z.object({
  AUTH_SERVICE_URL: z.string().url(),
  USER_SERVICE_URL: z.string().url(),
  CHAT_RELAY_SERVICE_URL: z.string().url()
});

const cfg = loadBaseConfig({ SERVICE_NAME: "gateway" });
const env = parseEnv(envSchema);
const logger = createLogger(cfg);

const app = Fastify({ loggerInstance: logger });
await app.register(cors, { origin: true, credentials: true });

const stripUnsupportedHeaders = (_req: any, headers: Record<string, any>) => {
  // undici (used by @fastify/reply-from) can reject certain hop-by-hop headers.
  // PowerShell/clients sometimes send `Expect: 100-continue`.
  // Remove it for upstream services.
  const next = { ...headers };
  delete next.expect;
  return next;
};

await app.register(swagger, {
  openapi: {
    info: { title: "AuraTalk gateway", version: "0.0.0" }
  }
});
await app.register(swaggerUi, { routePrefix: "/docs" });

app.get("/health", async () => makeHealth(cfg.SERVICE_NAME));

// auth-service
await app.register(httpProxy, {
  upstream: env.AUTH_SERVICE_URL,
  prefix: "/auth",
  rewritePrefix: "/auth",
  replyOptions: { rewriteRequestHeaders: stripUnsupportedHeaders }
});

// user-service
await app.register(httpProxy, {
  upstream: env.USER_SERVICE_URL,
  prefix: "/me",
  rewritePrefix: "/me",
  replyOptions: { rewriteRequestHeaders: stripUnsupportedHeaders }
});
await app.register(httpProxy, {
  upstream: env.USER_SERVICE_URL,
  prefix: "/devices",
  rewritePrefix: "/devices",
  replyOptions: { rewriteRequestHeaders: stripUnsupportedHeaders }
});
await app.register(httpProxy, {
  upstream: env.USER_SERVICE_URL,
  prefix: "/users",
  rewritePrefix: "/users",
  replyOptions: { rewriteRequestHeaders: stripUnsupportedHeaders }
});

// chat-relay-service
await app.register(httpProxy, {
  upstream: env.CHAT_RELAY_SERVICE_URL,
  prefix: "/messages",
  rewritePrefix: "/messages",
  replyOptions: { rewriteRequestHeaders: stripUnsupportedHeaders }
});
await app.register(httpProxy, {
  upstream: env.CHAT_RELAY_SERVICE_URL,
  prefix: "/conversations",
  rewritePrefix: "/conversations",
  replyOptions: { rewriteRequestHeaders: stripUnsupportedHeaders }
});

const port = cfg.PORT;
const host = "0.0.0.0";
await app.listen({ port, host });

