import Redis from "ioredis";
import { env } from "../config/env";

/**
 * Shared Redis client for the application.
 * Used by: token revocation store, rate limiter, and any future caching needs.
 *
 * Falls back to in-memory behaviour if REDIS_URL is not configured
 * (LRU cache in token-store, built-in memory store in rate limiter).
 */
let redis: Redis | null = null;

export function getRedis(): Redis | null {
  if (redis) return redis;
  if (!env.REDIS_URL) return null;

  redis = new Redis(env.REDIS_URL, {
    maxRetriesPerRequest: 3,
    enableReadyCheck: true,
    lazyConnect: false,
  });

  redis.on("error", (err) => {
    console.error("[redis] connection error:", err.message);
  });

  return redis;
}

/**
 * Graceful shutdown — close Redis connection.
 */
export async function closeRedis(): Promise<void> {
  if (redis) {
    await redis.quit();
    redis = null;
  }
}
