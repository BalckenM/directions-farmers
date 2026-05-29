import { Router } from "express";
import { advisorController } from "../controllers/advisor.controller";
import { authenticate } from "../middleware/auth.middleware";

export const advisorRouter = Router();

advisorRouter.use(authenticate);

advisorRouter.post("/advice", advisorController.getAdvice);
advisorRouter.get("/briefing", advisorController.getDailyBriefing);
