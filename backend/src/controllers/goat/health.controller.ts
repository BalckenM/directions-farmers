import type { NextFunction, Request, Response } from "express";
import { sendList, sendNoContent, sendOne } from "../../lib/response";
import { goatService } from "../../services/goat/goat.service";

export const goatHealthController = {
  listHealth: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(res, await goatService.listHealthEvents(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  createHealth: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await goatService.createHealthEvent(req.auth.farmOwnerId, req.body),
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
        await goatService.updateHealthEvent(
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

