import { z } from "zod";
import { loadBaseConfig, parseEnv } from "@auratalk/shared";

const authSchema = z.object({
  SERVICE_NAME: z.string().default("auth-service"),
  DATABASE_URL: z.string().min(1),
  JWT_SECRET: z.string().min(16),
  REDIS_URL: z.string().min(1).default("redis://localhost:6379"),
  DEV_OTP_CODE: z.string().min(4).max(12).default("123456"),
  DEV_OTP_ENABLED: z.coerce.boolean().default(true),
  ACCESS_TOKEN_TTL_SECONDS: z.coerce.number().int().min(60).default(15 * 60),
  REFRESH_TOKEN_TTL_SECONDS: z.coerce.number().int().min(60).default(30 * 24 * 60 * 60)
});

export type AuthConfig = ReturnType<typeof loadAuthConfig>;

export function loadAuthConfig() {
  const base = loadBaseConfig({ SERVICE_NAME: "auth-service" });
  const env = parseEnv(authSchema);
  return { ...base, ...env };
}

