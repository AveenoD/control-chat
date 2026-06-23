-- Phase: robust multi-device E2EE.
--
-- A single logical message now fans out to ONE encrypted envelope per recipient
-- device (and per sender device, for self-read / multi-device sync). All those
-- per-device rows share a stable `message_id` so delivery/read receipts and the
-- client UI can refer to one logical message regardless of which device's copy
-- they hold.
ALTER TABLE message_envelopes ADD COLUMN IF NOT EXISTS message_id UUID;

-- Backfill existing rows: each old envelope was its own logical message.
UPDATE message_envelopes SET message_id = id WHERE message_id IS NULL;

-- Fetch is now device-scoped (each device only pulls the envelopes addressed to
-- it), so this composite index backs the hot read path.
CREATE INDEX IF NOT EXISTS idx_message_envelopes_recipient_device
  ON message_envelopes (conversation_id, recipient_user_id, recipient_device_id, created_at DESC);

-- Receipts / pagination look messages up by their logical id.
CREATE INDEX IF NOT EXISTS idx_message_envelopes_message_id
  ON message_envelopes (message_id);
