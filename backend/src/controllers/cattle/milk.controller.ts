import type { NextFunction, Request, Response } from "express";
import { sendNoContent, sendOne } from "../../lib/response";
import { cattleService } from "../../services/cattle/cattle.service";

export const cattleMilkController = {

  listMilk: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(res, await cattleService.listDailyMilk(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  addMilk: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await cattleService.addDailyMilk(req.auth.farmOwnerId, req.body),
        201,
      );
    } catch (err) {
      next(err);
    }
  },

  deleteMilk: async (req: Request, res: Response, next: NextFunction) => {
    try {
      await cattleService.deleteDailyMilk(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
      );
      sendNoContent(res);
    } catch (err) {
      next(err);
    }
  },
};

