import type { NextFunction, Request, Response } from "express";
import { sendOne } from "../../lib/response";
import { cattleService } from "../../services/cattle/cattle.service";

export const cattlePregnancyController = {

  listPregnancyChecks: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(res, await cattleService.listPregnancyChecks(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  addPregnancyCheck: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await cattleService.addPregnancyCheck(req.auth.farmOwnerId, req.body),
        201,
      );
    } catch (err) {
      next(err);
    }
  },
};

