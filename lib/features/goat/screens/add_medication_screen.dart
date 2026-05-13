import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';

import '../providers/goat_providers.dart';


class GoatAddMedicationScreen extends ConsumerStatefulWidget {
  const GoatAddMedicationScreen({super.key, required this.goatId});
  final String goatId;

  @override
  ConsumerState<GoatAddMedicationScreen> createState() =>
      _GoatAddMedicationScreenState();
}

class _GoatAddMedicationScreenState
    extends ConsumerState<GoatAddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _drugController = TextEditingController();
  final _doseController = TextEditingController();
  final _reasonController = TextEditingController();
  final _withdrawalController = TextEditingController();
  final _adminByController = TextEditingController();
  String _route = 'injection';
  bool _isSaving = false;

  static const _routes = ['oral', 'injection', 'topical', 'intramuscular', 'subcutaneous'];

  @override
  void dispose() {
    _dateController.dispose();
    _drugController.dispose();
    _doseController.dispose();
    _reasonController.dispose();
    _withdrawalController.dispose();
    _adminByController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animalAsync = ref.watch(animalDetailProvider(widget.goatId));
    final animalName = animalAsync.asData?.value?.displayName ?? widget.goatId;

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Add Medication',
        subtitle: animalName,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Medication Details',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
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
              const SizedBox(height: 12),
              TextFormField(
                controller: _drugController,
                decoration: const InputDecoration(
                  labelText: 'Drug / Medication *',
                  prefixIcon: Icon(Icons.medication_rounded),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Drug name required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _doseController,
                decoration: const InputDecoration(
                  labelText: 'Dose *',
                  hintText: 'e.g. 5 ml',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Dose required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _route,
                decoration: const InputDecoration(labelText: 'Route *'),
                items: _routes
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => setState(() => _route = v ?? _route),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _withdrawalController,
                decoration: const InputDecoration(
                  labelText: 'Withdrawal Period (days)',
                  suffixText: 'days',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _adminByController,
                decoration: const InputDecoration(
                  labelText: 'Administered By',
                ),
              ),
              const SizedBox(height: 24),
              if (ref.watch(canManageHealthProvider))
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Save Medication Record'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    // Medication logs are currently read-only in mock data.
    // Show a snackbar confirmation and pop.
    final withdrawalDays = int.tryParse(_withdrawalController.text.trim());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Logged: ${_drugController.text.trim()} ${_doseController.text.trim()} '
          'via $_route'
          '${withdrawalDays != null ? ' · Withdrawal: $withdrawalDays days' : ''}',
        ),
      ),
    );

    Navigator.of(context).pop();
  }
}
