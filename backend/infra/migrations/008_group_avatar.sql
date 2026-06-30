-- Group avatar: an (E2EE) image blob shown for the group in lists/headers.
-- The image bytes live in object storage as ciphertext (reuses media_blobs).
-- avatar_key is the AES key for that blob; it is returned only to members via
-- the authenticated group endpoints, so access stays gated by membership.

ALTER TABLE groups ADD COLUMN IF NOT EXISTS avatar_blob_id TEXT NULL;
ALTER TABLE groups ADD COLUMN IF NOT EXISTS avatar_key TEXT NULL;
