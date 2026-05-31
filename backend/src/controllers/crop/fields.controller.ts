import type { NextFunction, Request, Response } from "express";
import { sendList, sendNoContent, sendOne } from "../../lib/response";
import { cropFieldsService } from "../../services/crop/fields.service";

export const cropFieldsController = {
  listFields: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await cropFieldsService.listFields(
        req.auth.farmOwnerId,
        req.query as Record<string, unknown>,
      );
      sendList(res, result.data, result.meta);
    } catch (err) {
      next(err);
    }
  },

  getField: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await cropFieldsService.getField(
          req.auth.farmOwnerId,
          (req.params as Record<string, string>)["id"],
        ),
      );
    } catch (err) {
      next(err);
    }
  },

  createField: async (req: Request, res: Response, next: NextFunction) => {
    try {
      res.status(201);
      sendOne(
        res,
        await cropFieldsService.createField(req.auth.farmOwnerId, req.body),
      );
    } catch (err) {
      next(err);
    }
  },

  updateField: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await cropFieldsService.updateField(
          req.auth.farmOwnerId,
          (req.params as Record<string, string>)["id"],
          req.body,
        ),
      );
    } catch (err) {
      next(err);
    }
  },

  deleteField: async (req: Request, res: Response, next: NextFunction) => {
    try {
      await cropFieldsService.deleteField(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
      );
      sendNoContent(res);
    } catch (err) {
      next(err);
    }
  },
};
