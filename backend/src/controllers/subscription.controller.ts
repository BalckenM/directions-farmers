import type { NextFunction, Request, Response } from "express";
import { sendError, sendOne } from "../lib/response";
import { subscriptionService } from "../services/subscription.service";

export const subscriptionController = {
  getPlans: async (_req: Request, res: Response, next: NextFunction) => {
    try {
      const plans = await subscriptionService.getAllPlans();
      res.json({ data: plans });
    } catch (err) {
      next(err);
    }
  },

  getCurrent: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { sub, subType, farmId } = req.auth;
      const farmOwnerId = subType === "owner" ? sub : farmId;

      const subscription = await subscriptionService.getPlan(farmOwnerId);
      if (!subscription) {
        return sendError(res, 404, "NO_SUBSCRIPTION", "No active subscription found");
      }
      sendOne(res, subscription);
    } catch (err) {
      next(err);
    }
  },

  upgrade: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { sub, subType, farmId } = req.auth;
      const farmOwnerId = subType === "owner" ? sub : farmId;

      // Only farm owners can upgrade
      if (subType !== "owner") {
        return sendError(res, 403, "FORBIDDEN", "Only farm owners can upgrade the subscription plan");
      }

      const { planId } = req.body;
      if (!planId || typeof planId !== "string") {
        return sendError(res, 400, "INVALID_INPUT", "planId is required");
      }

      const result = await subscriptionService.upgradePlan(farmOwnerId, planId);
      sendOne(res, result);
    } catch (err) {
      next(err);
    }
  },
};
