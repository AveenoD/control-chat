import {
  S3Client,
  PutObjectCommand,
  GetObjectCommand,
  DeleteObjectCommand
} from "@aws-sdk/client-s3";
import type { Readable } from "node:stream";

export interface MediaStoreConfig {
  S3_ENDPOINT: string;
  S3_REGION: string;
  S3_BUCKET: string;
  S3_ACCESS_KEY_ID: string;
  S3_SECRET_ACCESS_KEY: string;
  S3_FORCE_PATH_STYLE: boolean;
}

export interface MediaStore {
  put(key: string, body: Buffer, contentType?: string): Promise<void>;
  get(key: string): Promise<Readable>;
  del(key: string): Promise<void>;
}

/**
 * Thin S3-compatible blob store. Works with MinIO (dev) and Backblaze B2 (prod)
 * unchanged — only env differs. We always store opaque, client-side encrypted
 * bytes here; the server never sees plaintext or holds any decryption key.
 */
export function createMediaStore(cfg: MediaStoreConfig): MediaStore {
  const s3 = new S3Client({
    region: cfg.S3_REGION,
    endpoint: cfg.S3_ENDPOINT,
    forcePathStyle: cfg.S3_FORCE_PATH_STYLE,
    credentials: {
      accessKeyId: cfg.S3_ACCESS_KEY_ID,
      secretAccessKey: cfg.S3_SECRET_ACCESS_KEY
    }
  });

  return {
    async put(key, body, contentType) {
      await s3.send(
        new PutObjectCommand({
          Bucket: cfg.S3_BUCKET,
          Key: key,
          Body: body,
          ContentType: contentType ?? "application/octet-stream"
        })
      );
    },
    async get(key) {
      const res = await s3.send(
        new GetObjectCommand({ Bucket: cfg.S3_BUCKET, Key: key })
      );
      return res.Body as Readable;
    },
    async del(key) {
      await s3.send(new DeleteObjectCommand({ Bucket: cfg.S3_BUCKET, Key: key }));
    }
  };
}
