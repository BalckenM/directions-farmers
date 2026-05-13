import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/goat_records.dart';
import '../providers/goat_providers.dart';

class GoatMilkRecordsScreen extends ConsumerStatefulWidget {
  const GoatMilkRecordsScreen({super.key, required this.goatId});
  final String goatId;

  @override
  ConsumerState<GoatMilkRecordsScreen> createState() =>
      _GoatMilkRecordsScreenState();
}

class _GoatMilkRecordsScreenState
    extends ConsumerState<GoatMilkRecordsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _morningController = TextEditingController();
  final _eveningController = TextEditingController();
  final _lactDayController = TextEditingController();

  bool _showForm = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _dateController.dispose();
    _morningController.dispose();
    _eveningController.dispose();
    _lactDayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(animalMilkRecordsProvider(widget.goatId));
    final animalAsync = ref.watch(animalDetailProvider(widget.goatId));
    final animalName = animalAsync.asData?.value?.displayName ?? widget.goatId;

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Milk Records',
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
                      Text('Add Milk Record',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _dateController,
                        decoration: const InputDecoration(
                          labelText: 'Date *',
                          hintText: 'YYYY-MM-DD',
                          prefixIcon: Icon(Icons.calendar_today_rounded),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Date required' : null,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _morningController,
                              decoration: const InputDecoration(
                                labelText: 'Morning (L) *',
                                suffixText: 'L',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _eveningController,
                              decoration: const InputDecoration(
                                labelText: 'Evening (L)',
                                suffixText: 'L',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _lactDayController,
                        decoration: const InputDecoration(
                          labelText: 'Lactation Day',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isSaving ? null : _save,
                          child: const Text('Save Record'),
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
                        Icon(Icons.water_drop_outlined,
                            size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('No milk records yet'),
                      ],
                    ),
                  );
                }
                final total = records.fold<double>(
                    0, (sum, r) => sum + r.totalLitres);
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Text('${records.length} records',
                              style: Theme.of(context).textTheme.bodySmall),
                          const Spacer(),
                          Text(
                            'Total: ${total.toStringAsFixed(1)} L',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: records.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final r = records[i];
                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              leading: const Icon(Icons.water_drop_outlined),
                              title: Text(r.date),
                              subtitle: Text(
                                  'Morning: ${r.morningLitres.toStringAsFixed(1)} L'
                                  ' · Evening: ${r.eveningLitres.toStringAsFixed(1)} L'),
                              trailing: Text(
                                '${r.totalLitres.toStringAsFixed(1)} L',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
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

    final record = DailyMilkRecord(
      id: 'milk-${DateTime.now().millisecondsSinceEpoch}',
      animalId: widget.goatId,
      date: _dateController.text.trim(),
      morningLitres:
          double.tryParse(_morningController.text.trim()) ?? 0,
      eveningLitres: double.tryParse(_eveningController.text.trim()) ?? 0,
      lactationDay: int.tryParse(_lactDayController.text.trim()) ?? 0,
    );

    ref.read(newMilkRecordProvider.notifier).addRecord(widget.goatId, record);
    _dateController.clear();
    _morningController.clear();
    _eveningController.clear();
    _lactDayController.clear();
    setState(() {
      _isSaving = false;
      _showForm = false;
    });
  }
}
