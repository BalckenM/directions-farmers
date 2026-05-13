import 'package:flutter/material.dart';

/// Border radius constants for FarmTrack.
/// Never hard-code BorderRadius values — always reference AppRadius.*
abstract final class AppRadius {
  /// 4dp — Tiny elements (badges, progress bars)
  static const double xs = 4;

  /// 8dp — Chips, small tags
  static const double sm = 8;

  /// 12dp — Buttons, input fields
  static const double md = 12;

  /// 16dp — Cards, containers
  static const double lg = 16;

  /// 24dp — Sheets, dialogs, large containers
  static const double xl = 24;

  /// 50% — Circular avatars and FABs
  static const double full = 9999;

  // ── Pre-built BorderRadius objects ───────────────────────────────────────────

  /// Chip border radius
  static const BorderRadius chip = BorderRadius.all(Radius.circular(sm));

  /// Button + input field border radius
  static const BorderRadius button = BorderRadius.all(Radius.circular(md));

  /// Standard card border radius
  static const BorderRadius card = BorderRadius.all(Radius.circular(lg));

  /// Dialog / bottom sheet border radius
  static const BorderRadius dialog = BorderRadius.all(Radius.circular(xl));

  /// Input fields — 12dp
  static const BorderRadius input = BorderRadius.all(Radius.circular(md));

  /// Avatar / profile image — 50dp pill
  static const BorderRadius avatar = BorderRadius.all(Radius.circular(50));

  /// Bottom navigation bar — 28dp
  static const BorderRadius navBar = BorderRadius.all(Radius.circular(28));

  /// Circular (avatar, FAB)
  static const BorderRadius circular = BorderRadius.all(Radius.circular(full));

  /// Top-only (bottom sheets, snackbars)
  static const BorderRadius topOnly = BorderRadius.only(
    topLeft: Radius.circular(xl),
    topRight: Radius.circular(xl),
  );

  /// Pre-built radius for direct use in ClipRRect / decoration
  static BorderRadius fromRadius(double radius) =>
      BorderRadius.all(Radius.circular(radius));
}
