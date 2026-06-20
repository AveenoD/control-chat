-- Phase 2: faster conversation list queries

CREATE INDEX IF NOT EXISTS idx_message_envelopes_sender
  ON message_envelopes (sender_user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_message_envelopes_conversation_participants
  ON message_envelopes (conversation_id, created_at DESC);
