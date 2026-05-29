import type { NextFunction, Request, Response } from "express";
import { sendNoContent, sendOne } from "../../lib/response";
import { cattleService } from "../../services/cattle/cattle.service";

export const cattleBreedingController = {

  listBreeding: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(res, await cattleService.listBreedingRecords(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  addBreeding: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await cattleService.addBreedingRecord(req.auth.farmOwnerId, req.body),
        201,
      );
    } catch (err) {
      next(err);
    }
  },

  updateBreeding: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await cattleService.updateBreedingRecord(
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

