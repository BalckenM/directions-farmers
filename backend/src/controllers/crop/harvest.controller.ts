import type { NextFunction, Request, Response } from "express";
import { sendList, sendNoContent, sendOne } from "../../lib/response";
import { cropHarvestService } from "../../services/crop/harvest.service";

export const cropHarvestController = {
  listHarvest: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const records = await cropHarvestService.listHarvestRecords(
        req.auth.farmOwnerId,
      );
      sendList(res, records, { page: 1, limit: 100, total: records.length });
    } catch (err) {
      next(err);
    }
  },

  addHarvest: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const id = await cropHarvestService.addHarvestRecord(
        req.auth.farmOwnerId,
        req.body,
      );
      res.status(201).json({ data: { id } });
    } catch (err) {
      next(err);
    }
  },

  updateHarvest: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await cropHarvestService.updateHarvestRecord(
          req.auth.farmOwnerId,
          (req.params as Record<string, string>)["id"],
          req.body,
        ),
      );
    } catch (err) {
      next(err);
    }
  },

  deleteHarvest: async (req: Request, res: Response, next: NextFunction) => {
    try {
      await cropHarvestService.deleteHarvestRecord(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
      );
      sendNoContent(res);
    } catch (err) {
      next(err);
    }
  },
};
