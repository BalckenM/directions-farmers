import type { NextFunction, Request, Response } from "express";
import { sendNoContent, sendOne } from "../../lib/response";
import { cattleService } from "../../services/cattle/cattle.service";

export const cattleCalvingController = {

  listCalvingEvents: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(res, await cattleService.listCalvingEvents(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  addCalvingEvent: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await cattleService.addCalvingEvent(req.auth.farmOwnerId, req.body),
        201,
      );
    } catch (err) {
      next(err);
    }
  },
};

