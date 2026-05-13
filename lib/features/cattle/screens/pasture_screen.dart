import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/cattle_records.dart';
import '../providers/cattle_providers.dart';

class PastureScreen extends ConsumerStatefulWidget {
  const PastureScreen({super.key});

  @override
  ConsumerState<PastureScreen> createState() => _PastureScreenState();
}

class _PastureScreenState extends ConsumerState<PastureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _pastureIdController = TextEditingController();
  final _pastureNameController = TextEditingController();
  final _sizeHaController = TextEditingController();
  final _grassTypeController = TextEditingController();
  final _notesController = TextEditingController();

  bool _showForm = false;
  bool _isSaving = false;
  String _condition = 'good';

  @override
  void dispose() {
    _dateController.dispose();
    _pastureIdController.dispose();
    _pastureNameController.dispose();
    _sizeHaController.dispose();
    _grassTypeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final record = PastureRecord(
      id: 'pas_${DateTime.now().millisecondsSinceEpoch}',
      herdId: 'default',
      campId: _pastureIdController.text.trim(),
      entryDate: _dateController.text.trim(),
      estimatedHa:
          double.tryParse(_sizeHaController.text.trim()),
      veldCondition: _condition,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    ref
        .read(newCattlePastureRecordProvider.notifier)
        .addRecord('default', record);
    _dateController.clear();
    _pastureIdController.clear();
    _pastureNameController.clear();
    _sizeHaController.clear();
    _grassTypeController.clear();
    _notesController.clear();
    setState(() {
      _isSaving = false;
      _showForm = false;
      _condition = 'good';
    });
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(allCattlePastureRecordsProvider);

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Pasture Records',
        subtitle: 'Grazing management',
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
                      Text('Add Pasture Record',
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
                                ? 'Date required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _pastureIdController,
                            decoration: const InputDecoration(
                                labelText: 'Pasture ID *'),
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
                            controller: _pastureNameController,
                            decoration: const InputDecoration(
                                labelText: 'Pasture Name'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _sizeHaController,
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
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _grassTypeController,
                            decoration: const InputDecoration(
                                labelText: 'Grass Type'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _condition,
                            decoration: const InputDecoration(
                                labelText: 'Condition'),
                            items: [
                              'excellent',
                              'good',
                              'fair',
                              'poor'
                            ]
                                .map((c) => DropdownMenuItem(
                                    value: c, child: Text(c)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _condition = v!),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                            labelText: 'Notes'),
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
                          Text('No pasture records'),
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
                        Color condColor = Colors.green;
                        if (r.veldCondition == 'fair') condColor = Colors.orange;
                        if (r.veldCondition == 'poor')
                          condColor =
                              Theme.of(context).colorScheme.error;
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: Icon(Icons.grass_rounded,
                                color: condColor),
                            title: Text(r.campId),
                            subtitle: Text(
                                '${r.entryDate}${r.estimatedHa != null ? ' · ${r.estimatedHa} ha' : ''}'),
                            trailing: Chip(
                              label: Text(r.veldCondition ?? 'unknown'),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              backgroundColor:
                                  condColor.withOpacity(0.15),
                            ),
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
