import 'package:flutter/material.dart';

/// Semantic colour tokens — Agriculture / FarmTrack palette.
/// Primary: Forest Green. Clean white surfaces. Bold semantic status colors.
/// Never use raw hex values in widgets — always reference these tokens.
abstract final class AppColors {
  // ── Brand primaries — Green ──────────────────────────────────────────────────
  static const Color primary = Color(0xFF16A34A); // Green 600
  static const Color primaryLight = Color(0xFF22C55E); // Green 500
  static const Color primaryDark = Color(0xFF15803D); // Green 700
  static const Color primaryContainer = Color(0xFFDCFCE7); // Green 100
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF14532D); // Green 900

  // ── Secondary — Amber / Earth ────────────────────────────────────────────────
  static const Color secondary = Color(0xFFD97706); // Amber 600
  static const Color secondaryLight = Color(0xFFF59E0B); // Amber 500
  static const Color secondaryDark = Color(0xFFB45309); // Amber 700
  static const Color secondaryContainer = Color(0xFFFEF3C7); // Amber 100
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF78350F); // Amber 900

  // ── Tertiary — Sky / Water ───────────────────────────────────────────────────
  static const Color tertiary = Color(0xFF0284C7); // Sky 600
  static const Color tertiaryContainer = Color(0xFFE0F2FE); // Sky 100
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFF0C4A6E); // Sky 900

  // ── Semantic status ──────────────────────────────────────────────────────────
  static const Color success = Color(0xFF16A34A); // Green 600
  static const Color successContainer = Color(0xFFDCFCE7); // Green 100
  static const Color onSuccessContainer = Color(0xFF14532D); // Green 900

  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color warningContainer = Color(0xFFFEF3C7); // Amber 100
  static const Color onWarningContainer = Color(0xFF78350F); // Amber 900

  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color errorContainer = Color(0xFFFEE2E2); // Red 100
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF7F1D1D); // Red 900

  static const Color info = Color(0xFF0284C7); // Sky 600
  static const Color infoContainer = Color(0xFFE0F2FE); // Sky 100
  static const Color onInfoContainer = Color(0xFF0C4A6E); // Sky 900

  // ── Neutral surfaces ─────────────────────────────────────────────────────────
  static const Color background = Color(0xFFFFFFFF); // Pure white
  static const Color onBackground = Color(0xFF111827); // Gray 900
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF111827); // Gray 900
  static const Color surfaceVariant = Color(0xFFF9FAFB); // Gray 50
  static const Color onSurfaceVariant = Color(0xFF6B7280); // Gray 500
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF9FAFB); // Gray 50
  static const Color surfaceContainer = Color(0xFFF3F4F6); // Gray 100
  static const Color surfaceContainerHigh = Color(0xFFE5E7EB); // Gray 200
  static const Color surfaceContainerHighest = Color(0xFFD1D5DB); // Gray 300
  static const Color outline = Color(0xFFE5E7EB); // Gray 200
  static const Color outlineVariant = Color(0xFFF3F4F6); // Gray 100
  static const Color shadow = Color(0xFF000000);
  static const Color scrim = Color(0xFF000000);
  static const Color inverseSurface = Color(0xFF111827); // Gray 900
  static const Color onInverseSurface = Color(0xFFF9FAFB);
  static const Color inversePrimary = Color(0xFF4ADE80); // Green 400

  // ── Dark theme overrides ─────────────────────────────────────────────────────
  static const Color darkPrimary = Color(0xFF4ADE80); // Green 400
  static const Color darkPrimaryContainer = Color(0xFF15803D); // Green 700
  static const Color darkSecondary = Color(0xFFFCD34D); // Amber 300
  static const Color darkSecondaryContainer = Color(0xFFB45309); // Amber 700
  static const Color darkBackground = Color(0xFF0D1710); // Deep forest dark
  static const Color darkSurface = Color(0xFF1A2E1C); // Forest dark surface
  static const Color darkOnSurface = Color(0xFFF1F5F9); // Slate 100
  static const Color darkSurfaceVariant = Color(
    0xFF243327,
  ); // Dark forest variant
  static const Color darkOutline = Color(0xFF3D5C42); // Muted green outline

  // ── Per-species semantic colours (unchanged for farm modules) ────────────────
  static const Color cattleColor = Color(0xFF5D4037);
  static const Color cattleColorLight = Color(0xFF8B6558);
  static const Color cattleColorContainer = Color(0xFFD7CCC8);

  static const Color goatColor = Color(0xFF6D4C41);
  static const Color goatColorLight = Color(0xFF9A7B72);
  static const Color goatColorContainer = Color(0xFFE0CFC9);

  static const Color poultryColor = Color(0xFFF57F17);
  static const Color poultryColorLight = Color(0xFFFFB04C);
  static const Color poultryColorContainer = Color(0xFFFFE0B2);

  static const Color cropColor = Color(0xFF2E7D32);
  static const Color cropColorLight = Color(0xFF60AD5E);
  static const Color cropColorContainer = Color(0xFFA5D6A7);

  static const Color payrollColor = Color(
    0xFF16A34A,
  ); // Green — matches primary
  static const Color payrollColorContainer = Color(0xFFDCFCE7);

  // ── Additional species colours ────────────────────────────────────────────────
  static const Color sheepColor = Color(0xFF546E7A);
  static const Color sheepColorLight = Color(0xFF819CA9);
  static const Color sheepColorContainer = Color(0xFFCFD8DC);

  static const Color pigColor = Color(0xFFC2185B);
  static const Color pigColorLight = Color(0xFFF06292);
  static const Color pigColorContainer = Color(0xFFFCE4EC);

  static const Color rabbitColor = Color(0xFF8E24AA);
  static const Color rabbitColorLight = Color(0xFFBA68C8);
  static const Color rabbitColorContainer = Color(0xFFF3E5F5);

  static const Color aquacultureColor = Color(0xFF0277BD);
  static const Color aquacultureColorLight = Color(0xFF58A5F0);
  static const Color aquacultureColorContainer = Color(0xFFB3E5FC);

  static const Color cropGreen = Color(0xFF16A34A);
  static const Color cropGreenLight = Color(0xFF4ADE80);
  static const Color cropGreenDark = Color(0xFF14532D);
  static const Color cropGreenContainer = Color(0xFFDCFCE7);
  static const Color onCropGreenContainer = Color(0xFF14532D);

  static const Color beesColor = Color(0xFFF9A825);
  static const Color beesColorLight = Color(0xFFFFD95A);
  static const Color beesColorContainer = Color(0xFFFFF8E1);

  static const Color breedingPink = Color(0xFFC2185B);
  static const Color breedingPinkLight = Color(0xFFEF5350);
  static const Color breedingPinkContainer = Color(0xFFFCE4EC);
  static const Color onBreedingPinkContainer = Color(0xFF3D0022);

  // ── Overlay & shimmer ────────────────────────────────────────────────────────
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  static const Color shimmerBaseDark = Color(0xFF2C2C2C);
  static const Color shimmerHighlightDark = Color(0xFF3D3D3D);

  // ── Utility ──────────────────────────────────────────────────────────────────
  static const Color transparent = Colors.transparent;
  static const Color divider = Color(0xFFE0E0E0);
  static const Color disabledForeground = Color(0xFF9E9E9E);
  static const Color disabledBackground = Color(0xFFEEEEEE);

  // ── Returns the species colour for a given livestock type string ──────────────
  static Color forSpecies(String species) {
    return switch (species.toLowerCase()) {
      'cattle' => cattleColor,
      'goat' || 'goats' => goatColor,
      'sheep' => sheepColor,
      'pig' || 'pigs' => pigColor,
      'poultry' => poultryColor,
      'rabbit' || 'rabbits' => rabbitColor,
      'bees' || 'bee' => beesColor,
      _ => primary,
    };
  }

  static Color containerForSpecies(String species) {
    return switch (species.toLowerCase()) {
      'cattle' => cattleColorContainer,
      'goat' || 'goats' => goatColorContainer,
      'sheep' => sheepColorContainer,
      'pig' || 'pigs' => pigColorContainer,
      'poultry' => poultryColorContainer,
      'rabbit' || 'rabbits' => rabbitColorContainer,
      'bees' || 'bee' => beesColorContainer,
      _ => primaryContainer,
    };
  }
}
