import { payrollEmployeesService } from "./employees.service";
import { payrollEmployeesService } from "./employees.service";
import { payrollContractsService } from "./contracts.service";
import { payrollPayRunsService } from "./pay-runs.service";
import { payrollPayslipsService } from "./payslips.service";
import { payrollLeaveService } from "./leave.service";
import { payrollDeductionsService } from "./deductions.service";
import { payrollContractsFlatService } from "./contracts-flat.service";
import { payrollPayGroupsService } from "./pay-groups.service";
import { payrollPayStructuresService } from "./pay-structures.service";
import { payrollLeaveBalancesService } from "./leave-balances.service";
import { payrollComplianceService } from "./compliance.service";
import { payrollAuditService } from "./audit.service";
import { payrollCommunicationsService } from "./communications.service";

export const payrollService = {
  ...payrollEmployeesService,
  ...payrollEmployeesService,
  ...payrollContractsService,
  ...payrollPayRunsService,
  ...payrollPayslipsService,
  ...payrollLeaveService,
  ...payrollDeductionsService,
  ...payrollContractsFlatService,
  ...payrollPayGroupsService,
  ...payrollPayStructuresService,
  ...payrollLeaveBalancesService,
  ...payrollComplianceService,
  ...payrollAuditService,
  ...payrollCommunicationsService,
};
