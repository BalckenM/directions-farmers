import { randomUUID } from "crypto";
import { NextFunction, Request, Response } from "express";

/**
 * Assigns a unique request ID to every incoming request.
 * - Uses the client-supplied `X-Request-ID` header if present (for traceability across services).
 * - Otherwise generates a new UUID v4.
 * - Exposes the ID in the response header for client-side correlation.
 */
export function requestIdMiddleware(
  req: Request,
  res: Response,
  next: NextFunction,
): void {
  const requestId =
    (req.headers["x-request-id"] as string | undefined) || randomUUID();
  req.id = requestId;
  res.setHeader("X-Request-ID", requestId);
  next();
}
