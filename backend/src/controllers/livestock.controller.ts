import type { NextFunction, Request, Response } from "express";
import { sendNoContent, sendOne } from "../lib/response";
import { livestockService } from "../services/livestock.service";

export const livestockController = {
  getAnimals: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { species } = req.query as Record<string, string>;
      sendOne(res, await livestockService.getAnimals(req.auth.farmOwnerId, species));
    } catch (err) {
      next(err);
    }
  },

  getGroups: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(res, await livestockService.getGroups(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  createGroup: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await livestockService.createGroup(req.auth.farmOwnerId, req.body),
        201,
      );
    } catch (err) {
      next(err);
    }
  },

  updateGroup: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await livestockService.updateGroup(
          req.auth.farmOwnerId,
          (req.params as Record<string, string>)["id"],
          req.body,
        ),
      );
    } catch (err) {
      next(err);
    }
  },

  deleteGroup: async (req: Request, res: Response, next: NextFunction) => {
    try {
      await livestockService.deleteGroup(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
      );
      sendNoContent(res);
    } catch (err) {
      next(err);
    }
  },
};
