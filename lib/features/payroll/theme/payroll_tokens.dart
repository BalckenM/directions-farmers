import 'package:flutter/material.dart';

import '../models/compliance_alert.dart';
import '../models/employment_contract.dart';
import '../models/leave_request.dart';
import '../models/pay_run.dart';
import '../models/payroll_employee.dart';

// ─── Enterprise Payroll Design Tokens ────────────────────────────────────────
//
// Single source of truth for all colours, semantic helpers, and label maps
// used across the payroll feature. Import this instead of redeclaring
// local const colours in individual screens.

abstract final class PayrollTokens {
  // ── Brand palette ──────────────────────────────────────────────────────────
  static const navy   = Color(0xFF1E3A5F);
  static const teal   = Color(0xFF00695C);
  static const amber  = Color(0xFFF57F17);
  static const rose   = Color(0xFFC62828);
  static const indigo = Color(0xFF283593);
  static const purple = Color(0xFF6A1B9A);
  static const sky    = Color(0xFF0277BD);
  static const green  = Color(0xFF2E7D32);

  // ── Workforce donut palette ────────────────────────────────────────────────
  static const permanent = navy;
  static const seasonal  = Color(0xFF0288D1);
  static const casual    = Color(0xFF81D4FA);

  // ── Pay run status ─────────────────────────────────────────────────────────
  static Color payRunStatusColor(PayRunStatus s) => switch (s) {
    PayRunStatus.draft           => const Color(0xFF757575),
    PayRunStatus.calculated      => sky,
    PayRunStatus.pendingApproval => amber,
    PayRunStatus.approved        => teal,
    PayRunStatus.disbursed       => green,
    PayRunStatus.cancelled       => rose,
  };

  static String payRunStatusLabel(PayRunStatus s) => switch (s) {
    PayRunStatus.draft           => 'Draft',
    PayRunStatus.calculated      => 'Calculated',
    PayRunStatus.pendingApproval => 'Pending Approval',
    PayRunStatus.approved        => 'Approved',
    PayRunStatus.disbursed       => 'Disbursed',
    PayRunStatus.cancelled       => 'Cancelled',
  };

  // ── Leave status ───────────────────────────────────────────────────────────
  static Color leaveStatusColor(LeaveStatus s) => switch (s) {
    LeaveStatus.pending   => amber,
    LeaveStatus.approved  => teal,
    LeaveStatus.rejected  => rose,
    LeaveStatus.cancelled => const Color(0xFF757575),
  };

  static String leaveStatusLabel(LeaveStatus s) => switch (s) {
    LeaveStatus.pending   => 'Pending',
    LeaveStatus.approved  => 'Approved',
    LeaveStatus.rejected  => 'Rejected',
    LeaveStatus.cancelled => 'Cancelled',
  };

  // ── Employment status ──────────────────────────────────────────────────────
  static Color employmentStatusColor(EmploymentStatus s) => switch (s) {
    EmploymentStatus.active     => green,
    EmploymentStatus.inactive   => Color.fromARGB(255, 117, 117, 117),
    EmploymentStatus.terminated => rose,
  };

  // ── Engagement type labels ─────────────────────────────────────────────────
  static String engagementLabel(EngagementType t) => switch (t) {
    EngagementType.permanent  => 'Permanent',
    EngagementType.seasonal   => 'Seasonal',
    EngagementType.casual     => 'Casual',
    EngagementType.contractor => 'Contractor',
  };

  // ── Contract type labels ───────────────────────────────────────────────────
  static String contractTypeLabel(ContractType t) => switch (t) {
    ContractType.permanent  => 'Permanent',
    ContractType.fixedTerm  => 'Fixed Term',
    ContractType.seasonal   => 'Seasonal',
    ContractType.casual     => 'Casual',
  };

  // ── Contract status labels + colors ───────────────────────────────────────
  static String contractStatusLabel(ContractStatus s) => switch (s) {
    ContractStatus.draft      => 'Draft',
    ContractStatus.signed     => 'Active',
    ContractStatus.expired    => 'Expired',
    ContractStatus.terminated => 'Terminated',
  };

  static Color contractStatusColor(ContractStatus s) => switch (s) {
    ContractStatus.draft      => const Color(0xFF757575),
    ContractStatus.signed     => green,
    ContractStatus.expired    => rose,
    ContractStatus.terminated => rose,
  };

  // ── Disbursement method labels ─────────────────────────────────────────────
  static String disbursementLabel(DisbursementMethod m) => switch (m) {
    DisbursementMethod.bank        => 'Bank Transfer',
    DisbursementMethod.cash        => 'Cash',
    DisbursementMethod.mtnEwallet  => 'MTN eWallet',
    DisbursementMethod.orangeMoney => 'Orange Money',
  };

  // ── Compliance severity ────────────────────────────────────────────────────
  static Color complianceSeverityColor(ComplianceSeverity s) => switch (s) {
    ComplianceSeverity.critical => rose,
    ComplianceSeverity.warning  => amber,
    ComplianceSeverity.info     => sky,
  };

  // ── Gradient helpers ───────────────────────────────────────────────────────
  static const heroGradient = LinearGradient(
    colors: [navy, Color(0xFF2E5984)],
    begin: Alignment.topLeft,
    end:   Alignment.bottomRight,
  );

  static const netPayGradient = LinearGradient(
    colors: [teal, navy],
    begin: Alignment.centerLeft,
    end:   Alignment.centerRight,
  );
}
