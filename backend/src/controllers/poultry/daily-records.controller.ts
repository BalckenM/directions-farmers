import type { NextFunction, Request, Response } from "express";
import { sendList } from "../../lib/response";
import { poultryDailyRecordsService } from "../../services/poultry/daily-records.service";

export const poultryDailyRecordsController = {
  listDaily: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const flockId = (req.query as Record<string, string>)["flockId"];
      const records = await poultryDailyRecordsService.listDailyRecords(
        req.auth.farmOwnerId,
        flockId,
      );
      sendList(res, records, { page: 1, limit: 100, total: records.length });
    } catch (err) {
      next(err);
    }
  },

  addDaily: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const id = await poultryDailyRecordsService.addDailyRecord(
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
