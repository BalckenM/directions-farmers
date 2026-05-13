import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../models/goat_animal.dart';
import '../models/goat_records.dart';
import '../providers/goat_providers.dart';

class GoatFamachaScreen extends ConsumerStatefulWidget {
  const GoatFamachaScreen({super.key});

  @override
  ConsumerState<GoatFamachaScreen> createState() => _GoatFamachaScreenState();
}

class _GoatFamachaScreenState extends ConsumerState<GoatFamachaScreen> {
  // Form state for the bottom sheet
  String? _selectedAnimalId;
  int _score = 1;
  String _action = 'none';
  final _notesController = TextEditingController();
  bool _saving = false;

  static const _actions = ['none', 'monitored', 'drenched'];
  static const _actionLabels = {
    'none': 'No action',
    'monitored': 'Monitored',
    'drenched': 'Drenched',
  };

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Color _scoreColor(int score) {
    switch (score) {
      case 1:
        return const Color(0xFF388E3C); // green
      case 2:
        return const Color(0xFF8BC34A); // light green
      case 3:
        return const Color(0xFFFBC02D); // yellow
      case 4:
        return const Color(0xFFE64A19); // orange-red
      case 5:
        return const Color(0xFFC62828); // deep red
      default:
        return Colors.grey;
    }
  }

  String _scoreLabel(int score) {
    switch (score) {
      case 1:
        return 'Optimal';
      case 2:
        return 'Acceptable';
      case 3:
        return 'Borderline';
      case 4:
        return 'Anaemic';
      case 5:
        return 'Severe';
      default:
        return 'Unknown';
    }
  }

  void _showAddForm(List<GoatAnimal> animals) {
    _selectedAnimalId = animals.isNotEmpty ? animals.first.id : null;
    _score = 1;
    _action = 'none';
    _notesController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.md,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Record FAMACHA Score',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedAnimalId,
                decoration: const InputDecoration(
                  labelText: 'Animal',
                  border: OutlineInputBorder(),
                ),
                items: animals
                    .map((a) => DropdownMenuItem(
                          value: a.id,
                          child: Text(a.displayName),
                        ))
                    .toList(),
                onChanged: (v) {
                  setModalState(() => _selectedAnimalId = v);
                },
              ),
              const SizedBox(height: 12),
              Text('FAMACHA Score',
                  style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  5,
                  (i) {
                    final s = i + 1;
                    final selected = _score == s;
                    return GestureDetector(
                      onTap: () => setModalState(() => _score = s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: selected
                              ? _scoreColor(s)
                              : _scoreColor(s).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: selected
                              ? Border.all(
                                  color: _scoreColor(s).withValues(alpha: 0.8),
                                  width: 2.5)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '$s',
                            style: TextStyle(
                              color: selected ? Colors.white : _scoreColor(s),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Center(
                  child: Text(
                    _scoreLabel(_score),
                    style: TextStyle(
                        color: _scoreColor(_score),
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _action,
                decoration: const InputDecoration(
                  labelText: 'Action taken',
                  border: OutlineInputBorder(),
                ),
                items: _actions
                    .map((a) => DropdownMenuItem(
                          value: a,
                          child: Text(_actionLabels[a]!),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setModalState(() => _action = v);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving
                      ? null
                      : () async {
                          if (_selectedAnimalId == null) return;
                          setModalState(() => _saving = true);
                          final record = FamachaRecord(
                            id: 'famacha_${DateTime.now().millisecondsSinceEpoch}',
                            animalId: _selectedAnimalId!,
                            date: DateTime.now().toIso8601String().substring(0, 10),
                            score: _score,
                            actionTaken: _action == 'none' ? null : _action,
                            notes: _notesController.text.trim().isEmpty
                                ? null
                                : _notesController.text.trim(),
                          );
                          ref
                              .read(newFamachaRecordProvider.notifier)
                              .addRecord(_selectedAnimalId!, record);
                          if (ctx.mounted) Navigator.pop(ctx);
                          setModalState(() => _saving = false);
                        },
                  child: const Text('Save Score'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final animalsAsync = ref.watch(animalsProvider);
    final famachaAsync = ref.watch(allGoatFamachaRecordsProvider);
    final alertAnimalsAsync = ref.watch(famachaAlertProvider);
    final alertAnimals = alertAnimalsAsync.asData?.value ?? [];

    return FarmScaffold(
      appBar: const FarmAppBar(
        title: 'FAMACHA Scoring',
        subtitle: 'Parasite load monitoring',
      ),
      floatingActionButton: animalsAsync.asData?.value != null
          ? FloatingActionButton.extended(
              onPressed: () => _showAddForm(animalsAsync.asData!.value),
              icon: const Icon(Icons.add),
              label: const Text('Record Score'),
            )
          : null,
      body: famachaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (records) {
          final animals = animalsAsync.asData?.value ?? [];

          // Score distribution (counts per score 1-5)
          final dist = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
          // Latest score per animal
          final Map<String, FamachaRecord> latestByAnimal = {};
          for (final r in records) {
            final prev = latestByAnimal[r.animalId];
            if (prev == null || r.date.compareTo(prev.date) > 0) {
              latestByAnimal[r.animalId] = r;
            }
          }
          for (final r in latestByAnimal.values) {
            dist[r.score] = (dist[r.score] ?? 0) + 1;
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              // ── Alert banner ───────────────────────────────────────────
              if (alertAnimals.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFCDD2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFC62828), width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_rounded,
                          color: Color(0xFFC62828)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${alertAnimals.length} animal${alertAnimals.length > 1 ? 's' : ''} need treatment (score ≥ 4)',
                          style: const TextStyle(
                              color: Color(0xFFC62828),
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Score distribution card ────────────────────────────────
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Score Distribution',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(5, (i) {
                          final s = i + 1;
                          return _ScorePill(
                            score: s,
                            count: dist[s] ?? 0,
                            color: _scoreColor(s),
                            label: _scoreLabel(s),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // ── Animal list ────────────────────────────────────────────
              Text(
                'Animals (${latestByAnimal.length} scored)',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...animals.map((animal) {
                final latest = latestByAnimal[animal.id];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: latest != null
                          ? _scoreColor(latest.score)
                          : Colors.grey[300],
                      child: Text(
                        latest != null ? '${latest.score}' : '–',
                        style: TextStyle(
                          color: latest != null ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(animal.displayName),
                    subtitle: Text(
                      latest != null
                          ? '${_scoreLabel(latest.score)} · ${latest.date}'
                          : 'Not yet scored',
                      style: TextStyle(
                        color: latest != null
                            ? _scoreColor(latest.score)
                            : Colors.grey,
                      ),
                    ),
                    trailing: latest?.actionTaken != null
                        ? Chip(
                            label:
                                Text(_actionLabels[latest!.actionTaken] ?? ''),
                            visualDensity: VisualDensity.compact,
                          )
                        : null,
                  ),
                );
              }),

              if (records.isEmpty && animals.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'No animals found.\nAdd animals first, then record FAMACHA scores.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ),
                ),

              const SizedBox(height: 80), // FAB clearance
            ],
          );
        },
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  final int score;
  final int count;
  final Color color;
  final String label;

  const _ScorePill({
    required this.score,
    required this.count,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
          ),
          child: Center(
            child: Text(
              '$count',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text('$score', style: TextStyle(color: color, fontSize: 11)),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 9, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
