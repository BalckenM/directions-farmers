import { Router } from "express";
import { authenticate } from "../../middleware/auth.middleware";
import { requireModule } from "../../middleware/module-guard.middleware";
import { communicationsRouter } from "./communications.routes";
import { complianceRouter } from "./compliance.routes";
import { employeesRouter } from "./employees.routes";
import { leaveRouter } from "./leave.routes";
import { operationsRouter } from "./operations.routes";
import { payRunsRouter } from "./pay-runs.routes";

export const payrollRouter = Router();

payrollRouter.use(authenticate, requireModule("payroll"));

payrollRouter.use(employeesRouter);
payrollRouter.use(payRunsRouter);
payrollRouter.use(leaveRouter);
payrollRouter.use(complianceRouter);
payrollRouter.use(communicationsRouter);
payrollRouter.use(operationsRouter);
