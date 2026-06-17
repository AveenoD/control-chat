import { z } from "zod";
import { loadBaseConfig, parseEnv } from "@auratalk/shared";

const schema = z.object({
  SERVICE_NAME: z.string().default("user-service"),
  DATABASE_URL: z.string().min(1),
  JWT_SECRET: z.string().min(16)
});

export function loadUserConfig() {
  const base = loadBaseConfig({ SERVICE_NAME: "user-service" });
  const env = parseEnv(schema);
  return { ...base, ...env };
}

