import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/date_picker_field.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../models/crop_season.dart';
import '../../providers/crop_providers.dart';

class EditSeasonScreen extends ConsumerStatefulWidget {
  const EditSeasonScreen({super.key, required this.season});

  final CropSeason season;

  @override
  ConsumerState<EditSeasonScreen> createState() => _EditSeasonScreenState();
}

class _EditSeasonScreenState extends ConsumerState<EditSeasonScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController =
      TextEditingController(text: widget.season.name);
  late final _notesController =
      TextEditingController(text: widget.season.notes ?? '');

  late String _seasonType = widget.season.seasonType;
  late String _status = widget.season.status;
  late DateTime _startDate = widget.season.startDate;
  late DateTime _endDate = widget.season.endDate;
  bool _saving = false;

  static const _seasonTypes = [
    ('summer', 'Summer'),
    ('winter', 'Winter'),
    ('year_round', 'Year Round'),
  ];

  static const _statuses = [
    ('planned', 'Planned'),
    ('active', 'Active'),
    ('completed', 'Completed'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final updated = CropSeason(
      id: widget.season.id,
      farmId: widget.season.farmId,
      name: _nameController.text.trim(),
      seasonType: _seasonType,
      startDate: _startDate,
      endDate: _endDate,
      status: _status,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    try {
      await ref.read(cropRepositoryProvider).updateSeason(updated);
      ref.invalidate(seasonsProvider);
    } catch (_) {}

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Season updated')),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return FarmScaffold(
      appBar: AppBar(title: const Text('Edit Season')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Season Name',
                prefixIcon: Icon(Icons.label_outline),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            DropdownButtonFormField<String>(
              initialValue: _seasonType,
              decoration: const InputDecoration(
                labelText: 'Season Type',
                prefixIcon: Icon(Icons.wb_sunny_outlined),
              ),
              items: _seasonTypes
                  .map((t) =>
                      DropdownMenuItem(value: t.$1, child: Text(t.$2)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _seasonType = v);
              },
            ),
            const SizedBox(height: AppSpacing.md),

            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                prefixIcon: Icon(Icons.track_changes_outlined),
              ),
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
              label: 'Start Date',
              value: _startDate,
              onChanged: (d) => setState(() => _startDate = d),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            ),
            const SizedBox(height: AppSpacing.md),

            DatePickerField(
              label: 'End Date',
              value: _endDate,
              onChanged: (d) => setState(() => _endDate = d),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            ),
            const SizedBox(height: AppSpacing.md),

            TextFormField(
              controller: _notesController,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 56),
                  child: Icon(Icons.notes_outlined),
                ),
              ),
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
