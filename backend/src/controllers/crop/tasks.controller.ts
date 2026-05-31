import type { NextFunction, Request, Response } from "express";
import { sendList } from "../../lib/response";
import { cropTasksService } from "../../services/crop/tasks.service";

export const cropTasksController = {
  listTasks: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendList(
        res,
        await cropTasksService.listTasks(
          req.auth.farmOwnerId,
          req.query as Record<string, unknown>,
        ),
        { page: 1, limit: 100, total: 0 },
      );
    } catch (err) {
      next(err);
    }
  },

  createTask: async (req: Request, res: Response, next: NextFunction) => {
    try {
      res.status(201).json({
        data: {
          id: await cropTasksService.createTask(req.auth.farmOwnerId, req.body),
        },
      });
    } catch (err) {
      next(err);
    }
  },
};
