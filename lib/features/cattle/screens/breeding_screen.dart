import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/cattle_records.dart';
import '../providers/cattle_providers.dart';

class CattleBreedingScreen extends ConsumerStatefulWidget {
  const CattleBreedingScreen({super.key, required this.cattleId});
  final String cattleId;

  @override
  ConsumerState<CattleBreedingScreen> createState() =>
      _CattleBreedingScreenState();
}

class _CattleBreedingScreenState
    extends ConsumerState<CattleBreedingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _sireIdController = TextEditingController();
  final _expectedController = TextEditingController();
  final _notesController = TextEditingController();

  bool _showForm = false;
  bool _isSaving = false;
  String _serviceMethod = 'natural';
  String _outcome = 'uncertain';

  @override
  void dispose() {
    _dateController.dispose();
    _sireIdController.dispose();
    _expectedController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final record = BreedingRecord(
      id: 'br_${DateTime.now().millisecondsSinceEpoch}',
      cowId: widget.cattleId,
      bullId: _sireIdController.text.trim(),
      serviceDate: _dateController.text.trim(),
      serviceMethod: _serviceMethod,
      expectedCalvingDate: _expectedController.text.trim().isEmpty
          ? null
          : _expectedController.text.trim(),
      outcome: _outcome,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    ref
        .read(newCattleBreedingRecordProvider.notifier)
        .addRecord(widget.cattleId, record);
    _dateController.clear();
    _sireIdController.clear();
    _expectedController.clear();
    _notesController.clear();
    setState(() {
      _isSaving = false;
      _showForm = false;
      _serviceMethod = 'natural';
      _outcome = 'uncertain';
    });
  }

  @override
  Widget build(BuildContext context) {
    final animalAsync = ref.watch(cattleDetailProvider(widget.cattleId));
    final matingAsync =
        ref.watch(cattleBreedingRecordsProvider(widget.cattleId));
    final animalName =
        animalAsync.asData?.value?.displayName ?? widget.cattleId;

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Breeding Records',
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
                      Text('Log Mating',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _dateController,
                            decoration: const InputDecoration(
                                labelText: 'Service Date *',
                                hintText: 'YYYY-MM-DD'),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Date required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _serviceMethod,
                            decoration:
                                const InputDecoration(labelText: 'Method'),
                            items: ['natural', 'AI', 'embryo_transfer']
                                .map((m) => DropdownMenuItem(
                                    value: m, child: Text(m)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _serviceMethod = v!),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _sireIdController,
                        decoration: const InputDecoration(
                            labelText: 'Bull Tag / ID *'),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Bull ID required'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _expectedController,
                            decoration: const InputDecoration(
                                labelText: 'Expected Calving',
                                hintText: 'YYYY-MM-DD'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _outcome,
                            decoration: const InputDecoration(
                                labelText: 'Outcome'),
                            items: ['pregnant', 'empty', 'uncertain']
                                .map((o) => DropdownMenuItem(
                                    value: o, child: Text(o)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _outcome = v!),
                          ),
                        ),
                      ]),
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
                              : const Text('Save Mating Record'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: matingAsync.when(
              loading: () => const LoadingShimmer(),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (records) => records.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_border_rounded,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('No mating records'),
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
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.favorite_rounded,
                                        size: 18),
                                    const SizedBox(width: 6),
                                    Text(r.serviceDate,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall),
                                    const Spacer(),
                                    Chip(
                                      label: Text(r.serviceMethod),
                                      visualDensity:
                                          VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                _Row(label: 'Cow', value: r.cowId),
                                _Row(label: 'Bull', value: r.bullId),
                                if (r.expectedCalvingDate != null)
                                  _Row(
                                    label: 'Expected Calving',
                                    value: r.expectedCalvingDate!,
                                  ),
                                _Row(
                                    label: 'Outcome',
                                    value: r.outcome ?? 'pending'),
                                if (r.notes != null)
                                  _Row(
                                      label: 'Notes',
                                      value: r.notes!),
                              ],
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

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                    )),
          ),
          Expanded(
            child: Text(value,
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
