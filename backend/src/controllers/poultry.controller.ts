import type { NextFunction, Request, Response } from "express";
import { sendList, sendNoContent, sendOne } from "../lib/response";
import { poultryService } from "../services/poultry.service";

export const poultryController = {
  list: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await poultryService.listFlocks(
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
        await poultryService.getFlock(req.auth.farmOwnerId, (req.params as Record<string, string>)["id"]),
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
        await poultryService.createFlock(req.auth.farmOwnerId, req.body),
      );
    } catch (err) {
      next(err);
    }
  },

  update: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await poultryService.updateFlock(
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
      await poultryService.deleteFlock(req.auth.farmOwnerId, (req.params as Record<string, string>)["id"]);
      sendNoContent(res);
    } catch (err) {
      next(err);
    }
  },

  listDaily: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendList(
        res,
        await poultryService.listDailyRecords(
          req.auth.farmOwnerId,
          (req.params as Record<string, string>)["id"],
        ),
        { page: 1, limit: 100, total: 0 },
      );
    } catch (err) {
      next(err);
    }
  },

  addDaily: async (req: Request, res: Response, next: NextFunction) => {
    try {
      res
        .status(201)
        .json({
          data: {
            id: await poultryService.addDailyRecord(
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

  listVaccinations: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendList(
        res,
        await poultryService.listVaccinationSchedules(
          req.auth.farmOwnerId,
          (req.params as Record<string, string>)["id"],
        ),
        { page: 1, limit: 100, total: 0 },
      );
    } catch (err) {
      next(err);
    }
  },

  addVaccination: async (req: Request, res: Response, next: NextFunction) => {
    try {
      res
        .status(201)
        .json({
          data: {
            id: await poultryService.addVaccinationSchedule(
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

  listHarvest: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendList(
        res,
        await poultryService.listHarvestRecords(
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
            id: await poultryService.addHarvestRecord(
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
};
