import type { NextFunction, Request, Response } from "express";
import { sendNoContent, sendOne } from "../../lib/response";
import { payrollService } from "../../services/payroll/payroll.service";

// CRITICAL: Payroll GET lists return raw arrays (no wrapper) for Flutter PayrollRemoteDataSource compat

export const payrollContractsController = {
  listContracts: async (req: Request, res: Response, next: NextFunction) => {
    try {
      res.json(
        await payrollService.listContracts(
          req.auth.farmOwnerId,
          (req.params as Record<string, string>)["id"],
        ),
      );
    } catch (err) {
      next(err);
    }
  },

  createContract: async (req: Request, res: Response, next: NextFunction) => {
    try {
      res.status(201).json({
        data: {
          id: await payrollService.createContract(
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

