import { Router } from "express";
import { payrollController } from "../../controllers/payroll/payroll.controller";
import { validate } from "../../middleware/validate.middleware";
import {
  createIncidentSchema,
  updateIncidentSchema,
} from "../../validators/payroll/payroll.validator";

export const complianceRouter = Router();

// ── Compliance Alerts ─────────────────────────────────────────────────────────
complianceRouter.get("/compliance-alerts", payrollController.listComplianceAlerts);
complianceRouter.patch("/compliance-alerts/:id/resolve", payrollController.resolveComplianceAlert);

// ── Audit Log ─────────────────────────────────────────────────────────────────
complianceRouter.get("/audit-log", payrollController.listAuditLog);

// ── Incidents ─────────────────────────────────────────────────────────────────
complianceRouter.get("/incidents", payrollController.listIncidents);
complianceRouter.post("/incidents", validate(createIncidentSchema), payrollController.createIncident);
complianceRouter.put("/incidents/:id", validate(updateIncidentSchema), payrollController.updateIncident);
