import type { NextFunction, Request, Response } from "express";
import { sendNoContent, sendOne } from "../../lib/response";
import { payrollService } from "../../services/payroll/payroll.service";

// CRITICAL: Payroll GET lists return raw arrays (no wrapper) for Flutter PayrollRemoteDataSource compat

export const payrollAuditController = {
  listAuditLog: async (req: Request, res: Response, next: NextFunction) => {
    try {
      res.json(await payrollService.listAuditLog(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  // Incidents
  listIncidents: async (req: Request, res: Response, next: NextFunction) => {
    try {
      res.json(await payrollService.listIncidents(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  createIncident: async (req: Request, res: Response, next: NextFunction) => {
    try {
      res.status(201).json({
        data: {
          id: await payrollService.createIncident(
            req.auth.farmOwnerId,
            req.body,
          ),
        },
      });
    } catch (err) {
      next(err);
    }
  },

  updateIncident: async (req: Request, res: Response, next: NextFunction) => {
    try {
      await payrollService.updateIncident(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
        req.body,
      );
      res.json({ data: { message: "Updated" } });
    } catch (err) {
      next(err);
    }
  },
};

