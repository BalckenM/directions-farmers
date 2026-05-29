import type { NextFunction, Request, Response } from "express";
import { sendOne } from "../lib/response";
import { farmService } from "../services/farm.service";

export const settingsController = {
  getPaddocks: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(res, await farmService.getPaddocks(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },
};
