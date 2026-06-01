import type { NextFunction, Request, Response } from "express";
import { payrollService } from "../../services/payroll/payroll.service";

// CRITICAL: Payroll GET lists return raw arrays (no wrapper) for Flutter PayrollRemoteDataSource compat

export const payrollPayGroupsController = {
  listPayGroups: async (req: Request, res: Response, next: NextFunction) => {
    try {
      res.json(await payrollService.listPayGroups(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  createPayGroup: async (req: Request, res: Response, next: NextFunction) => {
    try {
      res.status(201).json({
        data: {
          id: await payrollService.createPayGroup(
            req.auth.farmOwnerId,
            req.body,
          ),
        },
      });
    } catch (err) {
      next(err);
    }
  },

  updatePayGroup: async (req: Request, res: Response, next: NextFunction) => {
    try {
      await payrollService.updatePayGroup(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
        req.body,
      );
      res.json({ data: { message: "Updated" } });
    } catch (err) {
      next(err);
    }
  },

  deactivatePayGroup: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const id = (req.params as Record<string, string>)["id"];
      await payrollService.updatePayGroup(req.auth.farmOwnerId, id, {
        isActive: false,
      });
      res.json({ data: { message: "Deactivated" } });
    } catch (err) {
      next(err);
    }
  },
};

