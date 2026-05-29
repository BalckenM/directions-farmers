import { randomUUID } from "crypto";
import { NextFunction, Request, Response } from "express";
import { db } from "../config/database";
import { auditLogs } from "../db/schema";

export function audit(action: string, resource: string) {
  return async (
    req: Request,
    _res: Response,
    next: NextFunction,
  ): Promise<void> => {
    if (req.auth) {
      const farmOwnerId = req.auth.farmOwnerId;
      const resourceId = (req.params as Record<string, string>)["id"] ?? null;

      db.insert(auditLogs)
        .values({
          id: randomUUID(),
          farmOwnerId,
          actorId: req.auth.sub,
          actorType: req.auth.subType,
          action,
          resource,
          resourceId,
          oldValues: null,
          newValues: null,
          ipAddress: req.ip ?? null,
          createdAt: new Date(),
        })
        .catch(() => {
          // Non-blocking — log failure silently
        });
    }
    next();
  };
}
