import type { NextFunction, Request, Response } from "express";
import { sendNoContent, sendOne } from "../../lib/response";
import { payrollService } from "../../services/payroll/payroll.service";

// CRITICAL: Payroll GET lists return raw arrays (no wrapper) for Flutter PayrollRemoteDataSource compat

export const payrollPayStructuresController = {
  listPayStructures: async (
    req: Request,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      res.json(await payrollService.listPayStructures(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  createPayStructure: async (
    req: Request,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      res.status(201).json({
        data: {
          id: await payrollService.createPayStructure(
            req.auth.farmOwnerId,
            req.body,
          ),
        },
      });
    } catch (err) {
      next(err);
    }
  },

  updatePayStructure: async (
    req: Request,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      await payrollService.updatePayStructure(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
        req.body,
      );
      res.json({ data: { message: "Updated" } });
    } catch (err) {
      next(err);
    }
  },

  // Garnishee orders
  listGarnisheeOrders: async (
    req: Request,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      res.json(await payrollService.listGarnisheeOrders(req.auth.farmOwnerId));
    } catch (err) {
      next(err);
    }
  },

  createGarnisheeOrder: async (
    req: Request,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      res.status(201).json({
        data: {
          id: await payrollService.createGarnisheeOrder(
            req.auth.farmOwnerId,
            req.body,
          ),
        },
      });
    } catch (err) {
      next(err);
    }
  },

  updateGarnisheeOrder: async (
    req: Request,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      await payrollService.updateGarnisheeOrder(
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

