import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/date_picker_field.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../models/crop.dart';
import '../../models/crop_field.dart';
import '../../models/crop_season.dart';
import '../../models/planting_plan.dart';
import '../../providers/crop_providers.dart';

class AddSeasonScreen extends ConsumerStatefulWidget {
  const AddSeasonScreen({super.key});

  @override
  ConsumerState<AddSeasonScreen> createState() => _AddSeasonScreenState();
}

class _AddSeasonScreenState extends ConsumerState<AddSeasonScreen> {
  // ── Stepper state ─────────────────────────────────────────────────────────
  int _step = 0; // 0 = season details, 1 = select fields, 2 = assign crops

  // ── Step 1 ────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  String _seasonType = 'summer';
  DateTime? _startDate;
  DateTime? _endDate;

  static const _seasonTypes = [
    ('summer', 'Summer'),
    ('winter', 'Winter'),
    ('year_round', 'Year Round'),
  ];

  // ── Step 2 ────────────────────────────────────────────────────────────────
  final Set<String> _selectedFieldIds = {};

  // ── Step 3 ────────────────────────────────────────────────────────────────
  // fieldId → selected cropId
  final Map<String, String?> _fieldCropMap = {};

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ── Navigation helpers ────────────────────────────────────────────────────

  void _nextStep() {
    if (_step == 0) {
      if (!_formKey.currentState!.validate()) return;
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select start and end dates')),
        );
        return;
      }
    }
    if (_step == 1 && _selectedFieldIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one field')),
      );
      return;
    }
    setState(() => _step++);
  }

  Future<void> _save() async {
    final hasAllCrops =
        _selectedFieldIds.every((id) => _fieldCropMap[id] != null);
    if (!hasAllCrops) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assign a crop to every selected field')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final repo = ref.read(cropRepositoryProvider);
    final now = DateTime.now();
    final seasonId = 'season-${now.millisecondsSinceEpoch}';

    final season = CropSeason(
      id: seasonId,
      farmId: ref.read(currentFarmIdProvider),
      name: _nameController.text.trim(),
      seasonType: _seasonType,
      startDate: _startDate!,
      endDate: _endDate!,
      status: 'planned',
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    try {
      await repo.addSeason(season);

      // Create a planting plan for each field + crop pairing
      for (final fieldId in _selectedFieldIds) {
        final cropId = _fieldCropMap[fieldId];
        if (cropId == null) continue;
        final plan = PlantingPlan(
          id: 'plan-${now.millisecondsSinceEpoch}-$fieldId',
          fieldId: fieldId,
          seasonId: seasonId,
          cropId: cropId,
          plannedPlantingDate: _startDate!,
          plannedHarvestDate: _endDate!,
          status: 'planned',
          createdAt: now,
        );
        await repo.addPlantingPlan(plan);
      }

      ref.invalidate(seasonsProvider);
      ref.invalidate(plantingPlansProvider);
    } catch (_) {}

    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Season created with planting plans')),
    );
    Navigator.of(context).pop();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'New Season',
      ),
      body: Column(
        children: [
          // ── Step indicator ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              children: List.generate(3, (i) {
                final active = i == _step;
                final done = i < _step;
                final labels = ['Season Details', 'Select Fields', 'Assign Crops'];
                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: done || active
                                    ? AppColors.primary
                                    : AppColors.surfaceContainerHighest,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                done ? Icons.check : Icons.circle,
                                size: done ? 16 : 10,
                                color: done || active
                                    ? AppColors.onPrimary
                                    : AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              labels[i],
                              style: tt.labelSmall?.copyWith(
                                color: active
                                    ? AppColors.primary
                                    : AppColors.onSurfaceVariant,
                                fontWeight: active
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      if (i < 2)
                        Expanded(
                          child: Divider(
                            color: i < _step
                                ? AppColors.primary
                                : AppColors.outlineVariant,
                            thickness: 2,
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),

          // ── Step content ─────────────────────────────────────────────────
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _step == 0
                  ? _StepDetails(
                      key: const ValueKey(0),
                      formKey: _formKey,
                      nameController: _nameController,
                      notesController: _notesController,
                      seasonType: _seasonType,
                      seasonTypes: _seasonTypes,
                      startDate: _startDate,
                      endDate: _endDate,
                      onSeasonTypeChanged: (v) =>
                          setState(() => _seasonType = v),
                      onStartChanged: (d) => setState(() => _startDate = d),
                      onEndChanged: (d) => setState(() => _endDate = d),
                    )
                  : _step == 1
                      ? _StepSelectFields(
                          key: const ValueKey(1),
                          selectedFieldIds: _selectedFieldIds,
                          onToggle: (id, selected) => setState(() {
                            if (selected) {
                              _selectedFieldIds.add(id);
                            } else {
                              _selectedFieldIds.remove(id);
                              _fieldCropMap.remove(id);
                            }
                          }),
                        )
                      : _StepAssignCrops(
                          key: const ValueKey(2),
                          selectedFieldIds: _selectedFieldIds,
                          fieldCropMap: _fieldCropMap,
                          onAssign: (fieldId, cropId) =>
                              setState(() => _fieldCropMap[fieldId] = cropId),
                        ),
            ),
          ),

          // ── Bottom action bar ─────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving
                      ? null
                      : _step < 2
                          ? _nextStep
                          : _save,
                  style: FilledButton.styleFrom(
                    minimumSize:
                        const Size.fromHeight(AppSpacing.minTouchTarget),
                    shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.button),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.onPrimary),
                        )
                      : Text(
                          _step < 2 ? 'Next' : 'Create Season',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: AppColors.onPrimary),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 1: Season Details ────────────────────────────────────────────────────

class _StepDetails extends StatelessWidget {
  const _StepDetails({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.notesController,
    required this.seasonType,
    required this.seasonTypes,
    required this.startDate,
    required this.endDate,
    required this.onSeasonTypeChanged,
    required this.onStartChanged,
    required this.onEndChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController notesController;
  final String seasonType;
  final List<(String, String)> seasonTypes;
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<String> onSeasonTypeChanged;
  final ValueChanged<DateTime> onStartChanged;
  final ValueChanged<DateTime> onEndChanged;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          TextFormField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Season Name',
              hintText: 'e.g. Summer 2025/26',
              prefixIcon: Icon(Icons.label_outline),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            initialValue: seasonType,
            decoration: const InputDecoration(
              labelText: 'Season Type',
              prefixIcon: Icon(Icons.wb_sunny_outlined),
            ),
            items: seasonTypes
                .map((t) =>
                    DropdownMenuItem(value: t.$1, child: Text(t.$2)))
                .toList(),
            onChanged: (v) {
              if (v != null) onSeasonTypeChanged(v);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          DatePickerField(
            label: 'Start Date',
            value: startDate,
            onChanged: onStartChanged,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          ),
          const SizedBox(height: AppSpacing.md),
          DatePickerField(
            label: 'End Date',
            value: endDate,
            onChanged: onEndChanged,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: notesController,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              hintText: 'Any additional information…',
              alignLabelWithHint: true,
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 56),
                child: Icon(Icons.notes_outlined),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 2: Select Fields ─────────────────────────────────────────────────────

class _StepSelectFields extends ConsumerWidget {
  const _StepSelectFields({
    super.key,
    required this.selectedFieldIds,
    required this.onToggle,
  });

  final Set<String> selectedFieldIds;
  final void Function(String id, bool selected) onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fieldsAsync = ref.watch(cropFieldsProvider(null));
    final tt = Theme.of(context).textTheme;

    return fieldsAsync.when(
      loading: () => Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: LoadingShimmer.list(count: 4, itemHeight: 72),
      ),
      error: (e, _) => Center(
        child: Text('Failed to load fields: $e',
            style: const TextStyle(color: AppColors.error)),
      ),
      data: (fields) {
        if (fields.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'No fields found. Add fields first.',
                style:
                    tt.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text(
              'Choose the fields to include in this season:',
              style: tt.bodyMedium
                  ?.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.md),
            ...fields.map((f) => _FieldCheckTile(
                  field: f,
                  selected: selectedFieldIds.contains(f.id),
                  onChanged: (v) => onToggle(f.id, v ?? false),
                )),
          ],
        );
      },
    );
  }
}

class _FieldCheckTile extends StatelessWidget {
  const _FieldCheckTile({
    required this.field,
    required this.selected,
    required this.onChanged,
  });

  final CropField field;
  final bool selected;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: selected
            ? const BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: CheckboxListTile(
        value: selected,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        title: Text(field.name,
            style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${field.sizeHectares.toStringAsFixed(1)} ha · '
          '${field.soilTypeLabel} · ${field.irrigationLabel}',
          style: tt.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
        ),
        activeColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      ),
    );
  }
}

// ── Step 3: Assign Crops ──────────────────────────────────────────────────────

class _StepAssignCrops extends ConsumerWidget {
  const _StepAssignCrops({
    super.key,
    required this.selectedFieldIds,
    required this.fieldCropMap,
    required this.onAssign,
  });

  final Set<String> selectedFieldIds;
  final Map<String, String?> fieldCropMap;
  final void Function(String fieldId, String cropId) onAssign;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fieldsAsync = ref.watch(cropFieldsProvider(null));
    final cropsAsync = ref.watch(cropsProvider(null));
    final tt = Theme.of(context).textTheme;

    final fields = (fieldsAsync.value ?? [])
        .where((f) => selectedFieldIds.contains(f.id))
        .toList();
    final crops = cropsAsync.value ?? [];

    if (cropsAsync.isLoading || fieldsAsync.isLoading) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: LoadingShimmer.list(count: 3, itemHeight: 80),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text(
          'Assign a crop to each selected field:',
          style:
              tt.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.md),
        ...fields.map((f) => _CropAssignTile(
              field: f,
              crops: crops,
              selectedCropId: fieldCropMap[f.id],
              onChanged: (cropId) {
                if (cropId != null) onAssign(f.id, cropId);
              },
            )),
      ],
    );
  }
}

class _CropAssignTile extends StatelessWidget {
  const _CropAssignTile({
    required this.field,
    required this.crops,
    required this.selectedCropId,
    required this.onChanged,
  });

  final CropField field;
  final List<Crop> crops;
  final String? selectedCropId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final assigned = selectedCropId != null;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: assigned
            ? const BorderSide(color: AppColors.success, width: 1)
            : BorderSide(color: AppColors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.grid_on_rounded,
                    size: AppSpacing.iconSm, color: AppColors.primary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  field.name,
                  style:
                      tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  '${field.sizeHectares.toStringAsFixed(1)} ha',
                  style: tt.bodySmall
                      ?.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: selectedCropId,
              decoration: InputDecoration(
                labelText: 'Select Crop',
                prefixIcon: const Icon(Icons.eco_outlined),
                border:
                    OutlineInputBorder(borderRadius: AppRadius.input),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                isDense: true,
              ),
              items: crops
                  .map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

