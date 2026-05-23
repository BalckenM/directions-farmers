import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../../data/payroll_repository.dart';
import '../../models/compliance_alert.dart';
import '../../providers/payroll_providers.dart';
import '../../theme/payroll_tokens.dart';

final _fmtDate = DateFormat('d MMM y');

enum _Filter { all, open, critical, resolved }

class ComplianceScreen extends ConsumerStatefulWidget {
  const ComplianceScreen({super.key});

  @override
  ConsumerState<ComplianceScreen> createState() => _ComplianceScreenState();
}

class _ComplianceScreenState extends ConsumerState<ComplianceScreen> {
  _Filter _filter = _Filter.open;

  @override
  Widget build(BuildContext context) {
    final allAlerts = ref.watch(allComplianceAlertsProvider);
    final cs = Theme.of(context).colorScheme;

    final openAlerts = allAlerts.where((a) => a.isOpen).toList();
    final criticalAlerts = allAlerts
        .where((a) => a.severity == ComplianceSeverity.critical && a.isOpen)
        .toList();
    final warningAlerts = allAlerts
        .where((a) => a.severity == ComplianceSeverity.warning && a.isOpen)
        .toList();
    final resolvedAlerts = allAlerts.where((a) => a.isResolved).toList();

    final filtered =
        List<ComplianceAlert>.from(switch (_filter) {
          _Filter.all => allAlerts,
          _Filter.open => openAlerts,
          _Filter.critical => criticalAlerts,
          _Filter.resolved => resolvedAlerts,
        })..sort((a, b) {
          if (a.severity == ComplianceSeverity.critical &&
              b.severity != ComplianceSeverity.critical) {
            return -1;
          }
          if (b.severity == ComplianceSeverity.critical &&
              a.severity != ComplianceSeverity.critical) {
            return 1;
          }
          return b.raisedAt.compareTo(a.raisedAt);
        });

    return FarmScaffold(
      appBar: const FarmAppBar(title: 'Compliance'),
      body: Column(
        children: [
          // ── Prominent alert count banner ─────────────────────────────
          _AlertsBanner(
            openCount: openAlerts.length,
            criticalCount: criticalAlerts.length,
          ),

          // ── Summary stats ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Open Alerts',
                    value: openAlerts.length.toString(),
                    icon: Icons.warning_amber_rounded,
                    accentColor: openAlerts.isEmpty
                        ? PayrollTokens.green
                        : cs.error,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: StatCard(
                    label: 'Critical',
                    value: criticalAlerts.length.toString(),
                    icon: Icons.error_rounded,
                    accentColor: criticalAlerts.isEmpty
                        ? PayrollTokens.green
                        : PayrollTokens.rose,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: StatCard(
                    label: 'Warnings',
                    value: warningAlerts.length.toString(),
                    icon: Icons.info_outline_rounded,
                    accentColor: warningAlerts.isEmpty
                        ? PayrollTokens.green
                        : PayrollTokens.amber,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: StatCard(
                    label: 'Resolved',
                    value: resolvedAlerts.length.toString(),
                    icon: Icons.check_circle_outline_rounded,
                    accentColor: PayrollTokens.green,
                  ),
                ),
              ],
            ),
          ),

          // ── Filter chips ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _Filter.values.map((f) {
                  final label = switch (f) {
                    _Filter.all => 'All (${allAlerts.length})',
                    _Filter.open => 'Open (${openAlerts.length})',
                    _Filter.critical => 'Critical (${criticalAlerts.length})',
                    _Filter.resolved => 'Resolved (${resolvedAlerts.length})',
                  };
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: FilterChip(
                      label: Text(label),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── Alert list ───────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? const EmptyState(
                    icon: Icon(
                      Icons.verified_outlined,
                      size: 56,
                      color: PayrollTokens.green,
                    ),
                    title: 'No alerts',
                    subtitle: 'No compliance issues found for this filter.',
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(allComplianceAlertsProvider);
                      ref.invalidate(complianceAlertsProvider);
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        0,
                        AppSpacing.md,
                        100,
                      ),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (_, i) => _AlertCard(alert: filtered[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Alert Card
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Alerts count banner
// ─────────────────────────────────────────────────────────────────────────────

class _AlertsBanner extends StatelessWidget {
  const _AlertsBanner({required this.openCount, required this.criticalCount});
  final int openCount;
  final int criticalCount;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final hasOpen = openCount > 0;
    final bg = criticalCount > 0
        ? PayrollTokens.rose
        : hasOpen
        ? PayrollTokens.amber
        : PayrollTokens.green;
    final icon = criticalCount > 0
        ? Icons.error_rounded
        : hasOpen
        ? Icons.warning_amber_rounded
        : Icons.verified_rounded;
    final label = criticalCount > 0
        ? '$criticalCount critical · $openCount open alert${openCount == 1 ? '' : 's'}'
        : hasOpen
        ? '$openCount open alert${openCount == 1 ? '' : 's'} require attention'
        : 'All compliance checks passed';

    return Container(
      width: double.infinity,
      color: bg,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 10,
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: tt.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (hasOpen)
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$openCount',
                style: tt.labelMedium?.copyWith(
                  color: bg,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _AlertCard extends ConsumerWidget {
  const _AlertCard({required this.alert});
  final ComplianceAlert alert;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employees = ref.watch(employeesProvider);
    final empMap = {for (final e in employees) e.id: e.fullName};
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final (color, icon) = switch (alert.severity) {
      ComplianceSeverity.critical => (PayrollTokens.rose, Icons.error_rounded),
      ComplianceSeverity.warning => (
        PayrollTokens.amber,
        Icons.warning_amber_rounded,
      ),
      ComplianceSeverity.info => (
        PayrollTokens.sky,
        Icons.info_outline_rounded,
      ),
    };

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () =>
            context.push(AppRoutes.payrollComplianceAlertDetail(alert.id)),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: alert.isResolved
                  ? cs.outlineVariant
                  : color.withValues(alpha: 0.5),
              width: alert.isResolved ? 1.0 : 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Icon(
                      icon,
                      color: alert.isResolved ? cs.onSurfaceVariant : color,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert.title,
                            style: tt.titleSmall?.copyWith(
                              color: alert.isResolved
                                  ? cs.onSurfaceVariant
                                  : cs.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            alert.code,
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _severityChip(context, tt, alert, color),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // Description
                Text(
                  alert.description,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),

                if (alert.employeeId != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 14,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        empMap[alert.employeeId] ?? alert.employeeId!,
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 13, color: cs.onSurfaceVariant),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Raised ${_fmtDate.format(alert.raisedAt)}',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    if (alert.isResolved && alert.resolvedAt != null) ...[
                      const Text(' \u00b7 '),
                      const Icon(
                        Icons.check_circle,
                        size: 13,
                        color: PayrollTokens.green,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Resolved ${_fmtDate.format(alert.resolvedAt!)}',
                        style: tt.labelSmall?.copyWith(
                          color: PayrollTokens.green,
                        ),
                      ),
                    ],
                  ],
                ),

                if (alert.isResolved && alert.resolution != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: PayrollTokens.green.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.notes,
                          size: 14,
                          color: PayrollTokens.green,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            alert.resolution!,
                            style: tt.bodySmall?.copyWith(
                              color: PayrollTokens.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (alert.isOpen) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Resolve'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: PayrollTokens.green,
                        side: const BorderSide(color: PayrollTokens.green),
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 6,
                        ),
                      ),
                      onPressed: () => _showResolveSheet(context, ref),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _severityChip(
    BuildContext context,
    TextTheme tt,
    ComplianceAlert alert,
    Color color,
  ) {
    if (alert.isResolved) {
      return Chip(
        label: const Text('Resolved'),
        backgroundColor: PayrollTokens.green.withValues(alpha: 0.12),
        labelStyle: tt.labelSmall?.copyWith(color: PayrollTokens.green),
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
      );
    }
    final label = switch (alert.severity) {
      ComplianceSeverity.critical => 'Critical',
      ComplianceSeverity.warning => 'Warning',
      ComplianceSeverity.info => 'Info',
    };
    return Chip(
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.12),
      labelStyle: tt.labelSmall?.copyWith(color: color),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }

  void _showResolveSheet(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Resolve Alert',
              style: Theme.of(
                ctx,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              alert.title,
              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                color: Theme.of(ctx).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: ctrl,
              autofocus: true,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Resolution notes',
                hintText: 'Describe what was done to resolve this alert\u2026',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: PayrollTokens.green,
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final resolution = ctrl.text.trim().isEmpty
                          ? 'Resolved by manager'
                          : ctrl.text.trim();
                      ref
                          .read(payrollRepositoryProvider)
                          .resolveAlert(alert.id, 'usr_manager', resolution);
                      ref.invalidate(allComplianceAlertsProvider);
                      ref.invalidate(complianceAlertsProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Alert marked as resolved.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Mark Resolved'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
