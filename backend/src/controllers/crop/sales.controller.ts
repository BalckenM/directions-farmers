import type { NextFunction, Request, Response } from "express";
import { sendList, sendNoContent, sendOne } from "../../lib/response";
import { cropSalesService } from "../../services/crop/sales.service";

export const cropSalesController = {
  listSales: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await cropSalesService.listSales(
        req.auth.farmOwnerId,
        req.query as Record<string, unknown>,
      );
      sendList(res, result.data, result.meta);
    } catch (err) {
      next(err);
    }
  },

  createSale: async (req: Request, res: Response, next: NextFunction) => {
    try {
      res.status(201);
      sendOne(
        res,
        await cropSalesService.createSale(req.auth.farmOwnerId, req.body),
      );
    } catch (err) {
      next(err);
    }
  },

  updateSale: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await cropSalesService.updateSale(
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
      await cropSalesService.deleteSale(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
      );
      sendNoContent(res);
    } catch (err) {
      next(err);
    }
  },
};
