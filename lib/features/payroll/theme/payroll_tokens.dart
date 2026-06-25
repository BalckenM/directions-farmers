import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/features/payroll/models/compliance_alert.dart';
import 'package:mobile_app/features/payroll/models/employment_contract.dart';
import 'package:mobile_app/features/payroll/models/leave_request.dart';
import 'package:mobile_app/features/payroll/models/pay_run.dart';
import 'package:mobile_app/features/payroll/models/payroll_employee.dart';

// ─── Enterprise Payroll Design Tokens ────────────────────────────────────────
//
// Single source of truth for ALL colours, semantic helpers, radii, spacing and
// shadow presets used across the payroll feature. Import only this file.
// lib/core/theme/payroll_design_tokens.dart re-exports this file so that both
// import paths resolve to the same class.

abstract final class PayrollTokens {
  // ── Named palette ──────────────────────────────────────────────────────────
  static const Color navy = Color(0xFF1E3A5F);
  static const Color teal = Color(0xFF00695C);
  static const Color amber = Color(0xFFF57F17);
  static const Color rose = Color(0xFFC62828);
  static const Color indigo = Color(0xFF283593);
  static const Color purple = Color(0xFF6A1B9A);
  static const Color sky = Color(0xFF0277BD);
  static const Color green = Color(0xFF2E7D32);

  // ── Brand ────────────────────────────────────────────────────────────────────
  static const Color brand = AppColors.primary;
  static const Color brandDark = AppColors.primaryDark;
  static const Color brandLight = AppColors.primaryLight;
  static const Color brandContainer = AppColors.primaryContainer;
  static const Color onBrand = AppColors.onPrimary;
  static const Color onBrandContainer = AppColors.onPrimaryContainer;
  static const Color brandSecondary = AppColors.secondary;
  static const Color accent = AppColors.secondary;
  static const Color accentContainer = AppColors.secondaryContainer;

  // ── Status ───────────────────────────────────────────────────────────────────
  static const Color statusSuccess = AppColors.success;
  static const Color statusSuccessContainer = AppColors.successContainer;
  static const Color statusWarning = AppColors.warning;
  static const Color statusWarningContainer = AppColors.warningContainer;
  static const Color statusError = AppColors.error;
  static const Color statusErrorContainer = AppColors.errorContainer;
  static const Color statusInfo = AppColors.info;
  static const Color statusInfoContainer = AppColors.infoContainer;

  // ── Pay Run status colors ────────────────────────────────────────────────────
  static const Color statusDraft = Color(0xFF6B7280);
  static const Color statusDraftContainer = Color(0xFFF3F4F6);
  static const Color statusCalculated = Color(0xFF0284C7);
  static const Color statusCalculatedContainer = Color(0xFFE0F2FE);
  static const Color statusApproved = Color(0xFFD97706);
  static const Color statusApprovedContainer = Color(0xFFFEF3C7);
  static const Color statusDisbursed = Color(0xFF10B981);
  static const Color statusDisbursedContainer = Color(0xFFD1FAE5);
  static const Color statusVoided = Color(0xFFEF4444);
  static const Color statusVoidedContainer = Color(0xFFFEE2E2);

  // ── Leave status colors ───────────────────────────────────────────────────────
  static const Color leavePending = Color(0xFFF59E0B);
  static const Color leavePendingContainer = Color(0xFFFEF3C7);
  static const Color leaveApproved = Color(0xFF10B981);
  static const Color leaveApprovedContainer = Color(0xFFD1FAE5);
  static const Color leaveRejected = Color(0xFFEF4444);
  static const Color leaveRejectedContainer = Color(0xFFFEE2E2);
  static const Color leaveCancelled = Color(0xFF6B7280);
  static const Color leaveCancelledContainer = Color(0xFFF3F4F6);

  // ── Engagement type colors ────────────────────────────────────────────────────
  static const Color permanent = Color(0xFF6366F1); // Indigo
  static const Color permanentContainer = Color(0xFFE0E7FF);
  static const Color seasonal = Color(0xFF10B981); // Emerald
  static const Color seasonalContainer = Color(0xFFD1FAE5);
  static const Color casual = Color(0xFFF59E0B); // Amber
  static const Color casualContainer = Color(0xFFFEF3C7);
  static const Color contractor = Color(0xFF8B5CF6); // Violet
  static const Color contractorContainer = Color(0xFFEDE9FE);

  // ── Surfaces ──────────────────────────────────────────────────────────────────
  static const Color pageBg = Color(0xFFF9FAFB);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color sectionBg = Color(0xFFF3F4F6);
  static const Color inputBg = Color(0xFFF9FAFB);
  static const Color surfaceContainer = Color(0xFFF3F4F6);
  static const Color surfaceContainerHigh = Color(0xFFE5E7EB);

  // ── Borders ───────────────────────────────────────────────────────────────────
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderFocus = AppColors.primary;
  static const Color borderError = Color(0xFFEF4444);

  // ── Text ─────────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textOnBrand = Color(0xFFFFFFFF);

  // ── KPI trend colors ──────────────────────────────────────────────────────────
  static const Color trendUp = Color(0xFF10B981);
  static const Color trendDown = Color(0xFFEF4444);
  static const Color trendFlat = Color(0xFF6B7280);

  // ── Shadows ───────────────────────────────────────────────────────────────────
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  // ── Border radius ──────────────────────────────────────────────────────────────
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(6));
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(8));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(12));
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(16));
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(999));

  // ── Spacing ───────────────────────────────────────────────────────────────────
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double spacingXxl = 48;

  // ── Gradients ─────────────────────────────────────────────────────────────────
  static const heroGradient = LinearGradient(
    colors: [Color(0xFF16A34A), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const heroGradientDark = LinearGradient(
    colors: [Color(0xFF15803D), Color(0xFF047857)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const netPayGradient = LinearGradient(
    colors: [teal, navy],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ── Semantic helpers (enum-based) ─────────────────────────────────────────────

  static Color payRunStatusColor(PayRunStatus s) => switch (s) {
    PayRunStatus.draft => statusDraft,
    PayRunStatus.calculated => statusCalculated,
    PayRunStatus.pendingApproval => statusApproved,
    PayRunStatus.approved => statusDisbursed,
    PayRunStatus.disbursed => statusDisbursed,
    PayRunStatus.cancelled => statusVoided,
  };

  static String payRunStatusLabel(PayRunStatus s) => switch (s) {
    PayRunStatus.draft => 'Draft',
    PayRunStatus.calculated => 'Calculated',
    PayRunStatus.pendingApproval => 'Pending Approval',
    PayRunStatus.approved => 'Approved',
    PayRunStatus.disbursed => 'Disbursed',
    PayRunStatus.cancelled => 'Cancelled',
  };

  static Color leaveStatusColor(LeaveStatus s) => switch (s) {
    LeaveStatus.pending => leavePending,
    LeaveStatus.approved => leaveApproved,
    LeaveStatus.rejected => leaveRejected,
    LeaveStatus.cancelled => leaveCancelled,
  };

  static String leaveStatusLabel(LeaveStatus s) => switch (s) {
    LeaveStatus.pending => 'Pending',
    LeaveStatus.approved => 'Approved',
    LeaveStatus.rejected => 'Rejected',
    LeaveStatus.cancelled => 'Cancelled',
  };

  static Color employmentStatusColor(EmploymentStatus s) => switch (s) {
    EmploymentStatus.active => statusSuccess,
    EmploymentStatus.inactive => statusDraft,
    EmploymentStatus.terminated => statusError,
  };

  static String engagementLabel(EngagementType t) => switch (t) {
    EngagementType.permanent => 'Permanent',
    EngagementType.seasonal => 'Seasonal',
    EngagementType.casual => 'Casual',
    EngagementType.contractor => 'Contractor',
  };

  static String contractTypeLabel(ContractType t) => switch (t) {
    ContractType.permanent => 'Permanent',
    ContractType.fixedTerm => 'Fixed Term',
    ContractType.seasonal => 'Seasonal',
    ContractType.casual => 'Casual',
  };

  static String contractStatusLabel(ContractStatus s) => switch (s) {
    ContractStatus.draft => 'Draft',
    ContractStatus.signed => 'Active',
    ContractStatus.expired => 'Expired',
    ContractStatus.terminated => 'Terminated',
  };

  static Color contractStatusColor(ContractStatus s) => switch (s) {
    ContractStatus.draft => statusDraft,
    ContractStatus.signed => statusSuccess,
    ContractStatus.expired => statusError,
    ContractStatus.terminated => statusError,
  };

  static String disbursementLabel(DisbursementMethod m) => switch (m) {
    DisbursementMethod.bank => 'Bank Transfer',
    DisbursementMethod.cash => 'Cash',
    DisbursementMethod.mtnEwallet => 'MTN eWallet',
    DisbursementMethod.orangeMoney => 'Orange Money',
  };

  static Color complianceSeverityColor(ComplianceSeverity s) => switch (s) {
    ComplianceSeverity.critical => statusError,
    ComplianceSeverity.warning => statusWarning,
    ComplianceSeverity.info => statusInfo,
  };

  // ── Semantic helpers (string-based, for flexibility with API responses) ────────

  /// Returns (foreground, background) for a pay run status string.
  static (Color fg, Color bg) payRunStatusColors(String status) =>
      switch (status.toLowerCase()) {
        'draft' => (statusDraft, statusDraftContainer),
        'calculated' => (statusCalculated, statusCalculatedContainer),
        'pendingapproval' => (statusApproved, statusApprovedContainer),
        'approved' => (statusApproved, statusApprovedContainer),
        'disbursed' => (statusDisbursed, statusDisbursedContainer),
        'cancelled' || 'voided' => (statusVoided, statusVoidedContainer),
        _ => (statusDraft, statusDraftContainer),
      };

  /// Returns (foreground, background) for a leave status string.
  static (Color fg, Color bg) leaveStatusColors(String status) =>
      switch (status.toLowerCase()) {
        'pending' => (leavePending, leavePendingContainer),
        'approved' => (leaveApproved, leaveApprovedContainer),
        'rejected' => (leaveRejected, leaveRejectedContainer),
        'cancelled' => (leaveCancelled, leaveCancelledContainer),
        _ => (leavePending, leavePendingContainer),
      };

  /// Returns (foreground, background) for an engagement type string.
  static (Color fg, Color bg) engagementColors(String type) =>
      switch (type.toLowerCase()) {
        'permanent' => (permanent, permanentContainer),
        'seasonal' => (seasonal, seasonalContainer),
        'casual' => (casual, casualContainer),
        'contractor' => (contractor, contractorContainer),
        _ => (permanent, permanentContainer),
      };
}
