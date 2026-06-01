import { Router } from "express";
import { payrollController } from "../../controllers/payroll/payroll.controller";
import { validate } from "../../middleware/validate.middleware";
import {
    createContractSchema,
    createDeductionRuleSchema,
    createEmployeeSchema,
    createGarnisheeOrderSchema,
    createPayGroupSchema,
    createPayStructureSchema,
    updateDeductionRuleSchema,
    updateEmployeeSchema,
    updateGarnisheeOrderSchema,
    updatePayGroupSchema,
    updatePayStructureSchema,
} from "../../validators/payroll/payroll.validator";

export const employeesRouter = Router();

// ── Employees ─────────────────────────────────────────────────────────────────
employeesRouter.get("/employees", payrollController.listEmployees);
employeesRouter.post("/employees", validate(createEmployeeSchema), payrollController.createEmployee);
employeesRouter.get("/employees/:id", payrollController.getEmployee);
employeesRouter.put("/employees/:id", validate(updateEmployeeSchema), payrollController.updateEmployee);
employeesRouter.delete("/employees/:id", payrollController.deleteEmployee);
employeesRouter.patch("/employees/:id/terminate", payrollController.terminateEmployee);

// ── Contracts ─────────────────────────────────────────────────────────────────
employeesRouter.get("/contracts", payrollController.listAllContracts);
employeesRouter.post("/contracts", validate(createContractSchema), payrollController.createContract);
employeesRouter.put("/contracts/:id", payrollController.updateContractById);
employeesRouter.patch("/contracts/:id/void", payrollController.voidContract);
employeesRouter.get("/employees/:id/contracts", payrollController.listContracts);

// ── Pay Groups ────────────────────────────────────────────────────────────────
employeesRouter.get("/pay-groups", payrollController.listPayGroups);
employeesRouter.post("/pay-groups", validate(createPayGroupSchema), payrollController.createPayGroup);
employeesRouter.put("/pay-groups/:id", validate(updatePayGroupSchema), payrollController.updatePayGroup);
employeesRouter.patch("/pay-groups/:id/deactivate", payrollController.deactivatePayGroup);

// ── Pay Structures ────────────────────────────────────────────────────────────
employeesRouter.get("/pay-structures", payrollController.listPayStructures);
employeesRouter.post("/pay-structures", validate(createPayStructureSchema), payrollController.createPayStructure);
employeesRouter.put("/pay-structures/:id", validate(updatePayStructureSchema), payrollController.updatePayStructure);

// ── Payslips ──────────────────────────────────────────────────────────────────
employeesRouter.get("/payslips", payrollController.listPayslips);
employeesRouter.get("/payslips/:id", payrollController.getPayslip);

// ── Deductions ────────────────────────────────────────────────────────────────
// Canonical path — Flutter uses /deductions, not /deduction-rules
employeesRouter.get("/deductions", payrollController.listDeductionRules);
employeesRouter.post("/deductions", validate(createDeductionRuleSchema), payrollController.createDeductionRule);
employeesRouter.put("/deductions/:id", validate(updateDeductionRuleSchema), payrollController.updateDeductionRule);
employeesRouter.patch("/deductions/:id/deactivate", payrollController.deactivateDeductionRule);
// Legacy alias kept for backwards compat
employeesRouter.get("/deduction-rules", payrollController.listDeductionRules);

// ── Garnishee Orders ──────────────────────────────────────────────────────────
employeesRouter.get("/garnishee-orders", payrollController.listGarnisheeOrders);
employeesRouter.post("/garnishee-orders", validate(createGarnisheeOrderSchema), payrollController.createGarnisheeOrder);
employeesRouter.put("/garnishee-orders/:id", validate(updateGarnisheeOrderSchema), payrollController.updateGarnisheeOrder);

// ── Transactions ──────────────────────────────────────────────────────────────
employeesRouter.get("/transactions", payrollController.listTransactions);
