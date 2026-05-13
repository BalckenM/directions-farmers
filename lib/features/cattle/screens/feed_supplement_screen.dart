import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/cattle_records.dart';
import '../providers/cattle_providers.dart';

class FeedSupplementScreen extends ConsumerStatefulWidget {
  const FeedSupplementScreen({super.key});

  @override
  ConsumerState<FeedSupplementScreen> createState() =>
      _FeedSupplementScreenState();
}

class _FeedSupplementScreenState
    extends ConsumerState<FeedSupplementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _feedTypeController = TextEditingController();
  final _brandController = TextEditingController();
  final _quantityKgController = TextEditingController();
  final _costPerKgController = TextEditingController();
  final _notesController = TextEditingController();
  bool _showForm = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _dateController.dispose();
    _feedTypeController.dispose();
    _brandController.dispose();
    _quantityKgController.dispose();
    _costPerKgController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final qty = double.tryParse(_quantityKgController.text.trim()) ?? 0;
    final cpk = double.tryParse(_costPerKgController.text.trim());
    final record = CattleFeedRecord(
      id: 'feed_${DateTime.now().millisecondsSinceEpoch}',
      animalId: 'herd_default',
      date: _dateController.text.trim(),
      feedType: _feedTypeController.text.trim(),
      quantityKg: qty,
      costPerKg: cpk,
      rationName: _brandController.text.trim().isEmpty
          ? null
          : _brandController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    ref.read(newCattleFeedRecordProvider.notifier).addRecord('herd_default', record);
    _dateController.clear();
    _feedTypeController.clear();
    _brandController.clear();
    _quantityKgController.clear();
    _costPerKgController.clear();
    _notesController.clear();
    setState(() {
      _isSaving = false;
      _showForm = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(allCattleFeedRecordsProvider);

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Feed & Supplements',
        subtitle: 'Nutrition records',
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
                      Text('Add Feed Record',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _dateController,
                            decoration: const InputDecoration(
                                labelText: 'Date *',
                                hintText: 'YYYY-MM-DD'),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _feedTypeController,
                            decoration: const InputDecoration(
                                labelText: 'Feed Type *'),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Required'
                                : null,
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _brandController,
                            decoration: const InputDecoration(
                                labelText: 'Brand'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _quantityKgController,
                            decoration: const InputDecoration(
                                labelText: 'Quantity (kg)',
                                suffixText: 'kg'),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _costPerKgController,
                            decoration: const InputDecoration(
                                labelText: 'Cost/kg',
                                prefixText: 'R '),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _notesController,
                        decoration:
                            const InputDecoration(labelText: 'Notes'),
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
              data: (records) => records.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.grass_rounded,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('No feed records'),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: records.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final r = records[i];
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: const Icon(
                                Icons.grass_rounded,
                                color: Colors.green),
                            title: Text(r.feedType),
                            subtitle: Text(
                                '${r.date} · ${r.quantityKg.toStringAsFixed(1)} kg${r.rationName != null ? ' · ${r.rationName}' : ''}'),
                            trailing: r.totalCost != null
                                ? Text(
                                    'R ${r.totalCost!.toStringAsFixed(2)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
