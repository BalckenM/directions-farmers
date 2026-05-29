import type { NextFunction, Request, Response } from "express";
import { sendList, sendNoContent, sendOne } from "../../lib/response";
import { goatService } from "../../services/goat/goat.service";

export const goatShearingController = {
  listShearing: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(res, await goatService.listShearingRecords(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  createShearing: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await goatService.createShearingRecord(req.auth.farmOwnerId, req.body),
        201,
      );
    } catch (err) {
      next(err);
    }
  },
};

