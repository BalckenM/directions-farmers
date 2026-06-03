import type { NextFunction, Request, Response } from "express";
import { payrollService } from "../../services/payroll/payroll.service";

// CRITICAL: Payroll GET lists return raw arrays (no wrapper) for Flutter PayrollRemoteDataSource compat

export const payrollComplianceController = {
  listComplianceAlerts: async (
    req: Request,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      res.json(await payrollService.listComplianceAlerts(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  resolveComplianceAlert: async (
    req: Request,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      await payrollService.resolveComplianceAlert(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
      );
      res.json({ data: { message: "Resolved" } });
    } catch (err) {
      next(err);
    }
  },
};

