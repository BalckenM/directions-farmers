import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/core/router/app_routes.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_spacing.dart';
import 'package:mobile_app/features/payroll/data/payroll_remote_data_source.dart';
import 'package:mobile_app/features/payroll/models/compliance_alert.dart';
import 'package:mobile_app/features/payroll/providers/payroll_providers.dart';
import 'package:mobile_app/features/payroll/theme/payroll_tokens.dart';
import 'package:mobile_app/shared/widgets/empty_state.dart';
import 'package:mobile_app/shared/widgets/farm_app_bar.dart';
import 'package:mobile_app/shared/widgets/farm_scaffold.dart';

final _fmtDate = DateFormat('d MMM y');

enum _Filter { all, open, critical, resolved }

class ComplianceScreen extends ConsumerStatefulWidget {
  const ComplianceScreen({super.key});

  @override
  ConsumerState<ComplianceScreen> createState() => _ComplianceScreenState();
}

class _ComplianceScreenState extends ConsumerState<ComplianceScreen> {
  _Filter _filter = _Filter.open;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Fetch fresh compliance alerts (including resolved) when screen opens.
    // Using addPostFrameCallback so it runs after the first build — prevents
    // the "setState during build" error from Riverpod subscription setup.
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshAlerts());
  }

  Future<void> _refreshAlerts() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final source = ref.read(payrollDataSourceProvider);
      if (source is PayrollRemoteDataSource) {
        await source.refreshComplianceAlerts(includeResolved: true);
      }
      if (mounted) {
        // Notify providers AFTER fetch — never during a build frame.
        ref.invalidate(allComplianceAlertsProvider);
        ref.invalidate(complianceAlertsProvider);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allAlerts = ref.watch(allComplianceAlertsProvider);
    final employees = ref.watch(employeesProvider);
    final empMap = {for (final e in employees) e.id: e.fullName};
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
      appBar: FarmAppBar(
        title: 'Compliance',
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // -- Status banner ---------------------------------------------
          _AlertsBanner(
            openCount: openAlerts.length,
            criticalCount: criticalAlerts.length,
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                // -- Compact stats strip ---------------------------------
                _StatsStrip(
                  openCount: openAlerts.length,
                  criticalCount: criticalAlerts.length,
                  warningCount: warningAlerts.length,
                  resolvedCount: resolvedAlerts.length,
                ),

                const SizedBox(height: AppSpacing.md),

                // -- Compliance sub-modules ------------------------------
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Text(
                          'Statutory Returns',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: Column(
                          children: [
                            _ModuleRow(
                              icon: Icons.receipt_long_outlined,
                              label: 'PAYE',
                              subtitle: 'Pay As You Earn tax',
                              color: AppColors.primary,
                              isFirst: true,
                              onTap: () => context.push(AppRoutes.payrollPaye),
                            ),
                            const Divider(height: 1, indent: 56),
                            _ModuleRow(
                              icon: Icons.people_alt_outlined,
                              label: 'UIF Returns',
                              subtitle: 'Unemployment Insurance Fund',
                              color: AppColors.success,
                              onTap: () =>
                                  context.push(AppRoutes.payrollUifReturns),
                            ),
                            const Divider(height: 1, indent: 56),
                            _ModuleRow(
                              icon: Icons.school_outlined,
                              label: 'SDL',
                              subtitle: 'Skills Development Levy',
                              color: AppColors.primary,
                              onTap: () => context.push(AppRoutes.payrollSdl),
                            ),
                            const Divider(height: 1, indent: 56),
                            _ModuleRow(
                              icon: Icons.summarize_outlined,
                              label: 'EMP501 Reconciliation',
                              subtitle: 'Annual employer reconciliation',
                              color: AppColors.secondary,
                              isLast: true,
                              onTap: () =>
                                  context.push(AppRoutes.payrollEmp501),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // -- Filter chips -----------------------------------------
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Text(
                          'Compliance Alerts',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _Filter.values.map((f) {
                            final label = switch (f) {
                              _Filter.all => 'All (${allAlerts.length})',
                              _Filter.open => 'Open (${openAlerts.length})',
                              _Filter.critical =>
                                'Critical (${criticalAlerts.length})',
                              _Filter.resolved =>
                                'Resolved (${resolvedAlerts.length})',
                            };
                            return Padding(
                              padding: const EdgeInsets.only(
                                right: AppSpacing.sm,
                              ),
                              child: FilterChip(
                                label: Text(label),
                                selected: _filter == f,
                                onSelected: (_) => setState(() {
                                  _filter = f;
                                }),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Alert list inline (not Expanded)
                      if (filtered.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xl,
                          ),
                          child: EmptyState(
                            icon: const Icon(
                              Icons.verified_outlined,
                              size: 56,
                              color: AppColors.success,
                            ),
                            title: 'No alerts',
                            subtitle:
                                'No compliance issues found for this filter.',
                          ),
                        )
                      else ...[
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) => Padding(
                            padding: EdgeInsets.only(
                              bottom: i < filtered.length - 1
                                  ? AppSpacing.sm
                                  : 0,
                            ),
                            child: _AlertCard(
                              alert: filtered[i],
                              empMap: empMap,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Compact stats strip
// -----------------------------------------------------------------------------

class _StatsStrip extends StatelessWidget {
  const _StatsStrip({
    required this.openCount,
    required this.criticalCount,
    required this.warningCount,
    required this.resolvedCount,
  });

  final int openCount;
  final int criticalCount;
  final int warningCount;
  final int resolvedCount;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    Widget stat(String label, int count, Color color) => Expanded(
      child: Column(
        children: [
          Text(
            '$count',
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: count > 0 ? color : cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    Widget divider() =>
        Container(width: 1, height: 28, color: cs.outlineVariant);

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        0,
      ),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          stat('Open', openCount, openCount > 0 ? cs.error : AppColors.success),
          divider(),
          stat(
            'Critical',
            criticalCount,
            criticalCount > 0 ? AppColors.error : AppColors.success,
          ),
          divider(),
          stat(
            'Warnings',
            warningCount,
            warningCount > 0 ? AppColors.warning : AppColors.success,
          ),
          divider(),
          stat('Resolved', resolvedCount, AppColors.success),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Compliance module row
// -----------------------------------------------------------------------------

class _ModuleRow extends StatelessWidget {
  const _ModuleRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final radius = BorderRadius.vertical(
      top: isFirst ? const Radius.circular(12) : Radius.zero,
      bottom: isLast ? const Radius.circular(12) : Radius.zero,
    );

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: cs.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Alerts count banner
// -----------------------------------------------------------------------------

class _AlertsBanner extends StatelessWidget {
  const _AlertsBanner({required this.openCount, required this.criticalCount});
  final int openCount;
  final int criticalCount;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final hasOpen = openCount > 0;
    final bg = criticalCount > 0
        ? AppColors.error
        : hasOpen
        ? AppColors.warning
        : AppColors.success;
    final icon = criticalCount > 0
        ? Icons.error_rounded
        : hasOpen
        ? Icons.warning_amber_rounded
        : Icons.verified_rounded;
    final label = criticalCount > 0
        ? '$criticalCount critical \u00b7 $openCount open alert${openCount == 1 ? '' : 's'}'
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

// -----------------------------------------------------------------------------
// Alert card
// -----------------------------------------------------------------------------

class _AlertCard extends ConsumerWidget {
  const _AlertCard({required this.alert, required this.empMap});
  final ComplianceAlert alert;
  final Map<String, String> empMap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final (color, icon) = switch (alert.severity) {
      ComplianceSeverity.critical => (AppColors.error, Icons.error_rounded),
      ComplianceSeverity.warning => (
        AppColors.warning,
        Icons.warning_amber_rounded,
      ),
      ComplianceSeverity.info => (
        PayrollTokens.sky,
        Icons.info_outline_rounded,
      ),
    };

    final accentColor = alert.isResolved ? AppColors.success : color;
    final borderColor = alert.isResolved
        ? cs.outlineVariant
        : color.withValues(alpha: 0.5);
    final borderWidth = alert.isResolved ? 1.0 : 1.5;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () =>
            context.push(AppRoutes.payrollComplianceAlertDetail(alert.id)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            child: Stack(
              children: [
                // Left accent bar � Positioned avoids IntrinsicHeight
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(11),
                        bottomLeft: Radius.circular(11),
                      ),
                    ),
                  ),
                ),
                // Card content � left-padded past the accent bar
                Padding(
                  padding: const EdgeInsets.only(
                    left: 4 + AppSpacing.md,
                    right: AppSpacing.md,
                    top: AppSpacing.md,
                    bottom: AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row: icon + title + severity chip
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            icon,
                            color: alert.isResolved
                                ? cs.onSurfaceVariant
                                : color,
                            size: 18,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  alert.title,
                                  style: tt.bodyMedium?.copyWith(
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
                          const SizedBox(width: AppSpacing.xs),
                          _severityChip(context, tt, alert, color),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),

                      // Description
                      Text(
                        alert.description,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),

                      if (alert.employeeId != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 13,
                              color: cs.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              empMap[alert.employeeId] ?? alert.employeeId!,
                              style: tt.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 13,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Raised ${_fmtDate.format(alert.raisedAt)}',
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          if (alert.isResolved && alert.resolvedAt != null) ...[
                            Text(
                              '  \u00b7  ',
                              style: tt.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            Icon(
                              Icons.check_circle,
                              size: 12,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Resolved ${_fmtDate.format(alert.resolvedAt!)}',
                              style: tt.labelSmall?.copyWith(
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ],
                      ),

                      if (alert.isResolved && alert.resolution != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.07),
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
                                size: 13,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  alert.resolution!,
                                  style: tt.bodySmall?.copyWith(
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      if (alert.isOpen) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.check_rounded, size: 15),
                                label: const Text('Mark Resolved'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.success,
                                  side: const BorderSide(
                                    color: AppColors.success,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                                onPressed: () =>
                                    _showResolveSheet(context, ref),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
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
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'Resolved',
          style: tt.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.success,
          ),
        ),
      );
    }
    final label = switch (alert.severity) {
      ComplianceSeverity.critical => 'Critical',
      ComplianceSeverity.warning => 'Warning',
      ComplianceSeverity.info => 'Info',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: tt.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
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
                      backgroundColor: AppColors.success,
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
