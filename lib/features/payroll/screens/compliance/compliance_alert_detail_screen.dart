// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../models/compliance_alert.dart';
import '../../providers/payroll_action_providers.dart';
import '../../providers/payroll_providers.dart';
import '../../theme/payroll_tokens.dart';

typedef _C = PayrollTokens;
final _dtFmt = DateFormat('d MMM y, HH:mm');

/// Full detail view for a single compliance alert.
class ComplianceAlertDetailScreen extends ConsumerStatefulWidget {
  const ComplianceAlertDetailScreen({super.key, required this.alertId});
  final String alertId;

  @override
  ConsumerState<ComplianceAlertDetailScreen> createState() =>
      _ComplianceAlertDetailScreenState();
}

class _ComplianceAlertDetailScreenState
    extends ConsumerState<ComplianceAlertDetailScreen> {
  final _resolutionCtrl = TextEditingController();
  bool _resolving = false;

  @override
  void dispose() {
    _resolutionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alerts = ref.watch(allComplianceAlertsProvider);
    final alert = alerts.where((a) => a.id == widget.alertId).firstOrNull;

    if (alert == null) {
      return FarmScaffold(
        appBar: const FarmAppBar(title: 'Compliance Alert'),
        body: const Center(child: Text('Alert not found')),
      );
    }

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final sColor = _severityColor(alert.severity);

    return FarmScaffold(
      appBar: FarmAppBar(title: 'Compliance Alert', subtitle: alert.code),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Severity header ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  sColor.withValues(alpha: 0.12),
                  sColor.withValues(alpha: 0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: sColor.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _severityIcon(alert.severity),
                      color: sColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    _SeverityChip(severity: alert.severity),
                    const Spacer(),
                    _StatusPill(resolved: alert.isResolved),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  alert.title,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: sColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(alert.description, style: tt.bodyMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.tag_outlined,
                      size: 14,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      alert.code,
                      style: tt.labelSmall?.copyWith(
                        fontFamily: 'monospace',
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Linked entities ──────────────────────────────────────────
          if (alert.employeeId != null || alert.payRunId != null) ...[
            _SectionCard(
              title: 'Linked To',
              children: [
                if (alert.employeeId != null)
                  _LinkedTile(
                    icon: Icons.person_outline,
                    label: 'Employee',
                    value: alert.employeeId!,
                    onTap: () => context.push(
                      AppRoutes.payrollEmployeeDetail(alert.employeeId!),
                    ),
                  ),
                if (alert.payRunId != null)
                  _LinkedTile(
                    icon: Icons.receipt_long_outlined,
                    label: 'Pay Run',
                    value: alert.payRunId!,
                    onTap: () => context.push(
                      AppRoutes.payrollPayRunDetail(alert.payRunId!),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // ── Timeline ─────────────────────────────────────────────────
          _SectionCard(
            title: 'Timeline',
            children: [
              _TimelineTile(
                color: sColor,
                icon: Icons.warning_amber_outlined,
                label: 'Alert raised',
                date: _dtFmt.format(alert.raisedAt),
              ),
              if (alert.isResolved && alert.resolvedAt != null)
                _TimelineTile(
                  color: _C.green,
                  icon: Icons.check_circle_outline,
                  label: 'Resolved by ${alert.resolvedByUserId ?? 'system'}',
                  date: _dtFmt.format(alert.resolvedAt!),
                  isLast: true,
                ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Resolution notes (read-only when resolved) ────────────────
          if (alert.isResolved && alert.resolution != null) ...[
            _SectionCard(
              title: 'Resolution Notes',
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _C.green.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(alert.resolution!, style: tt.bodyMedium),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // ── Resolve panel (only when open) ────────────────────────────
          if (!alert.isResolved) ...[
            _SectionCard(
              title: 'Mark as Resolved',
              children: [
                Text(
                  'Provide a resolution note describing the corrective action taken.',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _resolutionCtrl,
                  maxLines: 3,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: 'Describe the corrective action taken…',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: _resolving ? null : () => _resolve(alert),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _C.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: _resolving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_outline, size: 18),
                    label: Text(
                      _resolving ? 'Saving…' : 'Mark as Resolved',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // ── Action guidance ───────────────────────────────────────────
          _SectionCard(
            title: 'Guidance',
            children: [Text(_guidanceText(alert.code), style: tt.bodySmall)],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _resolve(ComplianceAlert alert) async {
    final notes = _resolutionCtrl.text.trim();
    if (notes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter resolution notes')),
      );
      return;
    }
    setState(() => _resolving = true);
    await ref
        .read(complianceAlertNotifierProvider.notifier)
        .resolve(alert.id, 'usr_current', notes);
    setState(() => _resolving = false);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Alert marked as resolved')));
      context.pop();
    }
  }

  Color _severityColor(ComplianceSeverity s) => switch (s) {
    ComplianceSeverity.critical => _C.rose,
    ComplianceSeverity.warning => _C.amber,
    ComplianceSeverity.info => _C.sky,
  };

  IconData _severityIcon(ComplianceSeverity s) => switch (s) {
    ComplianceSeverity.critical => Icons.error_outline,
    ComplianceSeverity.warning => Icons.warning_amber_outlined,
    ComplianceSeverity.info => Icons.info_outline,
  };

  String _guidanceText(String code) {
    return switch (code) {
      'NMWA_BREACH' =>
        'The employee\'s effective pay falls below the current National Minimum Wage Act rate. '
            'Immediately adjust the pay structure or daily rate and reprocess any affected payslips.',
      'CONTRACT_EXPIRED' =>
        'The fixed-term contract has reached its end date without renewal or termination. '
            'Either renew the contract via the Contracts module or initiate the termination workflow.',
      'UIF_MISSING_BANK' =>
        'Unemployment Insurance Fund declarations require a valid bank account on record. '
            'Update the employee\'s bank details in their profile.',
      'GARNISHEE_CAP' =>
        'Total non-statutory deductions exceed 25% of the employee\'s net pay, '
            'in violation of BCEA § 34. Reduce garnishee or deduction amounts before the next pay run.',
      'LEAVE_OVERDRAWN' =>
        'The employee has drawn more leave than is available. '
            'Review the leave allocation and either increase entitlement or process a leave without pay adjustment.',
      _ =>
        'Review the alert details and take corrective action before processing the next payroll run. '
            'Contact your payroll administrator or HR consultant if you are unsure of the required steps.',
    };
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _SeverityChip extends StatelessWidget {
  const _SeverityChip({required this.severity});
  final ComplianceSeverity severity;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (severity) {
      ComplianceSeverity.critical => ('Critical', _C.rose),
      ComplianceSeverity.warning => ('Warning', _C.amber),
      ComplianceSeverity.info => ('Info', _C.sky),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.resolved});
  final bool resolved;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (resolved ? _C.green : _C.rose).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        resolved ? 'Resolved' : 'Open',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: resolved ? _C.green : _C.rose,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Material(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: tt.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _C.navy,
                ),
              ),
              const Divider(height: 12),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _LinkedTile extends StatelessWidget {
  const _LinkedTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 18, color: _C.navy),
      title: Text(
        label,
        style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
      ),
      subtitle: Text(
        value,
        style: tt.bodySmall?.copyWith(
          color: _C.navy,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 16),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.color,
    required this.icon,
    required this.label,
    required this.date,
    this.isLast = false,
  });
  final Color color;
  final IconData icon;
  final String label;
  final String date;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, size: 14, color: color),
            ),
            if (!isLast)
              Container(width: 2, height: 28, color: cs.outlineVariant),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  date,
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                SizedBox(height: isLast ? 0 : 12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
