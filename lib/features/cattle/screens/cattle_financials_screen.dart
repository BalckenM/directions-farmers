import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../providers/cattle_providers.dart';

class CattleFinancialsScreen extends ConsumerWidget {
  const CattleFinancialsScreen({super.key, required this.cattleId});
  final String cattleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(cattleSaleRecordsProvider(cattleId));
    final milkAsync = ref.watch(cattleMilkRecordsProvider(cattleId));
    final feedAsync = ref.watch(allCattleFeedRecordsProvider);
    final medAsync = ref.watch(cattleMedicationLogsProvider(cattleId));
    final animalAsync = ref.watch(cattleDetailProvider(cattleId));
    final animal = animalAsync.asData?.value;
    final animalName = animal?.displayName ?? cattleId;

    final isLoading = salesAsync is AsyncLoading ||
        milkAsync is AsyncLoading ||
        feedAsync is AsyncLoading;
    final isError = salesAsync is AsyncError ||
        milkAsync is AsyncError ||
        feedAsync is AsyncError;

    if (isLoading) {
      return FarmScaffold(
        appBar: FarmAppBar(title: 'Financials', subtitle: animalName),
        body: const LoadingShimmer(),
      );
    }

    if (isError) {
      return FarmScaffold(
        appBar: FarmAppBar(title: 'Financials', subtitle: animalName),
        body: const Center(child: Text('Error loading financials')),
      );
    }

    final sales = salesAsync.asData?.value ?? [];
    final milkRecords = milkAsync.asData?.value ?? [];
    final feedRecords = (feedAsync.asData?.value ?? [])
        .where((r) => r.animalId == cattleId)
        .toList();
    final medRecords = medAsync.asData?.value ?? [];

    // ── Income ───────────────────────────────────────────────────────────────
    final totalSaleRevenue =
        sales.fold<double>(0, (s, r) => s + (r.totalAmount ?? 0));
    final totalMilkLitres =
        milkRecords.fold<double>(0, (s, r) => s + r.totalLitres);

    // ── Costs ────────────────────────────────────────────────────────────────
    final totalFeedCost =
        feedRecords.fold<double>(0, (s, r) => s + (r.totalCost ?? 0));
    final purchaseCost = animal?.purchasePrice ?? 0.0;

    // ── Net margin ───────────────────────────────────────────────────────────
    final totalIncome = totalSaleRevenue;
    final totalCosts = totalFeedCost + purchaseCost;
    final netMargin = totalIncome - totalCosts;
    final netColor = netMargin >= 0
        ? Colors.green.shade700
        : Theme.of(context).colorScheme.error;

    return FarmScaffold(
      appBar: FarmAppBar(title: 'Financials', subtitle: animalName),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Income section ───────────────────────────────────────────────
            Text('Income',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _SummaryCard(
              icon: Icons.sell_rounded,
              title: 'Sale Revenue',
              subtitle: '${sales.length} transaction(s)',
              amount: totalSaleRevenue,
              color: Colors.green.shade50,
            ),
            const SizedBox(height: 8),
            _SummaryCard(
              icon: Icons.water_drop_outlined,
              title: 'Milk Production',
              subtitle:
                  '${totalMilkLitres.toStringAsFixed(1)} L · ${milkRecords.length} records',
              amount: null,
              color: Colors.cyan.shade50,
            ),
            const SizedBox(height: 24),

            // ── Costs section ────────────────────────────────────────────────
            Text('Costs',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (purchaseCost > 0) ...[
              _SummaryCard(
                icon: Icons.shopping_cart_outlined,
                title: 'Purchase Cost',
                subtitle: animal?.purchaseDate != null
                    ? 'Acquired ${animal!.purchaseDate}'
                    : 'Initial cost',
                amount: purchaseCost,
                color: Colors.orange.shade50,
              ),
              const SizedBox(height: 8),
            ],
            _SummaryCard(
              icon: Icons.grass_rounded,
              title: 'Feed & Supplements',
              subtitle: '${feedRecords.length} record(s)',
              amount: totalFeedCost > 0 ? totalFeedCost : null,
              color: Colors.amber.shade50,
            ),
            const SizedBox(height: 8),
            _SummaryCard(
              icon: Icons.medical_services_outlined,
              title: 'Medication',
              subtitle: '${medRecords.length} treatment(s) — no cost data',
              amount: null,
              color: Colors.purple.shade50,
            ),
            const Divider(height: 32),

            // ── Net margin ───────────────────────────────────────────────────
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              color: netMargin >= 0
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Net Margin',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium),
                          Text(
                              'Income R${totalIncome.toStringAsFixed(0)} − Costs R${totalCosts.toStringAsFixed(0)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: Colors.grey[600])),
                        ]),
                    Text(
                      '${netMargin >= 0 ? '+' : ''}R${netMargin.toStringAsFixed(0)}',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                              color: netColor,
                              fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            // ── Sale history ─────────────────────────────────────────────────
            if (sales.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Sale History',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              ...sales.map(
                (s) => Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: Text(s.saleDate),
                    subtitle: Text(
                        '${(s.saleWeightKg ?? 0).toStringAsFixed(1)} kg · ${s.buyerName}'),
                    trailing: Text(
                      'R${(s.totalAmount ?? 0).toStringAsFixed(0)}',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
              ),
            ],

            // ── Feed cost breakdown ──────────────────────────────────────────
            if (feedRecords.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Feed Records',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              ...feedRecords.map(
                (f) => Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading:
                        const Icon(Icons.grass_rounded, size: 20),
                    title: Text(f.feedType),
                    subtitle: Text(
                        '${f.date} · ${f.quantityKg.toStringAsFixed(1)} kg'),
                    trailing: f.totalCost != null
                        ? Text(
                            'R${f.totalCost!.toStringAsFixed(0)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .error),
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.color,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final double? amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: amount != null
            ? Text('R${amount!.toStringAsFixed(0)}',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold))
            : null,
      ),
    );
  }
}
