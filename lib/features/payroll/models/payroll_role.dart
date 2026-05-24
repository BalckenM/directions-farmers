// Payroll RBAC — roles and per-action permissions.

/// Roles that a user can hold within the payroll module.
enum PayrollRole {
  /// Farm owner — unrestricted access including approve, disburse, and configure.
  owner,

  /// Payroll manager — can create pay runs, approve up to their tier, manage employees.
  payrollManager,

  /// Supervisor — can record attendance, view own team payslips, approve leave.
  supervisor,

  /// Worker / labourer — read-only self-service: own payslips, leave, disputes.
  worker,

  /// External auditor — read-only access to all payroll records; no mutations.
  auditor,
}

/// Granular permissions used to gate UI actions and service calls.
enum PayrollPermission {
  // Pay run
  viewPayRuns,
  createPayRun,
  approvePayRun,
  disbursePayRun,
  deletePayRun,

  // Employees
  viewAllEmployees,
  manageEmployees,
  terminateEmployee,

  // Payslips
  viewAllPayslips,
  viewOwnPayslip,

  // Leave
  viewAllLeave,
  approveLeave,
  submitLeaveRequest,

  // Compliance / reports
  viewComplianceAlerts,
  exportEmp201,
  exportEmp501,
  exportIrp5,
  exportSdl,
  exportUif,

  // Settings
  configurePayGroups,
  configureDeductionRules,
  configurePayStructures,

  // Disputes
  submitDispute,
  resolveDispute,
  viewAllDisputes,
}

/// Returns the set of permissions granted to [role].
Set<PayrollPermission> permissionsForRole(PayrollRole role) {
  switch (role) {
    case PayrollRole.owner:
      return PayrollPermission.values.toSet();

    case PayrollRole.payrollManager:
      return {
        PayrollPermission.viewPayRuns,
        PayrollPermission.createPayRun,
        PayrollPermission.approvePayRun,
        PayrollPermission.viewAllEmployees,
        PayrollPermission.manageEmployees,
        PayrollPermission.viewAllPayslips,
        PayrollPermission.viewOwnPayslip,
        PayrollPermission.viewAllLeave,
        PayrollPermission.approveLeave,
        PayrollPermission.viewComplianceAlerts,
        PayrollPermission.exportEmp201,
        PayrollPermission.exportEmp501,
        PayrollPermission.exportIrp5,
        PayrollPermission.exportSdl,
        PayrollPermission.exportUif,
        PayrollPermission.configureDeductionRules,
        PayrollPermission.viewAllDisputes,
        PayrollPermission.resolveDispute,
      };

    case PayrollRole.supervisor:
      return {
        PayrollPermission.viewPayRuns,
        PayrollPermission.viewAllEmployees,
        PayrollPermission.viewAllPayslips,
        PayrollPermission.viewOwnPayslip,
        PayrollPermission.viewAllLeave,
        PayrollPermission.approveLeave,
        PayrollPermission.submitLeaveRequest,
        PayrollPermission.viewComplianceAlerts,
        PayrollPermission.viewAllDisputes,
      };

    case PayrollRole.worker:
      return {
        PayrollPermission.viewOwnPayslip,
        PayrollPermission.submitLeaveRequest,
        PayrollPermission.submitDispute,
      };

    case PayrollRole.auditor:
      return {
        PayrollPermission.viewPayRuns,
        PayrollPermission.viewAllEmployees,
        PayrollPermission.viewAllPayslips,
        PayrollPermission.viewAllLeave,
        PayrollPermission.viewComplianceAlerts,
        PayrollPermission.exportEmp201,
        PayrollPermission.exportEmp501,
        PayrollPermission.exportIrp5,
        PayrollPermission.exportSdl,
        PayrollPermission.exportUif,
        PayrollPermission.viewAllDisputes,
      };
  }
}
