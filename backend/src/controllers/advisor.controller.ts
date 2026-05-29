import type { NextFunction, Request, Response } from "express";
import { sendOne } from "../lib/response";
import { advisorService } from "../services/advisor.service";

export const advisorController = {
  getAdvice: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { topic = "general" } = req.body as { topic?: string };
      sendOne(res, await advisorService.getAdvice(req.auth.farmOwnerId, topic));
    } catch (err) {
      next(err);
    }
  },

  getDailyBriefing: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(res, await advisorService.getDailyBriefing(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },
};
