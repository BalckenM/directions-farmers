import { payrollAuditService } from "./audit.service";
import { payrollCommunicationsService } from "./communications.service";
import { payrollComplianceService } from "./compliance.service";
import { payrollContractsFlatService } from "./contracts-flat.service";
import { payrollContractsService } from "./contracts.service";
import { payrollDeductionsService } from "./deductions.service";
import { payrollEmployeesService } from "./employees.service";
import { payrollLeaveBalancesService } from "./leave-balances.service";
import { payrollLeaveService } from "./leave.service";
import { payrollPayGroupsService } from "./pay-groups.service";
import { payrollPayRunsService } from "./pay-runs.service";
import { payrollPayStructuresService } from "./pay-structures.service";
import { payrollPayslipsService } from "./payslips.service";

export const payrollService = {
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
