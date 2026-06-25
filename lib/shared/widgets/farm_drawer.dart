import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile_app/core/auth/user_role.dart';
import 'package:mobile_app/core/router/app_routes.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/features/auth/providers/auth_provider.dart';

/// Immersive navigation drawer — modern sidebar with:
/// • Rich gradient header with farm identity + user card
/// • Left-bar active indicator (Linear/VS Code style)
/// • Collapsible section groups for Livestock and Crop
/// • Colored icon badges per section category
/// • Professional footer with sync status pill
class FarmDrawer extends ConsumerWidget {
  const FarmDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final current = GoRouterState.of(context).matchedLocation;
    final role = ref.watch(userRoleProvider);
    final hasPayroll = ref.watch(hasFeatureProvider('payroll'));

    return Drawer(
      width: 308,
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            color: isDark ? const Color(0xFF111812) : const Color(0xFFF7FCF8),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Navigation list (header scrolls with items) ────────
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 8),
                      children: [
                        // Header is the first item — scrolls naturally
                        _DrawerHeader(),
                        const SizedBox(height: 4),
                        // Overview
                        _NavItem(
                          icon: Icons.home_outlined,
                          activeIcon: Icons.home_rounded,
                          label: 'Dashboard',
                          route: AppRoutes.dashboard,
                          current: current,
                          accentColor: AppColors.primary,
                          exactMatch: true,
                        ),

                        _SectionDivider(label: 'Livestock'),

                        // Livestock group — collapsible
                        _DrawerGroup(
                          icon: Icons.pets_rounded,
                          label: 'Livestock',
                          accentColor: AppColors.cattleColor,
                          current: current,
                          groupRoutePrefix: '/livestock',
                          children: [
                            _NavItem(
                              icon: Icons.grid_view_outlined,
                              activeIcon: Icons.grid_view_rounded,
                              label: 'All Species',
                              route: AppRoutes.livestock,
                              current: current,
                              accentColor: AppColors.primary,
                              exactMatch: true,
                              indent: true,
                            ),
                            _NavItem(
                              icon: Icons.egg_alt_outlined,
                              activeIcon: Icons.egg_alt_rounded,
                              label: 'Poultry',
                              route: AppRoutes.poultryFlocks,
                              current: current,
                              accentColor: AppColors.poultryColor,
                              indent: true,
                            ),
                            _NavItem(
                              icon: Icons.water_drop_outlined,
                              activeIcon: Icons.water_drop_rounded,
                              label: 'Cattle',
                              route: AppRoutes.livestockSpeciesPath('cattle'),
                              current: current,
                              accentColor: AppColors.cattleColor,
                              indent: true,
                            ),
                            _NavItem(
                              icon: Icons.grass_outlined,
                              activeIcon: Icons.grass_rounded,
                              label: 'Sheep',
                              route: AppRoutes.livestockSpeciesPath('sheep'),
                              current: current,
                              accentColor: AppColors.sheepColor,
                              indent: true,
                            ),
                            _NavItem(
                              icon: Icons.eco_outlined,
                              activeIcon: Icons.eco_rounded,
                              label: 'Goats',
                              route: AppRoutes.livestockSpeciesPath('goats'),
                              current: current,
                              accentColor: AppColors.goatColor,
                              indent: true,
                            ),
                          ],
                        ),

                        _SectionDivider(label: 'Records'),

                        _NavItem(
                          icon: Icons.edit_note_outlined,
                          activeIcon: Icons.edit_note_rounded,
                          label: 'All Records',
                          route: AppRoutes.record,
                          current: current,
                          accentColor: AppColors.tertiary,
                        ),
                        _NavItem(
                          icon: Icons.monitor_heart_outlined,
                          activeIcon: Icons.monitor_heart_rounded,
                          label: 'Health Events',
                          route: AppRoutes.recordHealth,
                          current: current,
                          accentColor: AppColors.error,
                          badgeCount: 3,
                        ),
                        _NavItem(
                          icon: Icons.moving_outlined,
                          activeIcon: Icons.moving_rounded,
                          label: 'Movements',
                          route: AppRoutes.movementRecords,
                          current: current,
                          accentColor: AppColors.secondary,
                        ),

                        _SectionDivider(label: 'Analytics'),

                        _NavItem(
                          icon: Icons.insights_outlined,
                          activeIcon: Icons.insights_rounded,
                          label: 'Insights',
                          route: AppRoutes.insights,
                          current: current,
                          accentColor: AppColors.tertiary,
                        ),
                        _NavItem(
                          icon: Icons.storefront_outlined,
                          activeIcon: Icons.storefront_rounded,
                          label: 'Market Prices',
                          route: AppRoutes.marketPrices,
                          current: current,
                          accentColor: AppColors.secondary,
                        ),
                        _NavItem(
                          icon: Icons.description_outlined,
                          activeIcon: Icons.description_rounded,
                          label: 'Reports',
                          route: AppRoutes.reports,
                          current: current,
                          accentColor: AppColors.info,
                        ),

                        _SectionDivider(label: 'Crop Farming'),

                        // Crop group — collapsible
                        _DrawerGroup(
                          icon: Icons.agriculture_rounded,
                          label: 'Crop Hub',
                          accentColor: AppColors.cropGreen,
                          current: current,
                          groupRoutePrefix: '/crop',
                          children: [
                            _NavItem(
                              icon: Icons.grass_outlined,
                              activeIcon: Icons.grass_rounded,
                              label: 'My Fields',
                              route: AppRoutes.cropFields,
                              current: current,
                              accentColor: AppColors.cropGreen,
                              indent: true,
                            ),
                            _NavItem(
                              icon: Icons.library_books_outlined,
                              activeIcon: Icons.library_books_rounded,
                              label: 'Crop Catalog',
                              route: AppRoutes.cropCatalog,
                              current: current,
                              accentColor: AppColors.cropGreen,
                              indent: true,
                            ),
                            _NavItem(
                              icon: Icons.calendar_month_outlined,
                              activeIcon: Icons.calendar_month_rounded,
                              label: 'Planting Calendar',
                              route: AppRoutes.cropCalendar,
                              current: current,
                              accentColor: AppColors.cropGreen,
                              indent: true,
                            ),
                            _NavItem(
                              icon: Icons.task_alt_outlined,
                              activeIcon: Icons.task_alt_rounded,
                              label: 'Crop Tasks',
                              route: AppRoutes.cropTasks,
                              current: current,
                              accentColor: AppColors.cropGreen,
                              indent: true,
                            ),
                            _NavItem(
                              icon: Icons.bug_report_outlined,
                              activeIcon: Icons.bug_report_rounded,
                              label: 'Pests & Spray',
                              route: AppRoutes.cropPests,
                              current: current,
                              accentColor: AppColors.warning,
                              indent: true,
                            ),
                            _NavItem(
                              icon: Icons.trending_up_outlined,
                              activeIcon: Icons.trending_up_rounded,
                              label: 'Profitability',
                              route: AppRoutes.cropProfitability,
                              current: current,
                              accentColor: AppColors.success,
                              indent: true,
                            ),
                          ],
                        ),

                        _SectionDivider(label: 'Operations'),

                        if (role.canEditFinancials)
                          _NavItem(
                            icon: Icons.account_balance_outlined,
                            activeIcon: Icons.account_balance_rounded,
                            label: 'Financial',
                            route: AppRoutes.financial,
                            current: current,
                            accentColor: AppColors.tertiary,
                          ),
                        if (role.canEditFinancials && hasPayroll)
                          _NavItem(
                            icon: Icons.badge_outlined,
                            activeIcon: Icons.badge_rounded,
                            label: 'Payroll',
                            route: AppRoutes.payrollHub,
                            current: current,
                            accentColor: AppColors.secondary,
                          ),
                        _NavItem(
                          icon: Icons.tune_outlined,
                          activeIcon: Icons.tune_rounded,
                          label: 'Settings',
                          route: AppRoutes.settings,
                          current: current,
                          accentColor: AppColors.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),

                  // ── Footer user card ───────────────────────────────────
                  _DrawerFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Immersive header ──────────────────────────────────────────────────────────

class _DrawerHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final planLabel = (user?.subscriptionPlan ?? 'free').toUpperCase();
    final farmName = user?.farmName ?? '—';
    final farmInitials = farmName
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
    final location = user != null ? '${user.province}, ${user.country}' : '—';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF0F2716), const Color(0xFF071409)]
              : [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Stack(
        children: [
          // Background watermark
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.agriculture_rounded,
              size: 130,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Positioned(
            left: -10,
            bottom: -18,
            child: Icon(
              Icons.eco_rounded,
              size: 80,
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo + close row
                Row(
                  children: [
                    // Logo badge
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4ADE80), Color(0xFF16A34A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.30),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.agriculture_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '4Directions',
                            style: tt.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            'Smart Farm Platform',
                            style: tt.labelSmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Subscription badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ADE80).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: const Color(
                            0xFF4ADE80,
                          ).withValues(alpha: 0.40),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        planLabel,
                        style: TextStyle(
                          color: Color(0xFF86EFAC),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Farm name card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Farm avatar
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            farmInitials,
                            style: tt.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              farmName,
                              style: tt.bodyMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  size: 10,
                                  color: Colors.white.withValues(alpha: 0.55),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  location,
                                  style: tt.labelSmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.55),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.expand_more_rounded,
                        color: Colors.white.withValues(alpha: 0.45),
                        size: 18,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Quick stat row
                Row(
                  children: [
                    _HeaderStat(
                      value: '847',
                      label: 'Animals',
                      icon: Icons.pets_rounded,
                    ),
                    _HeaderStatDivider(),
                    _HeaderStat(
                      value: '12',
                      label: 'Fields',
                      icon: Icons.grass_rounded,
                    ),
                    _HeaderStatDivider(),
                    _HeaderStat(
                      value: '3',
                      label: 'Alerts',
                      icon: Icons.warning_rounded,
                      isAlert: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({
    required this.value,
    required this.label,
    required this.icon,
    this.isAlert = false,
  });
  final String value;
  final String label;
  final IconData icon;
  final bool isAlert;

  @override
  Widget build(BuildContext context) {
    final color = isAlert
        ? const Color(0xFFFBBF24)
        : Colors.white.withValues(alpha: 0.90);
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 13, color: color.withValues(alpha: 0.70)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderStatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white.withValues(alpha: 0.12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

// ── Section divider with label ────────────────────────────────────────────────

class _SectionDivider extends StatelessWidget {
  const _SectionDivider({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 3,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: cs.onSurfaceVariant.withValues(alpha: 0.55),
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1,
              color: cs.outlineVariant.withValues(alpha: 0.40),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Collapsible group ─────────────────────────────────────────────────────────

class _DrawerGroup extends StatefulWidget {
  const _DrawerGroup({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.current,
    required this.groupRoutePrefix,
    required this.children,
  });

  final IconData icon;
  final String label;
  final Color accentColor;
  final String current;
  final String groupRoutePrefix;
  final List<Widget> children;

  @override
  State<_DrawerGroup> createState() => _DrawerGroupState();
}

class _DrawerGroupState extends State<_DrawerGroup>
    with SingleTickerProviderStateMixin {
  late bool _expanded;
  late final AnimationController _ctrl;
  late final Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _expanded = widget.current.startsWith(widget.groupRoutePrefix);
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
      value: _expanded ? 1.0 : 0.0,
    );
    _rotation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  bool get _groupActive => widget.current.startsWith(widget.groupRoutePrefix);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final accent = widget.accentColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Group header row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
          child: Material(
            color: _groupActive
                ? accent.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _toggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    // Colored icon badge
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: accent.withValues(
                          alpha: _groupActive ? 0.18 : 0.10,
                        ),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(
                        widget.icon,
                        color: accent.withValues(
                          alpha: _groupActive ? 1.0 : 0.70,
                        ),
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.label,
                        style: tt.bodyMedium?.copyWith(
                          fontWeight: _groupActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: _groupActive ? accent : cs.onSurface,
                        ),
                      ),
                    ),
                    RotationTransition(
                      turns: _rotation,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.60),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Animated children
        AnimatedSize(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeInOutCubic,
          child: _expanded
              ? Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Column(children: widget.children),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ── Navigation item ───────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    required this.current,
    required this.accentColor,
    this.exactMatch = false,
    this.indent = false,
    this.badgeCount = 0,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final String current;
  final Color accentColor;
  final bool exactMatch;
  final bool indent;
  final int badgeCount;

  bool get _isActive =>
      exactMatch ? current == route : current.startsWith(route);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final active = _isActive;

    return Padding(
      padding: EdgeInsets.fromLTRB(indent ? 0 : 12, 1, 12, 1),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Left accent bar — only when active
          if (active && !indent)
            Positioned(
              left: 0,
              top: 6,
              bottom: 6,
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(3),
                  ),
                ),
              ),
            ),

          Material(
            color: active
                ? accentColor.withValues(alpha: indent ? 0.08 : 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            child: InkWell(
              borderRadius: BorderRadius.circular(11),
              onTap: () {
                Navigator.of(context).pop();
                context.go(route);
              },
              child: Padding(
                padding: EdgeInsets.fromLTRB(indent ? 8 : 12, 7, 12, 7),
                child: Row(
                  children: [
                    // Colored icon badge — always visible, accent-tinted
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOutCubic,
                      width: indent ? 28 : 32,
                      height: indent ? 28 : 32,
                      decoration: BoxDecoration(
                        color: active
                            ? accentColor.withValues(alpha: 0.18)
                            : accentColor.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(indent ? 8 : 9),
                        border: active
                            ? Border.all(
                                color: accentColor.withValues(alpha: 0.35),
                                width: 1,
                              )
                            : null,
                      ),
                      child: Icon(
                        active ? activeIcon : icon,
                        size: indent ? 15 : 17,
                        color: active
                            ? accentColor
                            : accentColor.withValues(alpha: 0.60),
                      ),
                    ),
                    const SizedBox(width: 11),

                    // Label
                    Expanded(
                      child: Text(
                        label,
                        style: tt.bodyMedium?.copyWith(
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: indent ? 13.5 : 14,
                          color: active ? accentColor : cs.onSurface,
                          height: 1.0,
                        ),
                      ),
                    ),

                    // Badge count
                    if (badgeCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          '$badgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Footer user card ──────────────────────────────────────────────────────────

class _DrawerFooter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final role = ref.watch(userRoleProvider);
    final fullName = user?.fullName ?? 'My Account';
    final initials = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
    final plan = user?.subscriptionPlan ?? 'starter';
    final planLabel = plan.isNotEmpty
        ? plan[0].toUpperCase() + plan.substring(1)
        : plan;
    final roleLine = '${role.displayName} · $planLabel';

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? cs.surfaceContainerLow
            : AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? cs.outlineVariant.withValues(alpha: 0.25)
              : AppColors.primary.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // Initials avatar
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: tt.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      roleLine,
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              // Settings icon
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => context.push(AppRoutes.settings),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.tune_rounded,
                      size: 18,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Container(
            height: 1,
            color: cs.outlineVariant.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 10),

          // Sync status + sign out
          Row(
            children: [
              // Sync pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.30),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Synced 2h ago',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Sign out
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () async {
                    Navigator.of(context).pop(); // close drawer
                    await ref.read(authProvider.notifier).signOut();
                    if (context.mounted) context.go(AppRoutes.login);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          size: 14,
                          color: AppColors.error.withValues(alpha: 0.75),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Sign out',
                          style: tt.labelSmall?.copyWith(
                            color: AppColors.error.withValues(alpha: 0.75),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
