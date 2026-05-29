import type { NextFunction, Request, Response } from "express";
import { sendList, sendNoContent, sendOne } from "../../lib/response";
import { goatService } from "../../services/goat/goat.service";

export const goatPastureController = {
  listPasture: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(res, await goatService.listPastureRecords(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  createPasture: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await goatService.createPastureRecord(req.auth.farmOwnerId, req.body),
        201,
      );
    } catch (err) {
      next(err);
    }
  },

  exitPasture: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await goatService.exitPasture(
          req.auth.farmOwnerId,
          (req.params as Record<string, string>)["id"],
          req.body,
        ),
      );
    } catch (err) {
      next(err);
    }
  },
};

