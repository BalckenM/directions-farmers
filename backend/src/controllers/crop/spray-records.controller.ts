import type { NextFunction, Request, Response } from "express";
import { sendList, sendNoContent, sendOne } from "../../lib/response";
import { cropSprayRecordsService } from "../../services/crop/spray-records.service";

export const cropSprayRecordsController = {
  listSprayRecords: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const records = await cropSprayRecordsService.listSprayRecords(
        req.auth.farmOwnerId,
        req.query as Record<string, unknown>,
      );
      sendList(res, records, { page: 1, limit: 100, total: records.length });
    } catch (err) {
      next(err);
    }
  },

  addSprayRecord: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const id = await cropSprayRecordsService.createSprayRecord(
        req.auth.farmOwnerId,
        req.body,
      );
      res.status(201).json({ data: { id } });
    } catch (err) {
      next(err);
    }
  },

  updateSprayRecord: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await cropSprayRecordsService.updateSprayRecord(
          req.auth.farmOwnerId,
          (req.params as Record<string, string>)["id"],
          req.body,
        ),
      );
    } catch (err) {
      next(err);
    }
  },

  deleteSprayRecord: async (req: Request, res: Response, next: NextFunction) => {
    try {
      await cropSprayRecordsService.deleteSprayRecord(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
      );
      sendNoContent(res);
    } catch (err) {
      next(err);
    }
  },
};
