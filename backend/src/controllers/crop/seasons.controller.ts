import type { NextFunction, Request, Response } from "express";
import { sendList, sendNoContent, sendOne } from "../../lib/response";
import { cropSeasonsService } from "../../services/crop/seasons.service";

export const cropSeasonsController = {
  listSeasons: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await cropSeasonsService.listSeasons(
        req.auth.farmOwnerId,
        req.query as Record<string, unknown>,
      );
      sendList(res, result.data, result.meta);
    } catch (err) {
      next(err);
    }
  },

  createSeason: async (req: Request, res: Response, next: NextFunction) => {
    try {
      res.status(201);
      sendOne(
        res,
        await cropSeasonsService.createSeason(req.auth.farmOwnerId, req.body),
      );
    } catch (err) {
      next(err);
    }
  },

  updateSeason: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await cropSeasonsService.updateSeason(
          req.auth.farmOwnerId,
          (req.params as Record<string, string>)["id"],
          req.body,
        ),
      );
    } catch (err) {
      next(err);
    }
  },

  deleteSeason: async (req: Request, res: Response, next: NextFunction) => {
    try {
      await cropSeasonsService.deleteSeason(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
      );
      sendNoContent(res);
    } catch (err) {
      next(err);
    }
  },
};
