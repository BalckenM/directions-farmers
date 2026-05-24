import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../models/crop_field.dart';
import '../../providers/crop_providers.dart';
import '../../providers/crop_action_providers.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

/// Form screen for adding a new crop field or editing an existing one.
///
/// Pass [fieldId] to enter edit mode; omit (null) for add mode.
class AddEditFieldScreen extends ConsumerStatefulWidget {
  const AddEditFieldScreen({super.key, this.fieldId});

  final String? fieldId;

  bool get isEdit => fieldId != null;

  @override
  ConsumerState<AddEditFieldScreen> createState() => _AddEditFieldScreenState();
}

class _AddEditFieldScreenState extends ConsumerState<AddEditFieldScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _nameCtrl;
  late final TextEditingController _sizeCtrl;
  late final TextEditingController _notesCtrl;

  // Dropdown selections
  String? _soilType;
  String? _irrigationType;

  bool _submitting = false;

  // ── Options ────────────────────────────────────────────────────────────────

  static const _soilTypes = [
    'loam',
    'clay',
    'clay_loam',
    'sandy_loam',
    'silt_loam',
    'well_drained',
  ];

  static const _irrigationTypes = ['dryland', 'irrigated', 'mixed'];

  static String _soilLabel(String value) =>
      value.replaceAll('_', ' ').toUpperCase();

  static String _irrigationLabel(String value) =>
      value[0].toUpperCase() + value.substring(1);

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _sizeCtrl = TextEditingController();
    _notesCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _sizeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final id = widget.fieldId ?? 'fld-${DateTime.now().millisecondsSinceEpoch}';

    final farmId = ref.read(currentFarmIdProvider);
    final field = CropField(
      id: id,
      farmId: farmId,
      name: _nameCtrl.text.trim(),
      sizeHectares: double.parse(_sizeCtrl.text.trim()),
      soilType: _soilType!,
      irrigationType: _irrigationType!,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    try {
      if (widget.isEdit) {
        await ref.read(cropActionProvider.notifier).updateField(field);
      } else {
        await ref.read(cropActionProvider.notifier).addField(field);
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.isEdit ? 'Field updated' : 'Field saved'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.pop();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return FarmScaffold(
      resizeToAvoidBottomInset: true,
      appBar: FarmAppBar(title: widget.isEdit ? 'Edit Field' : 'Add Field'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePaddingHorizontal,
            vertical: AppSpacing.pagePaddingVertical,
          ),
          children: [
            // ── Field Name ──────────────────────────────────────────────────
            Text(
              'Field Details',
              style: tt.titleSmall?.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: 'Field Name',
                hintText: 'e.g. North Block',
                prefixIcon: const Icon(Icons.grass_rounded),
                border: OutlineInputBorder(borderRadius: AppRadius.input),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Field name is required'
                  : null,
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Size ────────────────────────────────────────────────────────
            TextFormField(
              controller: _sizeCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Size',
                hintText: '0.0',
                prefixIcon: const Icon(Icons.square_foot_rounded),
                suffixText: 'ha',
                border: OutlineInputBorder(borderRadius: AppRadius.input),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Size is required';
                }
                final parsed = double.tryParse(v.trim());
                if (parsed == null || parsed <= 0) {
                  return 'Enter a valid size greater than 0';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Soil Type ───────────────────────────────────────────────────
            DropdownButtonFormField<String>(
              initialValue: _soilType,
              decoration: InputDecoration(
                labelText: 'Soil Type',
                prefixIcon: const Icon(Icons.layers_rounded),
                border: OutlineInputBorder(borderRadius: AppRadius.input),
              ),
              items: _soilTypes
                  .map(
                    (s) =>
                        DropdownMenuItem(value: s, child: Text(_soilLabel(s))),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _soilType = v),
              validator: (v) => v == null ? 'Please select a soil type' : null,
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Irrigation Type ─────────────────────────────────────────────
            DropdownButtonFormField<String>(
              initialValue: _irrigationType,
              decoration: InputDecoration(
                labelText: 'Irrigation Type',
                prefixIcon: const Icon(Icons.water_drop_outlined),
                border: OutlineInputBorder(borderRadius: AppRadius.input),
              ),
              items: _irrigationTypes
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(_irrigationLabel(t)),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _irrigationType = v),
              validator: (v) =>
                  v == null ? 'Please select an irrigation type' : null,
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Notes ───────────────────────────────────────────────────────
            TextFormField(
              controller: _notesCtrl,
              decoration: InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Any additional information about this field…',
                prefixIcon: const Icon(Icons.notes_rounded),
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: AppRadius.input),
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Save Button ─────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: AppSpacing.minTouchTarget,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : Text(
                        widget.isEdit ? 'Save Changes' : 'Save Field',
                        style: const TextStyle(fontWeight: FontWeight.w700),
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
