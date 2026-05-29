import type { NextFunction, Request, Response } from "express";
import { sendList, sendOne } from "../lib/response";
import { eventsService } from "../services/events.service";

export const eventsController = {
  listHealthEvents: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await eventsService.listHealthEvents(
        req.auth.farmOwnerId,
        req.query as Record<string, unknown>,
      );
      sendList(res, result.data, result.meta);
    } catch (err) {
      next(err);
    }
  },

  addHealthEvent: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(res, await eventsService.addHealthEvent(req.auth.farmOwnerId, req.body), 201);
    } catch (err) {
      next(err);
    }
  },

  listWeightRecords: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await eventsService.listWeightRecords(
        req.auth.farmOwnerId,
        req.query as Record<string, unknown>,
      );
      sendList(res, result.data, result.meta);
    } catch (err) {
      next(err);
    }
  },

  addWeightRecord: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await eventsService.addWeightRecord(req.auth.farmOwnerId, req.body),
        201,
      );
    } catch (err) {
      next(err);
    }
  },

  listBreedingEvents: async (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = await eventsService.listBreedingEvents(
        req.auth.farmOwnerId,
        req.query as Record<string, unknown>,
      );
      sendList(res, result.data, result.meta);
    } catch (err) {
      next(err);
    }
  },

  addBreedingEvent: async (req: Request, res: Response, next: NextFunction) => {
    try {
      sendOne(
        res,
        await eventsService.addBreedingEvent(req.auth.farmOwnerId, req.body),
        201,
      );
    } catch (err) {
      next(err);
    }
  },
};
