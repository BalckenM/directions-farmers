import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../models/crop_expense.dart';
import '../../models/crop_field.dart';
import '../../models/crop_sale.dart';
import '../../providers/crop_providers.dart';

// ── Formatters ────────────────────────────────────────────────────────────────

final _zarFmt = NumberFormat.currency(locale: 'en_ZA', symbol: 'R ');
final _pctFmt = NumberFormat('##0.0', 'en_ZA');

// ── Screen ────────────────────────────────────────────────────────────────────

class ProfitabilityScreen extends ConsumerWidget {
  const ProfitabilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grossAsync = ref.watch(grossMarginProvider);
    final salesAsync = ref.watch(cropSalesProvider(null));
    final expensesAsync = ref.watch(cropExpensesProvider(null));
    final fieldsAsync = ref.watch(cropFieldsProvider(null));
    final harvestAsync = ref.watch(harvestRecordsProvider(null));
    final cropsAsync = ref.watch(cropsProvider(null));
    final Map<String, String> cropNames = {for (final c in cropsAsync.value ?? []) c.id: c.name};
    // revenue per field: join sales → harvest → field
    final harvests = harvestAsync.value ?? [];
    final sales = salesAsync.value ?? [];
    final revenueByField = <String, double>{};
    for (final sale in sales) {
      if (sale.harvestId == null) continue;
      final harvest =
          harvests.where((h) => h.id == sale.harvestId).firstOrNull;
      if (harvest == null) continue;
      revenueByField[harvest.fieldId] =
          (revenueByField[harvest.fieldId] ?? 0.0) + sale.totalAmountZar;
    }

    return FarmScaffold(
      appBar: const FarmAppBar(title: 'Profitability'),
      body: CustomScrollView(
        slivers: [
          // ── KPI row ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: grossAsync.when(
              loading: () => Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: LoadingShimmer.list(count: 1, itemHeight: 100),
              ),
              error: (e, _) => _ErrorMessage(message: 'Failed to load KPIs: $e'),
              data: (gm) => Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: _KpiRow(
                  revenue: gm.revenue,
                  costs: gm.costs,
                  margin: gm.margin,
                  marginPct: gm.marginPct,
                ),
              ),
            ),
          ),

          // ── Revenue section ────────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Revenue',
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
          ),
          salesAsync.when(
            loading: () => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: LoadingShimmer.list(count: 3, itemHeight: 88),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: _ErrorMessage(message: 'Failed to load sales: $e'),
            ),
            data: (sales) => SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    if (i == sales.length) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            top: AppSpacing.sm, bottom: AppSpacing.sm),
                        child: TextButton.icon(
                          onPressed: () => _showLogSaleSheet(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Log Sale'),
                        ),
                      );
                    }
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _SaleCard(sale: sales[i], cropNames: cropNames),
                    );
                  },
                  childCount: sales.length + 1,
                ),
              ),
            ),
          ),

          // ── Cost breakdown section ─────────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Cost Breakdown',
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
          ),
          expensesAsync.when(
            loading: () => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: LoadingShimmer.list(count: 4, itemHeight: 56),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: _ErrorMessage(message: 'Failed to load expenses: $e'),
            ),
            data: (expenses) {
              final grouped = _groupExpensesByCategory(expenses);
              final total = expenses.fold<double>(0.0, (s, e) => s + e.amountZar);
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                sliver: SliverToBoxAdapter(
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.card),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        children: grouped.entries.map((entry) {
                          return _CostCategoryRow(
                            category: entry.key,
                            amount: entry.value,
                            totalCosts: total,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // ── Summary by field section ───────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Summary by Field',
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
          ),
          _buildFieldSummarySliver(fieldsAsync, expensesAsync, revenueByField),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xxl),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldSummarySliver(
    AsyncValue<List<CropField>> fieldsAsync,
    AsyncValue<List<CropExpense>> expensesAsync,
    Map<String, double> revenueByField,
  ) {
    if (fieldsAsync.isLoading || expensesAsync.isLoading) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: LoadingShimmer.list(count: 3, itemHeight: 64),
        ),
      );
    }
    if (fieldsAsync.hasError) {
      return SliverToBoxAdapter(
        child: _ErrorMessage(
            message: 'Failed to load fields: ${fieldsAsync.error}'),
      );
    }

    final fields = fieldsAsync.value ?? [];
    final expenses = expensesAsync.value ?? [];

    if (fields.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Center(child: Text('No fields found.')),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final field = fields[i];
            final fieldExpenses = expenses
                .where((e) => e.fieldId == field.id)
                .toList();
            final totalCosts =
                fieldExpenses.fold<double>(0.0, (s, e) => s + e.amountZar);
            final revenue = revenueByField[field.id] ?? 0.0;
            final margin = revenue - totalCosts;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _FieldSummaryCard(
                fieldName: field.name,
                totalExpenses: totalCosts,
                revenue: revenue,
                margin: margin,
              ),
            );
          },
          childCount: fields.length,
        ),
      ),
    );
  }
}

// ── KPI Row ───────────────────────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  const _KpiRow({
    required this.revenue,
    required this.costs,
    required this.margin,
    required this.marginPct,
  });

  final double revenue;
  final double costs;
  final double margin;
  final double marginPct;

  @override
  Widget build(BuildContext context) {
    final isPositive = margin >= 0;

    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            label: 'Total Revenue',
            value: _zarFmt.format(revenue),
            icon: Icons.trending_up_rounded,
            iconColor: AppColors.success,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _KpiCard(
            label: 'Total Costs',
            value: _zarFmt.format(costs),
            icon: Icons.receipt_long_outlined,
            iconColor: AppColors.error,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _KpiCard(
            label: 'Gross Margin',
            value: _zarFmt.format(margin),
            icon: Icons.account_balance_wallet_outlined,
            iconColor: isPositive ? AppColors.success : AppColors.error,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _KpiCard(
            label: 'Margin %',
            value: '${_pctFmt.format(marginPct)}%',
            icon: Icons.pie_chart_outline_rounded,
            iconColor: isPositive ? AppColors.success : AppColors.error,
            highlight: true,
            highlightColor:
                isPositive ? AppColors.successContainer : AppColors.errorContainer,
            highlightTextColor:
                isPositive ? AppColors.onSuccessContainer : AppColors.onErrorContainer,
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.highlight = false,
    this.highlightColor,
    this.highlightTextColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final bool highlight;
  final Color? highlightColor;
  final Color? highlightTextColor;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final bg = highlight ? highlightColor : cs.surfaceContainerLow;
    final textColor = highlight ? highlightTextColor : cs.onSurface;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppSpacing.iconSm, color: iconColor),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: tt.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: highlight
                  ? highlightTextColor?.withAlpha(180)
                  : cs.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Sale Card ─────────────────────────────────────────────────────────────────

class _SaleCard extends StatelessWidget {
  const _SaleCard({required this.sale, required this.cropNames});

  final CropSale sale;
  final Map<String, String> cropNames;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    Color statusColor;
    Color statusBg;
    String statusLabel;
    switch (sale.paymentStatus) {
      case 'paid':
        statusColor = AppColors.success;
        statusBg = AppColors.successContainer;
        statusLabel = 'Paid';
      case 'partial':
        statusColor = AppColors.warning;
        statusBg = AppColors.warningContainer;
        statusLabel = 'Partial';
      default:
        statusColor = AppColors.error;
        statusBg = AppColors.errorContainer;
        statusLabel = 'Pending';
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    cropNames[sale.cropId] ?? sale.cropId,
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: AppRadius.chip,
                  ),
                  child: Text(
                    statusLabel,
                    style: tt.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (sale.buyer != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                sale.buyer!,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _SaleDetail(
                  label: 'Qty',
                  value: '${sale.quantityTons.toStringAsFixed(1)} t',
                ),
                const SizedBox(width: AppSpacing.md),
                _SaleDetail(
                  label: 'Price/t',
                  value: _zarFmt.format(sale.pricePerTonZar),
                ),
                const Spacer(),
                Text(
                  _zarFmt.format(sale.totalAmountZar),
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
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

class _SaleDetail extends StatelessWidget {
  const _SaleDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
        Text(value, style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ── Cost Category Row ─────────────────────────────────────────────────────────

Map<ExpenseCategory, double> _groupExpensesByCategory(
    List<CropExpense> expenses) {
  final map = <ExpenseCategory, double>{};
  for (final e in expenses) {
    map[e.category] = (map[e.category] ?? 0.0) + e.amountZar;
  }
  return map;
}

IconData _iconForCategory(ExpenseCategory cat) => switch (cat) {
      ExpenseCategory.seed => Icons.eco_outlined,
      ExpenseCategory.fertilizer => Icons.science_outlined,
      ExpenseCategory.chemical => Icons.bug_report_outlined,
      ExpenseCategory.fuel => Icons.local_gas_station_outlined,
      ExpenseCategory.labor => Icons.people_outline,
      ExpenseCategory.machinery => Icons.agriculture_outlined,
      ExpenseCategory.irrigation => Icons.water_drop_outlined,
      ExpenseCategory.transport => Icons.local_shipping_outlined,
      ExpenseCategory.other => Icons.category_outlined,
    };

class _CostCategoryRow extends StatelessWidget {
  const _CostCategoryRow({
    required this.category,
    required this.amount,
    required this.totalCosts,
  });

  final ExpenseCategory category;
  final double amount;
  final double totalCosts;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final pct = totalCosts > 0 ? amount / totalCosts : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: AppRadius.chip,
                ),
                child: Icon(
                  _iconForCategory(category),
                  size: AppSpacing.iconSm,
                  color: cs.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  category.label,
                  style: tt.bodyMedium,
                ),
              ),
              Text(
                _zarFmt.format(amount),
                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: 42,
                child: Text(
                  '${_pctFmt.format(pct * 100)}%',
                  style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: AppRadius.chip,
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 4,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Field Summary Card ────────────────────────────────────────────────────────

class _FieldSummaryCard extends StatelessWidget {
  const _FieldSummaryCard({
    required this.fieldName,
    required this.totalExpenses,
    required this.revenue,
    required this.margin,
  });

  final String fieldName;
  final double totalExpenses;
  final double revenue;
  final double margin;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final isPositive = margin >= 0;
    final marginColor = isPositive ? AppColors.success : AppColors.error;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.grid_on_rounded,
                    size: AppSpacing.iconSm, color: cs.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    fieldName,
                    style:
                        tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? AppColors.successContainer
                        : AppColors.errorContainer,
                    borderRadius: AppRadius.chip,
                  ),
                  child: Text(
                    _zarFmt.format(margin),
                    style: tt.labelSmall?.copyWith(
                      color: marginColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _FieldMetric(
                    label: 'Revenue',
                    value: _zarFmt.format(revenue),
                    color: AppColors.success,
                  ),
                ),
                Expanded(
                  child: _FieldMetric(
                    label: 'Costs',
                    value: _zarFmt.format(totalExpenses),
                    color: AppColors.error,
                  ),
                ),
                Expanded(
                  child: _FieldMetric(
                    label: 'Margin',
                    value: _zarFmt.format(margin),
                    color: marginColor,
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

class _FieldMetric extends StatelessWidget {
  const _FieldMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(
          value,
          style: tt.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ── Log Sale Bottom Sheet ─────────────────────────────────────────────────────

void _showLogSaleSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.topOnly),
    builder: (_) => const _LogSaleSheet(),
  );
}

class _LogSaleSheet extends StatefulWidget {
  const _LogSaleSheet();

  @override
  State<_LogSaleSheet> createState() => _LogSaleSheetState();
}

class _LogSaleSheetState extends State<_LogSaleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _quantityCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _buyerCtrl = TextEditingController();

  String? _selectedCrop;
  DateTime? _saleDate;

  static const List<String> _crops = [
    'Maize (White)',
    'Tomato',
    'Wheat',
    'Sunflower',
  ];

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _priceCtrl.dispose();
    _buyerCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _saleDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _saleDate = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sale logged')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: AppRadius.chip,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Log Sale',
                style:
                    tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _selectedCrop,
              decoration: _dec('Crop'),
              items: _crops
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCrop = v),
              validator: (v) => v == null ? 'Select a crop' : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityCtrl,
                    decoration: _dec('Quantity (tons)'),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextFormField(
                    controller: _priceCtrl,
                    decoration: _dec('Price/ton (ZAR)'),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _buyerCtrl,
              decoration: _dec('Buyer (optional)'),
            ),
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: _pickDate,
              borderRadius: AppRadius.input,
              child: InputDecorator(
                decoration: _dec('Sale Date'),
                child: Text(
                  _saleDate == null
                      ? 'Select date'
                      : '${_saleDate!.day.toString().padLeft(2, '0')}/'
                          '${_saleDate!.month.toString().padLeft(2, '0')}/'
                          '${_saleDate!.year}',
                  style: _saleDate == null
                      ? tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant)
                      : tt.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                child: const Text('Save Sale'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: AppRadius.input),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        isDense: true,
      );
}

// ── Error message ─────────────────────────────────────────────────────────────

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Text(
        message,
        style: TextStyle(color: AppColors.error),
        textAlign: TextAlign.center,
      ),
    );
  }
}
