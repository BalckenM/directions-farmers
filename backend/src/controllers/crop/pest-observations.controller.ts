import type { NextFunction, Request, Response } from "express";
import { sendList, sendNoContent, sendOne } from "../../lib/response";
import { cropPestObservationsService } from "../../services/crop/pest-observations.service";

export const cropPestObservationsController = {
  listPestObservations: async (
    req: Request,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      const result = await cropPestObservationsService.listPestObservations(
        req.auth.farmOwnerId,
        req.query as Record<string, unknown>,
      );
      sendList(res, result.data, result.meta);
    } catch (err) {
      next(err);
    }
  },

  createPestObservation: async (
    req: Request,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      res.status(201);
      sendOne(
        res,
        await cropPestObservationsService.createPestObservation(
          req.auth.farmOwnerId,
          req.body,
        ),
      );
    } catch (err) {
      next(err);
    }
  },

  updatePestObservation: async (
    req: Request,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      sendOne(
        res,
        await cropPestObservationsService.updatePestObservation(
          req.auth.farmOwnerId,
          (req.params as Record<string, string>)["id"],
          req.body,
        ),
      );
    } catch (err) {
      next(err);
    }
  },

  deletePestObservation: async (
    req: Request,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      await cropPestObservationsService.deletePestObservation(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
      );
      sendNoContent(res);
    } catch (err) {
      next(err);
    }
  },
};
