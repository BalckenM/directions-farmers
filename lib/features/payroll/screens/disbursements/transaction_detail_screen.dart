// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../models/payment_transaction.dart';
import '../../providers/payroll_providers.dart';
import '../../theme/payroll_tokens.dart';

typedef _C = PayrollTokens;
final _zar = NumberFormat.currency(locale: 'en_ZA', symbol: 'R ', decimalDigits: 2);
final _dtFmt = DateFormat('d MMM y, HH:mm');
final _mFmt = DateFormat('d MMM y');

/// Full detail screen for a single [PaymentTransaction].
class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({super.key, required this.transactionId});
  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txList = ref.watch(allTransactionsProvider);
    final tx = txList.where((t) => t.id == transactionId).firstOrNull;

    if (tx == null) {
      return FarmScaffold(
        appBar: const FarmAppBar(title: 'Transaction'),
        body: const Center(child: Text('Transaction not found')),
      );
    }

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final sColor = _statusColor(tx.status);
    final mColor = _methodColor(tx.method);

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Transaction',
        subtitle: tx.reference ?? tx.id,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Amount hero ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E3A5F), Color(0xFF2E5984)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  _zar.format(tx.amount),
                  style: tt.displaySmall?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(tx.currency,
                    style: tt.bodySmall?.copyWith(color: Colors.white70)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _MethodBadge(method: tx.method, color: mColor),
                    const SizedBox(width: 10),
                    _StatusBadge(status: tx.status, color: sColor),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Reference & IDs ──────────────────────────────────────────
          _SectionCard(
            title: 'Reference & Identifiers',
            children: [
              if (tx.reference != null)
                _CopyRow(
                  label: 'Reference',
                  value: tx.reference!,
                  icon: Icons.tag_outlined,
                ),
              _DetailRow(
                  label: 'Transaction ID', value: tx.id, copyable: true),
              _DetailRow(label: 'Pay Run ID', value: tx.payRunId,
                  onTap: () => context.push(AppRoutes.payrollPayRunDetail(tx.payRunId))),
              _DetailRow(label: 'Employee ID', value: tx.employeeId,
                  onTap: () => context.push(AppRoutes.payrollEmployeeDetail(tx.employeeId))),
            ],
          ),
          const SizedBox(height: 12),

          // ── Bank / Disbursement details ───────────────────────────────
          if (tx.bankName != null || tx.accountNumber != null) ...[
            _SectionCard(
              title: 'Disbursement Details',
              children: [
                if (tx.bankName != null)
                  _DetailRow(label: 'Bank', value: tx.bankName!),
                if (tx.accountNumber != null)
                  _CopyRow(
                    label: 'Account Number',
                    value: tx.accountNumber!,
                    icon: Icons.account_balance_outlined,
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
                color: _C.sky,
                icon: Icons.send_outlined,
                label: 'Initiated',
                date: tx.initiatedAt != null
                    ? _dtFmt.format(tx.initiatedAt!)
                    : '—',
              ),
              if (tx.status == TransactionStatus.processing)
                _TimelineTile(
                  color: _C.amber,
                  icon: Icons.hourglass_top_outlined,
                  label: 'Processing',
                  date: '—',
                ),
              if (tx.status == TransactionStatus.completed &&
                  tx.completedAt != null)
                _TimelineTile(
                  color: _C.green,
                  icon: Icons.check_circle_outline,
                  label: 'Completed',
                  date: _dtFmt.format(tx.completedAt!),
                  isLast: true,
                ),
              if (tx.status == TransactionStatus.failed) ...[
                _TimelineTile(
                  color: _C.rose,
                  icon: Icons.cancel_outlined,
                  label: 'Failed',
                  date: tx.completedAt != null
                      ? _dtFmt.format(tx.completedAt!)
                      : '—',
                  isLast: true,
                ),
              ],
              if (tx.status == TransactionStatus.reversed)
                _TimelineTile(
                  color: _C.purple,
                  icon: Icons.undo_outlined,
                  label: 'Reversed',
                  date: tx.completedAt != null
                      ? _dtFmt.format(tx.completedAt!)
                      : '—',
                  isLast: true,
                ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Failure reason ───────────────────────────────────────────
          if (tx.failureReason != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _C.rose.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _C.rose.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline, size: 18, color: _C.rose),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Failure Reason',
                            style: tt.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700, color: _C.rose)),
                        const SizedBox(height: 4),
                        Text(tx.failureReason!, style: tt.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── Retry button (failed transactions) ───────────────────────
          if (tx.status == TransactionStatus.failed) ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _showRetryDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.navy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry Transaction',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── Created date ─────────────────────────────────────────────
          Center(
            child: Text(
              'Created ${_mFmt.format(tx.createdAt)}',
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Color _statusColor(TransactionStatus s) => switch (s) {
        TransactionStatus.initiated  => _C.sky,
        TransactionStatus.processing => _C.amber,
        TransactionStatus.completed  => _C.green,
        TransactionStatus.failed     => _C.rose,
        TransactionStatus.reversed   => _C.purple,
      };

  Color _methodColor(String method) {
    final m = method.toLowerCase();
    if (m.contains('bank')) return _C.indigo;
    if (m.contains('cash')) return _C.green;
    if (m.contains('ewallet') || m.contains('mtn')) return _C.amber;
    if (m.contains('orange')) return _C.rose;
    return _C.navy;
  }

  void _showRetryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Retry Transaction'),
        content: const Text(
            'This will re-submit the transaction to the payment provider. '
            'Are you sure?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Retry submitted — status will update shortly')));
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: _C.navy),
            child: const Text('Retry',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Badges ───────────────────────────────────────────────────────────────────

class _MethodBadge extends StatelessWidget {
  const _MethodBadge({required this.method, required this.color});
  final String method;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.payment_outlined, size: 13, color: color),
          const SizedBox(width: 5),
          Text(method,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.color});
  final TransactionStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      TransactionStatus.initiated  => 'Initiated',
      TransactionStatus.processing => 'Processing',
      TransactionStatus.completed  => 'Completed',
      TransactionStatus.failed     => 'Failed',
      TransactionStatus.reversed   => 'Reversed',
    };
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color)),
    );
  }
}

// ─── Section helpers ──────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: tt.labelMedium
                  ?.copyWith(fontWeight: FontWeight.w700, color: _C.navy)),
          const Divider(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.copyable = false,
    this.onTap,
  });
  final String label;
  final String value;
  final bool copyable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                value,
                style: tt.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: onTap != null ? _C.navy : cs.onSurface,
                    decoration:
                        onTap != null ? TextDecoration.underline : null),
              ),
            ),
          ),
          if (copyable)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Copied: $value')));
              },
              child: Icon(Icons.copy_outlined,
                  size: 14, color: cs.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}

class _CopyRow extends StatelessWidget {
  const _CopyRow({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 16, color: _C.navy),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: tt.labelSmall
                        ?.copyWith(color: cs.onSurfaceVariant)),
                Text(value,
                    style: tt.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Copied: $value')));
            },
            icon: Icon(Icons.copy_outlined,
                size: 16, color: cs.onSurfaceVariant),
            tooltip: 'Copy',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
          ),
        ],
      ),
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
              Container(
                  width: 2, height: 28, color: cs.outlineVariant),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: tt.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                Text(date,
                    style: tt.labelSmall
                        ?.copyWith(color: cs.onSurfaceVariant)),
                SizedBox(height: isLast ? 0 : 12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
