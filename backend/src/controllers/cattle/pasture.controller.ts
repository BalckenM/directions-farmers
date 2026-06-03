import type { NextFunction, Request, Response } from "express";
import { sendOne } from "../../lib/response";
import { cattleService } from "../../services/cattle/cattle.service";

export const cattlePastureController = {

  listPasture: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(res, await cattleService.listPastureRecords(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  addPasture: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await cattleService.addPastureRecord(req.auth.farmOwnerId, req.body),
        201,
      );
    } catch (err) {
      next(err);
    }
  },

  exitPasture: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await cattleService.exitPasture(
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

