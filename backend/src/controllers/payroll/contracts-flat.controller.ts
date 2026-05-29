import type { NextFunction, Request, Response } from "express";
import { sendNoContent, sendOne } from "../../lib/response";
import { payrollService } from "../../services/payroll/payroll.service";

// CRITICAL: Payroll GET lists return raw arrays (no wrapper) for Flutter PayrollRemoteDataSource compat

export const payrollContractsFlatController = {
  listAllContracts: async (req: Request, res: Response, next: NextFunction) => {
    try {
      res.json(await payrollService.listAllContracts(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  voidContract: async (req: Request, res: Response, next: NextFunction) => {
    try {
      await payrollService.voidContract(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
        req.body.reason ?? "",
      );
      res.json({ data: { message: "Voided" } });
    } catch (err) {
      next(err);
    }
  },
};

