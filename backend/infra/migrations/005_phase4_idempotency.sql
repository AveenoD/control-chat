-- Phase 4 (Reliability): fast lookup for send idempotency / outbox retries.
-- A retried message (same client_message_id) is detected via this index so we
-- never insert or fan-out a duplicate.
CREATE INDEX IF NOT EXISTS idx_message_envelopes_idempotency
  ON message_envelopes (conversation_id, sender_user_id, client_message_id);
