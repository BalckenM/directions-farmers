import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../providers/goat_providers.dart';

class GoatFinancialsScreen extends ConsumerWidget {
  const GoatFinancialsScreen({super.key, required this.goatId});
  final String goatId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(animalSaleRecordsProvider(goatId));
    final milkAsync = ref.watch(animalMilkRecordsProvider(goatId));
    final shearingAsync = ref.watch(animalShearingRecordsProvider(goatId));
    final animalAsync = ref.watch(animalDetailProvider(goatId));
    final animalName = animalAsync.asData?.value?.displayName ?? goatId;

    final isLoading = salesAsync is AsyncLoading ||
        milkAsync is AsyncLoading ||
        shearingAsync is AsyncLoading;
    final isError = salesAsync is AsyncError ||
        milkAsync is AsyncError ||
        shearingAsync is AsyncError;

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
    final shearing = shearingAsync.asData?.value ?? [];

    final totalSaleRevenue =
        sales.fold<double>(0, (s, r) => s + (r.totalRevenue ?? 0));
    final totalMilkLitres =
        milkRecords.fold<double>(0, (s, r) => s + r.totalLitres);
    final totalShearingRevenue =
        shearing.fold<double>(0, (s, r) => s + (r.totalRevenue ?? 0));
    final grandTotal =
        totalSaleRevenue + totalShearingRevenue;

    return FarmScaffold(
      appBar: FarmAppBar(title: 'Financials', subtitle: animalName),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Revenue Summary',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _SummaryCard(
              icon: Icons.sell_rounded,
              title: 'Sale Revenue',
              subtitle: '${sales.length} transaction(s)',
              amount: totalSaleRevenue,
              color: Colors.blue.shade50,
            ),
            const SizedBox(height: 8),
            _SummaryCard(
              icon: Icons.water_drop_outlined,
              title: 'Milk Production',
              subtitle:
                  '${totalMilkLitres.toStringAsFixed(1)} L total · ${milkRecords.length} records',
              amount: null,
              color: Colors.cyan.shade50,
            ),
            const SizedBox(height: 8),
            _SummaryCard(
              icon: Icons.cut_rounded,
              title: 'Shearing Revenue',
              subtitle: '${shearing.length} shearing(s)',
              amount: totalShearingRevenue,
              color: Colors.purple.shade50,
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Revenue',
                    style: Theme.of(context).textTheme.titleMedium),
                Text('R${grandTotal.toStringAsFixed(0)}',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold)),
              ],
            ),
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
                      'R${(s.totalRevenue ?? 0).toStringAsFixed(0)}',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(
                              color: Theme.of(context).colorScheme.primary),
                    ),
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
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
