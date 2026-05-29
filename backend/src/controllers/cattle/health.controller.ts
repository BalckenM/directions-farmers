import type { NextFunction, Request, Response } from "express";
import { sendNoContent, sendOne } from "../../lib/response";
import { cattleService } from "../../services/cattle/cattle.service";

export const cattleHealthController = {

  listHealth: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(res, await cattleService.listHealthEvents(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  addHealth: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await cattleService.addHealthEvent(req.auth.farmOwnerId, req.body),
        201,
      );
    } catch (err) {
      next(err);
    }
  },

  updateHealth: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await cattleService.updateHealthEvent(
          req.auth.farmOwnerId,
          (req.params as Record<string, string>)["id"],
          req.body,
        ),
      );
    } catch (err) {
      next(err);
    }
  },
};

