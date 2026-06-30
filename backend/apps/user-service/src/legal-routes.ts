import type { Db } from "./db.js";
import { z } from "zod";
import { LEGAL_DOCUMENTS, TOS_VERSION, PRIVACY_VERSION } from "./legal.js";

/**
 * True when the user has on record an accepted consent for BOTH the current
 * ToS version and the current Privacy Policy version.
 */
export async function hasCurrentConsent(db: Db, userId: string): Promise<boolean> {
  const res = await db.query<{ tos: boolean | null; privacy: boolean | null }>(
    `
    SELECT
      bool_or(doc_type = 'tos' AND version = $2)     AS tos,
      bool_or(doc_type = 'privacy' AND version = $3) AS privacy
    FROM user_consents
    WHERE user_id = $1
    `,
    [userId, TOS_VERSION, PRIVACY_VERSION]
  );
  const r = res.rows[0];
  return !!(r && r.tos && r.privacy);
}

export function registerLegalRoutes(
  app: {
    get: (...args: any[]) => any;
    post: (...args: any[]) => any;
  },
  db: Db
) {
  // Both documents in one call (used to render the consent screen / settings).
  app.get("/legal/documents", async () => ({
    ok: true,
    documents: LEGAL_DOCUMENTS,
    versions: { tos: TOS_VERSION, privacy: PRIVACY_VERSION }
  }));

  // Whether the current user still needs to accept the latest documents.
  app.get("/legal/status", async (req: any) => {
    const userId = req.user.sub as string;
    const consentRequired = !(await hasCurrentConsent(db, userId));
    return {
      ok: true,
      consentRequired,
      tosVersion: TOS_VERSION,
      privacyVersion: PRIVACY_VERSION
    };
  });

  // Record acceptance. Only the current versions are accepted so we never store
  // consent for a stale document the user didn't actually see.
  app.post("/legal/consent", async (req: any, reply: any) => {
    const userId = req.user.sub as string;
    const body = z
      .object({ tosVersion: z.string().min(1), privacyVersion: z.string().min(1) })
      .parse(req.body);
    if (body.tosVersion !== TOS_VERSION || body.privacyVersion !== PRIVACY_VERSION) {
      return reply.code(409).send({
        ok: false,
        error: "Outdated document version",
        tosVersion: TOS_VERSION,
        privacyVersion: PRIVACY_VERSION
      });
    }
    await db.query(
      `
      INSERT INTO user_consents (user_id, doc_type, version)
      VALUES ($1, 'tos', $2), ($1, 'privacy', $3)
      ON CONFLICT (user_id, doc_type, version) DO NOTHING
      `,
      [userId, TOS_VERSION, PRIVACY_VERSION]
    );
    return reply.send({ ok: true });
  });

  // A single document by type (keep AFTER the static routes above).
  app.get("/legal/:type", async (req: any, reply: any) => {
    const params = z.object({ type: z.enum(["tos", "privacy"]) }).parse(req.params);
    return reply.send({ ok: true, document: LEGAL_DOCUMENTS[params.type] });
  });
}
