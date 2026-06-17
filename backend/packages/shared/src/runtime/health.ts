export type HealthResponse = {
  ok: true;
  service: string;
  timestamp: string;
};

export function makeHealth(service: string): HealthResponse {
  return { ok: true, service, timestamp: new Date().toISOString() };
}

