import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../data/crop_repository.dart';
import '../../models/spray_record.dart';
import '../../providers/crop_providers.dart';

class EditSprayRecordScreen extends ConsumerStatefulWidget {
  const EditSprayRecordScreen({super.key, required this.record});

  final SprayRecord record;

  @override
  ConsumerState<EditSprayRecordScreen> createState() =>
      _EditSprayRecordScreenState();
}

class _EditSprayRecordScreenState extends ConsumerState<EditSprayRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  late final _productCtrl =
      TextEditingController(text: widget.record.productName);
  late final _dosageCtrl =
      TextEditingController(text: widget.record.dosagePerHa.toString());
  late final _areaCtrl =
      TextEditingController(text: widget.record.areaSprayedHa.toString());
  late final _applicatorCtrl =
      TextEditingController(text: widget.record.applicatorName ?? '');
  late final _withholdingCtrl =
      TextEditingController(text: widget.record.withholdingDays.toString());
  late final _outcomeCtrl =
      TextEditingController(text: widget.record.outcome ?? '');

  late String _selectedField = widget.record.fieldId;
  late DateTime _sprayDate = widget.record.sprayDate;
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
      firstDate: DateTime(2015),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _sprayDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final withholding = int.tryParse(_withholdingCtrl.text.trim()) ?? 14;
    final reEntry = _sprayDate.add(Duration(days: withholding));

    final updated = SprayRecord(
      id: widget.record.id,
      pestObservationId: widget.record.pestObservationId,
      fieldId: _selectedField,
      sprayDate: _sprayDate,
      productName: _productCtrl.text.trim(),
      dosagePerHa: double.parse(_dosageCtrl.text.trim()),
      areaSprayedHa: double.parse(_areaCtrl.text.trim()),
      applicatorName: _applicatorCtrl.text.trim().isEmpty
          ? null
          : _applicatorCtrl.text.trim(),
      withholdingDays: withholding,
      reEntryDate: reEntry,
      outcome:
          _outcomeCtrl.text.trim().isEmpty ? null : _outcomeCtrl.text.trim(),
    );

    try {
      await ref.read(cropRepositoryProvider).updateSprayRecord(updated);
      ref.invalidate(sprayRecordsProvider);
    } catch (_) {}

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Spray record updated')),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final fieldsAsync = ref.watch(cropFieldsProvider(null));
    final fields = fieldsAsync.value ?? [];
    final dateFmt = DateFormat('dd MMM yyyy');

    return FarmScaffold(
      resizeToAvoidBottomInset: true,
      appBar: const FarmAppBar(title: 'Edit Spray Record'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePaddingHorizontal,
            vertical: AppSpacing.pagePaddingVertical,
          ),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedField,
              decoration: _dec('Field', icon: Icons.grass_rounded),
              items: fields
                  .map((f) => DropdownMenuItem(value: f.id, child: Text(f.name)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedField = v);
              },
              validator: (v) => v == null ? 'Please select a field' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            InkWell(
              onTap: _pickDate,
              borderRadius: AppRadius.input,
              child: InputDecorator(
                decoration: _dec('Spray Date', icon: Icons.calendar_today_rounded),
                child: Text(dateFmt.format(_sprayDate), style: tt.bodyMedium),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            TextFormField(
              controller: _productCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: _dec('Product Name', icon: Icons.science_rounded),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Product name is required' : null,
            ),
            const SizedBox(height: AppSpacing.sm),

            TextFormField(
              controller: _dosageCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
              ],
              decoration: _dec('Dosage', suffix: 'L/ha', icon: Icons.water_drop_rounded),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (double.tryParse(v.trim()) == null) return 'Invalid number';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.sm),

            TextFormField(
              controller: _areaCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
              ],
              decoration: _dec('Area Sprayed', suffix: 'ha', icon: Icons.square_foot_rounded),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (double.tryParse(v.trim()) == null) return 'Invalid number';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            TextFormField(
              controller: _withholdingCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration:
                  _dec('Withholding Period', suffix: 'days', icon: Icons.timer_rounded),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            TextFormField(
              controller: _applicatorCtrl,
              textCapitalization: TextCapitalization.words,
              decoration:
                  _dec('Applicator Name (optional)', icon: Icons.person_rounded),
            ),
            const SizedBox(height: AppSpacing.md),

            TextFormField(
              controller: _outcomeCtrl,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Outcome / Notes (optional)',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 48),
                  child: Icon(Icons.notes_rounded),
                ),
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: AppRadius.input),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

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
                label: Text(_saving ? 'Saving…' : 'Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape:
                      RoundedRectangleBorder(borderRadius: AppRadius.button),
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
