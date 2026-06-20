import type { Db } from "./db.js";

export async function isBlocked(db: Db, userA: string, userB: string): Promise<boolean> {
  const res = await db.query(
    `
    SELECT 1 FROM user_blocks
    WHERE (blocker_user_id = $1 AND blocked_user_id = $2)
       OR (blocker_user_id = $2 AND blocked_user_id = $1)
    LIMIT 1
    `,
    [userA, userB]
  );
  return (res.rowCount ?? 0) > 0;
}

/** Sender may send only if recipient is in sender's saved contacts and not blocked. */
export async function canDirectMessage(
  db: Db,
  fromUserId: string,
  toUserId: string
): Promise<boolean> {
  if (fromUserId === toUserId) return false;
  if (await isBlocked(db, fromUserId, toUserId)) return false;
  const res = await db.query(
    `SELECT 1 FROM contacts WHERE owner_user_id = $1 AND contact_user_id = $2 LIMIT 1`,
    [fromUserId, toUserId]
  );
  return (res.rowCount ?? 0) > 0;
}

/** Either side saved the other — enough to open a 1:1 thread after request accept. */
export async function canAccessConversation(
  db: Db,
  userId: string,
  peerUserId: string
): Promise<boolean> {
  if (userId === peerUserId) return false;
  if (await isBlocked(db, userId, peerUserId)) return false;
  const res = await db.query(
    `
    SELECT 1 FROM contacts
    WHERE (owner_user_id = $1 AND contact_user_id = $2)
       OR (owner_user_id = $2 AND contact_user_id = $1)
    LIMIT 1
    `,
    [userId, peerUserId]
  );
  return (res.rowCount ?? 0) > 0;
}

export function directConversationId(userA: string, userB: string): string {
  const [a, b] = [userA, userB].sort();
  return `dm:${a}:${b}`;
}

export function groupConversationId(groupId: string): string {
  return `group:${groupId}`;
}

export function parseConversationId(conversationId: string): {
  kind: "dm" | "group";
  groupId?: string;
} | null {
  if (conversationId.startsWith("group:")) {
    return { kind: "group", groupId: conversationId.slice("group:".length) };
  }
  const parts = conversationId.split(":");
  if (parts.length === 3 && parts[0] === "dm") return { kind: "dm" };
  return null;
}

export async function isGroupMember(db: Db, groupId: string, userId: string): Promise<boolean> {
  const res = await db.query(
    `SELECT 1 FROM group_members WHERE group_id = $1 AND user_id = $2 LIMIT 1`,
    [groupId, userId]
  );
  return (res.rowCount ?? 0) > 0;
}

export async function canAccessGroup(db: Db, groupId: string, userId: string): Promise<boolean> {
  return isGroupMember(db, groupId, userId);
}

export async function listGroupMemberUserIds(db: Db, groupId: string): Promise<string[]> {
  const res = await db.query<{ user_id: string }>(
    `SELECT user_id FROM group_members WHERE group_id = $1`,
    [groupId]
  );
  return res.rows.map((r) => r.user_id);
}

export async function listMemberDevices(
  db: Db,
  userIds: string[]
): Promise<Array<{ userId: string; deviceId: string }>> {
  if (userIds.length === 0) return [];
  const res = await db.query<{ user_id: string; device_id: string }>(
    `
    SELECT user_id, device_id
    FROM device_keys
    WHERE user_id = ANY($1::uuid[])
    ORDER BY user_id, updated_at DESC
    `,
    [userIds]
  );
  return res.rows.map((r) => ({ userId: r.user_id, deviceId: r.device_id }));
}

export function peerUserIdFromConversation(
  conversationId: string,
  currentUserId: string
): string | null {
  const parts = conversationId.split(":");
  if (parts.length !== 3 || parts[0] !== "dm") return null;
  const [idA, idB] = [parts[1]!, parts[2]!];
  if (idA === currentUserId) return idB;
  if (idB === currentUserId) return idA;
  return null;
}

export async function userAllowsReadReceipts(db: Db, userId: string): Promise<boolean> {
  const res = await db.query<{ privacy_settings: { readReceipts?: boolean } }>(
    `SELECT privacy_settings FROM users WHERE id = $1`,
    [userId]
  );
  return res.rows[0]?.privacy_settings?.readReceipts !== false;
}

export async function userAllowsTyping(db: Db, userId: string): Promise<boolean> {
  const res = await db.query<{ privacy_settings: { typingIndicators?: boolean } }>(
    `SELECT privacy_settings FROM users WHERE id = $1`,
    [userId]
  );
  return res.rows[0]?.privacy_settings?.typingIndicators !== false;
}
