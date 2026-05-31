import type { NextFunction, Request, Response } from "express";
import { sendList } from "../../lib/response";
import { poultryHarvestService } from "../../services/poultry/harvest.service";

export const poultryHarvestController = {
  listHarvest: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendList(
        res,
        await poultryHarvestService.listHarvestRecords(
          req.auth.farmOwnerId,
          (req.params as Record<string, string>)["id"],
        ),
        { page: 1, limit: 100, total: 0 },
      );
    } catch (err) {
      next(err);
    }
  },

  addHarvest: async (req: Request, res: Response, next: NextFunction) => {
    try {
      res.status(201).json({
        data: {
          id: await poultryHarvestService.addHarvestRecord(
            req.auth.farmOwnerId,
            (req.params as Record<string, string>)["id"],
            req.body,
          ),
        },
      });
    } catch (err) {
      next(err);
    }
  },
};
