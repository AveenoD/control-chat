## [02-07-2026 12:00] — Todays task: privacy features status doc

**What changed:** Added `Todays task/privacy-features-status-02-07-2026.md` listing implemented privacy/chat features at top and pending items (per-chat screenshot, download enforce, 1-message request, screenshot notify, etc.) with date 02-07-2026.
**Files touched:** `Todays task/privacy-features-status-02-07-2026.md`
**API endpoints used:** None
**Breaking change:** NO
**Branch:** anees-dev-legal-ToS

---

## [01-07-2026 19:35] — Fix unread badges after leaving chat

**What changed:** Fixed `activeConversationIdProvider` not clearing when backing out of a chat thread (protected `.state` assignment + missing pop handler), which caused the app to think the chat was still open and skip unread-badge increments for new messages.
**Files touched:** `mobile/lib/core/chat/active_conversation.dart`, `mobile/lib/ui/chats/chat_thread_screen.dart`
**API endpoints used:** None
**Breaking change:** NO
**Branch:** anees-dev-legal-ToS

---

## [01-07-2026 19:15] — Typing indicator in chat list preview

**What changed:** Chat list now shows italic "typing…" in the message preview when the other person is typing (WhatsApp-style), via a global `TypingService` + `peerTypingProvider`; clears when a message arrives; thread screen reuses the same provider.
**Files touched:** `mobile/lib/core/chat/typing_service.dart`, `mobile/lib/core/chat/incoming_message_service.dart`, `mobile/lib/ui/shell/app_shell.dart`, `mobile/lib/ui/tabs/chats/chats_screen.dart`, `mobile/lib/ui/chats/chat_thread_screen.dart`
**API endpoints used:** None
**Breaking change:** NO
**Branch:** anees-dev-legal-ToS

---

## [01-07-2026 18:22] — Fix Riverpod provider modify during build

**What changed:** Deferred `activeConversationIdProvider` set/clear out of `initState`/`dispose` (post-frame + microtask) to fix the red-screen "Tried to modify a provider while the widget tree was building" crash on chat open.
**Files touched:** `mobile/lib/ui/chats/chat_thread_screen.dart`
**API endpoints used:** None
**Breaking change:** NO
**Branch:** anees-dev-legal-ToS

---


**What changed:** Started Pixel 7 and Pixel 8 Android emulators (`emulator-5554`, `emulator-5556`) and installed the latest debug APK on both for testing chat-list polish.
**Files touched:** None
**API endpoints used:** None
**Breaking change:** NO
**Branch:** anees-dev-legal-ToS

---

## [01-07-2026 15:45] — Chat list polish: unread badges + previews

**What changed:** Added per-chat unread badges (tile + bottom-nav Chats dot), real decrypted message previews on the chat list (text/photo/voice/file labels; group sender prefix), local preview updates on send/receive, removed "E2EE" subtitle from group thread header and group info, bold styling for unread chats, and backend group list sorting by last message time instead of group creation date.
**Files touched:** `mobile/lib/core/db/app_database.dart`, `mobile/lib/core/db/message_store.dart`, `mobile/lib/core/chat/chat_models.dart`, `mobile/lib/core/chat/message_preview.dart`, `mobile/lib/core/chat/active_conversation.dart`, `mobile/lib/core/chat/incoming_message_service.dart`, `mobile/lib/ui/tabs/chats/chats_screen.dart`, `mobile/lib/ui/shell/app_shell.dart`, `mobile/lib/ui/chats/chat_thread_screen.dart`, `mobile/lib/ui/chats/group_info_screen.dart`, `backend/apps/chat-relay-service/src/server.ts`
**API endpoints used:** None (client-local unread; existing `GET /conversations` group sort fix only)
**Breaking change:** NO
**Branch:** anees-dev-legal-ToS

---
