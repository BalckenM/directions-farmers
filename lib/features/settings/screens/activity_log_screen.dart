import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../providers/settings_ui_providers.dart';

// â”€â”€ Mock data â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ActivityEntry {
  final String id;
  final String title;
  final String detail;
  final String actor;
  final DateTime timestamp;
  final ActivityCategory category;
  final String? referenceId;

  const _ActivityEntry({
    required this.id,
    required this.title,
    required this.detail,
    required this.actor,
    required this.timestamp,
    required this.category,
    this.referenceId,
  });
}

final _now = DateTime.now();

final _mockActivity = [
  _ActivityEntry(
    id: 'ACT-001',
    title: 'Animal added',
    detail: 'Bull calf #NGC-2024-089 added to Herd A',
    actor: 'Thabo Nkosi',
    timestamp: _now.subtract(const Duration(hours: 1)),
    category: ActivityCategory.livestock,
    referenceId: 'NGC-2024-089',
  ),
  _ActivityEntry(
    id: 'ACT-002',
    title: 'Weight recorded',
    detail: '34 animals weighed â€” avg 287 kg',
    actor: 'Sipho Dlamini',
    timestamp: _now.subtract(const Duration(hours: 3)),
    category: ActivityCategory.livestock,
  ),
  _ActivityEntry(
    id: 'ACT-003',
    title: 'Payslip generated',
    detail: 'March 2024 payslips issued â€” 12 employees',
    actor: 'Thabo Nkosi',
    timestamp: _now.subtract(const Duration(hours: 5)),
    category: ActivityCategory.payroll,
    referenceId: 'PAY-2024-03',
  ),
  _ActivityEntry(
    id: 'ACT-004',
    title: 'Health treatment logged',
    detail: 'Lumpy Skin vaccination â€” Camp 1 (32 head)',
    actor: 'Dr. Zanele Mokoena',
    timestamp: _now.subtract(const Duration(hours: 8)),
    category: ActivityCategory.livestock,
  ),
  _ActivityEntry(
    id: 'ACT-005',
    title: 'Expense recorded',
    detail: 'Feed purchase â€” R4 200 (Camp 2 Lucerne)',
    actor: 'Thabo Nkosi',
    timestamp: _now.subtract(const Duration(days: 1, hours: 2)),
    category: ActivityCategory.financial,
  ),
  _ActivityEntry(
    id: 'ACT-006',
    title: 'Paddock status updated',
    detail: 'Camp 2 â€” Lusern set to Resting (30 days)',
    actor: 'Sipho Dlamini',
    timestamp: _now.subtract(const Duration(days: 1, hours: 6)),
    category: ActivityCategory.settings,
  ),
  _ActivityEntry(
    id: 'ACT-007',
    title: 'Movement certificate created',
    detail: '18 cattle moved to Thornhill South Camp',
    actor: 'Thabo Nkosi',
    timestamp: _now.subtract(const Duration(days: 1, hours: 9)),
    category: ActivityCategory.livestock,
    referenceId: 'MOV-2024-022',
  ),
  _ActivityEntry(
    id: 'ACT-008',
    title: 'Employee contract updated',
    detail: 'Sipho Dlamini â€” wage rate updated (R5 200/month)',
    actor: 'Thabo Nkosi',
    timestamp: _now.subtract(const Duration(days: 2, hours: 1)),
    category: ActivityCategory.payroll,
  ),
  _ActivityEntry(
    id: 'ACT-009',
    title: 'Breeding event logged',
    detail: 'Cow #BNS-2021-044 â€” AI breeding with Bonsmara bull',
    actor: 'Thabo Nkosi',
    timestamp: _now.subtract(const Duration(days: 2, hours: 4)),
    category: ActivityCategory.livestock,
  ),
  _ActivityEntry(
    id: 'ACT-010',
    title: 'Crop field created',
    detail: 'Maize field â€” Block 3 (4.2 ha) added',
    actor: 'Thabo Nkosi',
    timestamp: _now.subtract(const Duration(days: 3, hours: 0)),
    category: ActivityCategory.crop,
  ),
  _ActivityEntry(
    id: 'ACT-011',
    title: 'Milk production recorded',
    detail: '142 L â€” morning session, 8 cows',
    actor: 'Sipho Dlamini',
    timestamp: _now.subtract(const Duration(days: 3, hours: 6)),
    category: ActivityCategory.livestock,
  ),
  _ActivityEntry(
    id: 'ACT-012',
    title: 'Farm profile updated',
    detail: 'Phone number and location updated',
    actor: 'Thabo Nkosi',
    timestamp: _now.subtract(const Duration(days: 4, hours: 2)),
    category: ActivityCategory.settings,
  ),
];

// â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

IconData _categoryIcon(ActivityCategory c) => switch (c) {
  ActivityCategory.livestock => Icons.pets_rounded,
  ActivityCategory.payroll => Icons.payments_rounded,
  ActivityCategory.financial => Icons.account_balance_wallet_rounded,
  ActivityCategory.crop => Icons.grass_rounded,
  ActivityCategory.settings => Icons.settings_rounded,
};

Color _categoryColor(ActivityCategory c) => switch (c) {
  ActivityCategory.livestock => AppColors.primary,
  ActivityCategory.payroll => AppColors.secondary,
  ActivityCategory.financial => AppColors.success,
  ActivityCategory.crop => const Color(0xFF33691E),
  ActivityCategory.settings => AppColors.info,
};

String _categoryLabel(ActivityCategory c) => switch (c) {
  ActivityCategory.livestock => 'Livestock',
  ActivityCategory.payroll => 'Payroll',
  ActivityCategory.financial => 'Financial',
  ActivityCategory.crop => 'Crop',
  ActivityCategory.settings => 'Settings',
};

String _formatDate(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inDays == 0) return 'Today';
  if (diff.inDays == 1) return 'Yesterday';
  return '${dt.day} ${_monthName(dt.month)} ${dt.year}';
}

String _formatTime(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String _monthName(int month) => const [
  '',
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
][month];

// â”€â”€ Providers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

// â”€â”€ Screen â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class ActivityLogScreen extends ConsumerWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(activityFilterProvider);
    final cs = Theme.of(context).colorScheme;

    final filtered = filter == null
        ? _mockActivity
        : _mockActivity.where((e) => e.category == filter).toList();

    // Group by date label
    final Map<String, List<_ActivityEntry>> grouped = {};
    for (final entry in filtered) {
      final label = _formatDate(entry.timestamp);
      grouped.putIfAbsent(label, () => []).add(entry);
    }

    return FarmScaffold(
      appBar: const FarmAppBar(
        title: 'Activity Log',
        subtitle: 'Farm-wide audit trail',
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            color: cs.surface,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: filter == null,
                    color: AppColors.primary,
                    onTap: () =>
                        ref.read(activityFilterProvider.notifier).set(null),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ...ActivityCategory.values.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: _FilterChip(
                        label: _categoryLabel(c),
                        selected: filter == c,
                        color: _categoryColor(c),
                        onTap: () =>
                            ref.read(activityFilterProvider.notifier).set(c),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          // Log entries
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text('No activity entries for this filter.'),
                  )
                : ListView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: [
                      for (final dateLabel in grouped.keys) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.sm,
                            top: AppSpacing.xs,
                          ),
                          child: Text(
                            dateLabel,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                ),
                          ),
                        ),
                        ...grouped[dateLabel]!.map(
                          (e) => _ActivityTile(entry: e),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€ Filter chip â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? color : color.withAlpha(18),
          borderRadius: AppRadius.chip,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : color,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// â”€â”€ Activity tile â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.entry});
  final _ActivityEntry entry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = _categoryColor(entry.category);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.level1,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withAlpha(18),
            borderRadius: AppRadius.button,
          ),
          child: Icon(_categoryIcon(entry.category), color: color, size: 20),
        ),
        title: Text(
          entry.title,
          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.detail, style: tt.bodySmall),
            const SizedBox(height: 2),
            Text(
              '${entry.actor} Â· ${_formatTime(entry.timestamp)}',
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: color.withAlpha(18),
            borderRadius: AppRadius.chip,
          ),
          child: Text(
            _categoryLabel(entry.category),
            style: tt.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 9,
            ),
          ),
        ),
        isThreeLine: true,
      ),
    );
  }
}
