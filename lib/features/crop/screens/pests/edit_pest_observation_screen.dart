import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/date_picker_field.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../models/pest_observation.dart';
import '../../providers/crop_providers.dart';

class EditPestObservationScreen extends ConsumerStatefulWidget {
  const EditPestObservationScreen({super.key, required this.observation});

  final PestObservation observation;

  @override
  ConsumerState<EditPestObservationScreen> createState() =>
      _EditPestObservationScreenState();
}

class _EditPestObservationScreenState
    extends ConsumerState<EditPestObservationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _pestNameController =
      TextEditingController(text: widget.observation.pestName);
  late final _descriptionController =
      TextEditingController(text: widget.observation.description ?? '');
  late final _recommendedActionController =
      TextEditingController(text: widget.observation.recommendedAction ?? '');

  late String _selectedField = widget.observation.fieldId;
  late DateTime _observedDate = widget.observation.observedDate;
  late String _category = widget.observation.category;
  late String _severity = widget.observation.severity;
  late String _status = widget.observation.status;
  late DateTime? _followUpDate = widget.observation.followUpDate;
  bool _saving = false;

  static const _categories = ['pest', 'disease', 'weed'];
  static const _severities = ['low', 'moderate', 'high', 'critical'];
  static const _statuses = ['open', 'treated', 'resolved'];

  @override
  void dispose() {
    _pestNameController.dispose();
    _descriptionController.dispose();
    _recommendedActionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final repo = ref.read(cropRepositoryProvider);
    final updated = PestObservation(
      id: widget.observation.id,
      planId: widget.observation.planId,
      fieldId: _selectedField,
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
      status: _status,
    );

    try {
      await repo.updatePestObservation(updated);
      ref.invalidate(pestObservationsProvider);
    } catch (_) {}

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Observation updated')),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final fieldsAsync = ref.watch(cropFieldsProvider(null));
    final fields = fieldsAsync.value ?? [];

    return FarmScaffold(
      appBar: FarmAppBar(title: 'Edit Observation'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // Field selector
            DropdownButtonFormField<String>(
              initialValue: _selectedField,
              decoration: const InputDecoration(
                labelText: 'Field',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              items: fields
                  .map((f) => DropdownMenuItem(value: f.id, child: Text(f.name)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedField = v);
              },
            ),
            const SizedBox(height: AppSpacing.md),

            TextFormField(
              controller: _pestNameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Pest / Disease / Weed Name',
                prefixIcon: Icon(Icons.bug_report_outlined),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            // Category
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c[0].toUpperCase() + c.substring(1)),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _category = v);
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Severity
            DropdownButtonFormField<String>(
              initialValue: _severity,
              decoration: const InputDecoration(
                labelText: 'Severity',
                prefixIcon: Icon(Icons.warning_amber_rounded),
              ),
              items: _severities
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s[0].toUpperCase() + s.substring(1)),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _severity = v);
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Status
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                prefixIcon: Icon(Icons.track_changes_outlined),
              ),
              items: _statuses
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s[0].toUpperCase() + s.substring(1)),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _status = v);
              },
            ),
            const SizedBox(height: AppSpacing.md),

            DatePickerField(
              label: 'Observation Date',
              value: _observedDate,
              onChanged: (d) => setState(() => _observedDate = d),
              firstDate: DateTime(2015),
              lastDate: DateTime(2100),
            ),
            const SizedBox(height: AppSpacing.md),

            DatePickerField(
              label: 'Follow-up Date (optional)',
              value: _followUpDate,
              onChanged: (d) => setState(() => _followUpDate = d),
              firstDate: DateTime(2015),
              lastDate: DateTime(2100),
            ),
            const SizedBox(height: AppSpacing.md),

            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.notes_outlined),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            TextFormField(
              controller: _recommendedActionController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Recommended Action (optional)',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.check_circle_outline),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSpacing.minTouchTarget),
                shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.onPrimary),
                    )
                  : Text(
                      'Save Changes',
                      style: tt.labelLarge?.copyWith(color: AppColors.onPrimary),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
