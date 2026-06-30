-- Phase 4a: group management (members lifecycle, key rotation epochs, system events)

ALTER TABLE groups ADD COLUMN IF NOT EXISTS current_key_epoch INT NOT NULL DEFAULT 1;
ALTER TABLE groups ADD COLUMN IF NOT EXISTS needs_rekey BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE groups ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT now();

-- Server-recorded membership/lifecycle events ("X added Y", "X left", renamed, ...).
-- Plaintext metadata only (not message content) so it can render in the timeline
-- and back-fill on cold open without E2EE.
CREATE TABLE IF NOT EXISTS group_system_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  actor_user_id UUID NULL REFERENCES users(id) ON DELETE SET NULL,
  target_user_id UUID NULL REFERENCES users(id) ON DELETE SET NULL,
  meta JSONB NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_group_system_events_group
  ON group_system_events (group_id, created_at DESC);
