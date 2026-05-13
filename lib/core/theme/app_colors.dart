import 'package:flutter/material.dart';

/// All semantic colour tokens for FarmTrack.
/// Never use raw hex values in widgets — always reference these tokens.
abstract final class AppColors {
  // ── Brand primaries ─────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF2E7D32); // Forest Green
  static const Color primaryLight = Color(0xFF60AD5E);
  static const Color primaryDark = Color(0xFF005005);
  static const Color primaryContainer = Color(0xFFA5D6A7);
  static const Color onPrimary = Color.fromARGB(233, 255, 255, 255);
  static const Color onPrimaryContainer = Color(0xFF002106);

  static const Color secondary = Color(0xFFF57F17); // Warm Amber
  static const Color secondaryLight = Color(0xFFFFB04C);
  static const Color secondaryDark = Color(0xFFBB4D00);
  static const Color secondaryContainer = Color(0xFFFFE0B2);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF2D1600);

  static const Color tertiary = Color(0xFF0277BD); // Sky Blue
  static const Color tertiaryContainer = Color(0xFFB3E5FC);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFF001E31);

  // ── Semantic status ──────────────────────────────────────────────────────────
  static const Color success = Color(0xFF388E3C);
  static const Color successContainer = Color(0xFFC8E6C9);
  static const Color onSuccessContainer = Color(0xFF002106);

  static const Color warning = Color(0xFFFF8F00);
  static const Color warningContainer = Color(0xFFFFECB3);
  static const Color onWarningContainer = Color(0xFF2D1600);

  static const Color error = Color(0xFFB71C1C);
  static const Color errorContainer = Color(0xFFFFCDD2);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF370B1E);

  static const Color info = Color(0xFF00695C);
  static const Color infoContainer = Color(0xFFB2DFDB);
  static const Color onInfoContainer = Color(0xFF00201C);

  // ── Neutral surfaces ─────────────────────────────────────────────────────────
  static const Color background = Color(0xFFFAFDF6);
  static const Color onBackground = Color(0xFF1A1C18);
  static const Color surface = Color(0xFFFAFDF6);
  static const Color onSurface = Color(0xFF1A1C18);
  static const Color surfaceVariant = Color(0xFFDEE5D8);
  static const Color onSurfaceVariant = Color(0xFF424940);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF4F8EF);
  static const Color surfaceContainer = Color(0xFFEEF2EA);
  static const Color surfaceContainerHigh = Color(0xFFE8ECE4);
  static const Color surfaceContainerHighest = Color(0xFFE2E6DE);
  static const Color outline = Color(0xFF72796F);
  static const Color outlineVariant = Color(0xFFC2C9BE);
  static const Color shadow = Color(0xFF000000);
  static const Color scrim = Color(0xFF000000);
  static const Color inverseSurface = Color(0xFF2E312D);
  static const Color onInverseSurface = Color(0xFFF0F4EC);
  static const Color inversePrimary = Color(0xFF8BC98A);

  // ── Dark theme overrides ─────────────────────────────────────────────────────
  static const Color darkPrimary = Color(0xFF8BC98A);
  static const Color darkPrimaryContainer = Color(0xFF1B5E20);
  static const Color darkSecondary = Color(0xFFFFB74D);
  static const Color darkSecondaryContainer = Color(0xFFBF360C);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E2420);
  static const Color darkOnSurface = Color(0xFFE1E3DD);
  static const Color darkSurfaceVariant = Color(0xFF424940);
  static const Color darkOutline = Color(0xFF8C9389);

  // ── Per-species semantic colours ─────────────────────────────────────────────
  /// Cattle — warm brown earth tone
  static const Color cattleColor = Color(0xFF5D4037);
  static const Color cattleColorLight = Color(0xFF8B6558);
  static const Color cattleColorContainer = Color(0xFFD7CCC8);

  /// Goats — olive/army green
  static const Color goatColor = Color(0xFF827717);
  static const Color goatColorLight = Color(0xFFB4A444);
  static const Color goatColorContainer = Color(0xFFF9F3DC);

  /// Sheep — blue-grey, like a grey fleece
  static const Color sheepColor = Color(0xFF546E7A);
  static const Color sheepColorLight = Color(0xFF819CA9);
  static const Color sheepColorContainer = Color(0xFFCFD8DC);

  /// Pigs — pinkish-red
  static const Color pigColor = Color(0xFFC2185B);
  static const Color pigColorLight = Color(0xFFF06292);
  static const Color pigColorContainer = Color(0xFFFCE4EC);

  /// Poultry — warm amber/orange
  static const Color poultryColor = Color(0xFFF57F17);
  static const Color poultryColorLight = Color(0xFFFFB04C);
  static const Color poultryColorContainer = Color(0xFFFFE0B2);

  /// Horses — dark chestnut brown
  static const Color horseColor = Color(0xFF4E342E);
  static const Color horseColorLight = Color(0xFF7B5E57);
  static const Color horseColorContainer = Color(0xFFEFEBE9);

  /// Rabbits — soft lavender
  static const Color rabbitColor = Color(0xFF8E24AA);
  static const Color rabbitColorLight = Color(0xFFBA68C8);
  static const Color rabbitColorContainer = Color(0xFFF3E5F5);

  /// Aquaculture — sky blue / water
  static const Color aquacultureColor = Color(0xFF0277BD);
  static const Color aquacultureColorLight = Color(0xFF58A5F0);
  static const Color aquacultureColorContainer = Color(0xFFB3E5FC);

  /// Crop Farming — vibrant leaf green
  static const Color cropGreen = Color(0xFF16A34A);
  static const Color cropGreenLight = Color(0xFF4ADE80);
  static const Color cropGreenDark = Color(0xFF14532D);
  static const Color cropGreenContainer = Color(0xFFDCFCE7);
  static const Color onCropGreenContainer = Color(0xFF14532D);

  /// Bees — golden yellow
  static const Color beesColor = Color(0xFFF9A825);
  static const Color beesColorLight = Color(0xFFFFD95A);
  static const Color beesColorContainer = Color(0xFFFFF8E1);

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
      'horse' || 'horses' => horseColor,
      'rabbit' || 'rabbits' => rabbitColor,
      'aquaculture' || 'fish' => aquacultureColor,
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
      'horse' || 'horses' => horseColorContainer,
      'rabbit' || 'rabbits' => rabbitColorContainer,
      'aquaculture' || 'fish' => aquacultureColorContainer,
      'bees' || 'bee' => beesColorContainer,
      _ => primaryContainer,
    };
  }
}
