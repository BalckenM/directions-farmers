import { payrollEmployeesController } from "./employees.controller";
import { payrollEmployeesController } from "./employees.controller";
import { payrollContractsController } from "./contracts.controller";
import { payrollPayRunsController } from "./pay-runs.controller";
import { payrollPayslipsController } from "./payslips.controller";
import { payrollLeaveController } from "./leave.controller";
import { payrollDeductionsController } from "./deductions.controller";
import { payrollContractsFlatController } from "./contracts-flat.controller";
import { payrollPayGroupsController } from "./pay-groups.controller";
import { payrollPayStructuresController } from "./pay-structures.controller";
import { payrollLeaveBalancesController } from "./leave-balances.controller";
import { payrollComplianceController } from "./compliance.controller";
import { payrollAuditController } from "./audit.controller";
import { payrollCommunicationsController } from "./communications.controller";

export const payrollController = {
  ...payrollEmployeesController,
  ...payrollEmployeesController,
  ...payrollContractsController,
  ...payrollPayRunsController,
  ...payrollPayslipsController,
  ...payrollLeaveController,
  ...payrollDeductionsController,
  ...payrollContractsFlatController,
  ...payrollPayGroupsController,
  ...payrollPayStructuresController,
  ...payrollLeaveBalancesController,
  ...payrollComplianceController,
  ...payrollAuditController,
  ...payrollCommunicationsController,
};
