import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/cattle_records.dart';
import '../providers/cattle_providers.dart';

class VaccinationScreen extends ConsumerStatefulWidget {
  const VaccinationScreen({super.key, required this.cattleId});
  final String cattleId;

  @override
  ConsumerState<VaccinationScreen> createState() =>
      _VaccinationScreenState();
}

class _VaccinationScreenState extends ConsumerState<VaccinationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _vaccineController = TextEditingController();
  final _doseController = TextEditingController();
  final _nextDueController = TextEditingController();
  final _batchController = TextEditingController();
  final _vetController = TextEditingController();

  bool _showForm = false;
  bool _isSaving = false;
  String _route = 'subcutaneous';

  @override
  void dispose() {
    _dateController.dispose();
    _vaccineController.dispose();
    _doseController.dispose();
    _nextDueController.dispose();
    _batchController.dispose();
    _vetController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final record = CattleVaccination(
      id: 'vac_${DateTime.now().millisecondsSinceEpoch}',
      animalId: widget.cattleId,
      dueDate: _dateController.text.trim(),
      givenDate: _dateController.text.trim(),
      vaccineName: _vaccineController.text.trim(),
      route: _route,
      nextDueDate: _nextDueController.text.trim().isEmpty
          ? null
          : _nextDueController.text.trim(),
      batchNumber: _batchController.text.trim().isEmpty
          ? null
          : _batchController.text.trim(),
      administeredBy: _vetController.text.trim().isEmpty
          ? null
          : _vetController.text.trim(),
    );
    ref
        .read(newCattleVaccinationProvider.notifier)
        .addVaccination(widget.cattleId, record);
    _dateController.clear();
    _vaccineController.clear();
    _doseController.clear();
    _nextDueController.clear();
    _batchController.clear();
    _vetController.clear();
    setState(() {
      _isSaving = false;
      _showForm = false;
      _route = 'subcutaneous';
    });
  }

  @override
  Widget build(BuildContext context) {
    final animalAsync = ref.watch(cattleDetailProvider(widget.cattleId));
    final recordsAsync =
        ref.watch(cattleVaccinationsProvider(widget.cattleId));
    final animalName =
        animalAsync.asData?.value?.displayName ?? widget.cattleId;

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Vaccinations',
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
                      Text('Add Vaccination',
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
                            controller: _vaccineController,
                            decoration: const InputDecoration(
                                labelText: 'Vaccine *'),
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
                            controller: _doseController,
                            decoration: const InputDecoration(
                                labelText: 'Dose (mL)'),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _route,
                            decoration: const InputDecoration(
                                labelText: 'Route'),
                            items: [
                              'subcutaneous',
                              'intramuscular',
                              'intranasal',
                              'oral'
                            ]
                                .map((r) => DropdownMenuItem(
                                    value: r, child: Text(r)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _route = v!),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _nextDueController,
                            decoration: const InputDecoration(
                                labelText: 'Next Due',
                                hintText: 'YYYY-MM-DD'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _batchController,
                            decoration: const InputDecoration(
                                labelText: 'Batch No.'),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _vetController,
                        decoration: const InputDecoration(
                            labelText: 'Administered By'),
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
                          Icon(Icons.vaccines_rounded,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('No vaccinations recorded'),
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
                                    const Icon(Icons.vaccines_rounded,
                                        size: 18, color: Colors.teal),
                                    const SizedBox(width: 6),
                                    Text(r.givenDate ?? r.dueDate,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall),
                                    const Spacer(),
                                    Text(r.vaccineName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                                fontWeight:
                                                    FontWeight.w500)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                if (r.route != null)
                                  Text('Route: ${r.route}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                if (r.nextDueDate != null)
                                  Text('Next due: ${r.nextDueDate}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                              color: Colors.orange)),
                                if (r.administeredBy != null)
                                  Text('By: ${r.administeredBy}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
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
