import type { NextFunction, Request, Response } from "express";
import { sendOne } from "../../lib/response";
import { goatService } from "../../services/goat/goat.service";

export const goatFamachaController = {
  listFamacha: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(res, await goatService.listFamachaRecords(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  createFamacha: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await goatService.createFamachaRecord(req.auth.farmOwnerId, req.body),
        201,
      );
    } catch (err) {
      next(err);
    }
  },
};

