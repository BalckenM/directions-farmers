import rateLimit from "express-rate-limit";
import { sendError } from "../lib/response";

const buildLimiter = (max: number, windowMinutes: number) =>
  rateLimit({
    windowMs: windowMinutes * 60 * 1000,
    max,
    standardHeaders: true,
    legacyHeaders: false,
    handler: (_req, res) => {
      sendError(
        res,
        429,
        "RATE_LIMIT_EXCEEDED",
        "Too many requests, please try again later",
      );
    },
  });

export const authLoginLimiter = buildLimiter(10, 15);
export const authGeneralLimiter = buildLimiter(30, 15);
export const globalLimiter = buildLimiter(120, 1);
