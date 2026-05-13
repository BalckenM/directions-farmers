import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../providers/cattle_providers.dart';

class CrossHerdComparisonScreen extends ConsumerWidget {
  const CrossHerdComparisonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(cattleProvider);

    return FarmScaffold(
      appBar: const FarmAppBar(
          title: 'Herd Comparison', subtitle: 'Cross-breed statistics'),
      body: allAsync.when(
        loading: () => const LoadingShimmer(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (animals) {
          if (animals.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart_rounded,
                      size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('No cattle data for comparison'),
                ],
              ),
            );
          }

          // Group by breed
          final byBreed = <String, List<dynamic>>{};
          for (final a in animals) {
            byBreed.putIfAbsent(a.breed, () => []).add(a);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Breed Performance Comparison',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              ...byBreed.entries.map((entry) {
                final breedAnimals = entry.value;
                final total = breedAnimals.length;
                final avgAge = breedAnimals
                        .where((a) => a.ageMonths != null)
                        .isEmpty
                    ? null
                    : breedAnimals
                            .where((a) => a.ageMonths != null)
                            .fold<double>(
                                0,
                                (s, a) =>
                                    s + (a.ageMonths as double)) /
                        breedAnimals
                            .where((a) => a.ageMonths != null)
                            .length;
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Text(entry.key,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall),
                          ),
                          Chip(
                            label: Text('$total animals'),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                          ),
                        ]),
                        const Divider(),
                        _CompRow(
                            label: 'Count',
                            value: '$total'),
                        if (avgAge != null)
                          _CompRow(
                              label: 'Avg Age',
                              value:
                                  '${avgAge.toStringAsFixed(1)} months'),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _CompRow extends StatelessWidget {
  const _CompRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(value,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
