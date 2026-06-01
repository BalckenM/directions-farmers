import type { NextFunction, Request, Response } from "express";
import { sendList, sendNoContent, sendOne } from "../../lib/response";
import { cropPlantingPlansService } from "../../services/crop/planting-plans.service";

export const cropPlantingPlansController = {
  listPlans: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await cropPlantingPlansService.listPlantingPlans(
        req.auth.farmOwnerId,
        req.query as Record<string, unknown>,
      );
      sendList(res, result.data, result.meta);
    } catch (err) {
      next(err);
    }
  },

  getPlan: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await cropPlantingPlansService.getPlantingPlan(
          req.auth.farmOwnerId,
          (req.params as Record<string, string>)["id"],
        ),
      );
    } catch (err) {
      next(err);
    }
  },

  createPlan: async (req: Request, res: Response, next: NextFunction) => {
    try {
      res.status(201);
      sendOne(
        res,
        await cropPlantingPlansService.createPlantingPlan(
          req.auth.farmOwnerId,
          req.body,
        ),
      );
    } catch (err) {
      next(err);
    }
  },

  updatePlan: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await cropPlantingPlansService.updatePlantingPlan(
          req.auth.farmOwnerId,
          (req.params as Record<string, string>)["id"],
          req.body,
        ),
      );
    } catch (err) {
      next(err);
    }
  },

  deletePlan: async (req: Request, res: Response, next: NextFunction) => {
    try {
      await cropPlantingPlansService.deletePlantingPlan(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
      );
      sendNoContent(res);
    } catch (err) {
      next(err);
    }
  },
};
