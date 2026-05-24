import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/date_picker_field.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../models/harvest_record.dart';
import '../../providers/crop_providers.dart';
import '../../providers/crop_action_providers.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class AddHarvestScreen extends ConsumerStatefulWidget {
  const AddHarvestScreen({super.key});

  @override
  ConsumerState<AddHarvestScreen> createState() => _AddHarvestScreenState();
}

class _AddHarvestScreenState extends ConsumerState<AddHarvestScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _yieldCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _moistureCtrl = TextEditingController();
  final _storageCtrl = TextEditingController();
  final _lossesCtrl = TextEditingController();
  final _lossReasonCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // Dropdown values
  String? _selectedField;
  String? _selectedCrop;
  String? _selectedGrade;

  // Date
  DateTime? _harvestDate;

  // Derived state
  bool get _showLossReason {
    final v = double.tryParse(_lossesCtrl.text.trim()) ?? 0.0;
    return v > 0;
  }

  static const List<String> _grades = ['A', 'B', 'C', 'Below Grade'];

  @override
  void dispose() {
    _yieldCtrl.dispose();
    _areaCtrl.dispose();
    _moistureCtrl.dispose();
    _storageCtrl.dispose();
    _lossesCtrl.dispose();
    _lossReasonCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_harvestDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a harvest date')),
      );
      return;
    }

    final yield_ = double.parse(_yieldCtrl.text.trim());
    final area = double.parse(_areaCtrl.text.trim());

    // Resolve planId from the active planting plan on the selected field (if any).
    final allPlans =
        ref.read(plantingPlansProvider(_selectedField)).value ?? [];
    final activePlan = allPlans.where((p) => p.isActive).firstOrNull;
    final record = HarvestRecord(
      id: 'harv-${DateTime.now().millisecondsSinceEpoch}',
      planId: activePlan?.id ?? '',
      fieldId: _selectedField ?? 'fld-unknown',
      cropId: _selectedCrop ?? 'crop-unknown',
      harvestDate: _harvestDate!,
      actualYieldTons: yield_,
      areaHarvestedHa: area,
      yieldTHa: area > 0 ? yield_ / area : 0,
      qualityGrade: _selectedGrade,
      moisturePercent: double.tryParse(_moistureCtrl.text.trim()),
      storageLocation: _storageCtrl.text.trim().isEmpty
          ? null
          : _storageCtrl.text.trim(),
      lossesTons: double.tryParse(_lossesCtrl.text.trim()),
      lossReason: _lossReasonCtrl.text.trim().isEmpty
          ? null
          : _lossReasonCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    try {
      await ref.read(cropActionProvider.notifier).addHarvestRecord(record);
    } catch (_) {}

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Harvest logged')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final fieldsAsync = ref.watch(cropFieldsProvider(null));
    final cropsAsync = ref.watch(cropsProvider(null));
    final fields = fieldsAsync.value ?? [];
    final crops = cropsAsync.value ?? [];
    final tt = Theme.of(context).textTheme;

    return FarmScaffold(
      appBar: const FarmAppBar(title: 'Log Harvest'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePaddingHorizontal,
            vertical: AppSpacing.pagePaddingVertical,
          ),
          children: [
            // ── Field ─────────────────────────────────────────────────────────
            _SectionLabel(label: 'Field', textTheme: tt),
            const SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<String>(
              initialValue: _selectedField,
              decoration: _inputDecoration('Select field'),
              items: fields
                  .map(
                    (f) => DropdownMenuItem(value: f.id, child: Text(f.name)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedField = v),
              validator: (v) => v == null ? 'Please select a field' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Crop ──────────────────────────────────────────────────────────
            _SectionLabel(label: 'Crop', textTheme: tt),
            const SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<String>(
              initialValue: _selectedCrop,
              decoration: _inputDecoration('Select crop'),
              items: crops
                  .map(
                    (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedCrop = v),
              validator: (v) => v == null ? 'Please select a crop' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Harvest date ──────────────────────────────────────────────────
            _SectionLabel(label: 'Harvest Date', textTheme: tt),
            const SizedBox(height: AppSpacing.xs),
            DatePickerField(
              label: 'Harvest Date',
              value: _harvestDate,
              onChanged: (d) => setState(() => _harvestDate = d),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
              validator: (d) =>
                  d == null ? 'Please select a harvest date' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Actual yield ──────────────────────────────────────────────────
            _SectionLabel(label: 'Actual Yield (tons)', textTheme: tt),
            const SizedBox(height: AppSpacing.xs),
            TextFormField(
              controller: _yieldCtrl,
              decoration: _inputDecoration('e.g. 12.5'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Required';
                }
                if (double.tryParse(v.trim()) == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Area harvested ────────────────────────────────────────────────
            _SectionLabel(label: 'Area Harvested (ha)', textTheme: tt),
            const SizedBox(height: AppSpacing.xs),
            TextFormField(
              controller: _areaCtrl,
              decoration: _inputDecoration('e.g. 5.0'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (double.tryParse(v.trim()) == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Quality grade ─────────────────────────────────────────────────
            _SectionLabel(label: 'Quality Grade', textTheme: tt),
            const SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<String>(
              initialValue: _selectedGrade,
              decoration: _inputDecoration('Select grade (optional)'),
              items: _grades
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedGrade = v),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Moisture % ────────────────────────────────────────────────────
            _SectionLabel(label: 'Moisture %', textTheme: tt),
            const SizedBox(height: AppSpacing.xs),
            TextFormField(
              controller: _moistureCtrl,
              decoration: _inputDecoration('e.g. 14.5 (optional)'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) {
                if (v != null &&
                    v.trim().isNotEmpty &&
                    double.tryParse(v.trim()) == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Storage location ──────────────────────────────────────────────
            _SectionLabel(label: 'Storage Location', textTheme: tt),
            const SizedBox(height: AppSpacing.xs),
            TextFormField(
              controller: _storageCtrl,
              decoration: _inputDecoration('e.g. Silo 1 (optional)'),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Losses ────────────────────────────────────────────────────────
            _SectionLabel(label: 'Losses (tons)', textTheme: tt),
            const SizedBox(height: AppSpacing.xs),
            TextFormField(
              controller: _lossesCtrl,
              decoration: _inputDecoration('e.g. 0.5 (optional)'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) => setState(() {}),
              validator: (v) {
                if (v != null &&
                    v.trim().isNotEmpty &&
                    double.tryParse(v.trim()) == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
            ),

            // ── Loss reason (conditional) ─────────────────────────────────────
            if (_showLossReason) ...[
              const SizedBox(height: AppSpacing.md),
              _SectionLabel(label: 'Loss Reason', textTheme: tt),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _lossReasonCtrl,
                decoration: _inputDecoration('Describe the loss reason'),
              ),
            ],
            const SizedBox(height: AppSpacing.md),

            // ── Notes ─────────────────────────────────────────────────────────
            _SectionLabel(label: 'Notes', textTheme: tt),
            const SizedBox(height: AppSpacing.xs),
            TextFormField(
              controller: _notesCtrl,
              decoration: _inputDecoration('Additional notes (optional)'),
              maxLines: 4,
              minLines: 3,
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Save button ───────────────────────────────────────────────────
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSpacing.minTouchTarget),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
              ),
              child: const Text('Save Harvest'),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    border: OutlineInputBorder(borderRadius: AppRadius.input),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm + AppSpacing.xs,
    ),
  );
}

// ── Section label helper ──────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.textTheme});

  final String label;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: textTheme.labelMedium?.copyWith(
        color: AppColors.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
