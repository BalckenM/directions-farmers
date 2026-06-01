import type { NextFunction, Request, Response } from "express";
import { sendList } from "../../lib/response";
import { poultryVaccinationsService } from "../../services/poultry/vaccinations.service";

export const poultryVaccinationsController = {
  listVaccinations: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const flockId = (req.query as Record<string, string>)["flockId"];
      const records = await poultryVaccinationsService.listVaccinationSchedules(
        req.auth.farmOwnerId,
        flockId,
      );
      sendList(res, records, { page: 1, limit: 100, total: records.length });
    } catch (err) {
      next(err);
    }
  },

  addVaccination: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const id = await poultryVaccinationsService.addVaccinationSchedule(
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
