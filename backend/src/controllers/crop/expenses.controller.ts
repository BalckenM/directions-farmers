import type { NextFunction, Request, Response } from "express";
import { sendList, sendNoContent, sendOne } from "../../lib/response";
import { cropExpensesService } from "../../services/crop/expenses.service";

export const cropExpensesController = {
  listExpenses: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await cropExpensesService.listExpenses(
        req.auth.farmOwnerId,
        req.query as Record<string, unknown>,
      );
      sendList(res, result.data, result.meta);
    } catch (err) {
      next(err);
    }
  },

  createExpense: async (req: Request, res: Response, next: NextFunction) => {
    try {
      res.status(201);
      sendOne(
        res,
        await cropExpensesService.createExpense(
          req.auth.farmOwnerId,
          req.body,
        ),
      );
    } catch (err) {
      next(err);
    }
  },

  updateExpense: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await cropExpensesService.updateExpense(
          req.auth.farmOwnerId,
          (req.params as Record<string, string>)["id"],
          req.body,
        ),
      );
    } catch (err) {
      next(err);
    }
  },

  deleteExpense: async (req: Request, res: Response, next: NextFunction) => {
    try {
      await cropExpensesService.deleteExpense(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
      );
      sendNoContent(res);
    } catch (err) {
      next(err);
    }
  },
};
