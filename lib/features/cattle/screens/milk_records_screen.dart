import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/cattle_records.dart';
import '../providers/cattle_providers.dart';

class MilkRecordsScreen extends ConsumerStatefulWidget {
  const MilkRecordsScreen({super.key, required this.cattleId});
  final String cattleId;

  @override
  ConsumerState<MilkRecordsScreen> createState() =>
      _MilkRecordsScreenState();
}

class _MilkRecordsScreenState extends ConsumerState<MilkRecordsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _amYieldController = TextEditingController();
  final _pmYieldController = TextEditingController();
  final _fatController = TextEditingController();
  final _proteinController = TextEditingController();

  bool _showForm = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _dateController.dispose();
    _amYieldController.dispose();
    _pmYieldController.dispose();
    _fatController.dispose();
    _proteinController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final amYield = double.tryParse(_amYieldController.text.trim()) ?? 0;
    final pmYield = double.tryParse(_pmYieldController.text.trim());
    final record = DailyMilkRecord(
      id: 'milk_${DateTime.now().millisecondsSinceEpoch}',
      animalId: widget.cattleId,
      date: _dateController.text.trim(),
      morningLitres: amYield,
      eveningLitres: pmYield,
      lactationDay: 1,
    );
    ref
        .read(newCattleMilkRecordProvider.notifier)
        .addRecord(widget.cattleId, record);
    _dateController.clear();
    _amYieldController.clear();
    _pmYieldController.clear();
    _fatController.clear();
    _proteinController.clear();
    setState(() {
      _isSaving = false;
      _showForm = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final animalAsync = ref.watch(cattleDetailProvider(widget.cattleId));
    final recordsAsync =
        ref.watch(cattleMilkRecordsProvider(widget.cattleId));
    final animalName =
        animalAsync.asData?.value?.displayName ?? widget.cattleId;

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Milk Records',
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
                      Text('Add Milk Record',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 12),
                      TextFormField(
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
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _amYieldController,
                            decoration: const InputDecoration(
                                labelText: 'AM Yield (L)'),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _pmYieldController,
                            decoration: const InputDecoration(
                                labelText: 'PM Yield (L)'),
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
                            controller: _fatController,
                            decoration: const InputDecoration(
                                labelText: 'Fat %'),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _proteinController,
                            decoration: const InputDecoration(
                                labelText: 'Protein %'),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                          ),
                        ),
                      ]),
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
                          Icon(Icons.water_drop_rounded,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('No milk records'),
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
                                    const Icon(
                                        Icons.water_drop_rounded,
                                        size: 18,
                                        color: Colors.blue),
                                    const SizedBox(width: 6),
                                    Text(r.date,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall),
                                    const Spacer(),
                                    Text(
                                      '${r.totalLitres.toStringAsFixed(1)} L',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                              color: Colors.blue[700]),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(children: [
                                  Text(
                                      'AM: ${r.morningLitres.toStringAsFixed(1)} L',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                  const SizedBox(width: 16),
                                  Text(
                                      'PM: ${(r.eveningLitres ?? 0).toStringAsFixed(1)} L',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                ]),
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
