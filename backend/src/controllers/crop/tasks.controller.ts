import type { NextFunction, Request, Response } from "express";
import { sendList, sendNoContent, sendOne } from "../../lib/response";
import { cropTasksService } from "../../services/crop/tasks.service";

export const cropTasksController = {
  listTasks: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const tasks = await cropTasksService.listTasks(
        req.auth.farmOwnerId,
        req.query as Record<string, unknown>,
      );
      sendList(res, tasks, { page: 1, limit: 100, total: tasks.length });
    } catch (err) {
      next(err);
    }
  },

  createTask: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const id = await cropTasksService.createTask(
        req.auth.farmOwnerId,
        req.body,
      );
      res.status(201).json({ data: { id } });
    } catch (err) {
      next(err);
    }
  },

  updateTask: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await cropTasksService.updateTask(
          req.auth.farmOwnerId,
          (req.params as Record<string, string>)["id"],
          req.body,
        ),
      );
    } catch (err) {
      next(err);
    }
  },

  deleteTask: async (req: Request, res: Response, next: NextFunction) => {
    try {
      await cropTasksService.deleteTask(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
      );
      sendNoContent(res);
    } catch (err) {
      next(err);
    }
  },
};
