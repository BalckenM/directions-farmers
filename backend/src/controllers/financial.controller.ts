import type { NextFunction, Request, Response } from "express";
import { sendList, sendNoContent, sendOne } from "../lib/response";
import { financialService } from "../services/financial.service";

export const financialController = {
  list: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await financialService.list(
        req.auth.farmOwnerId,
        req.query as Record<string, unknown>,
      );
      sendList(res, result.data, result.meta);
    } catch (err) {
      next(err);
    }
  },

  get: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await financialService.getById(req.auth.farmOwnerId, (req.params as Record<string, string>)["id"]),
      );
    } catch (err) {
      next(err);
    }
  },

  create: async (req: Request, res: Response, next: NextFunction) => {
    try {
      res.status(201);
      sendOne(
        res,
        await financialService.create(req.auth.farmOwnerId, req.body),
      );
    } catch (err) {
      next(err);
    }
  },

  update: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await financialService.update(
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
      await financialService.delete(req.auth.farmOwnerId, (req.params as Record<string, string>)["id"]);
      sendNoContent(res);
    } catch (err) {
      next(err);
    }
  },
};
