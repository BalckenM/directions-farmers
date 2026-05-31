// ── Module routes (each module has its own folder) ────────────────────────────
export { cattleRouter } from "./cattle";
export { cropRouter } from "./crop";
export { goatRouter } from "./goat";
export { payrollRouter } from "./payroll";
export { poultryRouter } from "./poultry";

// ── Shared / infrastructure routes ───────────────────────────────────────────
export { advisorRouter } from "./advisor.routes";
export { authRouter } from "./auth.routes";
export { dashboardRouter } from "./dashboard.routes";
export { diseaseRouter } from "./disease.routes";
export { eventsRouter } from "./events.routes";
export { farmRouter } from "./farm.routes";
export { financialRouter } from "./financial.routes";
export { insightsRouter } from "./insights.routes";
export { livestockRouter } from "./livestock.routes";
export { productionRouter } from "./production.routes";
export { recordRouter } from "./record.routes";
export { settingsRouter } from "./settings.routes";
export { traceabilityRouter } from "./traceability.routes";
export { weatherRouter } from "./weather.routes";
