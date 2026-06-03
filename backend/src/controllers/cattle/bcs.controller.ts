import type { NextFunction, Request, Response } from "express";
import { sendOne } from "../../lib/response";
import { cattleService } from "../../services/cattle/cattle.service";

export const cattleBcsController = {

  listBcs: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(res, await cattleService.listBcsRecords(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  addBcs: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await cattleService.addBcsRecord(req.auth.farmOwnerId, req.body),
        201,
      );
    } catch (err) {
      next(err);
    }
  },
};

