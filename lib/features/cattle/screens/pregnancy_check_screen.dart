import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/cattle_records.dart';
import '../providers/cattle_providers.dart';

class PregnancyCheckScreen extends ConsumerStatefulWidget {
  const PregnancyCheckScreen({super.key, required this.cattleId});
  final String cattleId;

  @override
  ConsumerState<PregnancyCheckScreen> createState() =>
      _PregnancyCheckScreenState();
}

class _PregnancyCheckScreenState
    extends ConsumerState<PregnancyCheckScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _daysGestationController = TextEditingController();
  final _expectedCalvingController = TextEditingController();
  final _notesController = TextEditingController();

  bool _showForm = false;
  bool _isSaving = false;
  String _result = 'open';
  String _method = 'rectal_palpation';

  @override
  void dispose() {
    _dateController.dispose();
    _daysGestationController.dispose();
    _expectedCalvingController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final record = PregnancyCheck(
      id: 'pgc_${DateTime.now().millisecondsSinceEpoch}',
      animalId: widget.cattleId,
      date: _dateController.text.trim(),
      result: _result,
      method: _method,
      daysPregnant: int.tryParse(_daysGestationController.text.trim()),
      expectedCalvingDate: _expectedCalvingController.text.trim().isEmpty
          ? null
          : _expectedCalvingController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    ref
        .read(newCattlePregnancyCheckProvider.notifier)
        .addCheck(widget.cattleId, record);
    _dateController.clear();
    _daysGestationController.clear();
    _expectedCalvingController.clear();
    _notesController.clear();
    setState(() {
      _isSaving = false;
      _showForm = false;
      _result = 'open';
      _method = 'rectal_palpation';
    });
  }

  @override
  Widget build(BuildContext context) {
    final animalAsync = ref.watch(cattleDetailProvider(widget.cattleId));
    final checksAsync =
        ref.watch(cattlePregnancyChecksProvider(widget.cattleId));
    final animalName =
        animalAsync.asData?.value?.displayName ?? widget.cattleId;

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Pregnancy Checks',
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
                      Text('Add Pregnancy Check',
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _dateController,
                            decoration: const InputDecoration(
                                labelText: 'Check Date *',
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
                            decoration:
                                const InputDecoration(labelText: 'Method'),
                            items: [
                              'rectal_palpation',
                              'ultrasound',
                              'blood_test',
                              'visual'
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
                      DropdownButtonFormField<String>(
                        value: _result,
                        decoration:
                            const InputDecoration(labelText: 'Result'),
                        items: ['pregnant', 'open', 'uncertain']
                            .map((r) => DropdownMenuItem(
                                value: r, child: Text(r)))
                            .toList(),
                        onChanged: (v) => setState(() => _result = v!),
                      ),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _daysGestationController,
                            decoration: const InputDecoration(
                                labelText: 'Days Gestation'),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _expectedCalvingController,
                            decoration: const InputDecoration(
                                labelText: 'Expected Calving',
                                hintText: 'YYYY-MM-DD'),
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
                              : const Text('Save Check'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: checksAsync.when(
              loading: () => const LoadingShimmer(),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (checks) => checks.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.pregnant_woman_rounded,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('No pregnancy checks recorded'),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: checks.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final c = checks[i];
                        final isPregnant = c.result == 'pregnant';
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
                                    Icon(
                                        isPregnant
                                            ? Icons.pregnant_woman_rounded
                                            : Icons.remove_circle_outline_rounded,
                                        size: 18,
                                        color: isPregnant
                                            ? Colors.green
                                            : Colors.grey),
                                    const SizedBox(width: 6),
                                    Text(c.date,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall),
                                    const Spacer(),
                                    Chip(
                                      label: Text(c.result),
                                      visualDensity:
                                          VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      backgroundColor: isPregnant
                                          ? Colors.green[100]
                                          : null,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('Method: ${c.method}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall),
                                if (c.daysPregnant != null)
                                  Text('Days pregnant: ${c.daysPregnant}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                if (c.expectedCalvingDate != null)
                                  Text(
                                      'Expected calving: ${c.expectedCalvingDate}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                if (c.notes != null)
                                  Text(c.notes!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant)),
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
