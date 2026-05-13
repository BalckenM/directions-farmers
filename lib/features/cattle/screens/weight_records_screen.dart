import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/cattle_records.dart';
import '../providers/cattle_providers.dart';

class WeightRecordsScreen extends ConsumerStatefulWidget {
  const WeightRecordsScreen({super.key, required this.cattleId});
  final String cattleId;

  @override
  ConsumerState<WeightRecordsScreen> createState() =>
      _WeightRecordsScreenState();
}

class _WeightRecordsScreenState extends ConsumerState<WeightRecordsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  bool _showForm = false;
  bool _isSaving = false;
  String _method = 'scale';

  @override
  void dispose() {
    _dateController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final record = WeightRecord(
      id: 'wt_${DateTime.now().millisecondsSinceEpoch}',
      animalId: widget.cattleId,
      date: _dateController.text.trim(),
      weightKg: double.tryParse(_weightController.text.trim()) ?? 0,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    ref
        .read(newCattleWeightRecordProvider.notifier)
        .addRecord(widget.cattleId, record);
    _dateController.clear();
    _weightController.clear();
    _notesController.clear();
    setState(() {
      _isSaving = false;
      _showForm = false;
      _method = 'scale';
    });
  }

  @override
  Widget build(BuildContext context) {
    final animalAsync = ref.watch(cattleDetailProvider(widget.cattleId));
    final recordsAsync =
        ref.watch(cattleWeightRecordsProvider(widget.cattleId));
    final animalName =
        animalAsync.asData?.value?.displayName ?? widget.cattleId;

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Weight Records',
        subtitle: animalName,
        actions: [
          IconButton(
            icon: Icon(
                _showForm ? Icons.close_rounded : Icons.add_rounded),
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
                      Text('Add Weight Record',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _dateController,
                            decoration: const InputDecoration(
                                labelText: 'Date *',
                                hintText: 'YYYY-MM-DD',
                                prefixIcon:
                                    Icon(Icons.calendar_today_rounded)),
                            validator: (v) => (v == null || v.isEmpty)
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
                                prefixIcon: Icon(Icons.scale_rounded)),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Weight required'
                                : null,
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _method,
                        decoration:
                            const InputDecoration(labelText: 'Method'),
                        items: [
                          'scale',
                          'weigh_tape',
                          'estimate',
                          'crush_scale'
                        ]
                            .map((m) => DropdownMenuItem(
                                value: m, child: Text(m)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _method = v!),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                            labelText: 'Notes (optional)'),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          child: _isSaving
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2))
                              : const Text('Save'),
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
                        Icon(Icons.scale_rounded,
                            size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('No weight records'),
                      ],
                    ),
                  );
                }
                double? prevWeight;
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: records.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final r = records[i];
                    final delta = prevWeight != null
                        ? r.weightKg - prevWeight!
                        : null;
                    prevWeight = r.weightKg;
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.scale_rounded, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(r.date,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                  if (r.notes != null)
                                    Text(r.notes!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${r.weightKg.toStringAsFixed(1)} kg',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall,
                                ),
                                if (delta != null)
                                  Text(
                                    '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)} kg',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: delta >= 0
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                  ),
                              ],
                            ),
                          ],
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
}
