import { payrollAttendanceController } from "./attendance.controller";
import { payrollAuditController } from "./audit.controller";
import { payrollCommunicationsController } from "./communications.controller";
import { payrollComplianceController } from "./compliance.controller";
import { payrollContractsFlatController } from "./contracts-flat.controller";
import { payrollContractsController } from "./contracts.controller";
import { payrollDeductionsController } from "./deductions.controller";
import { payrollEmployeesController } from "./employees.controller";
import { payrollEmployerConfigController } from "./employer-config.controller";
import { payrollLeaveBalancesController } from "./leave-balances.controller";
import { payrollLeaveController } from "./leave.controller";
import { payrollPayGroupsController } from "./pay-groups.controller";
import { payrollPayRunsController } from "./pay-runs.controller";
import { payrollPayStructuresController } from "./pay-structures.controller";
import { payrollPayslipsController } from "./payslips.controller";
import { payrollShiftsController } from "./shifts.controller";
import { payrollTaskAssignmentsController } from "./task-assignments.controller";

export const payrollController = {
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
  ...payrollShiftsController,
  ...payrollTaskAssignmentsController,
  ...payrollAttendanceController,
  ...payrollEmployerConfigController,
};
