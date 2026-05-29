import type { NextFunction, Request, Response } from "express";
import { sendList, sendNoContent, sendOne } from "../lib/response";
import { cropService } from "../services/crop.service";

export const cropController = {
  listFields: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await cropService.listFields(
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
        await cropService.getField(req.auth.farmOwnerId, (req.params as Record<string, string>)["id"]),
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
        await cropService.createField(req.auth.farmOwnerId, req.body),
      );
    } catch (err) {
      next(err);
    }
  },

  updateField: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await cropService.updateField(
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
      await cropService.deleteField(req.auth.farmOwnerId, (req.params as Record<string, string>)["id"]);
      sendNoContent(res);
    } catch (err) {
      next(err);
    }
  },

  listPlans: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await cropService.listPlantingPlans(
        req.auth.farmOwnerId,
        req.query as Record<string, unknown>,
      );
      sendList(res, result.data, result.meta);
    } catch (err) {
      next(err);
    }
  },

  getPlan: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await cropService.getPlantingPlan(
          req.auth.farmOwnerId,
          (req.params as Record<string, string>)["id"],
        ),
      );
    } catch (err) {
      next(err);
    }
  },

  createPlan: async (req: Request, res: Response, next: NextFunction) => {
    try {
      res.status(201);
      sendOne(
        res,
        await cropService.createPlantingPlan(req.auth.farmOwnerId, req.body),
      );
    } catch (err) {
      next(err);
    }
  },

  updatePlan: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await cropService.updatePlantingPlan(
          req.auth.farmOwnerId,
          (req.params as Record<string, string>)["id"],
          req.body,
        ),
      );
    } catch (err) {
      next(err);
    }
  },

  listHarvest: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendList(
        res,
        await cropService.listHarvestRecords(
          req.auth.farmOwnerId,
          (req.params as Record<string, string>)["id"],
        ),
        { page: 1, limit: 100, total: 0 },
      );
    } catch (err) {
      next(err);
    }
  },

  addHarvest: async (req: Request, res: Response, next: NextFunction) => {
    try {
      res
        .status(201)
        .json({
          data: {
            id: await cropService.addHarvestRecord(
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

  listTasks: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendList(
        res,
        await cropService.listTasks(
          req.auth.farmOwnerId,
          req.query as Record<string, unknown>,
        ),
        { page: 1, limit: 100, total: 0 },
      );
    } catch (err) {
      next(err);
    }
  },

  createTask: async (req: Request, res: Response, next: NextFunction) => {
    try {
      res
        .status(201)
        .json({
          data: {
            id: await cropService.createTask(req.auth.farmOwnerId, req.body),
          },
        });
    } catch (err) {
      next(err);
    }
  },

  listSprayRecords: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendList(
        res,
        await cropService.listSprayRecords(
          req.auth.farmOwnerId,
          req.query as Record<string, unknown>,
        ),
        { page: 1, limit: 100, total: 0 },
      );
    } catch (err) {
      next(err);
    }
  },

  addSprayRecord: async (req: Request, res: Response, next: NextFunction) => {
    try {
      res
        .status(201)
        .json({
          data: {
            id: await cropService.createSprayRecord(
              req.auth.farmOwnerId,
              req.body,
            ),
          },
        });
    } catch (err) {
      next(err);
    }
  },
};
