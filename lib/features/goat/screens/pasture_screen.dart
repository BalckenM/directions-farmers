import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/goat_records.dart';
import '../providers/goat_providers.dart';

class GoatPastureScreen extends ConsumerStatefulWidget {
  const GoatPastureScreen({super.key});

  @override
  ConsumerState<GoatPastureScreen> createState() =>
      _GoatPastureScreenState();
}

class _GoatPastureScreenState extends ConsumerState<GoatPastureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _herdIdController = TextEditingController();
  final _campIdController = TextEditingController();
  final _entryDateController = TextEditingController();
  final _estimatedHaController = TextEditingController();
  final _notesController = TextEditingController();

  bool _showForm = false;
  bool _isSaving = false;
  String? _veldCondition;

  @override
  void dispose() {
    _herdIdController.dispose();
    _campIdController.dispose();
    _entryDateController.dispose();
    _estimatedHaController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final herdId = _herdIdController.text.trim();
    final record = PastureRecord(
      id: 'pas_${DateTime.now().millisecondsSinceEpoch}',
      herdId: herdId,
      campId: _campIdController.text.trim(),
      entryDate: _entryDateController.text.trim(),
      exitDate: null,
      estimatedHa:
          double.tryParse(_estimatedHaController.text.trim()),
      veldCondition: _veldCondition,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    ref
        .read(newPastureRecordProvider.notifier)
        .addRecord(herdId, record);
    _herdIdController.clear();
    _campIdController.clear();
    _entryDateController.clear();
    _estimatedHaController.clear();
    _notesController.clear();
    setState(() {
      _isSaving = false;
      _showForm = false;
      _veldCondition = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pastureAsync = ref.watch(allGoatPastureRecordsProvider);

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Pasture Records',
        subtitle: 'All herds',
        actions: [
          IconButton(
            icon: Icon(
                _showForm ? Icons.close_rounded : Icons.add_rounded),
            onPressed: () =>
                setState(() => _showForm = !_showForm),
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
                      Text('Log Pasture Move',
                          style:
                              Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _herdIdController,
                            decoration: const InputDecoration(
                                labelText: 'Herd ID *'),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Herd ID required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _campIdController,
                            decoration: const InputDecoration(
                                labelText: 'Camp ID *'),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Camp ID required'
                                : null,
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _entryDateController,
                            decoration: const InputDecoration(
                                labelText: 'Entry Date *',
                                hintText: 'YYYY-MM-DD'),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Date required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _estimatedHaController,
                            decoration: const InputDecoration(
                                labelText: 'Size (ha)',
                                suffixText: 'ha'),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _veldCondition,
                        decoration: const InputDecoration(
                            labelText: 'Veld Condition'),
                        items: ['good', 'fair', 'poor', 'degraded']
                            .map((c) => DropdownMenuItem(
                                value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _veldCondition = v),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                            labelText: 'Notes (optional)'),
                        maxLines: 2,
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
                              : const Text('Save Pasture Record'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: pastureAsync.when(
              loading: () => const LoadingShimmer(),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (records) {
                if (records.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.grass_rounded,
                            size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('No pasture records'),
                      ],
                    ),
                  );
                }
                final byHerd = <String, List<PastureRecord>>{};
                for (final r in records) {
                  (byHerd[r.herdId] ??= []).add(r);
                }
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: byHerd.entries
                      .map(
                        (entry) => Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8),
                              child: Text(
                                'Herd: ${entry.key}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall,
                              ),
                            ),
                            ...entry.value.map(
                              (r) => Card(
                                margin: const EdgeInsets.only(
                                    bottom: 8),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                              Icons.grass_rounded,
                                              size: 18),
                                          const SizedBox(width: 6),
                                          Text(r.campId,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall),
                                          const Spacer(),
                                          if (r.estimatedHa != null)
                                            Text(
                                                '${r.estimatedHa!.toStringAsFixed(1)} ha',
                                                style:
                                                    Theme.of(context)
                                                        .textTheme
                                                        .bodySmall),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                          'In: ${r.entryDate}'
                                          '${r.exitDate != null ? ' Â· Out: ${r.exitDate}' : ' Â· Current'}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall),
                                      if (r.veldCondition != null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(
                                                  top: 4),
                                          child: Text(
                                              'Condition: ${r.veldCondition}',
                                              style:
                                                  Theme.of(context)
                                                      .textTheme
                                                      .bodySmall),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
