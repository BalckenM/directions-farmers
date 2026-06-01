import { Router } from "express";
import { payrollController } from "../../controllers/payroll/payroll.controller";
import { validate } from "../../middleware/validate.middleware";
import { createPayRunSchema } from "../../validators/payroll/payroll.validator";

export const payRunsRouter = Router();

payRunsRouter.get("/pay-runs", payrollController.listPayRuns);
payRunsRouter.post("/pay-runs", validate(createPayRunSchema), payrollController.createPayRun);
payRunsRouter.post("/pay-runs/calculate", payrollController.calculatePayRun);
payRunsRouter.get("/pay-runs/:id", payrollController.getPayRun);
payRunsRouter.post("/pay-runs/:id/finalize", payrollController.finalizePayRun);
payRunsRouter.patch("/pay-runs/:id/approve", payrollController.approvePayRun);
payRunsRouter.patch("/pay-runs/:id/disburse", payrollController.disbursePayRun);
