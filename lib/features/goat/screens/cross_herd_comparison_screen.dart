import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/goat_animal.dart';
import '../providers/goat_providers.dart';

class CrossHerdComparisonScreen extends ConsumerWidget {
  const CrossHerdComparisonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animalsAsync = ref.watch(animalsProvider);

    return FarmScaffold(
      appBar: const FarmAppBar(
        title: 'Herd Comparison',
        subtitle: 'Cross-herd metrics',
      ),
      body: animalsAsync.when(
        loading: () => const LoadingShimmer(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (animals) {
          if (animals.isEmpty) {
            return const Center(child: Text('No animals to compare'));
          }

          final byHerd = <String, List<GoatAnimal>>{};
          for (final a in animals) {
            (byHerd[a.herdId] ??= []).add(a);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${byHerd.length} herds',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 12),
                // Comparison table header
                Table(
                  border: TableBorder.all(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1.4),
                    3: FlexColumnWidth(1),
                    4: FlexColumnWidth(1),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer),
                      children: [
                        _Header('Herd'),
                        _Header('Count'),
                        _Header('Avg Wt'),
                        _Header('Preg'),
                        _Header('Lact'),
                      ],
                    ),
                    ...byHerd.entries.map(
                      (entry) {
                        final herdAnimals = entry.value;
                        final weights = herdAnimals
                            .where((a) => a.currentWeightKg != null)
                            .map((a) => a.currentWeightKg!)
                            .toList();
                        final avgWeight = weights.isEmpty
                            ? null
                            : weights.reduce((a, b) => a + b) /
                                weights.length;
                        final pregnant = herdAnimals
                            .where((a) => a.status == 'pregnant')
                            .length;
                        final lactating = herdAnimals
                            .where((a) => a.status == 'lactating')
                            .length;

                        return TableRow(
                          children: [
                            _Cell(entry.key),
                            _Cell(herdAnimals.length.toString()),
                            _Cell(avgWeight != null
                                ? '${avgWeight.toStringAsFixed(1)} kg'
                                : '—'),
                            _Cell(pregnant.toString()),
                            _Cell(lactating.toString()),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Text(text,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(fontWeight: FontWeight.bold)),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Text(text, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
