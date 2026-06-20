# AuraTalk — Dependency versions (stability audit)

> Last audited: 2026-06-19  
> Policy: pin tested versions; avoid major bumps unless required. `package-lock.json` / `pubspec.lock` are source of truth.

---

## Runtime requirements

| Component | Pinned version | Notes |
|-----------|----------------|-------|
| Node.js | 20.x LTS (`node:20.19-alpine` in Docker) | Backend engines: `>=20` |
| Flutter | 3.41.1 stable | Dart 3.11.0 |
| PostgreSQL | 16-alpine | |
| Redis | 7-alpine | |
| Centrifugo | **v5.4.9** | Stay on v5 (v6 config differs); v5.4.9 has Redis stability fixes |
| LiveKit server | **v1.13.1** | Pairs with `livekit_client` 2.8.1 |

---

## Flutter (`mobile/pubspec.yaml`)

All direct deps are **exact-pinned** to lockfile versions.

| Package | Version | Status |
|---------|---------|--------|
| flutter_riverpod | 3.3.2 | Stable — Riverpod 3.x |
| dio | 5.9.2 | Stable HTTP client |
| centrifuge | 0.20.0 | Correct Dart client (not the old `^5.x` npm-style package) |
| livekit_client | 2.8.1 | Compatible with LiveKit server 1.13.x |
| cryptography | 2.9.0 | E2EE (X25519 + AES-GCM) |
| flutter_secure_storage | 9.2.4 | **Stay on 9.x** — v10 is breaking |
| google_fonts | 6.3.3 | **Stay on 6.x** — v8 is major |
| intl | 0.20.2 | Matches Dart 3.11 |
| uuid | 4.5.3 | |
| gap | 3.0.1 | |
| cupertino_icons | 1.0.9 | |
| flutter_lints | 6.0.0 | Dev only |

### Intentionally NOT upgraded

| Package | Latest | Why kept |
|---------|--------|----------|
| flutter_secure_storage | 10.3.1 | Major API/platform rewrite |
| google_fonts | 8.1.0 | Major; 6.3.3 works fine |
| livekit_client | 2.8.x | Already latest 2.x; pinned exact |

---

## Backend (npm workspaces)

All service `package.json` files use **exact versions** matching `package-lock.json`.

### Core stack

| Package | Version | Fastify 5 compatible |
|---------|---------|----------------------|
| fastify | 5.8.5 | ✅ |
| @fastify/cors | 11.2.0 | ✅ |
| @fastify/jwt | 9.1.0 | ✅ (do **not** jump to 10.x yet) |
| @fastify/swagger | 9.7.0 | ✅ |
| @fastify/swagger-ui | 5.2.6 | ✅ (do **not** jump to 6.x yet) |
| @fastify/http-proxy | 11.5.0 | ✅ gateway only |
| @fastify/rate-limit | 11.0.0 | ✅ auth only |
| zod | 4.4.3 | Zod 4 — already in use, typecheck passes |
| pg | 8.21.0 | Stable 8.x |
| ioredis | 5.11.1 | auth only |
| pino | 9.14.0 | Fastify 5 accepts ^9 \|\| ^10 |
| typescript | 5.9.3 | Stay on 5.x (TS 6 is preview-grade) |
| tsx | 4.22.4 | |

### Intentionally NOT upgraded

| Package | Latest | Why kept |
|---------|--------|----------|
| @fastify/jwt | 10.1.0 | Major — needs migration testing |
| @fastify/swagger-ui | 6.0.0 | Major |
| typescript | 6.0.3 | Too new for production pin |
| pino | 10.3.1 | Works but unnecessary churn |
| dotenv | 17.x | 16.6.1 stable |

---

## Compatibility matrix (Phase 3)

```
Flutter centrifuge 0.20  →  Centrifugo v5.4.9  ✅
livekit_client 2.8.1     →  livekit-server 1.13.1  ✅ (protobuf protocol)
Fastify 5.8 + @fastify/* 11.x / 9.x / 5.x  ✅
Zod 4.4 + Fastify swagger  ✅
```

---

## Upgrade checklist (when needed)

1. Run `flutter pub outdated` / `npm outdated` — review **major** bumps only
2. Bump one stack at a time (e.g. Fastify plugins together)
3. Run `npm run typecheck` and `flutter analyze`
4. Re-test: auth, WS subscribe, group send, LiveKit call
5. Update this file and lockfiles in the same commit

---

## Commands

```bash
# Verify backend
cd backend && npm install && npm run typecheck

# Verify mobile
cd mobile && flutter pub get && flutter analyze
```
