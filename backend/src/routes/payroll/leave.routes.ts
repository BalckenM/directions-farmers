import { Router } from "express";
import { payrollController } from "../../controllers/payroll/payroll.controller";
import { validate } from "../../middleware/validate.middleware";
import {
    createLeaveRequestSchema,
    createPieceworkLogSchema,
} from "../../validators/payroll/payroll.validator";

export const leaveRouter = Router();

// ── Leave Requests ────────────────────────────────────────────────────────────
leaveRouter.get("/leave-requests", payrollController.listLeaveRequests);
leaveRouter.post(
  "/leave-requests",
  validate(createLeaveRequestSchema),
  payrollController.createLeaveRequest,
);
leaveRouter.patch(
  "/leave-requests/:id/approve",
  payrollController.approveLeave,
);
leaveRouter.patch("/leave-requests/:id/reject", payrollController.rejectLeave);
leaveRouter.patch("/leave-requests/:id/cancel", payrollController.rejectLeave);
leaveRouter.delete("/leave-requests/:id", payrollController.deleteLeaveRequest);

// ── Leave Types & Balances ────────────────────────────────────────────────────
leaveRouter.get("/leave-types", payrollController.listLeaveTypes);
leaveRouter.get("/leave-balances", payrollController.listLeaveBalances);

// ── Piecework ─────────────────────────────────────────────────────────────────
leaveRouter.get("/piecework-logs", payrollController.listPiecework);
leaveRouter.post(
  "/piecework-logs",
  validate(createPieceworkLogSchema),
  payrollController.createPiecework,
);
leaveRouter.delete("/piecework/:id", payrollController.deletePiecework);
