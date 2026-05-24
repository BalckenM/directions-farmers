import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../models/spray_record.dart';
import '../../providers/crop_providers.dart';
import '../../providers/crop_action_providers.dart';

class AddSprayRecordScreen extends ConsumerStatefulWidget {
  const AddSprayRecordScreen({super.key, this.pestObservationId});

  /// When provided, links this spray record to an existing pest observation.
  final String? pestObservationId;

  @override
  ConsumerState<AddSprayRecordScreen> createState() =>
      _AddSprayRecordScreenState();
}

class _AddSprayRecordScreenState extends ConsumerState<AddSprayRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _productCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _applicatorCtrl = TextEditingController();
  final _withholdingCtrl = TextEditingController(text: '14');
  final _outcomeCtrl = TextEditingController();

  String? _selectedField;
  DateTime _sprayDate = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _productCtrl.dispose();
    _dosageCtrl.dispose();
    _areaCtrl.dispose();
    _applicatorCtrl.dispose();
    _withholdingCtrl.dispose();
    _outcomeCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, {String? suffix, IconData? icon}) =>
      InputDecoration(
        labelText: label,
        suffixText: suffix,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: AppRadius.input),
      );

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _sprayDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _sprayDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedField == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a field')));
      return;
    }

    setState(() => _saving = true);

    final withholding = int.tryParse(_withholdingCtrl.text.trim()) ?? 14;
    final reEntry = _sprayDate.add(Duration(days: withholding));

    final record = SprayRecord(
      id: 'spray-${DateTime.now().millisecondsSinceEpoch}',
      pestObservationId: widget.pestObservationId,
      fieldId: _selectedField!,
      sprayDate: _sprayDate,
      productName: _productCtrl.text.trim(),
      dosagePerHa: double.parse(_dosageCtrl.text.trim()),
      areaSprayedHa: double.parse(_areaCtrl.text.trim()),
      applicatorName: _applicatorCtrl.text.trim().isEmpty
          ? null
          : _applicatorCtrl.text.trim(),
      withholdingDays: withholding,
      reEntryDate: reEntry,
      outcome: _outcomeCtrl.text.trim().isEmpty
          ? null
          : _outcomeCtrl.text.trim(),
    );

    try {
      await ref.read(cropActionProvider.notifier).addSprayRecord(record);
    } catch (_) {}

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Spray record saved')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fieldsAsync = ref.watch(cropFieldsProvider(null));
    final fields = fieldsAsync.value ?? [];
    final dateFmt = DateFormat('dd MMM yyyy');

    return FarmScaffold(
      resizeToAvoidBottomInset: true,
      appBar: const FarmAppBar(title: 'Log Spray Record'),
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
              decoration: _dec('Select field', icon: Icons.grass_rounded),
              items: fields
                  .map(
                    (f) => DropdownMenuItem(value: f.id, child: Text(f.name)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedField = v),
              validator: (v) => v == null ? 'Please select a field' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Spray Date ────────────────────────────────────────────────────
            Text(
              'Spray Date',
              style: tt.titleSmall?.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.xs),
            InkWell(
              onTap: _pickDate,
              borderRadius: AppRadius.input,
              child: InputDecorator(
                decoration: _dec('Date', icon: Icons.calendar_today_rounded),
                child: Text(dateFmt.format(_sprayDate), style: tt.bodyMedium),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Product ───────────────────────────────────────────────────────
            Text(
              'Product Details',
              style: tt.titleSmall?.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextFormField(
              controller: _productCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: _dec('Product Name', icon: Icons.science_rounded),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Product name is required'
                  : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _dosageCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              decoration: _dec(
                'Dosage',
                suffix: 'L/ha',
                icon: Icons.water_drop_rounded,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Dosage is required';
                if (double.tryParse(v.trim()) == null)
                  return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _areaCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              decoration: _dec(
                'Area Sprayed',
                suffix: 'ha',
                icon: Icons.square_foot_rounded,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Area is required';
                if (double.tryParse(v.trim()) == null)
                  return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Withholding period ────────────────────────────────────────────
            Text(
              'Safety',
              style: tt.titleSmall?.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.xs),
            TextFormField(
              controller: _withholdingCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _dec(
                'Withholding Period',
                suffix: 'days',
                icon: Icons.timer_rounded,
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Withholding period required'
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Applicator ───────────────────────────────────────────────────
            TextFormField(
              controller: _applicatorCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: _dec(
                'Applicator Name (optional)',
                icon: Icons.person_rounded,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Outcome ───────────────────────────────────────────────────────
            TextFormField(
              controller: _outcomeCtrl,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Outcome / Notes (optional)',
                hintText: 'Was the spray effective?',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 48),
                  child: Icon(Icons.notes_rounded),
                ),
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: AppRadius.input),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Re-entry info chip ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: cs.tertiaryContainer,
                borderRadius: AppRadius.card,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: cs.onTertiaryContainer,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Re-entry date will be calculated automatically from the spray date + withholding period.',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onTertiaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Save ──────────────────────────────────────────────────────────
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
                label: Text(_saving ? 'Saving…' : 'Save Spray Record'),
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
