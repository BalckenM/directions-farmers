import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_dropdown.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../../models/payment_transaction.dart';
import '../../providers/payroll_providers.dart';
import '../../theme/payroll_tokens.dart';


enum _StatusFilter { all, completed, failed, processing }

class DisbursementsScreen extends ConsumerStatefulWidget {
  const DisbursementsScreen({super.key});

  @override
  ConsumerState<DisbursementsScreen> createState() =>
      _DisbursementsScreenState();
}

class _DisbursementsScreenState extends ConsumerState<DisbursementsScreen> {
  _StatusFilter _statusFilter = _StatusFilter.all;
  String? _selectedPayRunId;

  @override
  Widget build(BuildContext context) {
    final allTx = ref.watch(allTransactionsProvider);
    final allPayRuns = ref.watch(allPayRunsProvider);
    final employees = ref.watch(employeesProvider);
    final empMap = {for (final e in employees) e.id: e.fullName};

    // Pay run filter options
    final payRunOptions = [
      const DropdownMenuItem<String>(value: null, child: Text('All Pay Runs')),
      ...allPayRuns.map((r) => DropdownMenuItem<String>(
            value: r.id,
            child: Text(_periodLabel(r.periodStart, r.periodEnd),
                overflow: TextOverflow.ellipsis),
          )),
    ];

    // Apply filters
    var filtered = allTx.where((tx) {
      if (_selectedPayRunId != null && tx.payRunId != _selectedPayRunId) {
        return false;
      }
      return switch (_statusFilter) {
        _StatusFilter.completed => tx.status == TransactionStatus.completed,
        _StatusFilter.failed => tx.status == TransactionStatus.failed,
        _StatusFilter.processing => tx.status == TransactionStatus.processing,
        _StatusFilter.all => true,
      };
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Summary stats
    final completedTx =
        allTx.where((t) => t.status == TransactionStatus.completed).toList();
    final failedTx =
        allTx.where((t) => t.status == TransactionStatus.failed).toList();
    final processingTx =
        allTx.where((t) => t.status == TransactionStatus.processing).toList();
    final double totalDisbursed =
        completedTx.fold(0, (sum, t) => sum + t.amount);
    final double bankTotal = allTx
        .where((t) =>
            t.method == 'bank' && t.status == TransactionStatus.completed)
        .fold(0, (sum, t) => sum + t.amount);
    final double cashTotal = allTx
        .where((t) =>
            t.method == 'cash' && t.status == TransactionStatus.completed)
        .fold(0, (sum, t) => sum + t.amount);

    return FarmScaffold(
      appBar: const FarmAppBar(title: 'Disbursements'),
      body: Column(
        children: [
          // ── Summary stats ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Total Disbursed',
                    value: _zar(totalDisbursed),
                    icon: Icons.payments_outlined,
                    accentColor: PayrollTokens.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    label: 'Failed',
                    value: failedTx.length.toString(),
                    icon: Icons.error_outline,
                    accentColor:
                        failedTx.isEmpty ? PayrollTokens.green : PayrollTokens.rose,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    label: 'Processing',
                    value: processingTx.length.toString(),
                    icon: Icons.pending_outlined,
                    accentColor: PayrollTokens.amber,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Filters row ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: FarmDropdown<String>(
                    label: 'Pay Run',
                    value: _selectedPayRunId,
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    items: payRunOptions,
                    onChanged: (v) => setState(() => _selectedPayRunId = v),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Status filter tabs ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _StatusFilter.values.map((f) {
                  final label = switch (f) {
                    _StatusFilter.all =>
                      'All (${_selectedPayRunId == null ? allTx.length : allTx.where((t) => t.payRunId == _selectedPayRunId).length})',
                    _StatusFilter.completed =>
                      'Completed (${completedTx.length})',
                    _StatusFilter.failed => 'Failed (${failedTx.length})',
                    _StatusFilter.processing =>
                      'Processing (${processingTx.length})',
                  };
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(label),
                      selected: _statusFilter == f,
                      onSelected: (_) => setState(() => _statusFilter = f),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 4),

          // ── Transaction list ──────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? const EmptyState(
                    icon: Icon(Icons.account_balance_wallet_outlined),
                    title: 'No transactions',
                    subtitle: 'No disbursements match the selected filters.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: filtered.length + 1,
                    separatorBuilder: (_, i) =>
                        i < filtered.length ? const SizedBox(height: 8) : const SizedBox.shrink(),
                    itemBuilder: (ctx, i) {
                      if (i == filtered.length) {
                        return _methodBreakdown(ctx, bankTotal, cashTotal);
                      }
                      return _TxCard(
                        tx: filtered[i],
                        empName: empMap[filtered[i].employeeId] ??
                            filtered[i].employeeId,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _methodBreakdown(
      BuildContext ctx, double bankTotal, double cashTotal) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Method Breakdown (Completed)'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Bank Transfer',
                  value: _zar(bankTotal),
                  icon: Icons.account_balance_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  label: 'Cash',
                  value: _zar(cashTotal),
                  icon: Icons.payments_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _zar(double v) => 'R${v.toStringAsFixed(2)}';
  String _periodLabel(DateTime start, DateTime end) =>
      '${_shortDate(start)} – ${_shortDate(end)}';
  String _shortDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _TxCard extends ConsumerWidget {
  const _TxCard({required this.tx, required this.empName});
  final PaymentTransaction tx;
  final String empName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final (statusColor, statusLabel, statusIcon) = switch (tx.status) {
      TransactionStatus.completed => (
          PayrollTokens.green,
          'Completed',
          Icons.check_circle_outline
        ),
      TransactionStatus.failed => (
          PayrollTokens.rose,
          'Failed',
          Icons.cancel_outlined
        ),
      TransactionStatus.processing => (
          PayrollTokens.amber,
          'Processing',
          Icons.pending_outlined
        ),
      TransactionStatus.initiated => (
          Colors.blue,
          'Initiated',
          Icons.arrow_circle_up_outlined
        ),
      TransactionStatus.reversed => (
          Colors.purple,
          'Reversed',
          Icons.undo_outlined
        ),
    };

    final methodIcon = switch (tx.method) {
      'bank' => Icons.account_balance_outlined,
      'cash' => Icons.payments_outlined,
      'ewallet' => Icons.account_balance_wallet_outlined,
      _ => Icons.payment,
    };

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: tx.status == TransactionStatus.failed
            ? BorderSide(color: PayrollTokens.rose.withValues(alpha: 0.5), width: 1.5)
            : BorderSide(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRoutes.payrollTransactionDetail(tx.id)),
        child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: name + amount
            Row(
              children: [
                Icon(Icons.person_outline, size: 18, color: cs.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(empName,
                      style: tt.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ),
                Text(
                  'R${tx.amount.toStringAsFixed(2)}',
                  style: tt.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: tx.status == TransactionStatus.failed
                          ? Colors.red[700]
                          : Colors.green[700]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Method + bank info
            Row(
              children: [
                Icon(methodIcon, size: 15, color: cs.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  tx.method.toUpperCase(),
                  style:
                      tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                if (tx.bankName != null) ...[
                  const SizedBox(width: 6),
                  Text('· ${tx.bankName}',
                      style: tt.labelSmall
                          ?.copyWith(color: cs.onSurfaceVariant)),
                ],
                if (tx.reference != null) ...[
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text('Ref: ${tx.reference}',
                        style: tt.labelSmall
                            ?.copyWith(color: cs.onSurfaceVariant),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ],
            ),
            if (tx.status == TransactionStatus.failed &&
                tx.failureReason != null) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: PayrollTokens.rose.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, size: 14, color: Colors.red[700]),
                    const SizedBox(width: 6),
                    Expanded(
                        child: Text(tx.failureReason!,
                            style: tt.bodySmall
                                ?.copyWith(color: Colors.red[700]))),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, size: 13, color: cs.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(_fmt(tx.createdAt),
                    style:
                        tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                const Spacer(),
                // Status chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(statusLabel,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor)),
                    ],
                  ),
                ),
                if (tx.status == TransactionStatus.failed) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Retry initiated. Check back shortly.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: Colors.red[700],
                      side: BorderSide(color: Colors.red[400]!),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                    child: const Text('Retry', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}
