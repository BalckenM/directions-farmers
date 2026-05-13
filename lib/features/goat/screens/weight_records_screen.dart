import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/goat_records.dart';
import '../providers/goat_providers.dart';

class GoatWeightRecordsScreen extends ConsumerStatefulWidget {
  const GoatWeightRecordsScreen({super.key, required this.goatId});
  final String goatId;

  @override
  ConsumerState<GoatWeightRecordsScreen> createState() =>
      _GoatWeightRecordsScreenState();
}

class _GoatWeightRecordsScreenState
    extends ConsumerState<GoatWeightRecordsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  bool _showForm = false;
  bool _isSaving = false;
  double? _bcs;

  @override
  void dispose() {
    _dateController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync =
        ref.watch(animalWeightRecordsProvider(widget.goatId));
    final animalAsync = ref.watch(animalDetailProvider(widget.goatId));
    final animalName = animalAsync.asData?.value?.displayName ?? widget.goatId;

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Weight History',
        subtitle: animalName,
        actions: [
          IconButton(
            icon: Icon(_showForm ? Icons.close_rounded : Icons.add_rounded),
            onPressed: () => setState(() => _showForm = !_showForm),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showForm)
            Card(
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Record Weight',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _dateController,
                              decoration: const InputDecoration(
                                labelText: 'Date *',
                                hintText: 'YYYY-MM-DD',
                              ),
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Date required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _weightController,
                              decoration: const InputDecoration(
                                labelText: 'Weight (kg) *',
                                suffixText: 'kg',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              validator: (v) => v == null || v.isEmpty
                                  ? 'Weight required'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('BCS: '),
                          Expanded(
                            child: Slider(
                              value: _bcs ?? 3,
                              min: 1,
                              max: 5,
                              divisions: 8,
                              label: (_bcs ?? 3).toStringAsFixed(1),
                              onChanged: (v) => setState(() => _bcs = v),
                            ),
                          ),
                          Text((_bcs ?? 3).toStringAsFixed(1)),
                        ],
                      ),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isSaving ? null : _save,
                          child: const Text('Save Weight'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: recordsAsync.when(
              loading: () => const LoadingShimmer(),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (records) {
                if (records.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.monitor_weight_outlined,
                            size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('No weight records yet'),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: records.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final r = records[i];
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: const Icon(Icons.monitor_weight_outlined),
                        title: Text(r.date),
                        subtitle: r.bodyConditionScore != null
                            ? Text('BCS: ${r.bodyConditionScore}')
                            : null,
                        trailing: Text(
                          '${r.weightKg.toStringAsFixed(1)} kg',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final record = WeightRecord(
      id: 'wt-${DateTime.now().millisecondsSinceEpoch}',
      animalId: widget.goatId,
      date: _dateController.text.trim(),
      weightKg: double.tryParse(_weightController.text.trim()) ?? 0,
      bodyConditionScore: _bcs,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    ref
        .read(newWeightRecordProvider.notifier)
        .addRecord(widget.goatId, record);
    _dateController.clear();
    _weightController.clear();
    _notesController.clear();
    setState(() {
      _isSaving = false;
      _showForm = false;
      _bcs = null;
    });
  }
}
