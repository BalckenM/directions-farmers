import type { NextFunction, Request, Response } from "express";
import { sendNoContent, sendOne } from "../../lib/response";
import { cattleService } from "../../services/cattle/cattle.service";

export const cattleWeightController = {

  listWeights: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(res, await cattleService.listWeightRecords(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  addWeight: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await cattleService.addWeightRecord(req.auth.farmOwnerId, req.body),
        201,
      );
    } catch (err) {
      next(err);
    }
  },

  deleteWeight: async (req: Request, res: Response, next: NextFunction) => {
    try {
      await cattleService.deleteWeightRecord(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
      );
      sendNoContent(res);
    } catch (err) {
      next(err);
    }
  },
};

