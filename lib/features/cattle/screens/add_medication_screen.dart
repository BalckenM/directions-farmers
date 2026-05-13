import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/cattle_records.dart';
import '../providers/cattle_providers.dart';

class AddMedicationScreen extends ConsumerStatefulWidget {
  const AddMedicationScreen({super.key, required this.cattleId});
  final String cattleId;

  @override
  ConsumerState<AddMedicationScreen> createState() =>
      _AddMedicationScreenState();
}

class _AddMedicationScreenState
    extends ConsumerState<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _drugController = TextEditingController();
  final _doseController = TextEditingController();
  final _reasonController = TextEditingController();
  final _withdrawalMeatController = TextEditingController();
  final _withdrawalMilkController = TextEditingController();
  final _vetController = TextEditingController();

  bool _isSaving = false;
  String _route = 'intramuscular';

  @override
  void dispose() {
    _dateController.dispose();
    _drugController.dispose();
    _doseController.dispose();
    _reasonController.dispose();
    _withdrawalMeatController.dispose();
    _withdrawalMilkController.dispose();
    _vetController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final record = CattleMedicationLog(
      id: 'med_${DateTime.now().millisecondsSinceEpoch}',
      animalId: widget.cattleId,
      date: _dateController.text.trim(),
      medicationName: _drugController.text.trim(),
      doseMg: double.tryParse(_doseController.text.trim()) ?? 0,
      route: _route,
      notes: _reasonController.text.trim().isEmpty
          ? null
          : _reasonController.text.trim(),
      withdrawalDaysMeat:
          int.tryParse(_withdrawalMeatController.text.trim()),
      withdrawalDaysMilk:
          int.tryParse(_withdrawalMilkController.text.trim()),
      administeredBy: _vetController.text.trim().isEmpty
          ? null
          : _vetController.text.trim(),
    );
    ref
        .read(newCattleMedicationLogProvider.notifier)
        .addLog(widget.cattleId, record);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final animalAsync = ref.watch(cattleDetailProvider(widget.cattleId));
    final animalName =
        animalAsync.asData?.value?.displayName ?? widget.cattleId;

    return FarmScaffold(
      appBar: FarmAppBar(
          title: 'Add Medication', subtitle: animalName),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                        labelText: 'Date *',
                        hintText: 'YYYY-MM-DD',
                        prefixIcon: Icon(Icons.calendar_today_rounded)),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Date required' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _drugController,
                    decoration: const InputDecoration(
                        labelText: 'Drug Name *',
                        prefixIcon: Icon(Icons.medication_rounded)),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _doseController,
                    decoration: const InputDecoration(
                        labelText: 'Dose *',
                        hintText: 'e.g. 10mL'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _route,
                    decoration:
                        const InputDecoration(labelText: 'Route'),
                    items: [
                      'intramuscular',
                      'subcutaneous',
                      'intravenous',
                      'oral',
                      'topical'
                    ]
                        .map((r) =>
                            DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (v) => setState(() => _route = v!),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                    labelText: 'Reason / Condition',
                    prefixIcon: Icon(Icons.healing_rounded)),
              ),
              const SizedBox(height: 12),
              Text('Withdrawal Periods',
                  style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _withdrawalMeatController,
                    decoration: const InputDecoration(
                        labelText: 'Meat (days)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _withdrawalMilkController,
                    decoration: const InputDecoration(
                        labelText: 'Milk (days)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              TextFormField(
                controller: _vetController,
                decoration: const InputDecoration(
                    labelText: 'Prescribed By',
                    prefixIcon: Icon(Icons.person_rounded)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Save Medication Log'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Medication log list screen
class MedicationLogScreen extends ConsumerWidget {
  const MedicationLogScreen({super.key, required this.cattleId});
  final String cattleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animalAsync = ref.watch(cattleDetailProvider(cattleId));
    final recordsAsync = ref.watch(cattleMedicationLogsProvider(cattleId));
    final animalName =
        animalAsync.asData?.value?.displayName ?? cattleId;

    return FarmScaffold(
      appBar: FarmAppBar(title: 'Medication Log', subtitle: animalName),
      body: recordsAsync.when(
        loading: () => const LoadingShimmer(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (records) => records.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.medication_rounded,
                        size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('No medication records'),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: records.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final r = records[i];
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.medication_rounded,
                                  size: 18, color: Colors.deepOrange),
                              const SizedBox(width: 6),
                              Text(r.date,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall),
                              const Spacer(),
                              Text(r.medicationName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                              '${r.doseMg}mg · ${r.route}',
                              style:
                                  Theme.of(context).textTheme.bodySmall),
                          if (r.notes != null)
                            Text('Notes: ${r.notes}',
                                style:
                                    Theme.of(context).textTheme.bodySmall),
                          if (r.withdrawalDaysMeat != null ||
                              r.withdrawalDaysMilk != null)
                            Text(
                                'Withdrawal — Meat: ${r.withdrawalDaysMeat ?? '-'}d  Milk: ${r.withdrawalDaysMilk ?? '-'}d',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error)),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
