import type { NextFunction, Request, Response } from "express";
import { sendList, sendNoContent, sendOne } from "../../lib/response";
import { goatService } from "../../services/goat/goat.service";

export const goatPregnancyController = {
  listPregnancyChecks: async (
    req: Request,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      sendOne(
        res,
        await goatService.listPregnancyChecks(req.auth.farmOwnerId),
      );
    } catch (err) {
      next(err);
    }
  },

  createPregnancyCheck: async (
    req: Request,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      sendOne(
        res,
        await goatService.createPregnancyCheck(req.auth.farmOwnerId, req.body),
        201,
      );
    } catch (err) {
      next(err);
    }
  },
};

