import type { NextFunction, Request, Response } from "express";
import { sendNoContent, sendOne } from "../../lib/response";
import { goatService } from "../../services/goat/goat.service";

export const goatMilkController = {
  listMilk: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(res, await goatService.listDailyMilk(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  createMilk: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await goatService.createDailyMilk(req.auth.farmOwnerId, req.body),
        201,
      );
    } catch (err) {
      next(err);
    }
  },

  deleteMilk: async (req: Request, res: Response, next: NextFunction) => {
    try {
      await goatService.deleteDailyMilk(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
      );
      sendNoContent(res);
    } catch (err) {
      next(err);
    }
  },
};

