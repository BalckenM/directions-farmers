import type { NextFunction, Request, Response } from "express";
import { sendOne } from "../../lib/response";
import { payrollService } from "../../services/payroll/payroll.service";

// CRITICAL: Payroll GET lists return raw arrays (no wrapper) for Flutter PayrollRemoteDataSource compat

export const payrollPayslipsController = {
  listPayslips: async (req: Request, res: Response, next: NextFunction) => {
    try {
      res.json(await payrollService.listPayslips(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  getPayslip: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await payrollService.getPayslip(
          req.auth.farmOwnerId,
          (req.params as Record<string, string>)["id"],
        ),
      );
    } catch (err) {
      next(err);
    }
  },
};

