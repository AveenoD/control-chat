-- Group invite links: a shareable token that lets any signed-in user join a
-- group without an admin manually adding them. Tokens are opaque, revocable,
-- and (optionally) expirable. Joining adds the caller as a member; the group
-- key is then healed to their device by the normal distribution path.

CREATE TABLE IF NOT EXISTS group_invites (
  token TEXT PRIMARY KEY,
  group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  created_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at TIMESTAMPTZ NULL,
  revoked BOOLEAN NOT NULL DEFAULT false
);

-- One quick lookup of the active (non-revoked) token(s) per group.
CREATE INDEX IF NOT EXISTS idx_group_invites_group
  ON group_invites (group_id)
  WHERE revoked = false;
