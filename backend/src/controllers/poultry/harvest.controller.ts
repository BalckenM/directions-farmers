import type { NextFunction, Request, Response } from "express";
import { sendList } from "../../lib/response";
import { poultryHarvestService } from "../../services/poultry/harvest.service";

export const poultryHarvestController = {
  listHarvest: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const flockId = (req.query as Record<string, string>)["flockId"];
      const records = await poultryHarvestService.listHarvestRecords(
        req.auth.farmOwnerId,
        flockId,
      );
      sendList(res, records, { page: 1, limit: 100, total: records.length });
    } catch (err) {
      next(err);
    }
  },

  addHarvest: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const id = await poultryHarvestService.addHarvestRecord(
        req.auth.farmOwnerId,
        req.body.flockId,
        req.body,
      );
      res.status(201).json({ data: { id } });
    } catch (err) {
      next(err);
    }
  },
};
