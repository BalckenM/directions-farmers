import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../models/crop_expense.dart';
import '../../providers/crop_providers.dart';
import '../../providers/crop_action_providers.dart';

class ExpenseTrackerScreen extends ConsumerStatefulWidget {
  const ExpenseTrackerScreen({super.key});

  @override
  ConsumerState<ExpenseTrackerScreen> createState() =>
      _ExpenseTrackerScreenState();
}

class _ExpenseTrackerScreenState extends ConsumerState<ExpenseTrackerScreen> {
  final currencyFmt = NumberFormat.currency(
    locale: 'en_ZA',
    symbol: 'R ',
    decimalDigits: 2,
  );

  Future<bool> _confirmDelete(CropExpense expense) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete Expense?'),
            content: Text(
              'Remove "${expense.description}" (${currencyFmt.format(expense.amountZar)})?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _delete(CropExpense expense) async {
    await ref.read(cropActionProvider.notifier).deleteExpense(expense.id);
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(cropExpensesProvider(null));

    return FarmScaffold(
      appBar: FarmAppBar(title: 'Expense Tracker'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addCropExpense),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Expense'),
      ),
      body: expensesAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: LoadingShimmer(height: 140),
        ),
        error: (e, _) => Center(
          child: Text(
            'Failed to load expenses: $e',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
        data: (expenses) {
          final total = expenses.fold<double>(
            0.0,
            (sum, e) => sum + e.amountZar,
          );

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(cropExpensesProvider);
                  ref.invalidate(totalExpensesProvider);
                  ref.invalidate(grossMarginProvider);
                  await ref.read(cropExpensesProvider(null).future);
                },
                child: CustomScrollView(
                  slivers: [
                    // ── Summary card ───────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: _SummaryCard(
                          expenses: expenses,
                          total: total,
                          currencyFmt: currencyFmt,
                        ),
                      ),
                    ),

                    // ── All Expenses header ────────────────────────────────
                    const SliverToBoxAdapter(
                      child: SectionHeader(title: 'All Expenses'),
                    ),

                    // ── Expense list ───────────────────────────────────────
                    if (expenses.isEmpty)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Text(
                            'No expenses recorded yet.',
                            style: TextStyle(color: AppColors.onSurfaceVariant),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.xs,
                          AppSpacing.md,
                          // bottom padding accounts for FAB + footer bar
                          120,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final expense = expenses[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: Dismissible(
                                key: ValueKey(expense.id),
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (_) => _confirmDelete(expense),
                                onDismissed: (_) => _delete(expense),
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(
                                    right: AppSpacing.md,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    borderRadius: AppRadius.card,
                                  ),
                                  child: const Icon(
                                    Icons.delete_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                                child: GestureDetector(
                                  onLongPress: () => context.push(
                                    AppRoutes.editCropExpense,
                                    extra: expense,
                                  ),
                                  child: _ExpenseCard(
                                    expense: expense,
                                    currencyFmt: currencyFmt,
                                  ),
                                ),
                              ),
                            );
                          }, childCount: expenses.length),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Fixed total footer ─────────────────────────────────────
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _TotalFooter(total: total, currencyFmt: currencyFmt),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Summary Card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.expenses,
    required this.total,
    required this.currencyFmt,
  });

  final List<CropExpense> expenses;
  final double total;
  final NumberFormat currencyFmt;

  List<MapEntry<ExpenseCategory, double>> _topCategories() {
    final map = <ExpenseCategory, double>{};
    for (final e in expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amountZar;
    }
    final sorted = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final top = _topCategories();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.card,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(76),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Spent',
            style: tt.labelMedium?.copyWith(
              color: AppColors.onPrimary.withAlpha(204),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            currencyFmt.format(total),
            style: tt.headlineMedium?.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (top.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Top Categories',
              style: tt.labelSmall?.copyWith(
                color: AppColors.onPrimary.withAlpha(178),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _CategoryBar(categories: top, total: total),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: top.map((e) {
                final color = _categoryColor(e.key);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      e.key.label,
                      style: const TextStyle(
                        color: AppColors.onPrimary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({required this.categories, required this.total});

  final List<MapEntry<ExpenseCategory, double>> categories;
  final double total;

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: AppRadius.chip,
      child: SizedBox(
        height: 10,
        child: Row(
          children: categories.map((entry) {
            final proportion = entry.value / total;
            return Flexible(
              flex: (proportion * 1000).round(),
              child: Container(color: _categoryColor(entry.key)),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Expense Card ──────────────────────────────────────────────────────────────

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({required this.expense, required this.currencyFmt});

  final CropExpense expense;
  final NumberFormat currencyFmt;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final dateFmt = DateFormat('dd MMM yyyy');
    final color = _categoryColor(expense.category);
    final containerColor = color.withAlpha(31);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: AppRadius.card,
              ),
              child: Icon(
                _categoryIcon(expense.category),
                color: color,
                size: AppSpacing.iconMd,
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.description,
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${dateFmt.format(expense.date)}'
                    '${expense.supplier != null ? ' · ${expense.supplier}' : ''}',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),

            // Amount
            Text(
              currencyFmt.format(expense.amountZar),
              style: tt.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Total Footer ──────────────────────────────────────────────────────────────

class _TotalFooter extends StatelessWidget {
  const _TotalFooter({required this.total, required this.currencyFmt});

  final double total;
  final NumberFormat currencyFmt;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            currencyFmt.format(total),
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Color _categoryColor(ExpenseCategory cat) => switch (cat) {
  ExpenseCategory.seed => AppColors.success,
  ExpenseCategory.fertilizer => const Color(0xFF8BC34A), // lime
  ExpenseCategory.chemical => AppColors.secondaryDark,
  ExpenseCategory.fuel => AppColors.warning,
  ExpenseCategory.labor => AppColors.tertiary,
  ExpenseCategory.machinery => AppColors.rabbitColor, // purple
  ExpenseCategory.irrigation => AppColors.tertiaryContainer,
  ExpenseCategory.transport => AppColors.sheepColor,
  ExpenseCategory.other => AppColors.onSurfaceVariant,
};

IconData _categoryIcon(ExpenseCategory cat) => switch (cat) {
  ExpenseCategory.seed => Icons.grass_rounded,
  ExpenseCategory.fertilizer => Icons.science_rounded,
  ExpenseCategory.chemical => Icons.bubble_chart_rounded,
  ExpenseCategory.fuel => Icons.local_gas_station_rounded,
  ExpenseCategory.labor => Icons.people_rounded,
  ExpenseCategory.machinery => Icons.agriculture_rounded,
  ExpenseCategory.irrigation => Icons.water_rounded,
  ExpenseCategory.transport => Icons.local_shipping_rounded,
  ExpenseCategory.other => Icons.more_horiz_rounded,
};
