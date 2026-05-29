import type { NextFunction, Request, Response } from "express";
import { sendList, sendOne } from "../lib/response";
import { recordService } from "../services/record.service";

export const recordController = {
  listFeedLogs: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await recordService.list(
        req.auth.farmOwnerId,
        req.query as Record<string, unknown>,
      );
      sendList(res, result.data, result.meta);
    } catch (err) {
      next(err);
    }
  },

  addFeedLog: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(res, await recordService.add(req.auth.farmOwnerId, req.body), 201);
    } catch (err) {
      next(err);
    }
  },
};
