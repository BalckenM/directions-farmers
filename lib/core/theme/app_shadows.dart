import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Pre-defined shadow + elevation tokens for FarmTrack.
/// Material 3 uses tonal elevation for light themes (colour-based),
/// but shadow-based elevation is still used for dark mode overlays.
abstract final class AppShadows {
  // ── Elevation 0 — Flat surfaces (no shadow) ───────────────────────────────────
  static const List<BoxShadow> level0 = [];

  // ── Elevation 1 — Cards, list containers ─────────────────────────────────────
  static const List<BoxShadow> level1 = [
    BoxShadow(
      color: Color(0x0F000000), // 6% black
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x0A000000), // 4% black
      blurRadius: 1,
      spreadRadius: 0,
      offset: Offset(0, 1),
    ),
  ];

  // ── Elevation 2 — Navigation bars, app bars ──────────────────────────────────
  static const List<BoxShadow> level2 = [
    BoxShadow(
      color: Color(0x1A000000), // 10% black
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x0D000000), // 5% black
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  // ── Elevation 3 — FAB, primary actions ───────────────────────────────────────
  static const List<BoxShadow> level3 = [
    BoxShadow(
      color: Color(0x26000000), // 15% black
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x14000000), // 8% black
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  // ── Elevation 4 — Dialogs, modals ────────────────────────────────────────────
  static const List<BoxShadow> level4 = [
    BoxShadow(
      color: Color(0x33000000), // 20% black
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x1A000000), // 10% black
      blurRadius: 6,
      offset: Offset(0, 3),
    ),
  ];

  // ── Elevation 5 — Drawers, side sheets ───────────────────────────────────────
  static const List<BoxShadow> level5 = [
    BoxShadow(
      color: Color(0x40000000), // 25% black
      blurRadius: 40,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color(0x26000000), // 15% black
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  // ── Colour-tinted species card shadow ────────────────────────────────────────
  static List<BoxShadow> speciesCard(Color speciesColor) => [
        BoxShadow(
          color: speciesColor.withAlpha(40),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: AppColors.shadow.withAlpha(20),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];
}
