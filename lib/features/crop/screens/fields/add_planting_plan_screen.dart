import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/date_picker_field.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../models/planting_plan.dart';
import '../../providers/crop_providers.dart';
import '../../providers/crop_action_providers.dart';

class AddPlantingPlanScreen extends ConsumerStatefulWidget {
  const AddPlantingPlanScreen({super.key, this.preselectedFieldId});

  /// When provided, the field dropdown is pre-selected and locked.
  final String? preselectedFieldId;

  @override
  ConsumerState<AddPlantingPlanScreen> createState() =>
      _AddPlantingPlanScreenState();
}

class _AddPlantingPlanScreenState extends ConsumerState<AddPlantingPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _targetYieldCtrl = TextEditingController();

  String? _selectedField;
  String? _selectedCrop;
  String? _selectedSeason;
  DateTime? _plantingDate;
  DateTime? _harvestDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedField = widget.preselectedFieldId;
  }

  @override
  void dispose() {
    _targetYieldCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, {IconData? icon}) => InputDecoration(
    labelText: label,
    prefixIcon: icon != null ? Icon(icon) : null,
    border: OutlineInputBorder(borderRadius: AppRadius.input),
  );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedField == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a field')));
      return;
    }
    if (_selectedCrop == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a crop')));
      return;
    }

    setState(() => _saving = true);

    final plan = PlantingPlan(
      id: 'plan-${DateTime.now().millisecondsSinceEpoch}',
      fieldId: _selectedField!,
      seasonId: _selectedSeason ?? 'season-unlinked',
      cropId: _selectedCrop!,
      plannedPlantingDate: _plantingDate,
      plannedHarvestDate: _harvestDate,
      targetYieldTHa: double.tryParse(_targetYieldCtrl.text.trim()),
      status: 'active',
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(cropActionProvider.notifier).addPlantingPlan(plan);
    } catch (_) {}

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Planting plan created')));
    Navigator.of(context).pop();
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
      resizeToAvoidBottomInset: true,
      appBar: const FarmAppBar(title: 'New Planting Plan'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePaddingHorizontal,
            vertical: AppSpacing.pagePaddingVertical,
          ),
          children: [
            // ── Field ─────────────────────────────────────────────────────────
            Text(
              'Field',
              style: tt.titleSmall?.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<String>(
              initialValue: _selectedField,
              decoration: _dec('Select field', icon: Icons.map_outlined),
              items: fields
                  .map(
                    (f) => DropdownMenuItem(value: f.id, child: Text(f.name)),
                  )
                  .toList(),
              onChanged: widget.preselectedFieldId != null
                  ? null
                  : (v) => setState(() => _selectedField = v),
              validator: (v) => v == null ? 'Please select a field' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Crop ──────────────────────────────────────────────────────────
            Text(
              'Crop',
              style: tt.titleSmall?.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<String>(
              initialValue: _selectedCrop,
              decoration: _dec('Select crop', icon: Icons.grass_rounded),
              items: crops
                  .map(
                    (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedCrop = v),
              validator: (v) => v == null ? 'Please select a crop' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Season (optional) ─────────────────────────────────────────────
            Text(
              'Season (optional)',
              style: tt.titleSmall?.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<String>(
              initialValue: _selectedSeason,
              decoration: _dec(
                'Link to season',
                icon: Icons.date_range_rounded,
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('No season')),
                ...seasons.map(
                  (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                ),
              ],
              onChanged: (v) => setState(() => _selectedSeason = v),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Planting date ─────────────────────────────────────────────────
            Text(
              'Dates',
              style: tt.titleSmall?.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.xs),
            DatePickerField(
              label: 'Planned Planting Date (optional)',
              value: _plantingDate,
              onChanged: (d) => setState(() => _plantingDate = d),
              firstDate: DateTime(2020),
              lastDate: DateTime(2035),
            ),
            if (_plantingDate != null) ...[
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => setState(() => _plantingDate = null),
                  child: const Text('Clear'),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            DatePickerField(
              label: 'Planned Harvest Date (optional)',
              value: _harvestDate,
              onChanged: (d) => setState(() => _harvestDate = d),
              firstDate: DateTime(2020),
              lastDate: DateTime(2035),
            ),
            if (_harvestDate != null) ...[
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => setState(() => _harvestDate = null),
                  child: const Text('Clear'),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),

            // ── Target yield ──────────────────────────────────────────────────
            Text(
              'Target Yield',
              style: tt.titleSmall?.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextFormField(
              controller: _targetYieldCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              decoration: _dec(
                'Target yield (optional)',
                icon: Icons.trending_up_rounded,
              ).copyWith(suffixText: 't/ha'),
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

            // ── Save ───────────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: AppSpacing.minTouchTarget,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(_saving ? 'Saving…' : 'Create Plan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
