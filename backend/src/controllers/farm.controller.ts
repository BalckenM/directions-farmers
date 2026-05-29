import type { NextFunction, Request, Response } from "express";
import { sendList, sendNoContent, sendOne } from "../lib/response";
import { farmService } from "../services/farm.service";

export const farmController = {
  getTeam: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await farmService.getTeam(
        req.auth.farmOwnerId,
        req.query as Record<string, unknown>,
      );
      sendList(res, result.data, result.meta);
    } catch (err) {
      next(err);
    }
  },

  inviteStaff: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(res, await farmService.inviteStaff(req.auth.farmOwnerId, req.body), 201);
    } catch (err) {
      next(err);
    }
  },

  updateStaff: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await farmService.updateStaff(
          req.auth.farmOwnerId,
          (req.params as Record<string, string>)["id"],
          req.body,
        ),
      );
    } catch (err) {
      next(err);
    }
  },

  deactivateStaff: async (req: Request, res: Response, next: NextFunction) => {
    try {
      await farmService.deactivateStaff(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
      );
      sendNoContent(res);
    } catch (err) {
      next(err);
    }
  },
};
