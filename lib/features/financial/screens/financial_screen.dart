import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../data/financial_repository.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/financial_transaction.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

final financialTransactionsProvider =
    FutureProvider.autoDispose<List<FinancialTransaction>>((ref) async {
  final txns =
      await ref.watch(financialRepositoryProvider).getFinancialTransactions();
  return txns..sort((a, b) => b.date.compareTo(a.date));
});

// ── Screen ────────────────────────────────────────────────────────────────────

class FinancialScreen extends ConsumerWidget {
  const FinancialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(financialTransactionsProvider);

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Financial Records',
        subtitle: 'Income & expenses',
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filter',
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addFinancialRecord),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Entry'),
      ),
      body: asyncValue.when(
        loading: () => LoadingShimmer.list(count: 6),
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(financialTransactionsProvider),
        ),
        data: (transactions) {
          if (transactions.isEmpty) {
            return const EmptyState(
              title: 'No financial records',
              subtitle: 'Tap + to add your first income or expense entry.',
              icon: Icon(Icons.account_balance_wallet_outlined),
            );
          }
          return _TransactionList(transactions: transactions);
        },
      ),
    );
  }
}

// ── Summary header ────────────────────────────────────────────────────────────

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.transactions});

  final List<FinancialTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final incomeTotal = transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amountZar);
    final expenseTotal = transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amountZar);
    final net = incomeTotal - expenseTotal;
    final fmt = NumberFormat.currency(locale: 'en_ZA', symbol: 'R', decimalDigits: 0);

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          _SumTile(label: 'Income', amount: incomeTotal, color: const Color(0xFF2E7D32), fmt: fmt),
          const _Divider(),
          _SumTile(label: 'Expenses', amount: expenseTotal, color: cs.error, fmt: fmt),
          const _Divider(),
          _SumTile(
            label: 'Net',
            amount: net,
            color: net >= 0 ? const Color(0xFF2E7D32) : cs.error,
            fmt: fmt,
          ),
        ],
      ),
    );
  }
}

class _SumTile extends StatelessWidget {
  const _SumTile({
    required this.label,
    required this.amount,
    required this.color,
    required this.fmt,
  });
  final String label;
  final double amount;
  final Color color;
  final NumberFormat fmt;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 2),
          Text(fmt.format(amount),
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(color: color, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 36,
        child: VerticalDivider(
            color: Theme.of(context).colorScheme.outlineVariant));
  }
}

// ── Transaction list ──────────────────────────────────────────────────────────

class _TransactionList extends StatelessWidget {
  const _TransactionList({required this.transactions});

  final List<FinancialTransaction> transactions;

  Map<String, List<FinancialTransaction>> get _grouped {
    final map = <String, List<FinancialTransaction>>{};
    for (final t in transactions) {
      final parsed = DateTime.tryParse(t.date);
      final key = parsed != null
          ? DateFormat('MMMM yyyy').format(parsed)
          : t.date.substring(0, 7);
      map.putIfAbsent(key, () => []).add(t);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _grouped;
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        _SummaryHeader(transactions: transactions),
        for (final entry in groups.entries) ...[
          _MonthHeader(month: entry.key, items: entry.value),
          for (final t in entry.value) _TransactionTile(transaction: t),
        ],
      ],
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({required this.month, required this.items});
  final String month;
  final List<FinancialTransaction> items;

  @override
  Widget build(BuildContext context) {
    final incomeSum =
        items.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amountZar);
    final expenseSum =
        items.where((t) => t.isExpense).fold(0.0, (s, t) => s + t.amountZar);
    final fmt = NumberFormat.currency(locale: 'en_ZA', symbol: 'R', decimalDigits: 0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 4),
      child: Row(
        children: [
          Text(month,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text('+${fmt.format(incomeSum)} / -${fmt.format(expenseSum)}',
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});

  final FinancialTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isIncome = transaction.isIncome;
    final color = isIncome ? const Color(0xFF2E7D32) : cs.error;
    final fmt = NumberFormat.currency(locale: 'en_ZA', symbol: 'R', decimalDigits: 0);

    return Card(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: color.withAlpha(31),
          child: Icon(
            isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
            color: color,
            size: 18,
          ),
        ),
        title: Text(transaction.description,
            style: theme.textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        subtitle: Text('${transaction.category} • ${transaction.date}',
            style: theme.textTheme.bodySmall),
        trailing: Text(
          '${isIncome ? '+' : '-'}${fmt.format(transaction.amountZar)}',
          style: theme.textTheme.titleSmall!.copyWith(
              color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
