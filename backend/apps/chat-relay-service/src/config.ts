import { z } from "zod";
import { loadBaseConfig, parseEnv } from "@auratalk/shared";

const schema = z.object({
  SERVICE_NAME: z.string().default("chat-relay-service"),
  DATABASE_URL: z.string().min(1),
  JWT_SECRET: z.string().min(16),
  // Phase 1: just reserve config knobs; Centrifugo publish comes later in phase 1.1
  CENTRIFUGO_API_URL: z.string().url().optional(),
  CENTRIFUGO_API_KEY: z.string().min(1).optional()
});

export function loadChatRelayConfig() {
  const base = loadBaseConfig({ SERVICE_NAME: "chat-relay-service" });
  const env = parseEnv(schema);
  return { ...base, ...env };
}

