import type { NextFunction, Request, Response } from "express";
import { sendList, sendNoContent, sendOne } from "../../lib/response";
import { goatService } from "../../services/goat/goat.service";

export const goatSalesController = {
  listSales: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(res, await goatService.listSaleRecords(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  createSale: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await goatService.createSaleRecord(req.auth.farmOwnerId, req.body),
        201,
      );
    } catch (err) {
      next(err);
    }
  },

  updateSale: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await goatService.updateSaleRecord(
          req.auth.farmOwnerId,
          (req.params as Record<string, string>)["id"],
          req.body,
        ),
      );
    } catch (err) {
      next(err);
    }
  },

  deleteSale: async (req: Request, res: Response, next: NextFunction) => {
    try {
      await goatService.deleteSaleRecord(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
      );
      sendNoContent(res);
    } catch (err) {
      next(err);
    }
  },
};

