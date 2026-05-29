import type { NextFunction, Request, Response } from "express";
import { sendList, sendOne } from "../lib/response";
import { traceabilityService } from "../services/traceability.service";

export const traceabilityController = {
  listMovements: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await traceabilityService.list(
        req.auth.farmOwnerId,
        req.query as Record<string, unknown>,
      );
      sendList(res, result.data, result.meta);
    } catch (err) {
      next(err);
    }
  },

  addMovement: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await traceabilityService.add(req.auth.farmOwnerId, req.body),
        201,
      );
    } catch (err) {
      next(err);
    }
  },
};
