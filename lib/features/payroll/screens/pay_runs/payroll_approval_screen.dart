import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_spacing.dart';
import 'package:mobile_app/core/theme/payroll_design_tokens.dart'
    show PayrollTokens;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/shared/widgets/farm_app_bar.dart';
import 'package:mobile_app/shared/widgets/farm_scaffold.dart';
import 'package:mobile_app/features/payroll/models/pay_run.dart';
import 'package:mobile_app/features/payroll/providers/payroll_providers.dart';
import 'package:mobile_app/features/payroll/theme/payroll_tokens.dart' as pt;
import 'package:mobile_app/features/payroll/providers/payroll_action_providers.dart';

final _zar = NumberFormat.currency(
  locale: 'en_ZA',
  symbol: 'R ',
  decimalDigits: 0,
);

class PayrollApprovalScreen extends ConsumerWidget {
  const PayrollApprovalScreen({super.key, required this.payRunId});
  final String payRunId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payRun = ref.watch(payRunProvider(payRunId));

    if (payRun == null) {
      return FarmScaffold(
        appBar: const FarmAppBar(title: 'Approval'),
        body: const Center(child: Text('Pay run not found')),
      );
    }

    return FarmScaffold(
      appBar: const FarmAppBar(title: 'Approve Pay Run'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _StatusBanner(payRun: payRun),
          const SizedBox(height: AppSpacing.md),
          _SummaryCard(payRun: payRun),
          const SizedBox(height: AppSpacing.md),
          _ComplianceSection(payRun: payRun),
          const SizedBox(height: AppSpacing.lg),
          if (payRun.status == PayRunStatus.pendingApproval) ...[
            _ApproveButton(payRunId: payRunId),
            const SizedBox(height: 12),
            _RejectButton(payRunId: payRunId),
          ] else
            _ReadOnlyStatus(payRun: payRun),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.payRun});
  final PayRun payRun;

  (Color, String, IconData) _info() => switch (payRun.status) {
    PayRunStatus.pendingApproval => (
      AppColors.warning,
      'Awaiting Your Approval',
      Icons.pending_actions,
    ),
    PayRunStatus.approved => (
      AppColors.success,
      'Approved',
      Icons.check_circle_outline,
    ),
    PayRunStatus.disbursed => (
      AppColors.success,
      'Disbursed',
      Icons.payments_outlined,
    ),
    PayRunStatus.cancelled => (
      AppColors.error,
      'Cancelled',
      Icons.cancel_outlined,
    ),
    PayRunStatus.draft => (pt.PayrollTokens.sky, 'Draft', Icons.edit_outlined),
    PayRunStatus.calculated => (
      pt.PayrollTokens.sky,
      'Calculated',
      Icons.calculate_outlined,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final (color, label, icon) = _info();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  'Pay Run: ${payRun.id}',
                  style: TextStyle(
                    fontSize: 11,
                    color: color.withValues(alpha: 0.7),
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.payRun});
  final PayRun payRun;

  String _fmt(DateTime d) {
    const months = [
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
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Icon(
                  Icons.summarize_outlined,
                  color: pt.PayrollTokens.navy,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pay Run Summary',
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: pt.PayrollTokens.navy,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: cs.outlineVariant),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _row(
                  context,
                  'Period',
                  '${_fmt(payRun.periodStart)} – ${_fmt(payRun.periodEnd)}',
                ),
                _row(context, 'Pay Date', _fmt(payRun.payDate)),
                _row(
                  context,
                  'Employees',
                  '${payRun.employeeCount} worker${payRun.employeeCount == 1 ? '' : 's'}',
                ),
                Divider(height: 20, color: cs.outlineVariant),
                _row(
                  context,
                  'Total Gross',
                  _zar.format(payRun.totalGross),
                  bold: true,
                ),
                _row(
                  context,
                  'Total Deductions',
                  _zar.format(payRun.totalDeductions),
                  color: AppColors.error,
                ),
                Divider(height: 16, color: cs.outlineVariant),
                _row(
                  context,
                  'NET PAYABLE',
                  _zar.format(payRun.totalNet),
                  bold: true,
                  large: true,
                  color: AppColors.success,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String label,
    String value, {
    bool bold = false,
    bool large = false,
    Color? color,
  }) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: (large ? tt.bodyMedium : tt.bodySmall)?.copyWith(
                color: PayrollTokens.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: (large ? tt.titleMedium : tt.bodyMedium)?.copyWith(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              color: color ?? PayrollTokens.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComplianceSection extends StatelessWidget {
  const _ComplianceSection({required this.payRun});
  final PayRun payRun;

  @override
  Widget build(BuildContext context) {
    if (payRun.complianceAlertIds.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.verified_outlined,
              color: AppColors.success,
              size: 22,
            ),
            const SizedBox(width: 10),
            const Text(
              'No compliance alerts',
              style: TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_outlined,
                color: AppColors.warning,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                '${payRun.complianceAlertIds.length} Compliance Alert(s)',
                style: const TextStyle(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Review all compliance alerts before approving.',
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ApproveButton extends ConsumerWidget {
  const _ApproveButton({required this.payRunId});
  final String payRunId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(backgroundColor: AppColors.success),
        icon: const Icon(Icons.check_circle_outline),
        label: const Text(
          'Approve Pay Run',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Confirm Approval'),
              content: const Text(
                'Once approved, the pay run will be ready for disbursement. Proceed?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success,
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Approve'),
                ),
              ],
            ),
          );
          if (confirmed != true) return;
          if (!context.mounted) return;
          final ok = await ref
              .read(payRunNotifierProvider.notifier)
              .approvePayRun(payRunId);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                ok != null ? 'Pay run approved!' : 'Approval failed',
              ),
              backgroundColor: ok != null ? AppColors.success : AppColors.error,
            ),
          );
          if (ok != null) Navigator.of(context).pop();
        },
      ),
    );
  }
}

class _RejectButton extends ConsumerWidget {
  const _RejectButton({required this.payRunId});
  final String payRunId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
        ),
        icon: const Icon(Icons.cancel_outlined),
        label: const Text(
          'Reject',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        onPressed: () async {
          final noteCtrl = TextEditingController();
          final reason = await showDialog<String>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Reject Pay Run'),
              content: TextField(
                controller: noteCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Reason for rejection',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  onPressed: () => Navigator.pop(ctx, noteCtrl.text),
                  child: const Text('Reject'),
                ),
              ],
            ),
          );
          noteCtrl.dispose();
          if (reason == null || !context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pay run rejected.'),
              backgroundColor: AppColors.error,
            ),
          );
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class _ReadOnlyStatus extends StatelessWidget {
  const _ReadOnlyStatus({required this.payRun});
  final PayRun payRun;

  @override
  Widget build(BuildContext context) {
    final alreadyApproved =
        payRun.status == PayRunStatus.approved ||
        payRun.status == PayRunStatus.disbursed;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (alreadyApproved ? AppColors.success : AppColors.error)
            .withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            alreadyApproved ? Icons.check_circle : Icons.info_outline,
            color: alreadyApproved ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 10),
          Text(
            alreadyApproved
                ? 'This pay run has already been approved.'
                : 'This pay run cannot be approved in its current state.',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: alreadyApproved ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
