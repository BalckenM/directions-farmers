import type { NextFunction, Request, Response } from "express";
import { sendList } from "../../lib/response";
import { cropAdvisoryService } from "../../services/crop/advisory.service";

export const cropAdvisoryController = {
  listAdvisoryContent: async (
    req: Request,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      const result = await cropAdvisoryService.listAdvisoryContent(
        req.auth.farmOwnerId,
        req.query as Record<string, unknown>,
      );
      sendList(res, result.data, result.meta);
    } catch (err) {
      next(err);
    }
  },
};
