import type { NextFunction, Request, Response } from "express";
import { sendList, sendNoContent, sendOne } from "../../lib/response";
import { goatService } from "../../services/goat/goat.service";

export const goatBcsController = {
  listBcs: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(res, await goatService.listBcsRecords(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  createBcs: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await goatService.createBcsRecord(req.auth.farmOwnerId, req.body),
        201,
      );
    } catch (err) {
      next(err);
    }
  },
};

