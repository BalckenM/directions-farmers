import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_colors.dart';

/// Design tokens specific to the Payroll module.
/// Agriculture aesthetic — clean white, bold green, clear hierarchy.
abstract final class PayrollTokens {
  // ── Brand ────────────────────────────────────────────────────────────────────
  static const Color brand = AppColors.primary; // Indigo 500
  static const Color brandDark = AppColors.primaryDark; // Indigo 600
  static const Color brandLight = AppColors.primaryLight; // Indigo 400
  static const Color brandContainer = AppColors.primaryContainer; // Indigo 100
  static const Color onBrand = AppColors.onPrimary;
  static const Color onBrandContainer = AppColors.onPrimaryContainer;

  // ── Brand secondary ──────────────────────────────────────────────────────────
  static const Color brandSecondary = AppColors.secondary; // Violet 500

  // ── Accent ───────────────────────────────────────────────────────────────────
  static const Color accent = AppColors.secondary; // Violet 500
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

  // ── Pay Run Statuses ─────────────────────────────────────────────────────────
  static const Color statusDraft = Color(0xFF6B7280); // Gray 500
  static const Color statusDraftContainer = Color(0xFFF3F4F6); // Gray 100
  static const Color statusCalculated = Color(0xFF0284C7); // Sky 600
  static const Color statusCalculatedContainer = Color(0xFFE0F2FE); // Sky 100
  static const Color statusApproved = Color(0xFFD97706); // Amber 600
  static const Color statusApprovedContainer = Color(0xFFFEF3C7); // Amber 100
  static const Color statusDisbursed = Color(0xFF10B981); // Emerald 500
  static const Color statusDisbursedContainer = Color(
    0xFFD1FAE5,
  ); // Emerald 100
  static const Color statusVoided = Color(0xFFEF4444); // Red 500
  static const Color statusVoidedContainer = Color(0xFFFEE2E2); // Red 100

  // ── Leave Status ─────────────────────────────────────────────────────────────
  static const Color leavePending = Color(0xFFF59E0B);
  static const Color leavePendingContainer = Color(0xFFFEF3C7);
  static const Color leaveApproved = Color(0xFF10B981);
  static const Color leaveApprovedContainer = Color(0xFFD1FAE5);
  static const Color leaveRejected = Color(0xFFEF4444);
  static const Color leaveRejectedContainer = Color(0xFFFEE2E2);
  static const Color leaveCancelled = Color(0xFF6B7280);
  static const Color leaveCancelledContainer = Color(0xFFF3F4F6);

  // ── Surfaces ─────────────────────────────────────────────────────────────────
  static const Color pageBg = Color(0xFFF9FAFB); // Gray 50 — page background
  static const Color cardBg = Color(0xFFFFFFFF); // White — card surface
  static const Color sectionBg = Color(
    0xFFF3F4F6,
  ); // Gray 100 — grouped sections
  static const Color inputBg = Color(0xFFF9FAFB); // Gray 50 — text field fill
  static const Color surfaceContainer = Color(0xFFF3F4F6); // Gray 100
  static const Color surfaceContainerHigh = Color(0xFFE5E7EB); // Gray 200

  // ── Borders ───────────────────────────────────────────────────────────────────
  static const Color border = Color(0xFFE5E7EB); // Gray 200
  static const Color borderFocus = AppColors.primary; // Green 600
  static const Color borderError = Color(0xFFEF4444); // Red 500

  // ── Text ─────────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF111827); // Gray 900
  static const Color textSecondary = Color(0xFF6B7280); // Gray 500
  static const Color textMuted = Color(0xFF9CA3AF); // Gray 400
  static const Color textOnBrand = Color(0xFFFFFFFF);

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

  // ── Border radius ─────────────────────────────────────────────────────────────
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

  // ── Engagement type colors ────────────────────────────────────────────────────
  static const Color permanent = Color(0xFF6366F1); // Indigo
  static const Color permanentContainer = Color(0xFFE0E7FF);
  static const Color seasonal = Color(0xFF10B981); // Emerald
  static const Color seasonalContainer = Color(0xFFD1FAE5);
  static const Color casual = Color(0xFFF59E0B); // Amber
  static const Color casualContainer = Color(0xFFFEF3C7);
  static const Color contractor = Color(0xFF8B5CF6); // Violet
  static const Color contractorContainer = Color(0xFFEDE9FE);

  // ── KPI trend colors ─────────────────────────────────────────────────────────
  static const Color trendUp = Color(0xFF10B981);
  static const Color trendDown = Color(0xFFEF4444);
  static const Color trendFlat = Color(0xFF6B7280);

  /// Returns status color pair (foreground, background) for a pay run status.
  static (Color fg, Color bg) payRunStatusColors(String status) {
    return switch (status.toLowerCase()) {
      'draft' => (statusDraft, statusDraftContainer),
      'calculated' => (statusCalculated, statusCalculatedContainer),
      'approved' => (statusApproved, statusApprovedContainer),
      'disbursed' => (statusDisbursed, statusDisbursedContainer),
      'voided' => (statusVoided, statusVoidedContainer),
      _ => (statusDraft, statusDraftContainer),
    };
  }

  /// Returns status color pair for a leave status.
  static (Color fg, Color bg) leaveStatusColors(String status) {
    return switch (status.toLowerCase()) {
      'pending' => (leavePending, leavePendingContainer),
      'approved' => (leaveApproved, leaveApprovedContainer),
      'rejected' => (leaveRejected, leaveRejectedContainer),
      'cancelled' => (leaveCancelled, leaveCancelledContainer),
      _ => (leavePending, leavePendingContainer),
    };
  }

  /// Returns engagement type color pair (foreground, background).
  static (Color fg, Color bg) engagementColors(String type) {
    return switch (type.toLowerCase()) {
      'permanent' => (permanent, permanentContainer),
      'seasonal' => (seasonal, seasonalContainer),
      'casual' => (casual, casualContainer),
      'contractor' => (contractor, contractorContainer),
      _ => (permanent, permanentContainer),
    };
  }
}
