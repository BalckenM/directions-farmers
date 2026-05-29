import type { NextFunction, Request, Response } from "express";
import { sendNoContent, sendOne } from "../../lib/response";
import { payrollService } from "../../services/payroll/payroll.service";

// CRITICAL: Payroll GET lists return raw arrays (no wrapper) for Flutter PayrollRemoteDataSource compat

export const payrollCommunicationsController = {
  listCommunications: async (
    req: Request,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      res.json(await payrollService.listCommunications(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  sendCommunication: async (
    req: Request,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      res.status(201).json({
        data: {
          id: await payrollService.sendCommunication(
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

