# AuraTalk — Privacy & Chat Features Status

**Date:** 02-07-2026  
**Branch:** `anees-dev-legal-ToS`  
**Purpose:** Track which privacy/chat controls are live vs still to build (from product review).

---

## ✅ Already implemented (top)

### Core app (Phases 1–3 + recent polish)

| Feature | Notes |
|---------|--------|
| Phone OTP + `@username` onboarding | Phase 2 |
| 1:1 E2EE chat (X25519 + AES-GCM) | Client-side encrypt; server stores ciphertext |
| Groups + group E2EE (shared key MVP) | Create, members, admin actions |
| Realtime (Centrifugo) | Messages, typing, receipts, calls |
| Read receipts toggle | Global privacy setting; sender/respect on wire |
| Typing indicators toggle | Global privacy setting |
| Chat list unread badges + previews | Local DB + bottom-nav dot |
| Typing… in chat list preview | Global `TypingService` |
| Message requests (accept / decline) | Profile → Message requests |
| Block / Report | Safety flows |
| Voice / video calls (LiveKit dev) | Phase 3 |
| Legal signup (ToS + Privacy consent) | Gate on login |
| Group extras | @mentions, seen-by, invite links, group avatar |
| View once messages | Photo / video / text; server consume on open |
| Disappearing messages | Per-conversation timer (`conversationSettings`) |
| Hide phone from non-contacts | Profile lookup; phone not exposed by username |
| Hide phone from group members (setting) | Toggle in Privacy Settings |
| Groups show username, not phone | API returns `username` / `display_name` only; UI shows `@username` |
| Global screenshot block | Privacy Settings → FLAG_SECURE (whole app / device) |
| View-once extra protection | Forces secure flag while media is open |
| App switcher / background blur | `PrivacyShield` — blur when app leaves foreground |
| Show online status toggle | Privacy Settings |
| Allow file downloads toggle (UI + backend store) | Saved in `privacy_settings`; **not enforced in chat UI yet** |

---

## ❌ Not implemented yet

### Per-chat & media controls

| Feature | Target behaviour | Current gap |
|---------|------------------|-------------|
| Per-chat screenshot allow/block | User turns off screenshots for a specific chat | Only **global** screen security exists |
| Allow sharing control | Sender/recipient can block forward/share of media | No control |
| Allow download control (enforced) | Respect `allowDownload` when opening/saving files | Toggle exists but **file open/download ignores it** |
| Allow screenshot control (per chat / per user) | Policy per conversation or contact | Not built |
| Per-chat blur toggle | Blur only selected threads in list or thread | Only global `PrivacyShield` |
| Chat list preview blur | Obscure last message in list until unlock | Not built |

### Message requests (Instagram / WhatsApp style)

| Feature | Target behaviour | Current gap |
|---------|------------------|-------------|
| One intro message then send disabled | Unknown user sends **1** message; composer disabled until accept | **Full block** until request accepted + mutual contact; no free first message in chat |
| Intro message as real delivered chat | First message lands in recipient inbox | `intro_message` stored on request row only, not as E2EE chat message |
| `requireMessageRequest` enforced on send | Backend respects user privacy flag | Stored in settings; **not wired** into relay send policy |

### Screenshot detection & notify

| Feature | Target behaviour | Current gap |
|---------|------------------|-------------|
| Notify when screenshot taken | Recipient/sender sees “X took a screenshot” | Not built |
| Notify on screenshot **attempt** when blocked | User A disabled screenshots; B tries → A gets “tried to screenshot” | Not built |
| iOS attempt detection | Best-effort where OS allows | Not built (Android FLAG_SECURE only) |

### Chat actions & polish (related backlog)

| Feature | Status |
|---------|--------|
| Delete for everyone (1:1 unsend) | ❌ |
| Chat list search (functional) | ❌ Placeholder UI only |
| FCM push notifications | ❌ |
| Mute conversations | ❌ |
| Stories / Home feed | ❌ Phase 4 |

---

## ⚠️ Partial / needs completion

| Item | Done | Missing |
|------|------|---------|
| Allow file downloads | Setting saved | Enforce on `_ChatFile` / media save paths |
| Blur | Global on background | Per-chat + list preview options |
| Message requests | Accept/decline + intro field | 1-message model + deliver intro as chat |
| Screenshot privacy | Global + view-once window | Per-chat, notify, attempt detection |
| `requireMessageRequest` | UI toggle | Backend `canDirectMessage` / relay gate |

---

## Suggested build order (optional)

1. **1 intro message** message-request model + relay gate  
2. **Enforce `allowDownload`** in media/file UI  
3. **Per-chat privacy overrides** (screenshot, download, share) in `conversationSettings`  
4. **Screenshot notify** (Android detect where possible + realtime event)  
5. Delete for everyone, FCM, mute  

---

*Last updated: 02-07-2026*
