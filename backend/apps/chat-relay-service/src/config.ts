import { z } from "zod";
import { loadBaseConfig, parseEnv } from "@auratalk/shared";

const schema = z.object({
  SERVICE_NAME: z.string().default("chat-relay-service"),
  DATABASE_URL: z.string().min(1),
  JWT_SECRET: z.string().min(16),
  // Phase 1: just reserve config knobs; Centrifugo publish comes later in phase 1.1
  CENTRIFUGO_API_URL: z.string().url().optional(),
  CENTRIFUGO_API_KEY: z.string().min(1).optional(),
  // S3-compatible media storage (MinIO in dev, Backblaze B2 in prod).
  S3_ENDPOINT: z.string().url(),
  S3_REGION: z.string().default("us-east-005"),
  S3_BUCKET: z.string().min(1),
  S3_ACCESS_KEY_ID: z.string().min(1),
  S3_SECRET_ACCESS_KEY: z.string().min(1),
  S3_FORCE_PATH_STYLE: z.coerce.boolean().default(true),
  MEDIA_MAX_BYTES: z.coerce.number().int().positive().default(26_214_400)
});

export function loadChatRelayConfig() {
  const base = loadBaseConfig({ SERVICE_NAME: "chat-relay-service" });
  const env = parseEnv(schema);
  return { ...base, ...env };
}

