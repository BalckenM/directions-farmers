import type { NextFunction, Request, Response } from "express";
import { sendOne } from "../lib/response";
import { insightsService } from "../services/insights.service";

export const insightsController = {
  getMarketPrices: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { commodity } = req.query as Record<string, string>;
      sendOne(res, insightsService.getMarketPrices(commodity));
    } catch (err) {
      next(err);
    }
  },
};
