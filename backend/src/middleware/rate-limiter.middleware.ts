import rateLimit from "express-rate-limit";
import RedisStore from "rate-limit-redis";
import { sendError } from "../lib/response";
import { getRedis } from "../lib/redis";

const buildLimiter = (max: number, windowMinutes: number) => {
  const redis = getRedis();

  return rateLimit({
    windowMs: windowMinutes * 60 * 1000,
    max,
    standardHeaders: true,
    legacyHeaders: false,
    // Use Redis store if available; otherwise falls back to built-in memory store
    ...(redis
      ? {
          store: new RedisStore({
            // @ts-expect-error - ioredis sendCommand is compatible
            sendCommand: (...args: string[]) => redis.call(...args),
            prefix: "rl:",
          }),
        }
      : {}),
    handler: (_req, res) => {
      sendError(
        res,
        429,
        "RATE_LIMIT_EXCEEDED",
        "Too many requests, please try again later",
      );
    },
  });
};

export const authLoginLimiter = buildLimiter(10, 15);
export const authGeneralLimiter = buildLimiter(30, 15);
export const globalLimiter = buildLimiter(120, 1);
