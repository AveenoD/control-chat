import { z } from "zod";
import { loadBaseConfig, parseEnv } from "@auratalk/shared";

const schema = z.object({
  SERVICE_NAME: z.string().default("user-service"),
  DATABASE_URL: z.string().min(1),
  JWT_SECRET: z.string().min(16),
  CENTRIFUGO_TOKEN_SECRET: z.string().min(8).default("dev-change-me"),
  CENTRIFUGO_API_URL: z.string().url().optional(),
  CENTRIFUGO_API_KEY: z.string().min(1).optional(),
  LIVEKIT_API_KEY: z.string().default("devkey"),
  LIVEKIT_API_SECRET: z.string().default("secret"),
  LIVEKIT_URL: z.string().default("ws://livekit:7880")
});

export function loadUserConfig() {
  const base = loadBaseConfig({ SERVICE_NAME: "user-service" });
  const env = parseEnv(schema);
  return { ...base, ...env };
}

