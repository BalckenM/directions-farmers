import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/user_role.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/farm_app_bar.dart';

class AddMedicationScreen extends ConsumerStatefulWidget {
  const AddMedicationScreen({super.key, required this.flockId});

  final String flockId;

  @override
  ConsumerState<AddMedicationScreen> createState() =>
      _AddMedicationScreenState();
}

class _AddMedicationScreenState extends ConsumerState<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _drugNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _prescribedByController = TextEditingController();
  final _administeredByController = TextEditingController();
  final _batchNoController = TextEditingController();
  final _notesController = TextEditingController();
  final _withdrawalController = TextEditingController(text: '7');

  String _route = 'drinking_water';
  DateTime _date = DateTime.now();
  bool _submitting = false;

  static const _routeOptions = [
    ('drinking_water', 'Drinking Water'),
    ('injection', 'Injection'),
    ('feed', 'In-Feed'),
    ('spray', 'Spray'),
    ('eye_drop', 'Eye Drop'),
  ];

  @override
  void dispose() {
    _drugNameController.dispose();
    _dosageController.dispose();
    _diagnosisController.dispose();
    _prescribedByController.dispose();
    _administeredByController.dispose();
    _batchNoController.dispose();
    _notesController.dispose();
    _withdrawalController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Medication log recorded'),
        backgroundColor: AppColors.success,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(userRoleProvider);
    if (!role.canAdministerMedication) {
      return FarmScaffold(
        drawer: null,
        appBar: const FarmAppBar(
          title: 'Log Medication',
        ),
        body: const Center(
          child: Text('Access denied: insufficient permissions'),
        ),
      );
    }

    final dateLabel =
        '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}';

    return FarmScaffold(
      drawer: null,
      appBar: const FarmAppBar(
        title: 'Log Medication',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePaddingHorizontal,
            vertical: AppSpacing.pagePaddingVertical,
          ),
          children: [
            // Date
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Administration Date'),
              subtitle: Text(dateLabel),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _pickDate,
            ),
            const Divider(),
            const SizedBox(height: AppSpacing.md),

            // Drug Name
            TextFormField(
              controller: _drugNameController,
              decoration: const InputDecoration(
                labelText: 'Drug / Product Name *',
                hintText: 'e.g. Enrofloxacin 10%',
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            // Dosage
            TextFormField(
              controller: _dosageController,
              decoration: const InputDecoration(
                labelText: 'Dosage & Duration *',
                hintText: 'e.g. 1 ml/L drinking water for 5 days',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            // Route
            DropdownButtonFormField<String>(
              initialValue: _route,
              decoration: const InputDecoration(labelText: 'Route of Administration *'),
              items: _routeOptions
                  .map((o) => DropdownMenuItem(value: o.$1, child: Text(o.$2)))
                  .toList(),
              onChanged: (v) => setState(() => _route = v!),
            ),
            const SizedBox(height: AppSpacing.md),

            // Withdrawal period
            TextFormField(
              controller: _withdrawalController,
              decoration: const InputDecoration(
                labelText: 'Withdrawal Period (days) *',
                hintText: '0 for no withdrawal',
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (int.tryParse(v.trim()) == null) return 'Enter whole number';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Diagnosis
            TextFormField(
              controller: _diagnosisController,
              decoration: const InputDecoration(
                labelText: 'Diagnosis / Reason',
                hintText: 'Suspected condition being treated',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.md),

            // Batch No
            TextFormField(
              controller: _batchNoController,
              decoration: const InputDecoration(
                labelText: 'Product Batch Number',
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: AppSpacing.md),

            // Prescribed by
            TextFormField(
              controller: _prescribedByController,
              decoration: const InputDecoration(
                labelText: 'Prescribed By (name & designation)',
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Administered by
            TextFormField(
              controller: _administeredByController,
              decoration: const InputDecoration(
                labelText: 'Administered By',
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes / Observations',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.xl),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.poultryColor,
                ),
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Medication Log'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
