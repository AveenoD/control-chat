import pino from "pino";
import type { BaseConfig } from "./config.js";

export function createLogger(cfg: Pick<BaseConfig, "SERVICE_NAME" | "LOG_LEVEL" | "NODE_ENV">) {
  return pino({
    name: cfg.SERVICE_NAME,
    level: cfg.LOG_LEVEL,
    redact: {
      paths: [
        "req.headers.authorization",
        "req.headers.cookie",
        "req.body.otp",
        "req.body.refreshToken",
        "req.body.password"
      ],
      remove: true
    },
    transport:
      cfg.NODE_ENV === "development"
        ? {
            target: "pino-pretty",
            options: { colorize: true, translateTime: "SYS:standard", singleLine: true }
          }
        : undefined
  });
}

