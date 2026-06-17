import { z } from "zod";

export function parseEnv<T extends z.ZodTypeAny>(schema: T, rawEnv = process.env): z.infer<T> {
  const parsed = schema.safeParse(rawEnv);
  if (!parsed.success) {
    // Keep error readable for container logs
    const flattened = parsed.error.flatten();
    throw new Error(`Invalid environment variables: ${JSON.stringify(flattened.fieldErrors)}`);
  }
  return parsed.data;
}

