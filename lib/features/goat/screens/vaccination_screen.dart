import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/goat_records.dart';
import '../providers/goat_providers.dart';

class GoatVaccinationScreen extends ConsumerStatefulWidget {
  const GoatVaccinationScreen({super.key});

  @override
  ConsumerState<GoatVaccinationScreen> createState() =>
      _GoatVaccinationScreenState();
}

class _GoatVaccinationScreenState
    extends ConsumerState<GoatVaccinationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _animalIdController = TextEditingController();
  final _vaccineNameController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _givenDateController = TextEditingController();
  final _batchController = TextEditingController();
  final _adminByController = TextEditingController();

  bool _showForm = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _animalIdController.dispose();
    _vaccineNameController.dispose();
    _dueDateController.dispose();
    _givenDateController.dispose();
    _batchController.dispose();
    _adminByController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final vac = GoatVaccination(
      id: 'vac_${DateTime.now().millisecondsSinceEpoch}',
      animalId: _animalIdController.text.trim(),
      vaccineName: _vaccineNameController.text.trim(),
      dueDate: _dueDateController.text.trim(),
      givenDate: _givenDateController.text.trim().isEmpty
          ? null
          : _givenDateController.text.trim(),
      batchNumber: _batchController.text.trim().isEmpty
          ? null
          : _batchController.text.trim(),
      administeredBy: _adminByController.text.trim().isEmpty
          ? null
          : _adminByController.text.trim(),
    );
    ref
        .read(newVaccinationProvider.notifier)
        .addVaccination(_animalIdController.text.trim(), vac);
    _animalIdController.clear();
    _vaccineNameController.clear();
    _dueDateController.clear();
    _givenDateController.clear();
    _batchController.clear();
    _adminByController.clear();
    setState(() {
      _isSaving = false;
      _showForm = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final vaccsAsync = ref.watch(allGoatVaccinationsProvider);

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Vaccinations',
        subtitle: 'All animals',
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
                      Text('Schedule / Log Vaccination',
                          style:
                              Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _animalIdController,
                        decoration: const InputDecoration(
                            labelText: 'Animal Tag / ID *'),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Animal ID required'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _vaccineNameController,
                        decoration: const InputDecoration(
                            labelText: 'Vaccine Name *'),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Vaccine name required'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _dueDateController,
                            decoration: const InputDecoration(
                                labelText: 'Due Date *',
                                hintText: 'YYYY-MM-DD'),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Due date required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _givenDateController,
                            decoration: const InputDecoration(
                                labelText: 'Given Date',
                                hintText: 'YYYY-MM-DD'),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _batchController,
                            decoration: const InputDecoration(
                                labelText: 'Batch No.'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _adminByController,
                            decoration: const InputDecoration(
                                labelText: 'Administered By'),
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
                              : const Text('Save Vaccination'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: vaccsAsync.when(
              loading: () => const LoadingShimmer(),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (vaccs) => vaccs.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.vaccines_outlined,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('No vaccinations recorded'),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: vaccs.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final v = vaccs[i];
                        Color cardColor;
                        if (v.isGiven) {
                          cardColor = Colors.green.shade50;
                        } else if (v.isOverdue) {
                          cardColor = Colors.red.shade50;
                        } else {
                          cardColor = Colors.orange.shade50;
                        }
                        return Card(
                          color: cardColor,
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
                                        Icons.vaccines_outlined,
                                        size: 18),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(v.vaccineName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall),
                                    ),
                                    _StatusBadge(v: v),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text('Animal: ${v.animalId}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall),
                                const SizedBox(height: 2),
                                Text('Due: ${v.dueDate}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall),
                                if (v.givenDate != null)
                                  Text(
                                      'Given: ${v.givenDate}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                if (v.administeredBy != null)
                                  Text(
                                      'By: ${v.administeredBy}',
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.v});
  final GoatVaccination v;

  @override
  Widget build(BuildContext context) {
    if (v.isGiven) {
      return const Chip(
        label: Text('Given'),
        backgroundColor: Colors.green,
        padding: EdgeInsets.zero,
      );
    }
    if (v.isOverdue) {
      return const Chip(
        label: Text('Overdue'),
        backgroundColor: Colors.red,
        padding: EdgeInsets.zero,
      );
    }
    return const Chip(
      label: Text('Due Soon'),
      backgroundColor: Colors.orange,
      padding: EdgeInsets.zero,
    );
  }
}
