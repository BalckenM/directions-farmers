import type { NextFunction, Request, Response } from "express";
import { sendList } from "../../lib/response";
import { cropSprayRecordsService } from "../../services/crop/spray-records.service";

export const cropSprayRecordsController = {
  listSprayRecords: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendList(
        res,
        await cropSprayRecordsService.listSprayRecords(
          req.auth.farmOwnerId,
          req.query as Record<string, unknown>,
        ),
        { page: 1, limit: 100, total: 0 },
      );
    } catch (err) {
      next(err);
    }
  },

  addSprayRecord: async (req: Request, res: Response, next: NextFunction) => {
    try {
      res.status(201).json({
        data: {
          id: await cropSprayRecordsService.createSprayRecord(
            req.auth.farmOwnerId,
            req.body,
          ),
        },
      });
    } catch (err) {
      next(err);
    }
  },
};
