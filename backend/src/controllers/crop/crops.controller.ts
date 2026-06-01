import type { NextFunction, Request, Response } from "express";
import { sendList } from "../../lib/response";
import { cropCategoriesService } from "../../services/crop/categories.service";
import { cropsService } from "../../services/crop/crops.service";

export const cropCropsController = {
  listCategories: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await cropCategoriesService.listCategories(
        req.query as Record<string, unknown>,
      );
      sendList(res, result.data, result.meta);
    } catch (err) {
      next(err);
    }
  },

  listCrops: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await cropsService.listCrops(
        req.auth.farmOwnerId,
        req.query as Record<string, unknown>,
      );
      sendList(res, result.data, result.meta);
    } catch (err) {
      next(err);
    }
  },
};
