import { Router } from "express";
import { subscriptionController } from "../controllers/subscription.controller";
import { authenticate } from "../middleware/auth.middleware";

export const subscriptionRouter = Router();

subscriptionRouter.use(authenticate);

// GET  /v1/subscription/plans — list all available plans
subscriptionRouter.get("/plans", subscriptionController.getPlans);

// GET  /v1/subscription — get current subscription for the authenticated farm
subscriptionRouter.get("/", subscriptionController.getCurrent);

// PUT  /v1/subscription/upgrade — upgrade to a new plan
subscriptionRouter.put("/upgrade", subscriptionController.upgrade);
