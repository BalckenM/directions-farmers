import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/farm_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../models/vaccination_reference.dart';
import '../models/poultry_flock.dart';
import '../providers/poultry_providers.dart';

// ── Production type definition ────────────────────────────────────────────────

class _ProductionType {
  const _ProductionType(this.label, this.value, this.species);
  final String label;
  final String value;
  final String species;
}

const _productionTypes = [
  _ProductionType('Broiler (Meat Chicken)', 'broiler', 'chicken'),
  _ProductionType('Layer (Egg Production)', 'layer', 'chicken'),
  _ProductionType('Hatchery (Chick Production)', 'hatchery', 'chicken'),
  _ProductionType('Breeder / Parent Stock', 'breeder', 'chicken'),
  _ProductionType('Duck Meat', 'duck_meat', 'duck'),
  _ProductionType('Turkey', 'turkey', 'turkey'),
  _ProductionType('Quail', 'quail', 'quail'),
];

// ── Ross 308 benchmark strains per production type ────────────────────────────

const _strainsByType = {
  'broiler': ['Ross 308', 'Cobb 500', 'Arbor Acres', 'Hubbard Flex', 'Other'],
  'layer': [
    'Lohmann Brown Classic',
    'Hy-Line Brown',
    'ISA Brown',
    'Amberlink',
    'Other',
  ],
  'hatchery': ['Ross 308 PS', 'Cobb 500 PS', 'Lohmann Brown PS', 'Other'],
  'breeder': ['Ross PM3', 'Cobb 500 PS', 'Other'],
  'duck_meat': ['Pekin', 'Muscovy', 'Cherry Valley', 'Other'],
  'turkey': ['Nicholas 300', 'BUT 6', 'Other'],
  'quail': ['Coturnix', 'Bobwhite', 'Other'],
};

// ── Screen ────────────────────────────────────────────────────────────────────

class AddFlockScreen extends ConsumerStatefulWidget {
  const AddFlockScreen({super.key});

  @override
  ConsumerState<AddFlockScreen> createState() => _AddFlockScreenState();
}

class _AddFlockScreenState extends ConsumerState<AddFlockScreen> {
  final _formKey = GlobalKey<FormState>();

  // Core fields
  final _batchNameCtrl = TextEditingController();
  final _strainCtrl = TextEditingController();
  final _supplierCtrl = TextEditingController();
  final _headcountCtrl = TextEditingController();
  final _houseCtrl = TextEditingController();
  final _unitCostCtrl = TextEditingController();
  final _targetWeightCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  _ProductionType? _productionType;
  String? _strain;
  DateTime? _placementDate;
  DateTime? _expectedExitDate;
  bool _submitting = false;

  bool get _isBroilerOrDuck =>
      _productionType?.value == 'broiler' ||
      _productionType?.value == 'duck_meat';

  bool get _isLayer => _productionType?.value == 'layer';

  List<String> get _strainOptions =>
      _strainsByType[_productionType?.value ?? ''] ?? ['Other'];

  @override
  void dispose() {
    _batchNameCtrl.dispose();
    _strainCtrl.dispose();
    _supplierCtrl.dispose();
    _headcountCtrl.dispose();
    _houseCtrl.dispose();
    _unitCostCtrl.dispose();
    _targetWeightCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required DateTime? current,
    required ValueChanged<DateTime> onPicked,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) onPicked(picked);
  }

  String _formatDate(DateTime? d) {
    if (d == null) return 'Select date';
    return '${d.day.toString().padLeft(2, '0')} '
        '${_monthName(d.month)} '
        '${d.year}';
  }

  String _monthName(int m) => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m - 1];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_placementDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a placement date'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm)),
        ),
      );
      return;
    }
    setState(() => _submitting = true);
    // ── AIAO enforcement: block if selected house has an active flock ──
    final selectedHouseId = _houseCtrl.text.trim();
    if (selectedHouseId.isNotEmpty) {
      final flocks = ref.read(flocksProvider).value ?? [];
      final occupant = flocks
          .where((f) => f.houseId == selectedHouseId && f.isActive)
          .firstOrNull;
      if (occupant != null) {
        if (!mounted) return;
        setState(() => _submitting = false);
        await showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('AIAO Policy Violation'),
            content: Text(
              'House "$selectedHouseId" is currently occupied by '
              '"${occupant.batchName}".\n\n'
              'Deplete or harvest the existing flock before placing a new batch '
              '(All-In All-Out biosecurity protocol).',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
    }
    // ── AIAO 14-day downtime enforcement ──────────────────────────────────────
    if (selectedHouseId.isNotEmpty && _placementDate != null) {
      final flocks = ref.read(flocksProvider).value ?? [];
      // Find the most recently vacated flock in this house
      final pastFlocks = flocks
          .where((f) => f.houseId == selectedHouseId && !f.isActive)
          .toList();
      if (pastFlocks.isNotEmpty) {
        pastFlocks.sort((a, b) {
          final aDate = DateTime.tryParse(a.placementDate);
          final bDate = DateTime.tryParse(b.placementDate);
          if (aDate == null || bDate == null) return 0;
          return bDate.compareTo(aDate);
        });
        final lastFlock = pastFlocks.first;
        final lastPlacement = DateTime.tryParse(lastFlock.placementDate);
        if (lastPlacement != null && lastFlock.dayOfAge > 0) {
          final estimatedVacated =
              lastPlacement.add(Duration(days: lastFlock.dayOfAge));
          final downtimeDays =
              _placementDate!.difference(estimatedVacated).inDays;
          if (downtimeDays < 14) {
            if (!mounted) return;
            setState(() => _submitting = false);
            await showDialog<void>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Insufficient Downtime'),
                content: Text(
                  'House "$selectedHouseId" requires at least 14 days of '
                  'downtime between batches for cleaning and disinfection.\n\n'
                  'Last batch closed out ~${estimatedVacated.toLocal().toString().substring(0, 10)}. '
                  'Your placement date is only $downtimeDays day${downtimeDays == 1 ? '' : 's'} later.\n\n'
                  'Earliest allowed placement: '
                  '${estimatedVacated.add(const Duration(days: 14)).toLocal().toString().substring(0, 10)}.',
                ),
                actions: [
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
            return;
          }
        }
      }
    }
    // Simulate network save delay
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    // ── Build and save the new flock in-memory ────────────────────────────────
    final now = DateTime.now();
    final newFlock = PoultryFlock(
      id: 'flock-${now.millisecondsSinceEpoch}',
      farmId: 'farm-001',
      batchName: _batchNameCtrl.text.trim(),
      species: _productionType!.species,
      productionType: _productionType!.value,
      strain: _strainCtrl.text.trim(),
      houseId: _houseCtrl.text.trim(),
      status: 'active',
      placementDate: _placementDate!.toIso8601String().substring(0, 10),
      placementCount: int.tryParse(_headcountCtrl.text.trim()) ?? 0,
      currentCount: int.tryParse(_headcountCtrl.text.trim()) ?? 0,
      mortalityTotal: 0,
      mortalityPct: 0.0,
      dayOfAge: now.difference(_placementDate!).inDays.clamp(0, 999),
      livabilityPct: 100.0,
      unitCostPerChick: double.tryParse(_unitCostCtrl.text.trim()),
      projectedSlaughterDate:
          _expectedExitDate?.toIso8601String().substring(0, 10),
      createdAt: now.toIso8601String(),
      updatedAt: now.toIso8601String(),
    );
    ref.read(addedFlocksProvider.notifier).addFlock(newFlock);

    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Flock "${_batchNameCtrl.text.trim()}" created successfully'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm)),
      ),
    );

    // ── Show auto-generated vaccination schedule ────────────────────────
    final schedule = VaccinationReference.scheduledDates(
      placementDate: _placementDate!,
      productionType: _productionType?.value ?? 'broiler',
    );
    if (mounted) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => _VaccinationScheduleDialog(
          flockName: _batchNameCtrl.text.trim(),
          schedule: schedule,
        ),
      );
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return FarmScaffold(
      drawer: null,
      appBar: const FarmAppBar(
        title: 'Add New Flock',
        subtitle: 'Register a new batch / flock',
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
            // ── Section 1: Production Classification ─────────────────────
            _FormSection(
              title: 'Flock Classification',
              icon: Icons.category_outlined,
              child: Column(
                children: [
                  // Production Type
                  DropdownButtonFormField<_ProductionType>(
                    initialValue: _productionType,
                    decoration: const InputDecoration(
                      labelText: 'Production Type *',
                      prefixIcon: Icon(Icons.egg_alt_outlined),
                    ),
                    hint: const Text('Select production type'),
                    isExpanded: true,
                    items: _productionTypes
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(t.label),
                          ),
                        )
                        .toList(),
                    onChanged: (t) => setState(() {
                      _productionType = t;
                      _strain = null; // reset strain when type changes
                    }),
                    validator: (v) =>
                        v == null ? 'Please select a production type' : null,
                  ),
                  if (_productionType != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    // Strain / Breed
                    DropdownButtonFormField<String>(
                      initialValue: _strain,
                      decoration: const InputDecoration(
                        labelText: 'Strain / Breed *',
                        prefixIcon: Icon(Icons.science_outlined),
                      ),
                      hint: const Text('Select strain'),
                      isExpanded: true,
                      items: _strainOptions
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (s) => setState(() {
                        _strain = s;
                        if (s != 'Other') {
                          _strainCtrl.text = s ?? '';
                        } else {
                          _strainCtrl.clear();
                        }
                      }),
                      validator: (v) =>
                          v == null ? 'Please select a strain' : null,
                    ),
                    if (_strain == 'Other') ...[
                      const SizedBox(height: AppSpacing.md),
                      FarmTextField(
                        controller: _strainCtrl,
                        label: 'Custom Strain Name *',
                        hint: 'e.g. Indigenous Broiler Cross',
                        prefixIcon: const Icon(Icons.edit_outlined),
                        textInputAction: TextInputAction.next,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ],
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Section 2: Batch Identity ─────────────────────────────────
            _FormSection(
              title: 'Batch Identity',
              icon: Icons.badge_outlined,
              child: Column(
                children: [
                  FarmTextField(
                    controller: _batchNameCtrl,
                    label: 'Batch Name *',
                    hint: 'e.g. Broiler Batch Oct 2025',
                    prefixIcon: const Icon(Icons.label_outline),
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmTextField(
                    controller: _supplierCtrl,
                    label: 'Chick Supplier',
                    hint: 'e.g. Rainbow Chicken Ltd',
                    prefixIcon: const Icon(Icons.storefront_outlined),
                    textInputAction: TextInputAction.next,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Section 3: Placement Details ──────────────────────────────
            _FormSection(
              title: 'Placement Details',
              icon: Icons.event_outlined,
              child: Column(
                children: [
                  FarmTextField(
                    controller: _headcountCtrl,
                    label: 'Initial Headcount *',
                    hint: 'e.g. 20000',
                    prefixIcon: const Icon(Icons.groups_outlined),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final n = int.tryParse(v.trim());
                      if (n == null || n <= 0) {
                        return 'Must be a positive number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _DatePickerField(
                    label: 'Placement Date *',
                    icon: Icons.calendar_today_outlined,
                    value: _placementDate,
                    displayValue: _formatDate(_placementDate),
                    onTap: () => _pickDate(
                      current: _placementDate,
                      onPicked: (d) => setState(() => _placementDate = d),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmTextField(
                    controller: _houseCtrl,
                    label: 'House / Shed ID *',
                    hint: 'e.g. house-001, Shed A',
                    prefixIcon: const Icon(Icons.home_work_outlined),
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Section 4: Financial (Cost per Chick) ────────────────────
            _FormSection(
              title: 'Cost & Financials',
              icon: Icons.payments_outlined,
              child: FarmTextField(
                controller: _unitCostCtrl,
                label: 'Unit Cost per Chick (ZAR)',
                hint: 'e.g. 14.50',
                prefixIcon: const Icon(Icons.attach_money),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null; // optional
                  final n = double.tryParse(v.trim());
                  if (n == null || n < 0) return 'Enter a valid amount';
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Section 5: Target / Exit (Broiler / Duck only) ───────────
            if (_isBroilerOrDuck) ...[
              _FormSection(
                title: 'Production Targets',
                icon: Icons.flag_outlined,
                child: Column(
                  children: [
                    FarmTextField(
                      controller: _targetWeightCtrl,
                      label: 'Target Slaughter Weight (g)',
                      hint: 'e.g. 2500',
                      prefixIcon: const Icon(Icons.monitor_weight_outlined),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final n = int.tryParse(v.trim());
                        if (n == null || n <= 0) {
                          return 'Enter a valid weight in grams';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _DatePickerField(
                      label: 'Expected Slaughter / Exit Date',
                      icon: Icons.event_available_outlined,
                      value: _expectedExitDate,
                      displayValue: _formatDate(_expectedExitDate),
                      onTap: () => _pickDate(
                        current: _expectedExitDate,
                        onPicked: (d) => setState(() => _expectedExitDate = d),
                        firstDate: _placementDate ?? DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // ── Section 6: Layer target exit ──────────────────────────────
            if (_isLayer) ...[
              _FormSection(
                title: 'Production Targets',
                icon: Icons.flag_outlined,
                child: _DatePickerField(
                  label: 'Expected Point-of-Lay Date',
                  icon: Icons.event_available_outlined,
                  value: _expectedExitDate,
                  displayValue: _formatDate(_expectedExitDate),
                  onTap: () => _pickDate(
                    current: _expectedExitDate,
                    onPicked: (d) => setState(() => _expectedExitDate = d),
                    firstDate: _placementDate ?? DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // ── Section 7: Notes ──────────────────────────────────────────
            _FormSection(
              title: 'Notes',
              icon: Icons.notes_outlined,
              child: FarmTextField(
                controller: _notesCtrl,
                label: 'Additional Notes',
                hint: 'Delivery conditions, vaccination history, etc.',
                maxLines: 3,
                minLines: 2,
                textInputAction: TextInputAction.done,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Save button ───────────────────────────────────────────────
            PrimaryButton(
              label: 'Create Flock',
              onPressed: _submitting ? null : _submit,
              isLoading: _submitting,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Form Section wrapper ──────────────────────────────────────────────────────

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
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withAlpha(80),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.poultryColor),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.poultryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

// ── Date Picker Field ─────────────────────────────────────────────────────────

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.icon,
    required this.value,
    required this.displayValue,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final DateTime? value;
  final String displayValue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasValue = value != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          displayValue,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: hasValue
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ── Vaccination Schedule Preview Dialog ───────────────────────────────────────

class _VaccinationScheduleDialog extends StatelessWidget {
  const _VaccinationScheduleDialog({
    required this.flockName,
    required this.schedule,
  });

  final String flockName;
  final List<({DateTime dueDate, String vaccine, String route})> schedule;

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} '
      '${const ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][d.month - 1]} '
      '${d.year}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.poultryColorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.vaccines_outlined,
                color: AppColors.poultryColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Vaccination Schedule',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                Text(flockName,
                    style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Auto-generated schedule based on placement date and production type. '
                'Add reminders or log vaccinations from the Vaccination tab.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              ...schedule.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.poultryColor
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _fmt(e.dueDate),
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.poultryColor),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.vaccine,
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                            Text(e.route,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: theme
                                        .colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          style: FilledButton.styleFrom(
              backgroundColor: AppColors.poultryColor),
          onPressed: () => Navigator.pop(context),
          child: const Text('Got it'),
        ),
      ],
    );
  }
}
