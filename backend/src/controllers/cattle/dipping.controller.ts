import type { NextFunction, Request, Response } from "express";
import { sendOne } from "../../lib/response";
import { cattleService } from "../../services/cattle/cattle.service";

export const cattleDippingController = {

  listDipping: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(res, await cattleService.listDippingRecords(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  addDipping: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await cattleService.addDippingRecord(req.auth.farmOwnerId, req.body),
        201,
      );
    } catch (err) {
      next(err);
    }
  },
};

