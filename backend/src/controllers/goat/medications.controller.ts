import type { NextFunction, Request, Response } from "express";
import { sendList, sendNoContent, sendOne } from "../../lib/response";
import { goatService } from "../../services/goat/goat.service";

export const goatMedicationsController = {
  listMedications: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(res, await goatService.listMedicationLogs(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  createMedication: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await goatService.createMedicationLog(req.auth.farmOwnerId, req.body),
        201,
      );
    } catch (err) {
      next(err);
    }
  },
};

