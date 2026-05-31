import compression from "compression";
import cors from "cors";
import express from "express";
import helmet from "helmet";
import { pinoHttp } from "pino-http";
import { errorHandler } from "./middleware/error-handler.middleware";
import { globalLimiter } from "./middleware/rate-limiter.middleware";

import { advisorRouter } from "./routes/advisor.routes";
import { authRouter } from "./routes/auth.routes";
import { cattleRouter } from "./routes/cattle";
import { cropRouter } from "./routes/crop";
import { dashboardRouter } from "./routes/dashboard.routes";
import { diseaseRouter } from "./routes/disease.routes";
import { eventsRouter } from "./routes/events.routes";
import { farmRouter } from "./routes/farm.routes";
import { financialRouter } from "./routes/financial.routes";
import { goatRouter } from "./routes/goat";
import { insightsRouter } from "./routes/insights.routes";
import { livestockRouter } from "./routes/livestock.routes";
import { payrollRouter } from "./routes/payroll";
import { poultryRouter } from "./routes/poultry";
import { productionRouter } from "./routes/production.routes";
import { recordRouter } from "./routes/record.routes";
import { settingsRouter } from "./routes/settings.routes";
import { traceabilityRouter } from "./routes/traceability.routes";
import { weatherRouter } from "./routes/weather.routes";

export function buildApp(): express.Application {
  const app = express();

  app.set("trust proxy", 1);

  app.use(helmet());
  app.use(compression());
  app.use(
    cors({
      origin: process.env["ALLOWED_ORIGINS"]?.split(",") ?? "*",
      credentials: true,
    }),
  );
  app.use(pinoHttp());
  app.use(express.json({ limit: "1mb" }));

  app.use(globalLimiter);

  app.get("/health", (_req, res) => {
    res.json({ status: "ok", timestamp: new Date().toISOString() });
  });

  const v1 = express.Router();

  v1.use("/auth", authRouter);
  v1.use("/farm", farmRouter);
  v1.use("/dashboard", dashboardRouter);
  v1.use("/settings", settingsRouter);
  v1.use("/goats", goatRouter);
  v1.use("/cattle", cattleRouter);
  v1.use("/poultry", poultryRouter);
  v1.use("/livestock", livestockRouter);
  v1.use("/crop", cropRouter);
  v1.use("/events", eventsRouter);
  v1.use("/production", productionRouter);
  v1.use("/traceability", traceabilityRouter);
  v1.use("/record", recordRouter);
  v1.use("/payroll", payrollRouter);
  v1.use("/financial", financialRouter);
  v1.use("/weather", weatherRouter);
  v1.use("/advisor", advisorRouter);
  v1.use("/disease", diseaseRouter);
  v1.use("/insights", insightsRouter);

  app.use("/v1", v1);

  app.use(errorHandler);

  return app;
}
