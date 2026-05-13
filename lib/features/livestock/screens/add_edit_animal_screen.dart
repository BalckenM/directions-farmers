import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/livestock_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/farm_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../models/animal.dart';
import '../providers/local_animal_store.dart';
import '../providers/livestock_providers.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

/// Form screen for registering a new animal or editing an existing one.
///
/// Pass [animalId] to enter edit mode; omit (null) for add mode.
class AddEditAnimalScreen extends ConsumerStatefulWidget {
  const AddEditAnimalScreen({
    super.key,
    required this.species,
    this.animalId,
  });

  final String species;
  final String? animalId;

  bool get isEdit => animalId != null;

  @override
  ConsumerState<AddEditAnimalScreen> createState() =>
      _AddEditAnimalScreenState();
}

class _AddEditAnimalScreenState extends ConsumerState<AddEditAnimalScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  late final TextEditingController _tagCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _paddockCtrl;
  late final TextEditingController _notesCtrl;

  // Dropdown / selection state
  String? _breed;
  String? _gender;
  String? _status = 'active';
  String? _productionType;
  DateTime? _dob;
  int _bcs = 3;

  bool _submitting = false;
  bool _loadingAnimal = false;

  // ── Helpers ────────────────────────────────────────────────────────────────

  List<String> get _breeds => LivestockConstants.breedsFor(widget.species);
  List<String> get _genders =>
      LivestockConstants.genderBySpecies[widget.species] ??
      ['Male', 'Female', 'Unknown'];
  List<String> get _productionTypes =>
      LivestockConstants.productionBySpecies[widget.species] ?? [];

  String get _speciesName =>
      LivestockConstants.displayName(widget.species);

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _tagCtrl = TextEditingController();
    _nameCtrl = TextEditingController();
    _weightCtrl = TextEditingController();
    _paddockCtrl = TextEditingController();
    _notesCtrl = TextEditingController();

    if (widget.isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _populateForEdit());
    }
  }

  void _populateForEdit() {
    setState(() => _loadingAnimal = true);
    final animalAsync =
        ref.read(animalDetailProvider((widget.species, widget.animalId!)));
    animalAsync.whenData((animal) {
      if (animal == null || !mounted) return;
      setState(() {
        _tagCtrl.text = animal.tagNumber;
        _nameCtrl.text = animal.name;
        _weightCtrl.text = animal.currentWeightKg?.toStringAsFixed(0) ?? '';
        _paddockCtrl.text = animal.locationPaddock ?? '';
        _breed = _breeds.contains(animal.breed) ? animal.breed : null;
        _gender = _genders.contains(animal.sex) ? animal.sex : null;
        _productionType = _productionTypes.contains(animal.productionType)
            ? animal.productionType
            : null;
        _status = animal.status;
        _bcs = animal.bodyConditionScore ?? 3;
        if (animal.dateOfBirth != null) {
          _dob = DateTime.tryParse(animal.dateOfBirth!);
        }
        _loadingAnimal = false;
      });
    });
  }

  @override
  void dispose() {
    _tagCtrl.dispose();
    _nameCtrl.dispose();
    _weightCtrl.dispose();
    _paddockCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Form submit ────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    // Simulate async I/O (replaced with Drift later)
    await Future.delayed(const Duration(milliseconds: 400));

    final now = DateTime.now();
    final dobStr = _dob != null
        ? '${_dob!.year}-'
            '${_dob!.month.toString().padLeft(2, '0')}-'
            '${_dob!.day.toString().padLeft(2, '0')}'
        : null;
    final ageMonths = _dob != null
        ? ((now.difference(_dob!).inDays) ~/ 30)
        : null;
    final displayName = _nameCtrl.text.trim().isNotEmpty
        ? _nameCtrl.text.trim()
        : _tagCtrl.text.trim();

    final animal = Animal(
      id: widget.isEdit
          ? widget.animalId!
          : 'local_${now.millisecondsSinceEpoch}',
      farmId: 'farm_001',
      species: widget.species,
      tagNumber: _tagCtrl.text.trim(),
      name: displayName,
      breed: _breed ?? 'Unknown',
      sex: _gender?.toLowerCase() ?? 'unknown',
      status: _status ?? 'active',
      productionType: _productionType ?? '',
      dateOfBirth: dobStr,
      ageMonths: ageMonths,
      currentWeightKg: _weightCtrl.text.trim().isNotEmpty
          ? double.tryParse(_weightCtrl.text.trim())
          : null,
      bodyConditionScore: _bcs,
      locationPaddock: _paddockCtrl.text.trim().isEmpty
          ? null
          : _paddockCtrl.text.trim(),
    );

    final store = ref.read(localAnimalStoreProvider.notifier);
    if (widget.isEdit) {
      store.update(animal);
    } else {
      store.add(animal);
    }

    if (!mounted) return;
    setState(() => _submitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isEdit
              ? '${animal.name} updated successfully'
              : '${animal.name} added to $_speciesName',
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    );

    context.pop();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_loadingAnimal) {
      return FarmScaffold(
        appBar: FarmAppBar(
          title: 'Edit Animal',
          subtitle: _speciesName,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return FarmScaffold(
      appBar: FarmAppBar(
        title: widget.isEdit ? 'Edit Animal' : 'Add $_speciesName',
        subtitle: widget.isEdit ? 'Update record' : 'Register a new animal',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePaddingHorizontal,
            AppSpacing.md,
            AppSpacing.pagePaddingHorizontal,
            AppSpacing.xxl + 32,
          ),
          children: [
            // ── Identification ───────────────────────────────────────────────
            _FormSection(
              title: 'Identification',
              icon: Icons.badge_outlined,
              child: Column(
                children: [
                  FarmTextField(
                    controller: _tagCtrl,
                    label: 'Tag / Ear Number *',
                    hint: 'e.g. A-001 or RF-9843',
                    prefixIcon: const Icon(Icons.tag_rounded),
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Tag number is required'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmTextField(
                    controller: _nameCtrl,
                    label: 'Name (optional)',
                    hint: 'e.g. Bessie or Bull-1',
                    prefixIcon: const Icon(Icons.label_outline_rounded),
                    textInputAction: TextInputAction.next,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Animal details ───────────────────────────────────────────────
            _FormSection(
              title: 'Animal Details',
              icon: Icons.info_outline_rounded,
              child: Column(
                children: [
                  _BreedDropdown(
                    breeds: _breeds,
                    value: _breed,
                    onChanged: (v) => setState(() => _breed = v),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ChipSelector(
                    label: 'Sex / Gender *',
                    options: _genders,
                    selected: _gender,
                    accentColor: AppColors.tertiary,
                    onSelected: (v) => setState(() => _gender = v),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _DobPicker(
                    value: _dob,
                    onPicked: (d) => setState(() => _dob = d),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Physical ─────────────────────────────────────────────────────
            _FormSection(
              title: 'Physical Condition',
              icon: Icons.monitor_weight_outlined,
              child: Column(
                children: [
                  FarmTextField(
                    controller: _weightCtrl,
                    label: 'Current Weight (kg)',
                    hint: 'e.g. 320',
                    prefixIcon: const Icon(Icons.monitor_weight_outlined),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      final p = double.tryParse(v.trim());
                      if (p == null || p <= 0) return 'Enter a valid weight';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _BcsSlider(
                    value: _bcs,
                    onChanged: (v) => setState(() => _bcs = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Management ───────────────────────────────────────────────────
            _FormSection(
              title: 'Management',
              icon: Icons.tune_rounded,
              child: Column(
                children: [
                  _StatusSelector(
                    selected: _status,
                    onSelected: (v) => setState(() => _status = v),
                  ),
                  if (_productionTypes.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    _ChipSelector(
                      label: 'Production Type',
                      options: _productionTypes,
                      selected: _productionType,
                      accentColor: AppColors.secondary,
                      capitalize: true,
                      onSelected: (v) => setState(() => _productionType = v),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  FarmTextField(
                    controller: _paddockCtrl,
                    label: 'Location / Paddock',
                    hint: 'e.g. North Pasture B',
                    prefixIcon: const Icon(Icons.place_outlined),
                    textInputAction: TextInputAction.next,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Notes ────────────────────────────────────────────────────────
            _FormSection(
              title: 'Notes',
              icon: Icons.notes_rounded,
              child: FarmTextField(
                controller: _notesCtrl,
                label: 'Additional Notes',
                hint: 'Any observations or special care instructions…',
                maxLines: 4,
                minLines: 3,
                textInputAction: TextInputAction.done,
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Submit ───────────────────────────────────────────────────────
            PrimaryButton(
              onPressed: _submit,
              label: widget.isEdit ? 'Save Changes' : 'Add Animal',
              icon: Icon(
                widget.isEdit ? Icons.save_rounded : Icons.add_rounded,
                size: 18,
              ),
              isLoading: _submitting,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable sub-widgets ─────────────────────────────────────────────────────

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: cs.outlineVariant.withAlpha(80)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                title,
                style: tt.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

// ── Breed dropdown ────────────────────────────────────────────────────────────

class _BreedDropdown extends StatelessWidget {
  const _BreedDropdown({
    required this.breeds,
    required this.value,
    required this.onChanged,
  });

  final List<String> breeds;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: const InputDecoration(
        labelText: 'Breed *',
        prefixIcon: Icon(Icons.category_outlined),
      ),
      hint: const Text('Select breed'),
      isExpanded: true,
      items: breeds
          .map((b) => DropdownMenuItem(value: b, child: Text(b)))
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Please select a breed' : null,
    );
  }
}

// ── Generic chip selector ─────────────────────────────────────────────────────

class _ChipSelector extends StatelessWidget {
  const _ChipSelector({
    required this.label,
    required this.options,
    required this.selected,
    required this.accentColor,
    required this.onSelected,
    this.capitalize = false,
  });

  final String label;
  final List<String> options;
  final String? selected;
  final Color accentColor;
  final ValueChanged<String?> onSelected;
  final bool capitalize;

  String _display(String s) =>
      capitalize ? (s[0].toUpperCase() + s.substring(1)) : s;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: options.map((opt) {
            final isSelected = selected == opt;
            return ChoiceChip(
              label: Text(_display(opt)),
              selected: isSelected,
              onSelected: (_) => onSelected(opt),
              selectedColor: accentColor.withAlpha(28),
              labelStyle: tt.labelSmall?.copyWith(
                color: isSelected ? accentColor : cs.onSurface,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
              side: BorderSide(
                color: isSelected ? accentColor : cs.outlineVariant,
                width: isSelected ? 1.5 : 1,
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Status selector (Active / Sold / Deceased) ────────────────────────────────

class _StatusSelector extends StatelessWidget {
  const _StatusSelector({
    required this.selected,
    required this.onSelected,
  });

  final String? selected;
  final ValueChanged<String?> onSelected;

  static const _options = ['active', 'sold', 'deceased'];
  static const _labels = {
    'active': 'Active',
    'sold': 'Sold',
    'deceased': 'Deceased',
  };
  static const _icons = {
    'active': Icons.check_circle_outline_rounded,
    'sold': Icons.sell_outlined,
    'deceased': Icons.do_not_disturb_on_outlined,
  };
  static const _colors = {
    'active': AppColors.success,
    'sold': AppColors.secondary,
    'deceased': AppColors.outline,
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status *',
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: _options.map((s) {
            final isSelected = selected == s;
            final color = _colors[s]!;
            return ChoiceChip(
              avatar: Icon(
                _icons[s],
                size: 16,
                color: isSelected ? color : cs.onSurfaceVariant,
              ),
              label: Text(_labels[s]!),
              selected: isSelected,
              onSelected: (_) => onSelected(s),
              selectedColor: color.withAlpha(28),
              labelStyle: tt.labelSmall?.copyWith(
                color: isSelected ? color : cs.onSurface,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
              side: BorderSide(
                color: isSelected ? color : cs.outlineVariant,
                width: isSelected ? 1.5 : 1,
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Date of Birth picker ──────────────────────────────────────────────────────

class _DobPicker extends StatelessWidget {
  const _DobPicker({required this.value, required this.onPicked});

  final DateTime? value;
  final ValueChanged<DateTime> onPicked;

  String? get _formatted {
    if (value == null) return null;
    return '${value!.day.toString().padLeft(2, '0')}/'
        '${value!.month.toString().padLeft(2, '0')}/'
        '${value!.year}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ??
              DateTime.now().subtract(const Duration(days: 365)),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          helpText: 'Select date of birth',
        );
        if (picked != null) onPicked(picked);
      },
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date of Birth',
          prefixIcon: const Icon(Icons.cake_outlined),
          suffixIcon: Icon(
            Icons.calendar_today_outlined,
            color: cs.onSurfaceVariant,
          ),
        ),
        isEmpty: _formatted == null,
        child: Text(
          _formatted ?? 'Select date of birth (optional)',
          style: TextStyle(
            color: _formatted != null
                ? cs.onSurface
                : cs.onSurfaceVariant.withAlpha(180),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// ── Body Condition Score slider ───────────────────────────────────────────────

class _BcsSlider extends StatelessWidget {
  const _BcsSlider({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  static const _labels = {
    1: 'Emaciated',
    2: 'Thin',
    3: 'Ideal',
    4: 'Fat',
    5: 'Obese',
  };

  Color _colorForBcs(int v) => switch (v) {
        1 => AppColors.error,
        2 => AppColors.warning,
        3 => AppColors.success,
        4 => AppColors.warning,
        5 => AppColors.secondary,
        _ => AppColors.primary,
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = _colorForBcs(value);
    final label = _labels[value] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Body Condition Score (BCS)',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: 2),
              decoration: BoxDecoration(
                color: color.withAlpha(22),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: color, width: 1),
              ),
              child: Text(
                '$value – $label',
                style: tt.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            thumbColor: color,
            inactiveTrackColor: color.withAlpha(35),
            overlayColor: color.withAlpha(20),
            trackHeight: 4,
          ),
          child: Slider(
            value: value.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            label: '$value',
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1\nEmaciated',
                  textAlign: TextAlign.center,
                  style: tt.labelSmall?.copyWith(
                      fontSize: 9, color: cs.onSurfaceVariant)),
              Text('3\nIdeal',
                  textAlign: TextAlign.center,
                  style: tt.labelSmall?.copyWith(
                      fontSize: 9, color: cs.onSurfaceVariant)),
              Text('5\nObese',
                  textAlign: TextAlign.center,
                  style: tt.labelSmall?.copyWith(
                      fontSize: 9, color: cs.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}
