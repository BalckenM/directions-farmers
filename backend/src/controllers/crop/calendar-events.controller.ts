import type { NextFunction, Request, Response } from "express";
import { sendList, sendNoContent, sendOne } from "../../lib/response";
import { cropCalendarEventsService } from "../../services/crop/calendar-events.service";

export const cropCalendarEventsController = {
  listCalendarEvents: async (
    req: Request,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      const result = await cropCalendarEventsService.listCalendarEvents(
        req.auth.farmOwnerId,
        req.query as Record<string, unknown>,
      );
      sendList(res, result.data, result.meta);
    } catch (err) {
      next(err);
    }
  },

  createCalendarEvent: async (
    req: Request,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      res.status(201);
      sendOne(
        res,
        await cropCalendarEventsService.createCalendarEvent(
          req.auth.farmOwnerId,
          req.body,
        ),
      );
    } catch (err) {
      next(err);
    }
  },

  updateCalendarEvent: async (
    req: Request,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      sendOne(
        res,
        await cropCalendarEventsService.updateCalendarEvent(
          req.auth.farmOwnerId,
          (req.params as Record<string, string>)["id"],
          req.body,
        ),
      );
    } catch (err) {
      next(err);
    }
  },

  deleteCalendarEvent: async (
    req: Request,
    res: Response,
    next: NextFunction,
  ) => {
    try {
      await cropCalendarEventsService.deleteCalendarEvent(
        req.auth.farmOwnerId,
        (req.params as Record<string, string>)["id"],
      );
      sendNoContent(res);
    } catch (err) {
      next(err);
    }
  },
};
