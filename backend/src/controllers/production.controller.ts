import type { NextFunction, Request, Response } from "express";
import { sendList, sendOne } from "../lib/response";
import { productionService } from "../services/production.service";

export const productionController = {
  listMilk: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await productionService.listMilk(
        req.auth.farmOwnerId,
        req.query as Record<string, unknown>,
      );
      sendList(res, result.data, result.meta);
    } catch (err) {
      next(err);
    }
  },

  addMilk: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(res, await productionService.addMilk(req.auth.farmOwnerId, req.body), 201);
    } catch (err) {
      next(err);
    }
  },

  listEggs: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await productionService.listEggs(
        req.auth.farmOwnerId,
        req.query as Record<string, unknown>,
      );
      sendList(res, result.data, result.meta);
    } catch (err) {
      next(err);
    }
  },

  addEggs: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(res, await productionService.addEggs(req.auth.farmOwnerId, req.body), 201);
    } catch (err) {
      next(err);
    }
  },

  listWool: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await productionService.listWool(
        req.auth.farmOwnerId,
        req.query as Record<string, unknown>,
      );
      sendList(res, result.data, result.meta);
    } catch (err) {
      next(err);
    }
  },

  addWool: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(res, await productionService.addWool(req.auth.farmOwnerId, req.body), 201);
    } catch (err) {
      next(err);
    }
  },
};
