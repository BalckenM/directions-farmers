import type { NextFunction, Request, Response } from "express";
import { sendList } from "../../lib/response";
import { poultryVaccinationsService } from "../../services/poultry/vaccinations.service";

export const poultryVaccinationsController = {
  listVaccinations: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendList(
        res,
        await poultryVaccinationsService.listVaccinationSchedules(
          req.auth.farmOwnerId,
          (req.params as Record<string, string>)["id"],
        ),
        { page: 1, limit: 100, total: 0 },
      );
    } catch (err) {
      next(err);
    }
  },

  addVaccination: async (req: Request, res: Response, next: NextFunction) => {
    try {
      res.status(201).json({
        data: {
          id: await poultryVaccinationsService.addVaccinationSchedule(
            req.auth.farmOwnerId,
            (req.params as Record<string, string>)["id"],
            req.body,
          ),
        },
      });
    } catch (err) {
      next(err);
    }
  },
};
