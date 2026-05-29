import type { NextFunction, Request, Response } from "express";
import { sendNoContent, sendOne } from "../../lib/response";
import { cattleService } from "../../services/cattle/cattle.service";

export const cattleAnimalsController = {

  list: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await cattleService.listAnimals(
        req.auth.farmOwnerId,
        req.query as Record<string, unknown>,
      );
      sendOne(res, result.data);
    } catch (err) {
      next(err);
    }
  },

  get: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await cattleService.getAnimal(
          req.auth.farmOwnerId,
          (req.params as Record<string, string>)["id"],
        ),
      );
    } catch (err) {
      next(err);
    }
  },

  create: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await cattleService.createAnimal(req.auth.farmOwnerId, req.body),
        201,
      );
    } catch (err) {
      next(err);
    }
  },

  update: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await cattleService.updateAnimal(
          req.auth.farmOwnerId,
          (req.params as Record<string, string>)["id"],
          req.body,
        ),
      );
    } catch (err) {
      next(err);
    }
  },

  delete: async (req: Request, res: Response, next: NextFunction) => {
    try {
      await cattleService.deleteAnimal(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
      );
      sendNoContent(res);
    } catch (err) {
      next(err);
    }
  },
};

