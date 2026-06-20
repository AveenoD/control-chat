## 20-06-2026 — Phase 4A: WhatsApp-style delivery + incremental sync

What changed:
- chat-relay: `GET /messages?after=<uuid>` incremental sync; `POST /delivery` ephemeral delivery receipts
- Centrifugo event `type: delivery` distinct from read `receipt`
- Flutter: three-state ticks (… / ✓ sent / ✓✓ delivered / ✓✓ read blue)
- Flutter: delivery ACK on receive; WS reconnect exponential backoff; poll only when WS down
- Flutter: incremental message merge + decrypt cache; smart polling backoff

Files touched:
- backend/apps/chat-relay-service/src/server.ts
- backend/apps/chat-relay-service/src/publish-realtime.ts
- backend/docs/openapi.yml
- mobile/lib/core/chat/chat_models.dart
- mobile/lib/core/chat/chat_repository.dart
- mobile/lib/core/realtime/chat_realtime_service.dart
- mobile/lib/ui/chats/chat_thread_screen.dart
- mobile/lib/ui/shell/app_shell.dart
- mobile/lib/core/auth/session_provider.dart

API endpoints used:
- GET /conversations/:id/messages?after=
- POST /conversations/:id/delivery
- POST /conversations/:id/receipts (unchanged)

Breaking change:
- NO

---

## 19-06-2026 — Phase 3: Groups, realtime, calls, safety

What changed:
- Migration 004: user_blocks, user_reports, groups, group_key_envelopes, read_cursors, call_sessions
- user-service: block/report, groups + key distribution, LiveKit call tokens, Centrifugo call push
- chat-relay: group message fan-out, typing + read receipt endpoints, typed Centrifugo events
- gateway: proxies /blocks, /reports, /groups, /calls
- docker-compose: LiveKit dev server
- Flutter: groups UI, E2EE group crypto, typing/receipts, block/report, LiveKit calls, app-level WS

Files touched:
- backend/infra/migrations/004_phase3_groups_realtime_safety.sql
- backend/apps/user-service/src/phase3-routes.ts
- backend/apps/chat-relay-service/src/server.ts
- backend/apps/chat-relay-service/src/publish-realtime.ts
- backend/apps/chat-relay-service/src/messaging-policy.ts
- backend/apps/gateway/src/server.ts
- backend/docker-compose.yml
- mobile/lib/core/** (groups, safety, calls, crypto)
- mobile/lib/ui/** (chat thread, create group, calls, app shell)

API endpoints used:
- POST/GET/DELETE /blocks, POST /reports
- POST/GET /groups, GET/POST /groups/:id/members, GET/POST /groups/:id/keys
- POST /calls/start, POST /calls/:id/join, GET /calls/history
- POST /conversations/:id/typing, POST /conversations/:id/receipts

Breaking change:
- NO

Branch:
- main

---


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

## 17-06-2026 13:36 — Flutter scaffold + AuraTalk UI theme (Phase 1)

What changed:
- Created Flutter app scaffold (`mobile/`) with Riverpod and base theme matching provided AuraTalk reference UI
- Added bottom navigation shell + initial Home/Zones/Chats/Calls/Profile screens (layout-only)

Files touched:
- mobile/pubspec.yaml
- mobile/lib/main.dart
- mobile/lib/app/app.dart
- mobile/lib/theme/aura_theme.dart
- mobile/lib/ui/shell/app_shell.dart
- mobile/lib/ui/tabs/**/*
- mobile/test/widget_test.dart
- mobile/README.md

API endpoints used:
- None

Breaking change:
- NO

Branch:
- N/A (not a git repo)

---

## 19-06-2026 14:00 — Phase 2 identity core (backend + Flutter)

What changed:
- Added Phase 2 SQL migration: username, privacy_settings, contacts, message_requests
- user-service: onboarding, username lookup, privacy CRUD, contacts, message requests
- gateway: proxy routes for /contacts and /message-requests
- Flutter: auth flow (OTP → onboarding @username), privacy settings, message requests UI
- Zones tab shows Coming Soon (Phase 5)
- Saved execution phases roadmap at docs/EXECUTION_PHASES.md
- OpenAPI updated for Phase 2 endpoints

Files touched:
- backend/infra/migrations/002_phase2_identity.sql
- backend/apps/user-service/src/phase2-routes.ts
- backend/apps/user-service/src/server.ts
- backend/apps/gateway/src/server.ts
- backend/docs/openapi.yml
- docs/EXECUTION_PHASES.md
- mobile/lib/core/**
- mobile/lib/ui/auth/**
- mobile/lib/ui/onboarding/**
- mobile/lib/ui/privacy/**
- mobile/lib/ui/requests/**
- mobile/lib/ui/tabs/zones/zones_screen.dart
- mobile/lib/ui/tabs/profile/profile_screen.dart
- mobile/lib/app/app.dart

API endpoints used:
- POST /auth/request-otp, POST /auth/verify-otp
- GET /me, POST /me/onboarding, GET|PUT /me/privacy
- GET|POST|DELETE /contacts, GET /contacts/can-message/:targetUserId
- POST /message-requests, GET /message-requests/incoming, accept/decline

Breaking change:
- NO

Branch:
- main

---

## 19-06-2026 15:10 — Phase 2 complete: working 1:1 encrypted chats

What changed:
- chat-relay: GET /conversations, bidirectional message fetch, contact gate on send
- chat-relay: validates conversationId format and recipient device registration
- Flutter: X25519 + AES-GCM client encryption, device key registration on login
- Flutter: real Chats list, thread screen with polling, new chat by @username
- Migration 003 for conversation list indexes

Files touched:
- backend/apps/chat-relay-service/src/server.ts
- backend/apps/chat-relay-service/src/messaging-policy.ts
- backend/infra/migrations/003_phase2_chat_indexes.sql
- backend/docs/openapi.yml
- docs/EXECUTION_PHASES.md
- mobile/pubspec.yaml
- mobile/lib/core/crypto/**
- mobile/lib/core/chat/**
- mobile/lib/ui/chats/**
- mobile/lib/ui/tabs/chats/chats_screen.dart
- mobile/lib/core/auth/session_provider.dart

API endpoints used:
- GET /conversations, GET /conversations/:id/messages, POST /messages
- POST /devices/keys, GET /users/:id/devices/keys
- GET /contacts, GET /contacts/can-message/:id, POST /message-requests

Breaking change:
- NO (POST /messages now returns 403 without contact relationship)

Branch:
- main

---

