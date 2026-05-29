import { Router } from "express";
import { settingsController } from "../controllers/settings.controller";
import { authenticate } from "../middleware/auth.middleware";

export const settingsRouter = Router();

settingsRouter.use(authenticate);

// GET /v1/settings/paddocks — list all paddocks for the authenticated farm owner
settingsRouter.get("/paddocks", settingsController.getPaddocks);
