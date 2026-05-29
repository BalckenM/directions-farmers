import { Router } from "express";
import { payrollController } from "../controllers/payroll/payroll.controller";
import { authenticate } from "../middleware/auth.middleware";
import { requireModule } from "../middleware/module-guard.middleware";
import { validate } from "../middleware/validate.middleware";
import {
    createContractSchema,
    createDeductionRuleSchema,
    createEmployeeSchema,
    createGarnisheeOrderSchema,
    createIncidentSchema,
    createLeaveRequestSchema,
    createPayGroupSchema,
    createPayRunSchema,
    createPayStructureSchema,
    createPieceworkLogSchema,
    sendCommunicationSchema,
    updateDeductionRuleSchema,
    updateEmployeeSchema,
    updateGarnisheeOrderSchema,
    updateIncidentSchema,
    updatePayGroupSchema,
    updatePayStructureSchema,
} from "../validators/payroll.validator";

export const payrollRouter = Router();

payrollRouter.use(authenticate, requireModule("payroll"));

// Employees
payrollRouter.get("/employees", payrollController.listEmployees);
payrollRouter.post(
  "/employees",
  validate(createEmployeeSchema),
  payrollController.createEmployee,
);
payrollRouter.get("/employees/:id", payrollController.getEmployee);
payrollRouter.put(
  "/employees/:id",
  validate(updateEmployeeSchema),
  payrollController.updateEmployee,
);
payrollRouter.delete("/employees/:id", payrollController.deleteEmployee);

// Contracts — flat list and per-employee list
payrollRouter.get("/contracts", payrollController.listAllContracts);
payrollRouter.post(
  "/contracts",
  validate(createContractSchema),
  payrollController.createContract,
);
payrollRouter.patch("/contracts/:id/void", payrollController.voidContract);
payrollRouter.get("/employees/:id/contracts", payrollController.listContracts);

// Pay groups
payrollRouter.get("/pay-groups", payrollController.listPayGroups);
payrollRouter.post(
  "/pay-groups",
  validate(createPayGroupSchema),
  payrollController.createPayGroup,
);
payrollRouter.put(
  "/pay-groups/:id",
  validate(updatePayGroupSchema),
  payrollController.updatePayGroup,
);

// Pay structures
payrollRouter.get("/pay-structures", payrollController.listPayStructures);
payrollRouter.post(
  "/pay-structures",
  validate(createPayStructureSchema),
  payrollController.createPayStructure,
);
payrollRouter.put(
  "/pay-structures/:id",
  validate(updatePayStructureSchema),
  payrollController.updatePayStructure,
);

// Pay runs
payrollRouter.get("/pay-runs", payrollController.listPayRuns);
payrollRouter.post(
  "/pay-runs",
  validate(createPayRunSchema),
  payrollController.createPayRun,
);
payrollRouter.get("/pay-runs/:id", payrollController.getPayRun);
payrollRouter.post("/pay-runs/:id/finalize", payrollController.finalizePayRun);

// Payslips
payrollRouter.get("/payslips", payrollController.listPayslips);
payrollRouter.get("/payslips/:id", payrollController.getPayslip);

// Deductions (canonical path — Flutter uses /deductions, not /deduction-rules)
payrollRouter.get("/deductions", payrollController.listDeductionRules);
payrollRouter.post(
  "/deductions",
  validate(createDeductionRuleSchema),
  payrollController.createDeductionRule,
);
payrollRouter.put(
  "/deductions/:id",
  validate(updateDeductionRuleSchema),
  payrollController.updateDeductionRule,
);
payrollRouter.patch(
  "/deductions/:id/deactivate",
  payrollController.deactivateDeductionRule,
);
// Legacy alias kept for backwards compat
payrollRouter.get("/deduction-rules", payrollController.listDeductionRules);

// Garnishee orders
payrollRouter.get("/garnishee-orders", payrollController.listGarnisheeOrders);
payrollRouter.post(
  "/garnishee-orders",
  validate(createGarnisheeOrderSchema),
  payrollController.createGarnisheeOrder,
);
payrollRouter.put(
  "/garnishee-orders/:id",
  validate(updateGarnisheeOrderSchema),
  payrollController.updateGarnisheeOrder,
);

// Leave requests
payrollRouter.get("/leave-requests", payrollController.listLeaveRequests);
payrollRouter.post(
  "/leave-requests",
  validate(createLeaveRequestSchema),
  payrollController.createLeaveRequest,
);
payrollRouter.put(
  "/leave-requests/:id/approve",
  payrollController.approveLeave,
);
payrollRouter.put("/leave-requests/:id/reject", payrollController.rejectLeave);
payrollRouter.patch(
  "/leave-requests/:id/cancel",
  payrollController.rejectLeave,
);
payrollRouter.delete(
  "/leave-requests/:id",
  payrollController.deleteLeaveRequest,
);

// Leave types
payrollRouter.get("/leave-types", payrollController.listLeaveTypes);

// Leave balances
payrollRouter.get("/leave-balances", payrollController.listLeaveBalances);

// Piecework
payrollRouter.get("/piecework-logs", payrollController.listPiecework);
payrollRouter.post(
  "/piecework-logs",
  validate(createPieceworkLogSchema),
  payrollController.createPiecework,
);
payrollRouter.delete("/piecework/:id", payrollController.deletePiecework);

// Transactions
payrollRouter.get("/transactions", payrollController.listTransactions);

// Compliance alerts
payrollRouter.get("/compliance-alerts", payrollController.listComplianceAlerts);
payrollRouter.patch(
  "/compliance-alerts/:id/resolve",
  payrollController.resolveComplianceAlert,
);

// Audit log
payrollRouter.get("/audit-log", payrollController.listAuditLog);

// Incidents
payrollRouter.get("/incidents", payrollController.listIncidents);
payrollRouter.post(
  "/incidents",
  validate(createIncidentSchema),
  payrollController.createIncident,
);
payrollRouter.put(
  "/incidents/:id",
  validate(updateIncidentSchema),
  payrollController.updateIncident,
);

// Communications
payrollRouter.get("/communications", payrollController.listCommunications);
payrollRouter.post(
  "/communications",
  validate(sendCommunicationSchema),
  payrollController.sendCommunication,
);
