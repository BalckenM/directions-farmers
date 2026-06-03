import type { NextFunction, Request, Response } from "express";
import { sendOne } from "../../lib/response";
import { goatService } from "../../services/goat/goat.service";

export const goatVaccinationsController = {
  listVaccinations: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(res, await goatService.listVaccinations(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  createVaccination: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await goatService.createVaccination(req.auth.farmOwnerId, req.body),
        201,
      );
    } catch (err) {
      next(err);
    }
  },

  markVaccinationGiven: async (
    req: Request,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      sendOne(
        res,
        await goatService.markVaccinationGiven(
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

