import pg from "pg";

export type Db = pg.Pool;

export function createDb(databaseUrl: string): Db {
  const pool = new pg.Pool({
    connectionString: databaseUrl,
    max: 20,
    min: 4,
    idleTimeoutMillis: 60_000,
    connectionTimeoutMillis: 2_000,
    keepAlive: true,
    statement_timeout: 3_000
  });

  // Warm the pool at boot so the first message after idle doesn't pay the
  // TLS/connect handshake cost (the "send → wait 13s → fast after" symptom).
  void Promise.allSettled([1, 2, 3, 4].map(() => pool.query("SELECT 1")));

  return pool;
}
