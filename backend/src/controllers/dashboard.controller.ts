import type { NextFunction, Request, Response } from "express";
import { sendOne } from "../lib/response";
import { dashboardService } from "../services/dashboard.service";

export const dashboardController = {
  getSummary: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(res, await dashboardService.getSummary(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },
};
