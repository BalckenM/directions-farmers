import { Router } from "express";
import { weatherController } from "../controllers/weather.controller";
import { authenticate } from "../middleware/auth.middleware";

export const weatherRouter = Router();

weatherRouter.use(authenticate);

weatherRouter.get("/current", weatherController.getCurrent);
weatherRouter.get("/forecast", weatherController.getForecast);
weatherRouter.get("/alerts", weatherController.getAlerts);
