import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/date_picker_field.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../data/crop_repository.dart';
import '../../models/planting_plan.dart';
import '../../providers/crop_providers.dart';

class EditPlantingPlanScreen extends ConsumerStatefulWidget {
  const EditPlantingPlanScreen({super.key, required this.plan});

  final PlantingPlan plan;

  @override
  ConsumerState<EditPlantingPlanScreen> createState() =>
      _EditPlantingPlanScreenState();
}

class _EditPlantingPlanScreenState
    extends ConsumerState<EditPlantingPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _targetYieldCtrl = TextEditingController(
      text: widget.plan.targetYieldTHa?.toString() ?? '');

  late String _selectedField = widget.plan.fieldId;
  late String _selectedCrop = widget.plan.cropId;
  late String _selectedSeason = widget.plan.seasonId;
  late String _status = widget.plan.status;
  late DateTime? _plantingDate = widget.plan.plannedPlantingDate;
  late DateTime? _harvestDate = widget.plan.plannedHarvestDate;
  bool _saving = false;

  static const _statuses = [
    ('planned', 'Planned'),
    ('active', 'Active'),
    ('completed', 'Completed'),
    ('cancelled', 'Cancelled'),
  ];

  InputDecoration _dec(String label, {IconData? icon, String? suffix}) =>
      InputDecoration(
        labelText: label,
        suffixText: suffix,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: AppRadius.input),
      );

  @override
  void dispose() {
    _targetYieldCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final updated = PlantingPlan(
      id: widget.plan.id,
      fieldId: _selectedField,
      seasonId: _selectedSeason,
      cropId: _selectedCrop,
      plannedPlantingDate: _plantingDate,
      plannedHarvestDate: _harvestDate,
      targetYieldTHa: double.tryParse(_targetYieldCtrl.text.trim()),
      status: _status,
      createdAt: widget.plan.createdAt,
    );

    try {
      await ref.read(cropRepositoryProvider).updatePlantingPlan(updated);
      ref.invalidate(plantingPlansProvider);
    } catch (_) {}

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Planting plan updated')),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final fieldsAsync = ref.watch(cropFieldsProvider(null));
    final cropsAsync = ref.watch(cropsProvider(null));
    final seasonsAsync = ref.watch(seasonsProvider(null));
    final fields = fieldsAsync.value ?? [];
    final crops = cropsAsync.value ?? [];
    final seasons = seasonsAsync.value ?? [];

    return FarmScaffold(
      appBar: const FarmAppBar(title: 'Edit Planting Plan'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedField,
              decoration: _dec('Field', icon: Icons.grid_on_rounded),
              items: fields
                  .map((f) =>
                      DropdownMenuItem(value: f.id, child: Text(f.name)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedField = v);
              },
              validator: (v) => v == null ? 'Select a field' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            DropdownButtonFormField<String>(
              initialValue: _selectedCrop,
              decoration: _dec('Crop', icon: Icons.eco_outlined),
              items: crops
                  .map((c) =>
                      DropdownMenuItem(value: c.id, child: Text(c.name)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedCrop = v);
              },
              validator: (v) => v == null ? 'Select a crop' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            DropdownButtonFormField<String>(
              initialValue: _selectedSeason,
              decoration: _dec('Season', icon: Icons.calendar_month_outlined),
              items: seasons
                  .map((s) =>
                      DropdownMenuItem(value: s.id, child: Text(s.name)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedSeason = v);
              },
            ),
            const SizedBox(height: AppSpacing.md),

            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: _dec('Status', icon: Icons.track_changes_outlined),
              items: _statuses
                  .map((s) =>
                      DropdownMenuItem(value: s.$1, child: Text(s.$2)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _status = v);
              },
            ),
            const SizedBox(height: AppSpacing.md),

            DatePickerField(
              label: 'Planned Planting Date',
              value: _plantingDate,
              onChanged: (d) => setState(() => _plantingDate = d),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            ),
            const SizedBox(height: AppSpacing.md),

            DatePickerField(
              label: 'Planned Harvest Date',
              value: _harvestDate,
              onChanged: (d) => setState(() => _harvestDate = d),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            ),
            const SizedBox(height: AppSpacing.md),

            TextFormField(
              controller: _targetYieldCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
              ],
              decoration: _dec('Target Yield (optional)',
                  icon: Icons.trending_up_rounded, suffix: 't/ha'),
              validator: (v) {
                if (v != null &&
                    v.trim().isNotEmpty &&
                    double.tryParse(v.trim()) == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.xl),

            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSpacing.minTouchTarget),
                shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.button),
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
                      style: tt.labelLarge
                          ?.copyWith(color: AppColors.onPrimary),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
