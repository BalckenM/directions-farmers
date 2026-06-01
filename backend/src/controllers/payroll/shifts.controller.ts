import type { NextFunction, Request, Response } from "express";
import { payrollShiftsService } from "../../services/payroll/shifts.service";

export const payrollShiftsController = {
  listShifts: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await payrollShiftsService.list(
        req.auth.farmOwnerId,
        req.query as Record<string, unknown>,
      );
      res.json(result.data);
    } catch (err) {
      next(err);
    }
  },

  getShift: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const shift = await payrollShiftsService.get(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
      );
      res.json(shift);
    } catch (err) {
      next(err);
    }
  },

  createShift: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const shift = await payrollShiftsService.create(
        req.auth.farmOwnerId,
        req.body,
      );
      res.status(201).json(shift);
    } catch (err) {
      next(err);
    }
  },

  updateShift: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const shift = await payrollShiftsService.update(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
        req.body,
      );
      res.json(shift);
    } catch (err) {
      next(err);
    }
  },

  deleteShift: async (req: Request, res: Response, next: NextFunction) => {
    try {
      await payrollShiftsService.delete(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
      );
      res.status(204).end();
    } catch (err) {
      next(err);
    }
  },
};
