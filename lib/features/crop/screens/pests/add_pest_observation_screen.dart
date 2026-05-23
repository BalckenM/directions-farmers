import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/date_picker_field.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
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
  File? _pickedImage;
  bool _saving = false;

  final _imagePicker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked != null) setState(() => _pickedImage = File(picked.path));
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

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
      imageUrl: _pickedImage?.path,
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
      appBar: FarmAppBar(
        title: 'Log Observation',
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

            // ── Photo evidence ───────────────────────────────────────────
            _ImagePickerCard(
              image: _pickedImage,
              onTap: _showImageSourceSheet,
              onRemove: () => setState(() => _pickedImage = null),
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

// ── Image Picker Card ─────────────────────────────────────────────────────────

class _ImagePickerCard extends StatelessWidget {
  const _ImagePickerCard({
    required this.image,
    required this.onTap,
    required this.onRemove,
  });

  final File? image;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (image != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: AppRadius.card,
            child: Image.file(
              image!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: AppSpacing.xs,
            right: AppSpacing.xs,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.error,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.close,
                    size: 16, color: AppColors.onError),
                onPressed: onRemove,
              ),
            ),
          ),
        ],
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.card,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: cs.outlineVariant,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined,
                size: AppSpacing.iconLg, color: cs.onSurfaceVariant),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Add Photo Evidence (optional)',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

