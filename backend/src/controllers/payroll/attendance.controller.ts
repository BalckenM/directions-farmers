import type { NextFunction, Request, Response } from "express";
import { payrollAttendanceService } from "../../services/payroll/attendance.service";

export const payrollAttendanceController = {
  listAttendance: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await payrollAttendanceService.list(
        req.auth.farmOwnerId,
        req.query as Record<string, unknown>,
      );
      res.json(result.data);
    } catch (err) {
      next(err);
    }
  },

  createAttendance: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const record = await payrollAttendanceService.create(
        req.auth.farmOwnerId,
        req.body,
      );
      res.status(201).json(record);
    } catch (err) {
      next(err);
    }
  },

  updateAttendance: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const record = await payrollAttendanceService.update(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
        req.body,
      );
      res.json(record);
    } catch (err) {
      next(err);
    }
  },
};
