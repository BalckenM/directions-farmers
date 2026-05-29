import type { NextFunction, Request, Response } from "express";
import { sendNoContent, sendOne } from "../../lib/response";
import { payrollService } from "../../services/payroll/payroll.service";

// CRITICAL: Payroll GET lists return raw arrays (no wrapper) for Flutter PayrollRemoteDataSource compat

export const payrollPayRunsController = {
  listPayRuns: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await payrollService.listPayRuns(
        req.auth.farmOwnerId,
        req.query as Record<string, unknown>,
      );
      res.json(result.rows);
    } catch (err) {
      next(err);
    }
  },

  getPayRun: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await payrollService.getPayRun(req.auth.farmOwnerId, (req.params as Record<string, string>)["id"]),
      );
    } catch (err) {
      next(err);
    }
  },

  createPayRun: async (req: Request, res: Response, next: NextFunction) => {
    try {
      res.status(201);
      sendOne(
        res,
        await payrollService.createPayRun(req.auth.farmOwnerId, req.body),
      );
    } catch (err) {
      next(err);
    }
  },

  finalizePayRun: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await payrollService.finalizePayRun(
          req.auth.farmOwnerId,
          (req.params as Record<string, string>)["id"],
        ),
      );
    } catch (err) {
      next(err);
    }
  },
};

