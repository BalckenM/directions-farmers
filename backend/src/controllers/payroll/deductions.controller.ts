import type { NextFunction, Request, Response } from "express";
import { sendNoContent, sendOne } from "../../lib/response";
import { payrollService } from "../../services/payroll/payroll.service";

// CRITICAL: Payroll GET lists return raw arrays (no wrapper) for Flutter PayrollRemoteDataSource compat

export const payrollDeductionsController = {
  listDeductionRules: async (
    req: Request,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      res.json(await payrollService.listDeductionRules(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  createDeductionRule: async (
    req: Request,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      res.status(201).json({
        data: {
          id: await payrollService.createDeductionRule(
            req.auth.farmOwnerId,
            req.body,
          ),
        },
      });
    } catch (err) {
      next(err);
    }
  },

  updateDeductionRule: async (
    req: Request,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      await payrollService.updateDeductionRule(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
        req.body,
      );
      res.json({ data: { message: "Updated" } });
    } catch (err) {
      next(err);
    }
  },

  deactivateDeductionRule: async (
    req: Request,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      await payrollService.deactivateDeductionRule(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
      );
      res.json({ data: { message: "Deactivated" } });
    } catch (err) {
      next(err);
    }
  },
};

