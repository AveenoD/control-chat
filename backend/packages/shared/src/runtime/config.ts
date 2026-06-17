import { z } from "zod";
import { parseEnv } from "./env.js";

const baseSchema = z.object({
  NODE_ENV: z.enum(["development", "test", "production"]).default("development"),
  SERVICE_NAME: z.string().min(1).default("unknown-service"),
  PORT: z.coerce.number().int().min(1).max(65535).default(3000),
  LOG_LEVEL: z.enum(["fatal", "error", "warn", "info", "debug", "trace", "silent"]).default("info")
});

export type BaseConfig = z.infer<typeof baseSchema>;

export function loadBaseConfig(overrides?: Partial<BaseConfig>): BaseConfig {
  const env = parseEnv(baseSchema);
  return { ...env, ...(overrides ?? {}) };
}

