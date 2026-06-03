import type { NextFunction, Request, Response } from "express";
import { payrollService } from "../../services/payroll/payroll.service";

// CRITICAL: Payroll GET lists return raw arrays (no wrapper) for Flutter PayrollRemoteDataSource compat

export const payrollLeaveBalancesController = {
  listLeaveBalances: async (
    req: Request,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      res.json(await payrollService.listLeaveBalances(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },
};

