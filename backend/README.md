# AuraTalk Backend (Phase 1)

Production-style Node.js + TypeScript backend scaffold for AuraTalk.

## Services (Phase 1)
- `auth-service`: dev OTP + JWT + device registration
- `user-service`: profiles + public key bundle endpoints
- `chat-relay-service`: encrypted message envelope ingest + fetch

## Local development (Docker Compose)
This repo includes a `docker-compose.yml` (added next) that runs:
- Postgres
- Redis
- Centrifugo (WebSocket)

## Notes
- This backend never stores plaintext messages; only encrypted envelopes + metadata.

