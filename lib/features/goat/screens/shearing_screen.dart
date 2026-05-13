import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/goat_records.dart';
import '../providers/goat_providers.dart';

class GoatShearingScreen extends ConsumerStatefulWidget {
  const GoatShearingScreen({super.key, required this.goatId});
  final String goatId;

  @override
  ConsumerState<GoatShearingScreen> createState() =>
      _GoatShearingScreenState();
}

class _GoatShearingScreenState extends ConsumerState<GoatShearingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _fleeceController = TextEditingController();
  final _micronController = TextEditingController();
  final _colorGradeController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();

  bool _showForm = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _dateController.dispose();
    _fleeceController.dispose();
    _micronController.dispose();
    _colorGradeController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final fleeceKg = double.tryParse(_fleeceController.text.trim()) ?? 0;
    final pricePerKg = double.tryParse(_priceController.text.trim());
    final record = ShearingRecord(
      id: 'sh_${DateTime.now().millisecondsSinceEpoch}',
      animalId: widget.goatId,
      shearingDate: _dateController.text.trim(),
      fleeceWeightKg: fleeceKg,
      micron: double.tryParse(_micronController.text.trim()),
      colorGrade: _colorGradeController.text.trim().isEmpty
          ? null
          : _colorGradeController.text.trim(),
      pricePerKg: pricePerKg,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    ref
        .read(newShearingRecordProvider.notifier)
        .addRecord(widget.goatId, record);
    _dateController.clear();
    _fleeceController.clear();
    _micronController.clear();
    _colorGradeController.clear();
    _priceController.clear();
    _notesController.clear();
    setState(() {
      _isSaving = false;
      _showForm = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync =
        ref.watch(animalShearingRecordsProvider(widget.goatId));
    final animalAsync = ref.watch(animalDetailProvider(widget.goatId));
    final animalName =
        animalAsync.asData?.value?.displayName ?? widget.goatId;

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Shearing Records',
        subtitle: animalName,
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
                      Text('Log Shearing',
                          style:
                              Theme.of(context).textTheme.titleSmall),
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
                            controller: _fleeceController,
                            decoration: const InputDecoration(
                                labelText: 'Fleece Weight (kg) *',
                                suffixText: 'kg'),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
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
                            controller: _micronController,
                            decoration: const InputDecoration(
                                labelText: 'Micron (Âµm)',
                                suffixText: 'Âµm'),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _colorGradeController,
                            decoration: const InputDecoration(
                                labelText: 'Colour Grade'),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                            labelText: 'Price per kg (R)',
                            prefixText: 'R'),
                        keyboardType:
                            const TextInputType.numberWithOptions(
                                decimal: true),
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
                              : const Text('Save Shearing Record'),
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
                          Icon(Icons.cut_rounded,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('No shearing records'),
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
                                    const Icon(Icons.cut_rounded,
                                        size: 18),
                                    const SizedBox(width: 6),
                                    Text(r.shearingDate,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall),
                                    const Spacer(),
                                    if (r.totalRevenue != null)
                                      Text(
                                        'R${r.totalRevenue!.toStringAsFixed(0)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 16,
                                  children: [
                                    _Chip(
                                        label: 'Fleece',
                                        value:
                                            '${r.fleeceWeightKg.toStringAsFixed(2)} kg'),
                                    if (r.micron != null)
                                      _Chip(
                                          label: 'Micron',
                                          value:
                                              '${r.micron!.toStringAsFixed(1)} Âµm'),
                                    if (r.colorGrade != null)
                                      _Chip(
                                          label: 'Grade',
                                          value: r.colorGrade!),
                                    if (r.pricePerKg != null)
                                      _Chip(
                                          label: 'Price',
                                          value:
                                              'R${r.pricePerKg!.toStringAsFixed(0)}/kg'),
                                  ],
                                ),
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

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
