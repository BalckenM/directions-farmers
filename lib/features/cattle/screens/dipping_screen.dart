import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/cattle_records.dart';
import '../providers/cattle_providers.dart';

class DippingScreen extends ConsumerStatefulWidget {
  const DippingScreen({super.key, required this.cattleId});
  final String cattleId;

  @override
  ConsumerState<DippingScreen> createState() => _DippingScreenState();
}

class _DippingScreenState extends ConsumerState<DippingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _productController = TextEditingController();
  final _concentrationController = TextEditingController();
  final _nextDueController = TextEditingController();
  final _notesController = TextEditingController();

  bool _showForm = false;
  bool _isSaving = false;
  String _method = 'dip_tank';

  @override
  void dispose() {
    _dateController.dispose();
    _productController.dispose();
    _concentrationController.dispose();
    _nextDueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final record = DippingRecord(
      id: 'dip_${DateTime.now().millisecondsSinceEpoch}',
      animalId: widget.cattleId,
      dippingDate: _dateController.text.trim(),
      productUsed: _productController.text.trim(),
      method: _method,
      concentration: _concentrationController.text.trim().isEmpty
          ? '0%'
          : _concentrationController.text.trim(),
      nextDueDays: int.tryParse(_nextDueController.text.trim()) ?? 14,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    ref
        .read(newCattleDippingRecordProvider.notifier)
        .addRecord(widget.cattleId, record);
    _dateController.clear();
    _productController.clear();
    _concentrationController.clear();
    _nextDueController.clear();
    _notesController.clear();
    setState(() {
      _isSaving = false;
      _showForm = false;
      _method = 'dip_tank';
    });
  }

  @override
  Widget build(BuildContext context) {
    final animalAsync = ref.watch(cattleDetailProvider(widget.cattleId));
    final recordsAsync =
        ref.watch(cattleDippingRecordsProvider(widget.cattleId));
    final animalName =
        animalAsync.asData?.value?.displayName ?? widget.cattleId;

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Dipping Records',
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
                      Text('Add Dipping Record',
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
                          child: DropdownButtonFormField<String>(
                            value: _method,
                            decoration: const InputDecoration(
                                labelText: 'Method'),
                            items: [
                              'dip_tank',
                              'spray_race',
                              'pour_on',
                              'hand_spray'
                            ]
                                .map((m) => DropdownMenuItem(
                                    value: m, child: Text(m)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _method = v!),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _productController,
                        decoration: const InputDecoration(
                            labelText: 'Product *'),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Product required'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _concentrationController,
                            decoration: const InputDecoration(
                                labelText: 'Concentration'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _nextDueController,
                            decoration: const InputDecoration(
                                labelText: 'Days to next dip',
                                hintText: '14'),
                            keyboardType: TextInputType.number,
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
                          Icon(Icons.water_drop_rounded,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('No dipping records'),
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
                                    const Icon(Icons.water_drop_rounded,
                                        size: 18, color: Colors.blue),
                                    const SizedBox(width: 6),
                                    Text(r.dippingDate,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall),
                                    const Spacer(),
                                    Chip(
                                      label: Text(r.method),
                                      visualDensity:
                                          VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(r.productUsed,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                            fontWeight:
                                                FontWeight.w500)),
                                Text(
                                    'Concentration: ${r.concentration}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall),
                                Text('Next due: ${r.nextDueDate}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color: Colors.orange)),
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
