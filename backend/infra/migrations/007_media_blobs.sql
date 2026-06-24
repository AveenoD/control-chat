-- Phase 5: E2EE media sharing.
-- Tracks encrypted blobs stored in S3-compatible object storage (MinIO/B2).
-- The blob bytes are client-side encrypted; the server only stores ciphertext
-- plus minimal metadata for access-control on download.

CREATE TABLE IF NOT EXISTS media_blobs (
  id              TEXT PRIMARY KEY,                 -- blobId == storage object key
  conversation_id TEXT NOT NULL,                    -- scopes who may download
  owner_user_id   UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  size_bytes      BIGINT NOT NULL,
  content_type    TEXT NOT NULL DEFAULT 'application/octet-stream',
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_media_blobs_conversation
  ON media_blobs (conversation_id, created_at DESC);
