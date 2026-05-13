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

class EditHarvestScreen extends ConsumerStatefulWidget {
  const EditHarvestScreen({super.key, required this.record});

  final HarvestRecord record;

  @override
  ConsumerState<EditHarvestScreen> createState() => _EditHarvestScreenState();
}

class _EditHarvestScreenState extends ConsumerState<EditHarvestScreen> {
  final _formKey = GlobalKey<FormState>();

  late final _yieldCtrl =
      TextEditingController(text: widget.record.actualYieldTons.toString());
  late final _areaCtrl =
      TextEditingController(text: widget.record.areaHarvestedHa.toString());
  late final _moistureCtrl = TextEditingController(
      text: widget.record.moisturePercent?.toString() ?? '');
  late final _storageCtrl =
      TextEditingController(text: widget.record.storageLocation ?? '');
  late final _lossesCtrl =
      TextEditingController(text: widget.record.lossesTons?.toString() ?? '');
  late final _lossReasonCtrl =
      TextEditingController(text: widget.record.lossReason ?? '');
  late final _notesCtrl =
      TextEditingController(text: widget.record.notes ?? '');

  late String _selectedField = widget.record.fieldId;
  late String _selectedCrop = widget.record.cropId;
  late String? _selectedGrade = widget.record.qualityGrade;
  late DateTime _harvestDate = widget.record.harvestDate;

  bool _saving = false;

  static const List<String> _grades = ['A', 'B', 'C', 'Below Grade'];

  bool get _showLossReason {
    final v = double.tryParse(_lossesCtrl.text.trim()) ?? 0.0;
    return v > 0;
  }

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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final yield_ = double.parse(_yieldCtrl.text.trim());
    final area = double.parse(_areaCtrl.text.trim());

    final updated = HarvestRecord(
      id: widget.record.id,
      planId: widget.record.planId,
      fieldId: _selectedField,
      cropId: _selectedCrop,
      harvestDate: _harvestDate,
      actualYieldTons: yield_,
      areaHarvestedHa: area,
      yieldTHa: area > 0 ? yield_ / area : 0,
      qualityGrade: _selectedGrade,
      moisturePercent: double.tryParse(_moistureCtrl.text.trim()),
      storageLocation:
          _storageCtrl.text.trim().isEmpty ? null : _storageCtrl.text.trim(),
      lossesTons: double.tryParse(_lossesCtrl.text.trim()),
      lossReason: _lossReasonCtrl.text.trim().isEmpty
          ? null
          : _lossReasonCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    try {
      await ref.read(cropRepositoryProvider).updateHarvestRecord(updated);
      ref.invalidate(harvestRecordsProvider);
    } catch (_) {}

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Harvest record updated')),
    );
    Navigator.of(context).pop(true);
  }

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: AppRadius.input),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + AppSpacing.xs,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final fieldsAsync = ref.watch(cropFieldsProvider(null));
    final cropsAsync = ref.watch(cropsProvider(null));
    final fields = fieldsAsync.value ?? [];
    final crops = cropsAsync.value ?? [];
    final tt = Theme.of(context).textTheme;

    return FarmScaffold(
      appBar: const FarmAppBar(title: 'Edit Harvest'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePaddingHorizontal,
            vertical: AppSpacing.pagePaddingVertical,
          ),
          children: [
            _Label('Field', tt),
            const SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<String>(
              initialValue: _selectedField,
              decoration: _dec('Select field'),
              items: fields
                  .map((f) => DropdownMenuItem(value: f.id, child: Text(f.name)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedField = v);
              },
              validator: (v) => v == null ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            _Label('Crop', tt),
            const SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<String>(
              initialValue: _selectedCrop,
              decoration: _dec('Select crop'),
              items: crops
                  .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedCrop = v);
              },
              validator: (v) => v == null ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            _Label('Harvest Date', tt),
            const SizedBox(height: AppSpacing.xs),
            DatePickerField(
              label: 'Harvest Date',
              value: _harvestDate,
              onChanged: (d) => setState(() => _harvestDate = d),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            ),
            const SizedBox(height: AppSpacing.md),

            _Label('Actual Yield (tons)', tt),
            const SizedBox(height: AppSpacing.xs),
            TextFormField(
              controller: _yieldCtrl,
              decoration: _dec('e.g. 12.5'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (double.tryParse(v.trim()) == null) return 'Invalid number';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            _Label('Area Harvested (ha)', tt),
            const SizedBox(height: AppSpacing.xs),
            TextFormField(
              controller: _areaCtrl,
              decoration: _dec('e.g. 5.0'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (double.tryParse(v.trim()) == null) return 'Invalid number';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            _Label('Quality Grade', tt),
            const SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<String>(
              initialValue: _selectedGrade,
              decoration: _dec('Select grade (optional)'),
              items: _grades
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedGrade = v),
            ),
            const SizedBox(height: AppSpacing.md),

            _Label('Moisture %', tt),
            const SizedBox(height: AppSpacing.xs),
            TextFormField(
              controller: _moistureCtrl,
              decoration: _dec('e.g. 14.5 (optional)'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v != null &&
                    v.trim().isNotEmpty &&
                    double.tryParse(v.trim()) == null) {
                  return 'Invalid number';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            _Label('Storage Location', tt),
            const SizedBox(height: AppSpacing.xs),
            TextFormField(
              controller: _storageCtrl,
              decoration: _dec('e.g. Silo 1 (optional)'),
            ),
            const SizedBox(height: AppSpacing.md),

            _Label('Losses (tons)', tt),
            const SizedBox(height: AppSpacing.xs),
            TextFormField(
              controller: _lossesCtrl,
              decoration: _dec('e.g. 0.5 (optional)'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              validator: (v) {
                if (v != null &&
                    v.trim().isNotEmpty &&
                    double.tryParse(v.trim()) == null) {
                  return 'Invalid number';
                }
                return null;
              },
            ),

            if (_showLossReason) ...[
              const SizedBox(height: AppSpacing.md),
              _Label('Loss Reason', tt),
              const SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _lossReasonCtrl,
                decoration: _dec('Describe the loss reason'),
              ),
            ],
            const SizedBox(height: AppSpacing.md),

            _Label('Notes', tt),
            const SizedBox(height: AppSpacing.xs),
            TextFormField(
              controller: _notesCtrl,
              decoration: _dec('Additional notes (optional)'),
              maxLines: 4,
              minLines: 3,
            ),
            const SizedBox(height: AppSpacing.xl),

            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSpacing.minTouchTarget),
                shape:
                    RoundedRectangleBorder(borderRadius: AppRadius.button),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.onPrimary),
                    )
                  : const Text('Save Changes'),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, this.tt);
  final String text;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: tt.labelMedium?.copyWith(
          color: AppColors.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      );
}
