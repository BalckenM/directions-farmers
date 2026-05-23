import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/payment_transaction.dart';
import '../../providers/payroll_providers.dart';
import '../../theme/payroll_tokens.dart';

final _zar = NumberFormat.currency(
  locale: 'en_ZA',
  symbol: 'R ',
  decimalDigits: 2,
);
final _dateFmt = DateFormat('d MMM yyyy');

class PaymentHistoryScreen extends ConsumerStatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  ConsumerState<PaymentHistoryScreen> createState() =>
      _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends ConsumerState<PaymentHistoryScreen> {
  TransactionStatus? _filterStatus;

  (Color, IconData) _methodStyle(String method) => switch (method) {
    'bank' => (PayrollTokens.indigo, Icons.account_balance_outlined),
    'cash' => (PayrollTokens.amber, Icons.payments_outlined),
    'ewallet' => (PayrollTokens.teal, Icons.phone_android_outlined),
    _ => (PayrollTokens.sky, Icons.help_outline),
  };

  (Color, String) _statusStyle(TransactionStatus s) => switch (s) {
    TransactionStatus.initiated => (PayrollTokens.amber, 'Initiated'),
    TransactionStatus.processing => (PayrollTokens.sky, 'Processing'),
    TransactionStatus.completed => (PayrollTokens.green, 'Completed'),
    TransactionStatus.failed => (PayrollTokens.rose, 'Failed'),
    TransactionStatus.reversed => (Colors.grey, 'Reversed'),
  };

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(allTransactionsProvider);
    final filtered = _filterStatus == null
        ? all
        : all.where((t) => t.status == _filterStatus).toList();

    // sort newest first
    final sorted = [...filtered]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final totalAmount = sorted.fold(0.0, (s, t) => s + t.amount);
    final completed = sorted
        .where((t) => t.status == TransactionStatus.completed)
        .length;
    final failed = sorted
        .where((t) => t.status == TransactionStatus.failed)
        .length;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 246, 249),
      appBar: AppBar(
        backgroundColor: PayrollTokens.navy,
        foregroundColor: Colors.white,
        title: const Text(
          'Payment History',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Summary row
          Container(
            color: PayrollTokens.navy,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryChip(
                    'Total',
                    _zar.format(totalAmount),
                    Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SummaryChip(
                    'Completed',
                    '$completed',
                    PayrollTokens.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SummaryChip('Failed', '$failed', PayrollTokens.rose),
                ),
              ],
            ),
          ),
          // Filter chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children:
                  [
                        _filterChip('All', null, _filterStatus),
                        _filterChip(
                          'Completed',
                          TransactionStatus.completed,
                          _filterStatus,
                        ),
                        _filterChip(
                          'Processing',
                          TransactionStatus.processing,
                          _filterStatus,
                        ),
                        _filterChip(
                          'Failed',
                          TransactionStatus.failed,
                          _filterStatus,
                        ),
                        _filterChip(
                          'Initiated',
                          TransactionStatus.initiated,
                          _filterStatus,
                        ),
                        _filterChip(
                          'Reversed',
                          TransactionStatus.reversed,
                          _filterStatus,
                        ),
                      ]
                      .map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(c.label),
                            selected: c.current == c.value,
                            selectedColor: PayrollTokens.navy.withValues(
                              alpha: 0.15,
                            ),
                            onSelected: (_) =>
                                setState(() => _filterStatus = c.value),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: sorted.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.receipt_long_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _filterStatus == null
                              ? 'No transactions yet'
                              : 'No ${_filterStatus!.name} transactions',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: sorted.length,
                    itemBuilder: (ctx, i) => _TransactionCard(
                      transaction: sorted[i],
                      methodStyle: _methodStyle,
                      statusStyle: _statusStyle,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipData {
  const _FilterChipData(this.label, this.value, this.current);
  final String label;
  final TransactionStatus? value, current;
}

_FilterChipData _filterChip(
  String label,
  TransactionStatus? value,
  TransactionStatus? current,
) => _FilterChipData(label, value, current);

class _SummaryChip extends StatelessWidget {
  const _SummaryChip(this.label, this.value, this.color);
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({
    required this.transaction,
    required this.methodStyle,
    required this.statusStyle,
  });
  final PaymentTransaction transaction;
  final (Color, IconData) Function(String) methodStyle;
  final (Color, String) Function(TransactionStatus) statusStyle;

  @override
  Widget build(BuildContext context) {
    final (mColor, mIcon) = methodStyle(transaction.method);
    final (sColor, sLabel) = statusStyle(transaction.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: mColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(mIcon, color: mColor, size: 22),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  transaction.employeeId,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: PayrollTokens.navy,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: sColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  sLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: sColor,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 12,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _dateFmt.format(transaction.createdAt),
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 12),
                  if (transaction.reference != null) ...[
                    Icon(Icons.tag, size: 12, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      transaction.reference!,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ],
              ),
              if (transaction.failureReason != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    transaction.failureReason!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: PayrollTokens.rose,
                    ),
                  ),
                ),
            ],
          ),
          trailing: Text(
            _zar.format(transaction.amount),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: PayrollTokens.navy,
            ),
          ),
        ),
      ),
    );
  }
}
