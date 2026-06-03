import type { NextFunction, Request, Response } from "express";
import { sendOne } from "../../lib/response";
import { cattleService } from "../../services/cattle/cattle.service";

export const cattleVaccinationsController = {

  listVaccinations: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(res, await cattleService.listVaccinations(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  addVaccination: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await cattleService.addVaccination(req.auth.farmOwnerId, req.body),
        201,
      );
    } catch (err) {
      next(err);
    }
  },

  markVaccinationGiven: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await cattleService.markVaccinationGiven(
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

