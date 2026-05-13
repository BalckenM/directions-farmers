import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// App-wide navigation drawer.
///
/// Shows a sidebar with all major sections, a farm header,
/// and an offline/user footer.
class FarmDrawer extends StatelessWidget {
  const FarmDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final current = GoRouterState.of(context).matchedLocation;

    return Drawer(
      backgroundColor: cs.surface,
      width: 292,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Farm header ─────────────────────────────────────────────
            _DrawerHeader(primaryColor: AppColors.primary),

            const Divider(height: 1),

            // ── Navigation sections ─────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                children: [
                  _SectionLabel('Overview'),
                  _DrawerItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: 'Dashboard',
                    route: AppRoutes.dashboard,
                    current: current,
                  ),

                  _SectionLabel('Livestock'),
                  _DrawerItem(
                    icon: Icons.grid_view_outlined,
                    activeIcon: Icons.grid_view_rounded,
                    label: 'All Species',
                    route: AppRoutes.livestock,
                    current: current,
                    exactMatch: true,
                  ),
                  _DrawerSpeciesItem(
                    icon: Icons.egg_alt_outlined,
                    label: 'Poultry',
                    color: AppColors.poultryColor,
                    route: AppRoutes.poultryFlocks,
                    current: current,
                  ),
                  _DrawerSpeciesItem(
                    icon: Icons.set_meal_outlined,
                    label: 'Aquaculture',
                    color: AppColors.aquacultureColor,
                    route: AppRoutes.aquacultureUnits,
                    current: current,
                  ),
                  _DrawerSpeciesItem(
                    icon: Icons.hive_outlined,
                    label: 'Apiculture',
                    color: AppColors.beesColor,
                    route: AppRoutes.apiculture,
                    current: current,
                  ),
                  _DrawerSpeciesItem(
                    icon: Icons.ramen_dining_outlined,
                    label: 'Pigs',
                    color: AppColors.pigColor,
                    route: AppRoutes.pigsBoard,
                    current: current,
                  ),
                  _DrawerSpeciesItem(
                    icon: Icons.local_offer_outlined,
                    label: 'Cattle',
                    color: AppColors.cattleColor,
                    route: AppRoutes.livestockSpeciesPath('cattle'),
                    current: current,
                  ),
                  _DrawerSpeciesItem(
                    icon: Icons.grass_outlined,
                    label: 'Sheep',
                    color: AppColors.sheepColor,
                    route: AppRoutes.livestockSpeciesPath('sheep'),
                    current: current,
                  ),
                  _DrawerSpeciesItem(
                    icon: Icons.eco_outlined,
                    label: 'Goats',
                    color: AppColors.goatColor,
                    route: AppRoutes.livestockSpeciesPath('goats'),
                    current: current,
                  ),

                  _SectionLabel('Records'),
                  _DrawerItem(
                    icon: Icons.edit_note_outlined,
                    activeIcon: Icons.edit_note_rounded,
                    label: 'All Records',
                    route: AppRoutes.record,
                    current: current,
                  ),
                  _DrawerItem(
                    icon: Icons.monitor_heart_outlined,
                    activeIcon: Icons.monitor_heart_rounded,
                    label: 'Health Events',
                    route: AppRoutes.recordHealth,
                    current: current,
                  ),
                  _DrawerItem(
                    icon: Icons.swap_horiz_rounded,
                    activeIcon: Icons.swap_horiz_rounded,
                    label: 'Movements',
                    route: AppRoutes.movementRecords,
                    current: current,
                  ),

                  _SectionLabel('Analytics'),
                  _DrawerItem(
                    icon: Icons.bar_chart_outlined,
                    activeIcon: Icons.bar_chart_rounded,
                    label: 'Insights',
                    route: AppRoutes.insights,
                    current: current,
                  ),
                  _DrawerItem(
                    icon: Icons.storefront_outlined,
                    activeIcon: Icons.storefront_rounded,
                    label: 'Market Prices',
                    route: AppRoutes.marketPrices,
                    current: current,
                  ),
                  _DrawerItem(
                    icon: Icons.description_outlined,
                    activeIcon: Icons.description_rounded,
                    label: 'Reports',
                    route: AppRoutes.reports,
                    current: current,
                  ),

                  _SectionLabel('Crop Farming'),
                  _DrawerItem(
                    icon: Icons.agriculture_outlined,
                    activeIcon: Icons.agriculture_rounded,
                    label: 'Crop Hub',
                    route: AppRoutes.crop,
                    current: current,
                  ),
                  _DrawerItem(
                    icon: Icons.grass_outlined,
                    activeIcon: Icons.grass_rounded,
                    label: 'My Fields',
                    route: AppRoutes.cropFields,
                    current: current,
                  ),
                  _DrawerItem(
                    icon: Icons.library_books_outlined,
                    activeIcon: Icons.library_books_rounded,
                    label: 'Crop Catalog',
                    route: AppRoutes.cropCatalog,
                    current: current,
                  ),
                  _DrawerItem(
                    icon: Icons.calendar_month_outlined,
                    activeIcon: Icons.calendar_month_rounded,
                    label: 'Planting Calendar',
                    route: AppRoutes.cropCalendar,
                    current: current,
                  ),
                  _DrawerItem(
                    icon: Icons.task_alt_outlined,
                    activeIcon: Icons.task_alt_rounded,
                    label: 'Crop Tasks',
                    route: AppRoutes.cropTasks,
                    current: current,
                  ),
                  _DrawerItem(
                    icon: Icons.event_note_outlined,
                    activeIcon: Icons.event_note_rounded,
                    label: 'Season Plan',
                    route: AppRoutes.cropSeasons,
                    current: current,
                  ),
                  _DrawerItem(
                    icon: Icons.bug_report_outlined,
                    activeIcon: Icons.bug_report_rounded,
                    label: 'Pests & Spray',
                    route: AppRoutes.cropPests,
                    current: current,
                  ),
                  _DrawerItem(
                    icon: Icons.receipt_long_outlined,
                    activeIcon: Icons.receipt_long_rounded,
                    label: 'Crop Expenses',
                    route: AppRoutes.cropExpenses,
                    current: current,
                  ),
                  _DrawerItem(
                    icon: Icons.agriculture_outlined,
                    activeIcon: Icons.agriculture_rounded,
                    label: 'Harvest',
                    route: AppRoutes.cropHarvest,
                    current: current,
                  ),
                  _DrawerItem(
                    icon: Icons.trending_up_outlined,
                    activeIcon: Icons.trending_up_rounded,
                    label: 'Profitability',
                    route: AppRoutes.cropProfitability,
                    current: current,
                  ),

                  _SectionLabel('Operations'),
                  _DrawerItem(
                    icon: Icons.account_balance_wallet_outlined,
                    activeIcon: Icons.account_balance_wallet_rounded,
                    label: 'Financial',
                    route: AppRoutes.financial,
                    current: current,
                  ),
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings_rounded,
                    label: 'Settings',
                    route: AppRoutes.settings,
                    current: current,
                  ),
                ],
              ),
            ),

            // ── Footer ──────────────────────────────────────────────────
            const Divider(height: 1),
            _DrawerFooter(),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.primaryColor});
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor,
            primaryColor.withAlpha(200),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Farm logo / icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.agriculture_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'FarmTrack SA',
            style: tt.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          Text(
            'Livestock Management',
            style: tt.bodySmall?.copyWith(
              color: Colors.white.withAlpha(180),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xs),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

// ── Standard drawer item ──────────────────────────────────────────────────────

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    required this.current,
    this.exactMatch = false,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final String current;
  final bool exactMatch;

  bool get _isActive =>
      exactMatch ? current == route : current.startsWith(route);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final active = _isActive;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: 2),
      child: Material(
        color: active
            ? AppColors.primary.withAlpha(18)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            Navigator.of(context).pop(); // close drawer
            context.go(route);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: 10),
            child: Row(
              children: [
                Icon(
                  active ? activeIcon : icon,
                  size: 20,
                  color: active ? AppColors.primary : cs.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  label,
                  style: tt.bodyMedium?.copyWith(
                    fontWeight:
                        active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? AppColors.primary : cs.onSurface,
                  ),
                ),
                if (active)
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Species drawer item (colored dot) ─────────────────────────────────────────

class _DrawerSpeciesItem extends StatelessWidget {
  const _DrawerSpeciesItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
    required this.current,
  });

  final IconData icon;
  final String label;
  final Color color;
  final String route;
  final String current;

  bool get _isActive => current.startsWith(route);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final active = _isActive;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: 1),
      child: Material(
        color: active ? color.withAlpha(15) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            Navigator.of(context).pop();
            context.go(route);
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 8, AppSpacing.md, 8),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: color.withAlpha(active ? 40 : 20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  label,
                  style: tt.bodyMedium?.copyWith(
                    fontWeight:
                        active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? color : cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Footer ────────────────────────────────────────────────────────────────────

class _DrawerFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withAlpha(25),
            child: const Icon(
              Icons.person_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Farm Manager',
                  style: tt.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  'Offline · Last sync 2h ago',
                  style: tt.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.circle, color: AppColors.warning, size: 8),
        ],
      ),
    );
  }
}
