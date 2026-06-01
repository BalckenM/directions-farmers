import { LRUCache } from "lru-cache";
import { env } from "../config/env";
import { getRedis } from "./redis";

// ─── Redis key prefix ────────────────────────────────────────────────────────
const REVOKED_PREFIX = "revoked:";

// ─── Fallback in-memory store (development / no-Redis) ───────────────────────
const memStore = new LRUCache<string, true>({
  max: 10_000,
  ttl: env.REFRESH_TOKEN_TTL * 1000,
});

/**
 * Mark a token (by its jti) as revoked.
 * Stored in Redis with automatic expiry matching the refresh token TTL,
 * so entries self-clean. Falls back to in-memory LRU if Redis unavailable.
 */
export async function revokeToken(jti: string): Promise<void> {
  const redis = getRedis();
  if (redis) {
    await redis.set(
      `${REVOKED_PREFIX}${jti}`,
      "1",
      "EX",
      env.REFRESH_TOKEN_TTL,
    );
  } else {
    memStore.set(jti, true);
  }
}

/**
 * Check whether a token (by jti) has been revoked.
 */
export async function isRevoked(jti: string): Promise<boolean> {
  const redis = getRedis();
  if (redis) {
    const val = await redis.exists(`${REVOKED_PREFIX}${jti}`);
    return val === 1;
  }
  return memStore.has(jti);
}

