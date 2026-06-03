import type { NextFunction, Request, Response } from "express";
import { sendNoContent, sendOne } from "../../lib/response";
import { goatService } from "../../services/goat/goat.service";

export const goatWeightController = {
  listWeights: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(res, await goatService.listWeightRecords(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  createWeight: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await goatService.createWeightRecord(req.auth.farmOwnerId, req.body),
        201,
      );
    } catch (err) {
      next(err);
    }
  },

  deleteWeight: async (req: Request, res: Response, next: NextFunction) => {
    try {
      await goatService.deleteWeightRecord(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
      );
      sendNoContent(res);
    } catch (err) {
      next(err);
    }
  },
};

