import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/date_picker_field.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../models/pest_observation.dart';
import '../../providers/crop_providers.dart';

class AddPestObservationScreen extends ConsumerStatefulWidget {
  const AddPestObservationScreen({super.key});

  @override
  ConsumerState<AddPestObservationScreen> createState() =>
      _AddPestObservationScreenState();
}

class _AddPestObservationScreenState
    extends ConsumerState<AddPestObservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pestNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _recommendedActionController = TextEditingController();

  String? _selectedField;
  DateTime _observedDate = DateTime.now();
  String _category = 'pest';
  String _severity = 'moderate';
  DateTime? _followUpDate;
  bool _saving = false;

  static const _categories = ['pest', 'disease', 'weed'];
  static const _severities = ['low', 'moderate', 'high', 'critical'];

  @override
  void dispose() {
    _pestNameController.dispose();
    _descriptionController.dispose();
    _recommendedActionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedField == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a field')),
      );
      return;
    }
    setState(() => _saving = true);

    final repo = ref.read(cropRepositoryProvider);
    final obs = PestObservation(
      id: 'pest-${DateTime.now().millisecondsSinceEpoch}',
      fieldId: _selectedField!,
      observedDate: _observedDate,
      pestName: _pestNameController.text.trim(),
      category: _category,
      severity: _severity,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      recommendedAction: _recommendedActionController.text.trim().isEmpty
          ? null
          : _recommendedActionController.text.trim(),
      followUpDate: _followUpDate,
      status: 'open',
    );

    try {
      await repo.addPestObservation(obs);
      ref.invalidate(pestObservationsProvider);
    } catch (_) {}

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Observation logged')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final fieldsAsync = ref.watch(cropFieldsProvider(null));
    return FarmScaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Log Observation'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // ── Field selection ──────────────────────────────────────────
            DropdownButtonFormField<String>(
              decoration: _inputDecoration('Field', Icons.map_outlined),
              initialValue: _selectedField,
              hint: const Text('Select field'),
              items: (fieldsAsync.value ?? [])
                  .map((f) => DropdownMenuItem(value: f.id, child: Text(f.name)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedField = v),
              validator: (v) => v == null ? 'Please select a field' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Observation date ─────────────────────────────────────────
            DatePickerField(
              label: 'Observation Date',
              value: _observedDate,
              onChanged: (d) => setState(() => _observedDate = d),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Pest / disease name ──────────────────────────────────────
            TextFormField(
              controller: _pestNameController,
              decoration: _inputDecoration(
                'Pest / Disease Name',
                Icons.pest_control_rounded,
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Category ─────────────────────────────────────────────────
            DropdownButtonFormField<String>(
              decoration: _inputDecoration('Category', Icons.category_outlined),
              initialValue: _category,
              items: _categories
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(_categoryLabel(c)),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? _category),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Severity ─────────────────────────────────────────────────
            DropdownButtonFormField<String>(
              decoration:
                  _inputDecoration('Severity', Icons.warning_amber_rounded),
              initialValue: _severity,
              items: _severities
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(_severityLabel(s)),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _severity = v ?? _severity),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Description ──────────────────────────────────────────────
            TextFormField(
              controller: _descriptionController,
              decoration: _inputDecoration(
                'Description (optional)',
                Icons.description_outlined,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Recommended action ───────────────────────────────────────
            TextFormField(
              controller: _recommendedActionController,
              decoration: _inputDecoration(
                'Recommended Action (optional)',
                Icons.checklist_rounded,
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Follow-up date ───────────────────────────────────────────
            DatePickerField(
              label: 'Follow-up Date (optional)',
              value: _followUpDate,
              onChanged: (d) => setState(() => _followUpDate = d),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            ),
            if (_followUpDate != null) ...[
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => setState(() => _followUpDate = null),
                  child: const Text('Clear follow-up date'),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),

            // ── Save button ──────────────────────────────────────────────
            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSpacing.minTouchTarget),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.onPrimary,
                      ),
                    )
                  : const Text('Save Observation'),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: AppRadius.input),
      filled: true,
    );
  }

  String _categoryLabel(String c) => switch (c) {
        'pest' => 'Pest',
        'disease' => 'Disease',
        _ => 'Weed',
      };

  String _severityLabel(String s) => switch (s) {
        'low' => 'Low',
        'moderate' => 'Moderate',
        'high' => 'High',
        _ => 'Critical',
      };
}

