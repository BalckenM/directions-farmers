import { Router } from "express";
import { eventsController } from "../controllers/events.controller";
import { authenticate } from "../middleware/auth.middleware";
import { validate } from "../middleware/validate.middleware";
import {
  addBreedingEventSchema,
  addHealthEventSchema,
  addWeightRecordSchema,
} from "../validators/events.validator";

export const eventsRouter = Router();

eventsRouter.use(authenticate);

eventsRouter.get("/health", eventsController.listHealthEvents);
eventsRouter.post("/health", validate(addHealthEventSchema), eventsController.addHealthEvent);
eventsRouter.get("/weights", eventsController.listWeightRecords);
eventsRouter.post(
  "/weights",
  validate(addWeightRecordSchema),
  eventsController.addWeightRecord,
);
eventsRouter.get("/breeding", eventsController.listBreedingEvents);
eventsRouter.post(
  "/breeding",
  validate(addBreedingEventSchema),
  eventsController.addBreedingEvent,
);
