## 17-06-2026 13:12 — Backend scaffold (Phase 1)

What changed:
- Created Node.js + TypeScript backend scaffold with three services (auth, user, chat-relay)
- Added Docker Compose (Postgres, Redis, Centrifugo) and initial SQL migration

Files touched:
- backend/package.json
- backend/tsconfig.base.json
- backend/.gitignore
- backend/README.md
- backend/docker-compose.yml
- backend/infra/centrifugo/config.json
- backend/infra/migrations/001_init.sql
- backend/apps/auth-service/**
- backend/apps/user-service/**
- backend/apps/chat-relay-service/**
- backend/packages/shared/**

API endpoints used:
- None

Breaking change:
- NO

Branch:
- N/A (not a git repo)

---

## 17-06-2026 13:10 — Smoke-run fixes (auth-service)

What changed:
- Fixed env defaulting for base config
- Added `pino-pretty` dependency for dev logging
- Corrected Fastify logger wiring (`loggerInstance`)

Files touched:
- backend/packages/shared/src/runtime/config.ts
- backend/packages/shared/package.json
- backend/apps/auth-service/src/server.ts
- backend/apps/user-service/src/server.ts
- backend/apps/chat-relay-service/src/server.ts

API endpoints used:
- None

Breaking change:
- NO

Branch:
- N/A (not a git repo)

---

## 17-06-2026 13:12 — OpenAPI docs + changelog

What changed:
- Added consolidated OpenAPI spec (`docs/openapi.yml`) documenting Phase 1 endpoints
- Added root `Changelog.md` with strict entry format

Files touched:
- backend/docs/openapi.yml
- backend/Changelog.md

API endpoints used:
- None

Breaking change:
- NO

Branch:
- N/A (not a git repo)

---

## 17-06-2026 13:31 — Backend “single base URL” + realtime + rate limiting

What changed:
- Removed Traefik approach (Windows Docker provider issues) and added `gateway` reverse-proxy service
- Gateway exposes one base URL and routes to auth/user/chat services
- Added Redis-backed rate limiting to `auth-service` OTP endpoints
- Enabled Centrifugo publish in `chat-relay-service` (server-side publish on message send)

Files touched:
- backend/docker-compose.yml
- backend/apps/gateway/**
- backend/apps/auth-service/src/server.ts
- backend/apps/auth-service/src/config.ts
- backend/apps/auth-service/package.json
- backend/apps/*/Dockerfile
- backend/apps/chat-relay-service/src/server.ts
- backend/docs/openapi.yml
- backend/Changelog.md

API endpoints used:
- POST /auth/verify-otp
- GET /me
- POST /messages
- GET /conversations/{conversationId}/messages

Breaking change:
- NO

Branch:
- N/A (not a git repo)

---

