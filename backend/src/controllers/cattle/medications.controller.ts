import type { NextFunction, Request, Response } from "express";
import { sendOne } from "../../lib/response";
import { cattleService } from "../../services/cattle/cattle.service";

export const cattleMedicationsController = {

  listMedications: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(res, await cattleService.listMedicationLogs(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  addMedication: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await cattleService.addMedicationLog(req.auth.farmOwnerId, req.body),
        201,
      );
    } catch (err) {
      next(err);
    }
  },
};

