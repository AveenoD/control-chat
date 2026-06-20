# AuraTalk — Execution Phases

> Last updated: 2026-06-19  
> Zones deferred to Phase 5 (most complex). Username globally unique. Message requests for non-contacts only.

---

## Phase 1 — Foundation ✅ (mostly complete)

- Backend: auth, user, chat-relay, gateway, Postgres, Redis, Centrifugo
- Flutter: AuraTalk theme, 5-tab shell, UI mockups
- OpenAPI + Changelog

**Remaining:** Flutter ↔ gateway auth wiring (continues in Phase 2).

---

## Phase 2 — Identity + Privacy Core ✅ (complete)

**Goal:** Username identity, message requests, privacy controls, functional 1:1 chat path.

| Feature | Status |
|---------|--------|
| Onboarding | ✅ Phone OTP + `@username` |
| Public profile | ✅ By username only — no phone |
| Contacts + message requests | ✅ |
| Privacy Control Center | ✅ |
| E2EE 1:1 | ✅ X25519 + AES-GCM (client-side; server stores ciphertext) |
| Chats tab | ✅ List, thread, send/receive, new chat |
| Message gate on send | ✅ Contacts required (chat-relay enforced) |

**Note:** Full Signal Double Ratchet planned as upgrade path; current stack is production-grade transport E2EE MVP.

---

## Phase 3 — Groups + Realtime + Calls ✅ (complete)

| Feature | Status |
|---------|--------|
| Private E2EE groups (shared key MVP) | ✅ |
| Group UI + create flow | ✅ |
| Centrifugo realtime (message, typing, receipt, call) | ✅ |
| Read receipts + typing (privacy toggles) | ✅ |
| Voice/video (LiveKit dev) | ✅ |
| Report + Block | ✅ |

**Note:** Group E2EE uses admin-distributed symmetric key; upgrade path to sender keys / MLS later.

---

## Phase 4 — Social (pre-Zones)

- E2EE Stories (24h)
- Home feed + stories row
- Screenshot block/detect, chat blur
- Legal signup: ToS + Privacy consent

---

## Phase 5 — Zones (end — biggest)

- Public / Private Zones
- **Username only** in Zone UI — phone never shown
- Shield Levels (Open / Guarded / Fortress)
- Immutable Zone posts
- Moderation + exam-season protocol

---

## Phase 6 — Launch hardening

- Grievance / appeals in-app
- CSAM client hash check
- DPDP data export / delete
- Transparency reports
- Scale (ScyllaDB, NATS) as traffic grows

---

## Feature → Phase map

| Feature | Phase |
|---------|-------|
| Globally unique @username | 2 |
| Message request (non-contacts) | 2 / 3 groups |
| Hide phone / username-only public | 2 |
| File download control | 2 |
| Privacy Control Center | 2 |
| E2EE 1:1 | 2 |
| Groups | 3 |
| Calls | 3 |
| Stories / Home | 4 |
| Zones | 5 |
