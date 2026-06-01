import type { NextFunction, Request, Response } from "express";
import { payrollEmployerConfigService } from "../../services/payroll/employer-config.service";

export const payrollEmployerConfigController = {
  getConfig: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const config = await payrollEmployerConfigService.get(
        req.auth.farmOwnerId,
      );
      res.json(config);
    } catch (err) {
      next(err);
    }
  },

  upsertConfig: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const config = await payrollEmployerConfigService.update(
        req.auth.farmOwnerId,
        req.body,
      );
      res.json(config);
    } catch (err) {
      next(err);
    }
  },
};
