import { Router } from "express";
import { insightsController } from "../controllers/insights.controller";
import { authenticate } from "../middleware/auth.middleware";

export const insightsRouter = Router();

insightsRouter.use(authenticate);

insightsRouter.get("/market-prices", insightsController.getMarketPrices);
