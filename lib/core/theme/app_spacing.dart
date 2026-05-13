/// Spacing constants following an 8dp base grid.
/// Never hard-code dp values in widgets — always use AppSpacing.*
abstract final class AppSpacing {
  /// 4dp — Smallest gap (icon internal padding, hairline separators)
  static const double xs = 4;

  /// 8dp — Between tightly related elements (icon + label)
  static const double sm = 8;

  /// 16dp — Standard component padding (card interior, list tile padding)
  static const double md = 16;

  /// 24dp — Section gaps, between cards in a list
  static const double lg = 24;

  /// 32dp — Major section separation
  static const double xl = 32;

  /// 48dp — Page-level top/bottom padding, hero spacing
  static const double xxl = 48;

  // ── Named aliases for common patterns ────────────────────────────────────────

  /// Standard horizontal page padding (16dp)
  static const double pagePaddingHorizontal = md;

  /// Standard vertical page padding (16dp)
  static const double pagePaddingVertical = md;

  /// Bottom nav extra safe-area padding
  static const double bottomNavPadding = sm;

  /// FAB bottom margin above bottom nav
  static const double fabMarginBottom = lg;

  /// Minimum touch target size (Material guidance)
  static const double minTouchTarget = 48;

  /// Icon size — small inline icons
  static const double iconSm = 16;

  /// Icon size — standard action icons
  static const double iconMd = 24;

  /// Icon size — large display icons
  static const double iconLg = 32;

  /// Icon size — hero / empty state illustrations
  static const double iconXl = 64;

  /// Avatar size — small (list tile leading)
  static const double avatarSm = 36;

  /// Avatar size — standard (profile headers)
  static const double avatarMd = 48;

  /// Avatar size — large (detail screens)
  static const double avatarLg = 72;

  /// Content max width on wide screens (tablet / desktop)
  static const double contentMaxWidth = 800;

  /// Navigation rail width
  static const double navRailWidth = 80;

  /// Navigation drawer width
  static const double navDrawerWidth = 280;
}
