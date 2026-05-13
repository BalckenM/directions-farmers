import 'dart:convert';
import '../../../core/utils/web_download.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as xl;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/user_role.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../models/flock.dart';
import '../models/poultry_flock.dart';
import '../providers/poultry_providers.dart';

class FlockFinancialScreen extends ConsumerWidget {
  const FlockFinancialScreen({super.key, required this.flockId});

  final String flockId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(userRoleProvider);
    if (!role.canEditFinancials) {
      return FarmScaffold(
        drawer: null,
        appBar: const FarmAppBar(title: 'Batch Financials'),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Text(
              'You do not have permission to view financial records.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final flockAsync = ref.watch(flockDetailProvider(flockId));

    return FarmScaffold(
      drawer: null,
      appBar: const FarmAppBar(title: 'Batch Financials'),
      body: flockAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (flock) {
          if (flock == null) {
            return const Center(child: Text('Flock not found'));
          }
          return _FinancialBody(flock: flock);
        },
      ),
    );
  }
}

class _FinancialBody extends ConsumerWidget {
  const _FinancialBody({required this.flock});

  final PoultryFlock flock;

  void _exportCsv(BuildContext context, PoultryFlock flock,
      double chickCost, double feedCost, double medicationCost,
      double otherCosts, double totalCosts, double revenue,
      double grossMargin) {
    final rows = [
      ['Item', 'Amount (ZAR)'],
      ['Day-Old Chick Cost', chickCost.toStringAsFixed(2)],
      ['Feed Cost', feedCost.toStringAsFixed(2)],
      ['Medication & Vaccines', medicationCost.toStringAsFixed(2)],
      ['Labour & Other', otherCosts.toStringAsFixed(2)],
      ['Total Costs', totalCosts.toStringAsFixed(2)],
      ['Revenue', revenue.toStringAsFixed(2)],
      ['Gross Margin', grossMargin.toStringAsFixed(2)],
    ];
    final csvString = CsvEncoder().convert(rows);
    if (kIsWeb) {
      final encoded = base64Encode(utf8.encode(csvString));
      final uri = 'data:text/csv;base64,$encoded';
      triggerWebDownload(uri, '${flock.batchName}_financials.csv');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CSV export is available on web only.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _exportExcel(
    BuildContext context,
    PoultryFlock flock,
    List<EggSale> sales,
    double chickCost,
    double feedCost,
    double medicationCost,
    double otherCosts,
    double totalCosts,
    double revenue,
    double grossMargin,
  ) {
    if (!kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Excel export is available on web only.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final excel = xl.Excel.createExcel();

    // ── Summary Sheet ────────────────────────────────────────────
    final summarySheet = excel['Financial Summary'];
    summarySheet.appendRow([xl.TextCellValue('Item'), xl.TextCellValue('Amount (ZAR)')]);
    summarySheet.appendRow([xl.TextCellValue('Day-Old Chick Cost'), xl.DoubleCellValue(chickCost)]);
    summarySheet.appendRow([xl.TextCellValue('Feed Cost'), xl.DoubleCellValue(feedCost)]);
    summarySheet.appendRow([xl.TextCellValue('Medication & Vaccines'), xl.DoubleCellValue(medicationCost)]);
    summarySheet.appendRow([xl.TextCellValue('Labour & Other'), xl.DoubleCellValue(otherCosts)]);
    summarySheet.appendRow([xl.TextCellValue('Total Costs'), xl.DoubleCellValue(totalCosts)]);
    summarySheet.appendRow([xl.TextCellValue('Revenue'), xl.DoubleCellValue(revenue)]);
    summarySheet.appendRow([xl.TextCellValue('Gross Margin'), xl.DoubleCellValue(grossMargin)]);

    // ── Egg Sales Sheet ──────────────────────────────────────────
    if (sales.isNotEmpty) {
      final salesSheet = excel['Egg Sales'];
      salesSheet.appendRow([
        xl.TextCellValue('Date'),
        xl.TextCellValue('Buyer'),
        xl.TextCellValue('Dozens'),
        xl.TextCellValue('Price/Doz'),
        xl.TextCellValue('Total Revenue'),
        xl.TextCellValue('Invoice Ref'),
        xl.TextCellValue('Notes'),
      ]);
      for (final s in sales) {
        salesSheet.appendRow([
          xl.TextCellValue(s.date),
          xl.TextCellValue(s.buyerName),
          xl.DoubleCellValue(s.dozensTotal),
          xl.DoubleCellValue(s.pricePerDozen),
          xl.DoubleCellValue(s.totalRevenue),
          xl.TextCellValue(s.invoiceRef ?? ''),
          xl.TextCellValue(s.notes ?? ''),
        ]);
      }
    }

    // Delete default "Sheet1" if it exists
    if (excel.sheets.containsKey('Sheet1')) excel.delete('Sheet1');

    final bytes = excel.encode()!;
    final encoded = base64Encode(bytes);
    final uri = 'data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,$encoded';
    triggerWebDownload(uri, '${flock.batchName}_financials.xlsx');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    // Real medication cost from logs (R 280 per treatment course)
    final medAsync = ref.watch(flockMedicationLogsProvider(flock.id));
    final realMedCost = medAsync.whenOrNull(
      data: (logs) => logs.length * 280.0,
    );

    // --- Financial data derived from flock model ---
    final chickCost = flock.placementCount * (flock.unitCostPerChick ?? 18.50);
    final feedCostPerKg = 7.80; // ZAR/kg
    final feedCost =
        (flock.feedConsumedTotalKg ?? (flock.placementCount * 0.18 * flock.dayOfAge)) *
            feedCostPerKg;
    final medicationCost = realMedCost ?? 3200.0;
    const otherCosts = 1850.0; // labour, litter, utilities stub
    final totalCosts = chickCost + feedCost + medicationCost + otherCosts;

    // Revenue — use real egg sales for layer/breeder flocks
    final eggSalesAsync = ref.watch(flockEggSalesProvider(flock.id));
    final eggSalesRevenueAsync = ref.watch(flockEggSalesRevenueProvider(flock.id));
    final eggSales = eggSalesAsync.whenOrNull(data: (s) => s) ?? [];
    double revenue = 0;
    String revenueLabel = '—';
    if (flock.isBroiler || flock.isDuck) {
      const pricePerKg = 28.50;
      final liveWeightKg =
          (flock.currentCount * (flock.currentAvgWeightG ?? 2000)) / 1000;
      revenue = liveWeightKg * pricePerKg;
      revenueLabel = 'R ${revenue.toStringAsFixed(0)} '
          '(${liveWeightKg.toStringAsFixed(0)} kg × R${pricePerKg.toStringAsFixed(2)}/kg)';
    } else if (flock.isLayer || flock.productionType == 'breeder') {
      // Use real egg sales revenue if available
      final realRevenue = eggSalesRevenueAsync.whenOrNull(data: (r) => r);
      if (realRevenue != null && realRevenue > 0) {
        revenue = realRevenue;
        revenueLabel = 'R ${revenue.toStringAsFixed(0)} (${eggSales.length} sales recorded)';
      } else {
        final weeklyEggs = (flock.layerSpecific?.currentHdpPct ?? 80) / 100 *
            flock.currentCount *
            7;
        const pricePerDozen = 28.0;
        revenue = (weeklyEggs / 12) * pricePerDozen;
        revenueLabel =
            'R ${revenue.toStringAsFixed(0)}/week (${flock.layerSpecific?.currentHdpPct?.toStringAsFixed(0) ?? '—'}% HDP estimate)';
      }
    }

    final grossMargin = revenue - totalCosts;
    final grossMarginColor =
        grossMargin >= 0 ? AppColors.success : AppColors.error;

    double costPerUnit = 0;
    String costPerUnitLabel = '—';
    if (flock.isBroiler || flock.isDuck) {
      final liveWeightKg =
          (flock.currentCount * (flock.currentAvgWeightG ?? 2000)) / 1000;
      costPerUnit = liveWeightKg > 0 ? totalCosts / liveWeightKg : 0;
      costPerUnitLabel = 'R ${costPerUnit.toStringAsFixed(2)}/kg live weight';
    } else if (flock.isLayer) {
      final totalEggs =
          (flock.layerSpecific?.currentHdpPct ?? 80) / 100 * flock.currentCount * 7;
      final dozens = totalEggs / 12;
      costPerUnit = dozens > 0 ? totalCosts / dozens : 0;
      costPerUnitLabel = 'R ${costPerUnit.toStringAsFixed(2)}/dozen';
    }

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePaddingHorizontal,
        vertical: AppSpacing.pagePaddingVertical,
      ),
      children: [
        // Header
        Text(flock.batchName, style: tt.titleLarge),
        Text(
          '${flock.productionType.toUpperCase()} · ${flock.houseId} · Day ${flock.dayOfAge}',
          style: tt.bodyMedium?.copyWith(color: cs.outline),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Summary cards row
        Row(
          children: [
            _SummaryCard(
              label: 'Total Costs',
              value: 'R ${(totalCosts / 1000).toStringAsFixed(1)}k',
              icon: Icons.trending_down_rounded,
              color: AppColors.error,
            ),
            const SizedBox(width: AppSpacing.sm),
            _SummaryCard(
              label: 'Gross Margin',
              value: grossMargin >= 0
                  ? '+R ${(grossMargin / 1000).toStringAsFixed(1)}k'
                  : '-R ${(grossMargin.abs() / 1000).toStringAsFixed(1)}k',
              icon: Icons.account_balance_wallet_outlined,
              color: grossMarginColor,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // Cost breakdown
        _SectionTitle('Cost Breakdown'),
        _CostRow(label: 'Day-Old Chick (DOC) Cost', amount: chickCost),
        _CostRow(label: 'Feed Cost', amount: feedCost),
        _CostRow(label: 'Medication & Vaccines', amount: medicationCost),
        _CostRow(label: 'Labour & Other', amount: otherCosts),
        const Divider(thickness: 1),
        _CostRow(
          label: 'Total Costs',
          amount: totalCosts,
          bold: true,
        ),
        const SizedBox(height: AppSpacing.xl),

        // Revenue
        _SectionTitle('Revenue'),
        if ((flock.isLayer || flock.productionType == 'breeder') && eggSales.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: OutlinedButton.icon(
              onPressed: () => context.push(AppRoutes.addEggSale(flock.id)),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Record Egg Sale'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.poultryColor,
                side: const BorderSide(color: AppColors.poultryColor),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                (flock.isLayer || flock.productionType == 'breeder') && eggSales.isNotEmpty
                    ? 'Egg Sales Revenue'
                    : 'Estimated Revenue',
              ),
              Flexible(
                child: Text(
                  revenueLabel,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        const Divider(thickness: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gross Margin',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                grossMargin >= 0
                    ? '+R ${grossMargin.toStringAsFixed(0)}'
                    : '-R ${grossMargin.abs().toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: grossMarginColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Per-unit cost
        _SectionTitle('Efficiency'),
        _InfoTile(
          label: 'Cost per Unit',
          value: costPerUnitLabel,
          icon: Icons.scale_outlined,
        ),
        _InfoTile(
          label: 'FCR to Date',
          value: flock.fcrToDate != null
              ? flock.fcrToDate!.toStringAsFixed(2)
              : '—',
          icon: Icons.swap_vert_rounded,
        ),
        _InfoTile(
          label: 'Livability',
          value: flock.livabilityPct != null
              ? '${flock.livabilityPct!.toStringAsFixed(1)}%'
              : '—',
          icon: Icons.health_and_safety_outlined,
        ),
        const SizedBox(height: AppSpacing.xl),

        // Export buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _exportCsv(
                  context, flock, chickCost, feedCost, medicationCost,
                  otherCosts, totalCosts, revenue, grossMargin,
                ),
                icon: const Icon(Icons.table_rows_outlined, size: 16),
                label: const Text('CSV'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.poultryColor,
                  side: const BorderSide(color: AppColors.poultryColor),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _exportExcel(
                  context, flock, eggSales, chickCost, feedCost, medicationCost,
                  otherCosts, totalCosts, revenue, grossMargin,
                ),
                icon: const Icon(Icons.grid_on_outlined, size: 16),
                label: const Text('Excel'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green.shade700,
                  side: BorderSide(color: Colors.green.shade700),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        const Text(
          '* All financial figures are estimates based on current batch data. '
          'Actual margins will be confirmed at harvest.',
          style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: AppSpacing.xs),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  const _CostRow({required this.label, required this.amount, this.bold = false});
  final String label;
  final double amount;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? const TextStyle(fontWeight: FontWeight.bold)
        : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('R ${amount.toStringAsFixed(0)}', style: style),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 20),
      title: Text(label),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      dense: true,
    );
  }
}
