import type { NextFunction, Request, Response } from "express";
import { sendOne } from "../lib/response";
import { diseaseService } from "../services/disease.service";

export const diseaseController = {
  getLibrary: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { species } = req.query as Record<string, string>;
      sendOne(res, diseaseService.getLibrary(species));
    } catch (err) {
      next(err);
    }
  },

  detect: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { symptoms = [] } = req.body as { symptoms?: string[] };
      sendOne(res, diseaseService.detect(symptoms));
    } catch (err) {
      next(err);
    }
  },
};
