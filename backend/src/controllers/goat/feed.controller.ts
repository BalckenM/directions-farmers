import type { NextFunction, Request, Response } from "express";
import { sendNoContent, sendOne } from "../../lib/response";
import { goatService } from "../../services/goat/goat.service";

export const goatFeedController = {
  listFeed: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(res, await goatService.listFeedRecords(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  createFeed: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await goatService.createFeedRecord(req.auth.farmOwnerId, req.body),
        201,
      );
    } catch (err) {
      next(err);
    }
  },

  deleteFeed: async (req: Request, res: Response, next: NextFunction) => {
    try {
      await goatService.deleteFeedRecord(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
      );
      sendNoContent(res);
    } catch (err) {
      next(err);
    }
  },
};

