import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography system for FarmTrack.
/// Primary font: Inter (body, labels, UI)
/// Display font: Plus Jakarta Sans (headlines, hero numbers)
abstract final class AppTypography {
  // ── Font family helpers ───────────────────────────────────────────────────────
  static TextStyle _inter({
    required double size,
    FontWeight weight = FontWeight.w400,
    double? height,
    double? letterSpacing,
    Color? color,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        height: height != null ? height / size : null,
        letterSpacing: letterSpacing,
        color: color,
      );

  static TextStyle _jakarta({
    required double size,
    FontWeight weight = FontWeight.w400,
    double? height,
    double? letterSpacing,
    Color? color,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        height: height != null ? height / size : null,
        letterSpacing: letterSpacing,
        color: color,
      );

  // ── Material 3 TextTheme ─────────────────────────────────────────────────────

  static TextTheme get textTheme => TextTheme(
        // Display — hero stats and section heroes
        displayLarge: _jakarta(size: 57, height: 64, letterSpacing: -0.25),
        displayMedium: _jakarta(size: 45, height: 52),
        displaySmall: _jakarta(size: 36, height: 44),

        // Headline — page and section titles
        headlineLarge: _jakarta(
            size: 32, weight: FontWeight.w600, height: 40, letterSpacing: -0.5),
        headlineMedium: _jakarta(
            size: 28, weight: FontWeight.w600, height: 36, letterSpacing: -0.25),
        headlineSmall: _jakarta(size: 24, weight: FontWeight.w600, height: 32),

        // Title — card titles, dialog titles, list primaries
        titleLarge: _inter(
            size: 22, weight: FontWeight.w600, height: 28, letterSpacing: 0),
        titleMedium: _inter(
            size: 16, weight: FontWeight.w600, height: 24, letterSpacing: 0.15),
        titleSmall: _inter(
            size: 14, weight: FontWeight.w600, height: 20, letterSpacing: 0.1),

        // Body — descriptions, list secondaries
        bodyLarge:
            _inter(size: 16, height: 24, letterSpacing: 0.5),
        bodyMedium:
            _inter(size: 14, height: 20, letterSpacing: 0.25),
        bodySmall:
            _inter(size: 12, height: 16, letterSpacing: 0.4),

        // Label — buttons, form labels, chips
        labelLarge: _inter(
            size: 14, weight: FontWeight.w600, height: 20, letterSpacing: 0.1),
        labelMedium: _inter(
            size: 12, weight: FontWeight.w500, height: 16, letterSpacing: 0.5),
        labelSmall: _inter(
            size: 11, weight: FontWeight.w500, height: 16, letterSpacing: 0.5),
      );

  // ── Named text style helpers (for direct use when context is unavailable) ────

  static TextStyle get heroNumber =>
      _jakarta(size: 48, weight: FontWeight.w700, letterSpacing: -1);

  static TextStyle get kpiValue =>
      _jakarta(size: 32, weight: FontWeight.w700, letterSpacing: -0.5);

  static TextStyle get kpiLabel =>
      _inter(size: 12, weight: FontWeight.w500, letterSpacing: 0.5);

  static TextStyle get statValue =>
      _jakarta(size: 24, weight: FontWeight.w700);

  static TextStyle get statLabel =>
      _inter(size: 11, weight: FontWeight.w500, letterSpacing: 0.5);

  static TextStyle get buttonLabel =>
      _inter(size: 14, weight: FontWeight.w600, letterSpacing: 0.1);

  static TextStyle get chipLabel =>
      _inter(size: 12, weight: FontWeight.w600, letterSpacing: 0.5);

  static TextStyle get timestamp =>
      _inter(size: 11, weight: FontWeight.w400, letterSpacing: 0.4);

  static TextStyle get sectionHeader =>
      _jakarta(size: 18, weight: FontWeight.w700, letterSpacing: -0.25);
}
