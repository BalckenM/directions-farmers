import type { NextFunction, Request, Response } from "express";
import { sendOne } from "../lib/response";
import { weatherService } from "../services/weather.service";

export const weatherController = {
  getCurrent: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const lat = Number((req.query as Record<string, string>)["lat"]) || -26.0;
      const lon = Number((req.query as Record<string, string>)["lon"]) || 28.0;
      sendOne(res, await weatherService.getCurrent(lat, lon));
    } catch (err) {
      next(err);
    }
  },

  getForecast: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const lat = Number((req.query as Record<string, string>)["lat"]) || -26.0;
      const lon = Number((req.query as Record<string, string>)["lon"]) || 28.0;
      sendOne(res, await weatherService.getForecast(lat, lon));
    } catch (err) {
      next(err);
    }
  },

  getAlerts: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const lat = Number((req.query as Record<string, string>)["lat"]) || -26.0;
      const lon = Number((req.query as Record<string, string>)["lon"]) || 28.0;
      sendOne(res, await weatherService.getAlerts(lat, lon));
    } catch (err) {
      next(err);
    }
  },
};
