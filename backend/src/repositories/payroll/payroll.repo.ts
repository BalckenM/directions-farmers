import { payrollEmployeesRepo } from "./employees.repo";
import { payrollContractsRepo } from "./contracts.repo";
import { payrollPayRunsRepo } from "./pay-runs.repo";
import { payrollPayslipsRepo } from "./payslips.repo";
import { payrollLeaveRequestsRepo } from "./leave-requests.repo";
import { payrollLeaveRepo } from "./leave.repo";
import { payrollPieceworkRepo } from "./piecework.repo";
import { payrollDeductionsRepo } from "./deductions.repo";
import { payrollTransactionsRepo } from "./transactions.repo";
import { payrollContractsFlatRepo } from "./contracts-flat.repo";
import { payrollPayGroupsRepo } from "./pay-groups.repo";
import { payrollPayStructuresRepo } from "./pay-structures.repo";
import { payrollLeaveBalancesRepo } from "./leave-balances.repo";
import { payrollComplianceRepo } from "./compliance.repo";
import { payrollAuditRepo } from "./audit.repo";
import { payrollCommunicationsRepo } from "./communications.repo";

export const payrollRepo = {
  ...payrollEmployeesRepo,
  ...payrollContractsRepo,
  ...payrollPayRunsRepo,
  ...payrollPayslipsRepo,
  ...payrollLeaveRequestsRepo,
  ...payrollLeaveRepo,
  ...payrollPieceworkRepo,
  ...payrollDeductionsRepo,
  ...payrollTransactionsRepo,
  ...payrollContractsFlatRepo,
  ...payrollPayGroupsRepo,
  ...payrollPayStructuresRepo,
  ...payrollLeaveBalancesRepo,
  ...payrollComplianceRepo,
  ...payrollAuditRepo,
  ...payrollCommunicationsRepo,
};
