import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/goat_records.dart';
import '../providers/goat_providers.dart';

class PregnancyCheckScreen extends ConsumerStatefulWidget {
  const PregnancyCheckScreen({super.key});

  @override
  ConsumerState<PregnancyCheckScreen> createState() =>
      _PregnancyCheckScreenState();
}

class _PregnancyCheckScreenState
    extends ConsumerState<PregnancyCheckScreen> {
  final _formKey = GlobalKey<FormState>();
  final _animalIdController = TextEditingController();
  final _dateController = TextEditingController();
  final _expectedController = TextEditingController();
  final _daysController = TextEditingController();
  final _notesController = TextEditingController();

  bool _showForm = false;
  bool _isSaving = false;
  String _method = 'visual';
  String _result = 'uncertain';

  @override
  void dispose() {
    _animalIdController.dispose();
    _dateController.dispose();
    _expectedController.dispose();
    _daysController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final animalId = _animalIdController.text.trim();
    final check = PregnancyCheck(
      id: 'pc_${DateTime.now().millisecondsSinceEpoch}',
      animalId: animalId,
      date: _dateController.text.trim(),
      method: _method,
      result: _result,
      expectedKiddingDate: _expectedController.text.trim().isEmpty
          ? null
          : _expectedController.text.trim(),
      daysPregnant: int.tryParse(_daysController.text.trim()),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    ref
        .read(newPregnancyCheckProvider.notifier)
        .addCheck(animalId, check);
    _animalIdController.clear();
    _dateController.clear();
    _expectedController.clear();
    _daysController.clear();
    _notesController.clear();
    setState(() {
      _isSaving = false;
      _showForm = false;
      _method = 'visual';
      _result = 'uncertain';
    });
  }

  @override
  Widget build(BuildContext context) {
    final checksAsync = ref.watch(allGoatPregnancyChecksProvider);

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Pregnancy Checks',
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
                      Text('Record Pregnancy Check',
                          style:
                              Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _animalIdController,
                            decoration: const InputDecoration(
                                labelText: 'Animal Tag / ID *'),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Animal ID required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
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
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _method,
                            decoration: const InputDecoration(
                                labelText: 'Method'),
                            items: [
                              'visual',
                              'ultrasound',
                              'manual'
                            ]
                                .map((m) => DropdownMenuItem(
                                    value: m, child: Text(m)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _method = v!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _result,
                            decoration: const InputDecoration(
                                labelText: 'Result'),
                            items: [
                              'pregnant',
                              'empty',
                              'uncertain'
                            ]
                                .map((r) => DropdownMenuItem(
                                    value: r, child: Text(r)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _result = v!),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _expectedController,
                            decoration: const InputDecoration(
                                labelText: 'Expected Kidding',
                                hintText: 'YYYY-MM-DD'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _daysController,
                            decoration: const InputDecoration(
                                labelText: 'Days Pregnant'),
                            keyboardType: TextInputType.number,
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
                              : const Text('Save Pregnancy Check'),
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
                                    const Icon(
                                        Icons
                                            .pregnant_woman_rounded,
                                        size: 18),
                                    const SizedBox(width: 6),
                                    Text(c.animalId,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall),
                                    const Spacer(),
                                    _ResultBadge(result: c.result),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _InfoRow(
                                    label: 'Check Date',
                                    value: c.date),
                                _InfoRow(
                                    label: 'Method', value: c.method),
                                if (c.daysPregnant != null)
                                  _InfoRow(
                                      label: 'Days Pregnant',
                                      value: '${c.daysPregnant}'),
                                if (c.expectedKiddingDate != null)
                                  _InfoRow(
                                      label: 'Expected Kidding',
                                      value:
                                          c.expectedKiddingDate!),
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

class _ResultBadge extends StatelessWidget {
  const _ResultBadge({required this.result});
  final String result;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Color bg;
    switch (result.toLowerCase()) {
      case 'pregnant':
        bg = Colors.green.shade100;
        break;
      case 'empty':
        bg = Colors.red.shade100;
        break;
      default:
        bg = cs.surfaceContainerHighest;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(result,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(fontWeight: FontWeight.bold)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                    )),
          ),
          Expanded(
            child: Text(value,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

