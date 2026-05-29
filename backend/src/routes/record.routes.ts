import { Router } from "express";
import { recordController } from "../controllers/record.controller";
import { authenticate } from "../middleware/auth.middleware";
import { validate } from "../middleware/validate.middleware";
import { addFeedLogSchema } from "../validators/record.validator";

export const recordRouter = Router();

recordRouter.use(authenticate);

recordRouter.get("/feed-logs", recordController.listFeedLogs);
recordRouter.post("/feed-logs", validate(addFeedLogSchema), recordController.addFeedLog);
