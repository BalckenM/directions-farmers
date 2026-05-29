import { NextFunction, Request, Response } from "express";
import { verifyToken } from "../lib/jwt";
import { sendError } from "../lib/response";

export async function authMiddleware(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  const header = req.headers.authorization;
  if (!header || !header.startsWith("Bearer ")) {
    sendError(
      res,
      401,
      "UNAUTHORIZED",
      "Missing or invalid Authorization header",
    );
    return;
  }

  const token = header.slice(7);
  try {
    const payload = await verifyToken(token);

    const farmOwnerId =
      payload.subType === "owner" ? payload.sub : payload.farmId;

    req.auth = {
      sub: payload.sub,
      subType: payload.subType,
      farmId: payload.farmId,
      modules: payload.modules,
      role: payload.role,
      farmOwnerId,
    };

    next();
  } catch {
    sendError(res, 401, "INVALID_TOKEN", "Token is invalid or expired");
  }
}

export const authenticate = authMiddleware;
