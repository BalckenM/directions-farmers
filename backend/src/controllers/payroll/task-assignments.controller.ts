import type { NextFunction, Request, Response } from "express";
import { payrollTaskAssignmentsService } from "../../services/payroll/task-assignments.service";

export const payrollTaskAssignmentsController = {
  listTaskAssignments: async (
    req: Request,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      const result = await payrollTaskAssignmentsService.list(
        req.auth.farmOwnerId,
        req.query as Record<string, unknown>,
      );
      res.json(result.data);
    } catch (err) {
      next(err);
    }
  },

  createTaskAssignment: async (
    req: Request,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      const task = await payrollTaskAssignmentsService.create(
        req.auth.farmOwnerId,
        req.body,
      );
      res.status(201).json(task);
    } catch (err) {
      next(err);
    }
  },

  updateTaskAssignment: async (
    req: Request,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      const task = await payrollTaskAssignmentsService.update(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
        req.body,
      );
      res.json(task);
    } catch (err) {
      next(err);
    }
  },

  deleteTaskAssignment: async (
    req: Request,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      await payrollTaskAssignmentsService.delete(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
      );
      res.status(204).end();
    } catch (err) {
      next(err);
    }
  },
};
