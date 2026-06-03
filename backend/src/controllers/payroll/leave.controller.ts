import type { NextFunction, Request, Response } from "express";
import { sendNoContent } from "../../lib/response";
import { payrollService } from "../../services/payroll/payroll.service";

// CRITICAL: Payroll GET lists return raw arrays (no wrapper) for Flutter PayrollRemoteDataSource compat

export const payrollLeaveController = {
  listLeaveRequests: async (
    req: Request,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      res.json(await payrollService.listLeaveRequests(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  createLeaveRequest: async (
    req: Request,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      res.status(201).json({
        data: {
          id: await payrollService.createLeaveRequest(
            req.auth.farmOwnerId,
            req.body,
          ),
        },
      });
    } catch (err) {
      next(err);
    }
  },

  approveLeave: async (req: Request, res: Response, next: NextFunction) => {
    try {
      await payrollService.approveLeaveRequest(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
      );
      res.json({ data: { message: "Approved" } });
    } catch (err) {
      next(err);
    }
  },

  rejectLeave: async (req: Request, res: Response, next: NextFunction) => {
    try {
      await payrollService.rejectLeaveRequest(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
      );
      res.json({ data: { message: "Rejected" } });
    } catch (err) {
      next(err);
    }
  },

  deleteLeaveRequest: async (
    req: Request,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      await payrollService.deleteLeaveRequest(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
      );
      sendNoContent(res);
    } catch (err) {
      next(err);
    }
  },

  listLeaveTypes: async (req: Request, res: Response, next: NextFunction) => {
    try {
      res.json(await payrollService.listLeaveTypes(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  // Piecework
  listPiecework: async (req: Request, res: Response, next: NextFunction) => {
    try {
      res.json(await payrollService.listPieceworkLogs(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  createPiecework: async (req: Request, res: Response, next: NextFunction) => {
    try {
      res.status(201).json({
        data: {
          id: await payrollService.createPieceworkLog(
            req.auth.farmOwnerId,
            req.body,
          ),
        },
      });
    } catch (err) {
      next(err);
    }
  },

  deletePiecework: async (req: Request, res: Response, next: NextFunction) => {
    try {
      await payrollService.deletePieceworkLog(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
      );
      sendNoContent(res);
    } catch (err) {
      next(err);
    }
  },

  // Transactions
  listTransactions: async (req: Request, res: Response, next: NextFunction) => {
    try {
      res.json(await payrollService.listTransactions(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },
};

