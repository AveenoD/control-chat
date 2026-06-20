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

export async function publishToUserDevice(opts: {
  apiUrl: string;
  apiKey: string;
  userId: string;
  deviceId: string;
  data: RealtimeEvent;
}): Promise<void> {
  const channel = `user:${opts.userId}:${opts.deviceId}`;
  const res = await fetch(opts.apiUrl, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `apikey ${opts.apiKey}`
    },
    body: JSON.stringify({
      method: "publish",
      params: { channel, data: opts.data }
    })
  });
  if (!res.ok) {
    const text = await res.text().catch(() => "");
    throw new Error(`Centrifugo publish failed: ${res.status} ${text}`);
  }
}

export async function fanoutToDevices(
  cfg: { apiUrl: string; apiKey: string },
  targets: Array<{ userId: string; deviceId: string }>,
  data: RealtimeEvent
): Promise<void> {
  await Promise.allSettled(
    targets.map((t) =>
      publishToUserDevice({
        apiUrl: cfg.apiUrl,
        apiKey: cfg.apiKey,
        userId: t.userId,
        deviceId: t.deviceId,
        data
      })
    )
  );
}
