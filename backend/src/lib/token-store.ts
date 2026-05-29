import { LRUCache } from "lru-cache";
import { env } from "../config/env";

// Blocklist for invalidated refresh tokens (logout / rotation).
// TTL matches refresh token lifespan.
const store = new LRUCache<string, true>({
  max: 10_000,
  ttl: env.REFRESH_TOKEN_TTL * 1000,
});

export function revokeToken(jti: string): void {
  store.set(jti, true);
}

export function isRevoked(jti: string): boolean {
  return store.has(jti);
}
