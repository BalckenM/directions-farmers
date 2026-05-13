import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/section_header.dart';

class RecordScreen extends StatelessWidget {
  const RecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FarmScaffold(
      appBar: const FarmAppBar(
        title: 'Record',
        subtitle: 'Log farm events and data',
      ),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: _LogTypeGrid()),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Recent Logs',
              actionLabel: 'View all',
              onAction: () {},
            ),
          ),
          const SliverToBoxAdapter(child: _RecentLogsList()),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
        ],
      ),
    );
  }
}

// ── Log type grid ─────────────────────────────────────────────────────────────

class _LogTypeGrid extends StatelessWidget {
  const _LogTypeGrid();

  static const _items = [
    _LogType(
      icon: Icons.health_and_safety_rounded,
      label: 'Health\nEvent',
      color: AppColors.error,
      route: AppRoutes.recordHealth,
    ),
    _LogType(
      icon: Icons.monitor_weight_rounded,
      label: 'Weight\nRecord',
      color: AppColors.tertiary,
      route: AppRoutes.recordWeight,
    ),
    _LogType(
      icon: Icons.favorite_rounded,
      label: 'Breeding\nEvent',
      color: Color(0xFFE91E63),
      route: AppRoutes.recordBreeding,
    ),
    _LogType(
      icon: Icons.water_drop_rounded,
      label: 'Milk\nRecord',
      color: AppColors.primary,
      route: AppRoutes.recordMilk,
    ),
    _LogType(
      icon: Icons.egg_rounded,
      label: 'Egg\nRecord',
      color: AppColors.secondary,
      route: AppRoutes.recordEggs,
    ),
    _LogType(
      icon: Icons.content_cut_rounded,
      label: 'Wool\nRecord',
      color: Color(0xFF5C6BC0),
      route: AppRoutes.recordWool,
    ),
    _LogType(
      icon: Icons.notifications_active_rounded,
      label: 'View\nAlerts',
      color: AppColors.warning,
      route: AppRoutes.recordAlerts,
    ),
    _LogType(
      icon: Icons.move_down_rounded,
      label: 'Move\nAnimal',
      color: Color(0xFF795548),
      route: AppRoutes.movementRecords,
    ),
    _LogType(
      icon: Icons.inventory_2_rounded,
      label: 'Feed\nLog',
      color: Color(0xFF388E3C),
      route: AppRoutes.recordFeed,
    ),
    _LogType(
      icon: Icons.account_balance_wallet_rounded,
      label: 'Financial\nLedger',
      color: Color(0xFF1565C0),
      route: AppRoutes.financial,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePaddingHorizontal,
        AppSpacing.md,
        AppSpacing.pagePaddingHorizontal,
        AppSpacing.sm,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.65,
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
        ),
        itemCount: _items.length,
        itemBuilder: (context, i) => _LogTypeCard(item: _items[i]),
      ),
    );
  }
}

class _LogType {
  const _LogType({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });
  final IconData icon;
  final String label;
  final Color color;
  final String? route;
}

class _LogTypeCard extends StatelessWidget {
  const _LogTypeCard({required this.item});
  final _LogType item;

  void _onTap(BuildContext context) {
    if (item.route != null) {
      context.push(item.route!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Coming soon'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.inverseSurface,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isPlaceholder = item.route == null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onTap(context),
        borderRadius: AppRadius.card,
        child: Opacity(
          opacity: isPlaceholder ? 0.65 : 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: item.color.withAlpha(18),
              borderRadius: AppRadius.card,
              border: Border.all(color: item.color.withAlpha(55), width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: item.color.withAlpha(28),
                    borderRadius: AppRadius.button,
                  ),
                  child: Icon(item.icon, color: item.color, size: 22),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  item.label,
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    letterSpacing: -0.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
                if (isPlaceholder)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Coming soon',
                      style: tt.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 9,
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

// ── Recent logs list ──────────────────────────────────────────────────────────

class _RecentLogsList extends StatelessWidget {
  const _RecentLogsList();

  static const _todayLogs = [
    _LogEntry(
      icon: Icons.monitor_weight_rounded,
      iconColor: AppColors.tertiary,
      iconBg: AppColors.tertiaryContainer,
      title: 'Weight Record',
      subtitle: 'Goat #G-007 · 23.4 kg',
      timestamp: '09:14',
    ),
    _LogEntry(
      icon: Icons.health_and_safety_rounded,
      iconColor: AppColors.success,
      iconBg: AppColors.successContainer,
      title: 'Vaccination',
      subtitle: 'Cattle group · FMD booster · 12 animals',
      timestamp: '08:30',
    ),
    _LogEntry(
      icon: Icons.water_drop_rounded,
      iconColor: AppColors.primary,
      iconBg: AppColors.primaryContainer,
      title: 'Milk Record',
      subtitle: '3 cows · 42.3 L total',
      timestamp: '06:00',
    ),
  ];

  static const _yesterdayLogs = [
    _LogEntry(
      icon: Icons.favorite_rounded,
      iconColor: Color(0xFFE91E63),
      iconBg: Color(0xFFFCE4EC),
      title: 'Breeding Event',
      subtitle: 'Cow #C-014 · Mating recorded',
      timestamp: '14:22',
    ),
    _LogEntry(
      icon: Icons.egg_rounded,
      iconColor: AppColors.secondary,
      iconBg: AppColors.secondaryContainer,
      title: 'Egg Collection',
      subtitle: 'Poultry house A · 287 eggs',
      timestamp: '11:00',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePaddingHorizontal,
        0,
        AppSpacing.pagePaddingHorizontal,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DateDivider(label: 'Today', cs: cs, tt: tt),
          Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: AppRadius.card,
              border: Border.all(color: cs.outlineVariant, width: 1),
            ),
            child: Column(
              children: [
                for (int i = 0; i < _todayLogs.length; i++) ...[
                  _LogEntryTile(entry: _todayLogs[i]),
                  if (i < _todayLogs.length - 1)
                    Divider(
                      height: 1,
                      indent: 56 + AppSpacing.md,
                      color: cs.outlineVariant,
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _DateDivider(label: 'Yesterday', cs: cs, tt: tt),
          Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: AppRadius.card,
              border: Border.all(color: cs.outlineVariant, width: 1),
            ),
            child: Column(
              children: [
                for (int i = 0; i < _yesterdayLogs.length; i++) ...[
                  _LogEntryTile(entry: _yesterdayLogs[i]),
                  if (i < _yesterdayLogs.length - 1)
                    Divider(
                      height: 1,
                      indent: 56 + AppSpacing.md,
                      color: cs.outlineVariant,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateDivider extends StatelessWidget {
  const _DateDivider({
    required this.label,
    required this.cs,
    required this.tt,
  });
  final String label;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        label,
        style: tt.labelSmall?.copyWith(
          color: cs.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _LogEntry {
  const _LogEntry({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.timestamp,
  });
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String timestamp;
}

class _LogEntryTile extends StatelessWidget {
  const _LogEntryTile({required this.entry});
  final _LogEntry entry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 10,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: entry.iconBg,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(entry.icon, color: entry.iconColor, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  entry.subtitle,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                entry.timestamp,
                style: tt.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 2),
              Icon(
                Icons.edit_outlined,
                size: 14,
                color: cs.onSurfaceVariant.withAlpha(120),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
