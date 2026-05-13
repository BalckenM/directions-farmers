import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/goat_animal.dart';
import '../providers/goat_providers.dart';

class GoatInventoryScreen extends ConsumerWidget {
  const GoatInventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animalsAsync = ref.watch(animalsProvider);

    return FarmScaffold(
      appBar: const FarmAppBar(
        title: 'Inventory',
        subtitle: 'Herd census',
      ),
      body: animalsAsync.when(
        loading: () => const LoadingShimmer(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (animals) {
          if (animals.isEmpty) {
            return const Center(child: Text('No animals recorded'));
          }

          // Group by herd
          final byHerd = <String, List<GoatAnimal>>{};
          for (final a in animals) {
            (byHerd[a.herdId] ??= []).add(a);
          }

          // Summary counts
          final bySex = <String, int>{};
          final byType = <String, int>{};
          final byStatus = <String, int>{};
          for (final a in animals) {
            bySex[a.sex] = (bySex[a.sex] ?? 0) + 1;
            byType[a.productionType] =
                (byType[a.productionType] ?? 0) + 1;
            byStatus[a.status] = (byStatus[a.status] ?? 0) + 1;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary chips
                Text('Total: ${animals.length} animals',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    ...bySex.entries.map(
                      (e) => Chip(label: Text('${e.value} ${e.key}')),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    ...byType.entries.map(
                      (e) => Chip(
                          label: Text(
                              '${e.value} ${e.key}')),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Text('By Herd',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                ...byHerd.entries.map(
                  (entry) => _HerdSection(
                    herdId: entry.key,
                    animals: entry.value,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HerdSection extends StatelessWidget {
  const _HerdSection({required this.herdId, required this.animals});
  final String herdId;
  final List<GoatAnimal> animals;

  @override
  Widget build(BuildContext context) {
    final females = animals.where((a) => a.isFemale).length;
    final males = animals.where((a) => a.isMale).length;
    final kids = animals.where((a) => a.isKid).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(herdId,
            style: Theme.of(context).textTheme.titleSmall),
        subtitle: Text(
            '${animals.length} animals · $females does · $males males · $kids kids'),
        children: animals
            .map(
              (a) => ListTile(
                dense: true,
                leading: Icon(
                  a.sex == 'doe'
                      ? Icons.female_rounded
                      : Icons.male_rounded,
                  size: 18,
                ),
                title: Text(a.displayName),
                subtitle: Text(a.breed),
                trailing: Chip(
                  label: Text(a.status),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
