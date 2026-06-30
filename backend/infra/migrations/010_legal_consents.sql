-- Legal consent records: append-only proof that a user accepted a specific
-- version of the Terms of Service / Privacy Policy, and when. We never delete
-- rows (audit trail). "Current consent" is derived by checking whether a row
-- exists for the user at the latest document version (see legal-routes.ts).

CREATE TABLE IF NOT EXISTS user_consents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  doc_type TEXT NOT NULL CHECK (doc_type IN ('tos', 'privacy')),
  version TEXT NOT NULL,
  accepted_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, doc_type, version)
);

CREATE INDEX IF NOT EXISTS idx_user_consents_user ON user_consents (user_id);
