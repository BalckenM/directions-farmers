import type { NextFunction, Request, Response } from "express";
import { sendNoContent, sendOne } from "../../lib/response";
import { cattleService } from "../../services/cattle/cattle.service";

export const cattleFeedController = {

  listFeed: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(res, await cattleService.listFeedRecords(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  addFeed: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await cattleService.addFeedRecord(req.auth.farmOwnerId, req.body),
        201,
      );
    } catch (err) {
      next(err);
    }
  },

  deleteFeed: async (req: Request, res: Response, next: NextFunction) => {
    try {
      await cattleService.deleteFeedRecord(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
      );
      sendNoContent(res);
    } catch (err) {
      next(err);
    }
  },
};

