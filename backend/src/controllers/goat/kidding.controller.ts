import type { NextFunction, Request, Response } from "express";
import { sendList, sendNoContent, sendOne } from "../../lib/response";
import { goatService } from "../../services/goat/goat.service";

export const goatKiddingController = {
  listKidding: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(res, await goatService.listKiddingEvents(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  createKidding: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await goatService.createKiddingEvent(req.auth.farmOwnerId, req.body),
        201,
      );
    } catch (err) {
      next(err);
    }
  },
};

