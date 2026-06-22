export type RealtimeEvent =
  | {
      type: "message";
      envelopeId: string;
      conversationId: string;
      senderUserId: string;
      senderDeviceId: string;
      ciphertext: string;
      clientMessageId?: string | null;
    }
  | {
      type: "typing";
      conversationId: string;
      userId: string;
      isTyping: boolean;
    }
  | {
      type: "delivery";
      conversationId: string;
      userId: string;
      envelopeId: string;
      deliveredAt: string;
    }
  | {
      type: "receipt";
      conversationId: string;
      userId: string;
      envelopeId: string;
      readAt: string;
    }
  | {
      type: "call";
      callId: string;
      conversationId: string;
      roomName: string;
      callType: "voice" | "video";
      initiatorUserId: string;
    };

// Node 20's global fetch (undici) keeps connections alive per-origin, so
// repeated publishes to Centrifugo reuse the same TCP socket.
async function centrifugoApi(
  cfg: { apiUrl: string; apiKey: string },
  payload: unknown
): Promise<void> {
  const res = await fetch(cfg.apiUrl, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `apikey ${cfg.apiKey}`
    },
    body: JSON.stringify(payload)
  });
  if (!res.ok) {
    const text = await res.text().catch(() => "");
    throw new Error(`Centrifugo API failed: ${res.status} ${text}`);
  }
}

export async function publishToUserDevice(opts: {
  apiUrl: string;
  apiKey: string;
  userId: string;
  deviceId: string;
  data: RealtimeEvent;
}): Promise<void> {
  const channel = `user:${opts.userId}:${opts.deviceId}`;
  await centrifugoApi(
    { apiUrl: opts.apiUrl, apiKey: opts.apiKey },
    { method: "publish", params: { channel, data: opts.data } }
  );
}

export async function fanoutToDevices(
  cfg: { apiUrl: string; apiKey: string },
  targets: Array<{ userId: string; deviceId: string }>,
  data: RealtimeEvent,
  opts: { skipHistory?: boolean } = {}
): Promise<void> {
  if (targets.length === 0) return;
  // One HTTP call for every recipient device via Centrifugo's broadcast.
  // Ephemeral events (typing/delivery/receipt) skip history so they're never
  // replayed on recovery — only durable `message` events persist in history.
  const channels = targets.map((t) => `user:${t.userId}:${t.deviceId}`);
  await centrifugoApi(cfg, {
    method: "broadcast",
    params: { channels, data, skip_history: opts.skipHistory ?? false }
  });
}
