import type { NextFunction, Request, Response } from "express";
import { sendNoContent, sendOne } from "../../lib/response";
import { payrollService } from "../../services/payroll/payroll.service";

// CRITICAL: Payroll GET lists return raw arrays (no wrapper) for Flutter PayrollRemoteDataSource compat

export const payrollEmployeesController = {
  listEmployees: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await payrollService.listEmployees(
        req.auth.farmOwnerId,
        req.query as Record<string, unknown>,
      );
      res.json(result.rows);
    } catch (err) {
      next(err);
    }
  },

  getEmployee: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await payrollService.getEmployee(
          req.auth.farmOwnerId,
          (req.params as Record<string, string>)["id"],
        ),
      );
    } catch (err) {
      next(err);
    }
  },

  createEmployee: async (req: Request, res: Response, next: NextFunction) => {
    try {
      res.status(201);
      sendOne(
        res,
        await payrollService.createEmployee(req.auth.farmOwnerId, req.body),
      );
    } catch (err) {
      next(err);
    }
  },

  updateEmployee: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await payrollService.updateEmployee(
          req.auth.farmOwnerId,
          (req.params as Record<string, string>)["id"],
          req.body,
        ),
      );
    } catch (err) {
      next(err);
    }
  },

  deleteEmployee: async (req: Request, res: Response, next: NextFunction) => {
    try {
      await payrollService.deleteEmployee(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
      );
      sendNoContent(res);
    } catch (err) {
      next(err);
    }
  },

  terminateEmployee: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const id = (req.params as Record<string, string>)["id"];
      const { terminationDate, reason } = req.body;
      await payrollService.updateEmployee(req.auth.farmOwnerId, id, {
        isActive: false,
        endDate: terminationDate,
        notes: reason,
      });
      const emp = await payrollService.getEmployee(req.auth.farmOwnerId, id);
      res.json(emp);
    } catch (err) {
      next(err);
    }
  },
};

