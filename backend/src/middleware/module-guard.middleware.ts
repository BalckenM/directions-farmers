import { NextFunction, Request, Response } from "express";
import { sendError } from "../lib/response";

export function requireModule(module: string) {
  return (req: Request, res: Response, next: NextFunction): void => {
    if (!req.auth) {
      sendError(res, 401, "UNAUTHORIZED", "Authentication required");
      return;
    }
    if (!req.auth.modules.includes(module)) {
      sendError(
        res,
        403,
        "MODULE_NOT_ACTIVE",
        `Module '${module}' is not active on your subscription`,
      );
      return;
    }
    next();
  };
}
