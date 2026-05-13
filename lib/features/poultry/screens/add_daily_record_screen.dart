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
import '../models/flock.dart';
import '../models/inventory_item.dart';
import '../providers/poultry_providers.dart';

class AddDailyRecordScreen extends ConsumerStatefulWidget {
  const AddDailyRecordScreen({super.key, required this.flockId});

  final String flockId;

  @override
  ConsumerState<AddDailyRecordScreen> createState() =>
      _AddDailyRecordScreenState();
}

class _AddDailyRecordScreenState extends ConsumerState<AddDailyRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  // Field controllers
  final _mortalityCtrl = TextEditingController();
  final _cullsCtrl = TextEditingController();
  final _feedCtrl = TextEditingController();
  final _waterCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _eggsAmCtrl = TextEditingController();
  final _eggsPmCtrl = TextEditingController();
  final _brokenEggsCtrl = TextEditingController();
  final _floorEggsCtrl = TextEditingController();
  final _eggsJumboCtrl = TextEditingController();
  final _eggsExtraLargeCtrl = TextEditingController();
  final _eggsLargeCtrl = TextEditingController();
  final _eggsMediumCtrl = TextEditingController();
  final _eggsSmallCtrl = TextEditingController();
  final _eggsPeeweeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime _recordDate = DateTime.now();
  String? _feedType;
  String? _mortalityCause;
  bool _submitting = false;

  @override
  void dispose() {
    _mortalityCtrl.dispose();
    _cullsCtrl.dispose();
    _feedCtrl.dispose();
    _waterCtrl.dispose();
    _tempCtrl.dispose();
    _weightCtrl.dispose();
    _eggsAmCtrl.dispose();
    _eggsPmCtrl.dispose();
    _brokenEggsCtrl.dispose();
    _floorEggsCtrl.dispose();
    _eggsJumboCtrl.dispose();
    _eggsExtraLargeCtrl.dispose();
    _eggsLargeCtrl.dispose();
    _eggsMediumCtrl.dispose();
    _eggsSmallCtrl.dispose();
    _eggsPeeweeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _recordDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _recordDate = picked);
  }

  String get _dateDisplay {
    final d = _recordDate;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    // Read flock for placement date / dayOfAge computation
    final flock = ref.read(flockDetailProvider(widget.flockId)).value;
    final placement = flock != null
        ? DateTime.tryParse(flock.placementDate)
        : null;
    final dayOfAge = placement != null
        ? _recordDate.difference(placement).inDays + 1
        : flock?.dayOfAge;

    final mortality = int.tryParse(_mortalityCtrl.text.trim()) ?? 0;
    final culls = int.tryParse(_cullsCtrl.text.trim()) ?? 0;
    final feedKg = double.tryParse(_feedCtrl.text.trim());
    final dateStr =
        '${_recordDate.year}-${_recordDate.month.toString().padLeft(2, '0')}-${_recordDate.day.toString().padLeft(2, '0')}';

    // Build the DailyRecord
    final isLayer =
        flock?.productionType == 'layer' || flock?.productionType == 'breeder';
    final record = DailyRecord(
      id: 'new-${DateTime.now().millisecondsSinceEpoch}',
      flockId: widget.flockId,
      date: dateStr,
      dayOfAge: dayOfAge,
      mortalityCount: mortality,
      mortalityCause: _mortalityCause,
      culls: culls,
      feedConsumedKg: feedKg,
      waterConsumedLitres: double.tryParse(_waterCtrl.text.trim()),
      feedType: _feedType,
      avgHouseTempC: double.tryParse(_tempCtrl.text.trim()),
      avgBodyWeightG: int.tryParse(_weightCtrl.text.trim()),
      eggsCollectedAm: isLayer ? int.tryParse(_eggsAmCtrl.text.trim()) : null,
      eggsCollectedPm: isLayer ? int.tryParse(_eggsPmCtrl.text.trim()) : null,
      brokenEggs: isLayer ? int.tryParse(_brokenEggsCtrl.text.trim()) : null,
      floorEggs: isLayer ? int.tryParse(_floorEggsCtrl.text.trim()) : null,
      eggsJumbo: isLayer ? int.tryParse(_eggsJumboCtrl.text.trim()) : null,
      eggsExtraLarge:
          isLayer ? int.tryParse(_eggsExtraLargeCtrl.text.trim()) : null,
      eggsLarge: isLayer ? int.tryParse(_eggsLargeCtrl.text.trim()) : null,
      eggsMedium: isLayer ? int.tryParse(_eggsMediumCtrl.text.trim()) : null,
      eggsSmall: isLayer ? int.tryParse(_eggsSmallCtrl.text.trim()) : null,
      eggsPeewee: isLayer ? int.tryParse(_eggsPeeweeCtrl.text.trim()) : null,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      recordedBy: 'Farm Manager',
    );

    // Persist in-session
    ref.read(newDailyRecordProvider.notifier).add(record);

    // Deduct feed from inventory (find first item with category == 'feed')
    if (feedKg != null && feedKg > 0) {
      final inventory = ref.read(inventoryProvider).value ?? [];
      try {
        final feedItem = inventory.firstWhere(
          (i) => i.category == InventoryCategory.feed,
        );
        final newQty = (feedItem.currentStock - feedKg).clamp(0.0, double.infinity);
        ref.read(inventoryEditProvider.notifier).update(feedItem.id, newQty);
      } catch (_) {
        // No feed inventory item found — silent; user can manage manually
      }
    }

    // Deduct egg trays from inventory for layer flocks (1 tray = 30 eggs)
    if (isLayer && record.totalEggs > 0) {
      final traysUsed = (record.totalEggs / 30).ceil();
      final inventory = ref.read(inventoryProvider).value ?? [];
      try {
        final trayItem = inventory.firstWhere(
          (i) => i.name.toLowerCase().contains('tray') ||
              i.name.toLowerCase().contains('egg tray'),
        );
        final newQty =
            (trayItem.currentStock - traysUsed).clamp(0.0, double.infinity);
        ref.read(inventoryEditProvider.notifier).update(trayItem.id, newQty);
      } catch (_) {
        // No egg tray item found — silent
      }
    }

    // Check mortality spike: compare today vs rolling average of previous records
    bool isSpiking = false;
    if (mortality > 0) {
      final existing =
          ref.read(flockDailyRecordsProvider(widget.flockId)).value ?? [];
      // existing still has mock data; new record is in newDailyRecordProvider
      final previous = existing.take(7);
      final total =
          previous.fold<int>(0, (sum, r) => sum + (r.mortalityCount ?? 0));
      if (previous.isNotEmpty) {
        final avg = total / previous.length;
        isSpiking = avg > 0 && mortality > avg * 3;
      }
    }

    // Determine active feed phase for informational notification
    FeedPhase? activePhase;
    if (dayOfAge != null) {
      final phases =
          ref.read(flockFeedPhasesProvider(widget.flockId)).value ?? [];
      try {
        activePhase = phases.firstWhere((p) => p.isActiveOnDay(dayOfAge));
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() => _submitting = false);

    // Mortality spike warning dialog
    if (isSpiking) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: Row(children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            const SizedBox(width: 8),
            const Text('Mortality Spike Alert'),
          ]),
          content: Text(
            'Today\'s mortality ($mortality) is more than 3× '
            'the recent batch average. Consider investigating '
            'disease, environmental, or management causes.',
          ),
          actions: [
            FilledButton(
              style:
                  FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () => Navigator.pop(context),
              child: const Text('Noted'),
            ),
          ],
        ),
      );
    }
    if (!mounted) return;

    // Feed phase informational snackbar
    if (activePhase != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Feed phase: ${activePhase.phaseName} (${activePhase.feedType})'
            ' — Day ${activePhase.dayStart}–${activePhase.dayEnd}',
          ),
          duration: const Duration(seconds: 5),
          backgroundColor: AppColors.info,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm)),
        ),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Daily record saved successfully'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm)),
      ),
    );

    // Auto-populate feed expense in financials
    if (feedKg != null && feedKg > 0) {
      const feedCostPerKg = 7.80; // ZAR/kg stub
      ref.read(financialAutoEntryProvider.notifier).add(FinancialAutoEntry(
        id: 'fa-feed-${DateTime.now().millisecondsSinceEpoch}',
        flockId: widget.flockId,
        date: dateStr,
        type: FinancialEntryType.expense,
        category: 'feed',
        description: '${feedKg.toStringAsFixed(1)} kg feed consumed',
        amount: feedKg * feedCostPerKg,
        sourceId: record.id,
      ));
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final flockAsync = ref.watch(flockDetailProvider(widget.flockId));

    final isLayer =
        flockAsync.whenOrNull(data: (f) => f?.isLayer) ?? false;
    final batchName =
        flockAsync.whenOrNull(data: (f) => f?.batchName) ?? 'Flock';
    final productionType =
        flockAsync.whenOrNull(data: (f) => f?.productionType) ?? 'broiler';
    final feedTypes = FeedPhaseType.forProductionType(productionType);

    return FarmScaffold(
      drawer: null,
      appBar: FarmAppBar(
        title: 'Daily Record',
        subtitle: batchName,
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
            // ── Record Date ───────────────────────────────────────────────
            _FormSection(
              title: 'Record Date',
              icon: Icons.calendar_today_outlined,
              child: InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date *',
                    prefixIcon: Icon(Icons.calendar_month_outlined),
                    suffixIcon: Icon(Icons.arrow_drop_down),
                  ),
                  child: Text(_dateDisplay),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Mortality & Culls ─────────────────────────────────────────
            _FormSection(
              title: 'Mortality & Culls',
              icon: Icons.trending_down_outlined,
              child: Row(
                children: [
                  Expanded(
                    child: FarmTextField(
                      controller: _mortalityCtrl,
                      label: 'Mortality Count',
                      hint: '0',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        if (int.tryParse(v.trim()) == null) {
                          return 'Whole number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FarmTextField(
                      controller: _cullsCtrl,
                      label: 'Culls',
                      hint: '0',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        if (int.tryParse(v.trim()) == null) {
                          return 'Whole number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Mortality Cause (shown when deaths > 0) ───────────────────
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _mortalityCtrl,
              builder: (_, value, _) {
                final count = int.tryParse(value.text.trim()) ?? 0;
                if (count <= 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _FormSection(
                    title: 'Mortality Cause',
                    icon: Icons.info_outline,
                    child: DropdownButtonFormField<String>(
                      initialValue: _mortalityCause,
                      decoration: const InputDecoration(
                        labelText: 'Primary Cause',
                        prefixIcon: Icon(Icons.local_hospital_outlined),
                      ),
                      hint: const Text('Select cause (optional)'),
                      items: MortalityCause.allValues
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(MortalityCause.label(c)),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _mortalityCause = v),
                    ),
                  ),
                );
              },
            ),

            // ── Feed & Water ──────────────────────────────────────────────
            _FormSection(
              title: 'Feed & Water',
              icon: Icons.water_drop_outlined,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _feedType,
                    decoration: const InputDecoration(
                      labelText: 'Feed Type',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    hint: const Text('Select feed type'),
                    items: feedTypes
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(FeedPhaseType.label(t)),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _feedType = v),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: FarmTextField(
                          controller: _feedCtrl,
                          label: 'Feed Consumed (kg)',
                          hint: '0.0',
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,1}')),
                          ],
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: FarmTextField(
                          controller: _waterCtrl,
                          label: 'Water (L)',
                          hint: '0.0',
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,1}')),
                          ],
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Environment ───────────────────────────────────────────────
            _FormSection(
              title: 'House Environment',
              icon: Icons.thermostat_outlined,
              child: FarmTextField(
                controller: _tempCtrl,
                label: 'Avg House Temp (°C)',
                hint: 'e.g. 32',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^-?\d+\.?\d{0,1}')),
                ],
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final n = double.tryParse(v.trim());
                  if (n == null || n < -10 || n > 60) {
                    return 'Enter a valid temperature (-10 to 60°C)';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Weight Sampling (Broiler / Duck) ──────────────────────────
            if (!isLayer) ...[
              _FormSection(
                title: 'Weight Sampling',
                icon: Icons.monitor_weight_outlined,
                child: FarmTextField(
                  controller: _weightCtrl,
                  label: 'Avg Body Weight (g)',
                  hint: 'e.g. 1250',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final n = int.tryParse(v.trim());
                    if (n == null || n <= 0) return 'Enter a valid weight';
                    return null;
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // ── Egg Production (Layer only) ───────────────────────────────
            if (isLayer) ...[
              _FormSection(
                title: 'Egg Production',
                icon: Icons.egg_outlined,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: FarmTextField(
                            controller: _eggsAmCtrl,
                            label: 'Eggs AM',
                            hint: '0',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: FarmTextField(
                            controller: _eggsPmCtrl,
                            label: 'Eggs PM',
                            hint: '0',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: FarmTextField(
                            controller: _brokenEggsCtrl,
                            label: 'Broken Eggs',
                            hint: '0',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: FarmTextField(
                            controller: _floorEggsCtrl,
                            label: 'Floor Eggs',
                            hint: '0',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Egg Grade Breakdown ─────────────────────────────────────
              _FormSection(
                title: 'Egg Grading',
                icon: Icons.grade_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grade breakdown (optional — must sum to total collected)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _GradeRow(
                      label: 'Jumbo (> 70 g)',
                      controller: _eggsJumboCtrl,
                    ),
                    _GradeRow(
                      label: 'Extra Large (63–70 g)',
                      controller: _eggsExtraLargeCtrl,
                    ),
                    _GradeRow(
                      label: 'Large (56–63 g)',
                      controller: _eggsLargeCtrl,
                    ),
                    _GradeRow(
                      label: 'Medium (49–56 g)',
                      controller: _eggsMediumCtrl,
                    ),
                    _GradeRow(
                      label: 'Small (42–49 g)',
                      controller: _eggsSmallCtrl,
                    ),
                    _GradeRow(
                      label: 'Peewee (< 42 g)',
                      controller: _eggsPeeweeCtrl,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // ── Notes ─────────────────────────────────────────────────────
            _FormSection(
              title: 'Notes',
              icon: Icons.notes_outlined,
              child: FarmTextField(
                controller: _notesCtrl,
                label: 'Observations / Notes',
                hint:
                    'e.g. Litter quality, unusual behaviour, disease signs...',
                maxLines: 3,
                minLines: 2,
                textInputAction: TextInputAction.done,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            PrimaryButton(
              label: 'Save Record',
              onPressed: _submitting ? null : _submit,
              isLoading: _submitting,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Form Section ──────────────────────────────────────────────────────────────

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

// ── Grade Row ─────────────────────────────────────────────────────────────────

class _GradeRow extends StatelessWidget {
  const _GradeRow({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 2,
            child: FarmTextField(
              controller: controller,
              label: '',
              hint: '0',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textInputAction: TextInputAction.next,
            ),
          ),
        ],
      ),
    );
  }
}
