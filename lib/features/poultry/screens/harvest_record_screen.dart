import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/user_role.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/farm_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/poultry_providers.dart';

class HarvestRecordScreen extends ConsumerStatefulWidget {
  const HarvestRecordScreen({super.key, required this.flockId});

  final String flockId;

  @override
  ConsumerState<HarvestRecordScreen> createState() =>
      _HarvestRecordScreenState();
}

class _HarvestRecordScreenState extends ConsumerState<HarvestRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _birdsHarvestedCtrl = TextEditingController();
  final _totalLiveWeightCtrl = TextEditingController();
  final _processorNameCtrl = TextEditingController();
  final _gradeACtrl = TextEditingController();
  final _condemnationCtrl = TextEditingController();
  final _pricePerKgCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime _harvestDate = DateTime.now();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _birdsHarvestedCtrl.dispose();
    _totalLiveWeightCtrl.dispose();
    _processorNameCtrl.dispose();
    _gradeACtrl.dispose();
    _condemnationCtrl.dispose();
    _pricePerKgCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Computed fields ────────────────────────────────────────────────────────

  double? get _avgHarvestWeight {
    final birds = int.tryParse(_birdsHarvestedCtrl.text);
    final weight = double.tryParse(_totalLiveWeightCtrl.text);
    if (birds != null && birds > 0 && weight != null) {
      return weight / birds;
    }
    return null;
  }

  double? get _totalRevenue {
    final weight = double.tryParse(_totalLiveWeightCtrl.text);
    final price = double.tryParse(_pricePerKgCtrl.text);
    if (weight != null && price != null) return weight * price;
    return null;
  }

  // ── Date picker ────────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _harvestDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _harvestDate = picked);
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // ── Withdrawal blocker ─────────────────────────────────────────────
    final withdrawalsAsync =
        ref.read(activeWithdrawalProvider(widget.flockId));
    final withdrawals = withdrawalsAsync.value ?? [];
    if (withdrawals.isNotEmpty) {
      final latest = withdrawals
          .map((l) => DateTime.parse(l.clearanceDate))
          .reduce((a, b) => a.isAfter(b) ? a : b);
      final latestStr =
          '${latest.year}-${latest.month.toString().padLeft(2, '0')}-${latest.day.toString().padLeft(2, '0')}';
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: Row(children: [
            const Icon(Icons.block, color: AppColors.error),
            const SizedBox(width: 8),
            const Text('Harvest Blocked'),
          ]),
          content: Text(
            'Active medication withdrawal in effect until $latestStr.\n\n'
            'Harvesting before this date risks drug residues in the carcass.\n\n'
            'Drug: ${withdrawals.first.drugName}',
          ),
          actions: [
            FilledButton(
              style:
                  FilledButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel Harvest'),
            ),
          ],
        ),
      );
      return; // block harvest
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Harvest record saved'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final flockAsync = ref.watch(flockDetailProvider(widget.flockId));
    final batchName =
        flockAsync.whenOrNull(data: (f) => f?.batchName) ?? 'Flock';
    final canFinancials = ref.watch(userRoleProvider).canEditFinancials;
    final dateLabel = DateFormat('dd MMM yyyy').format(_harvestDate);
    final medAsync = ref.watch(flockMedicationLogsProvider(widget.flockId));
    final now = DateTime.now();
    final withdrawalLogs = medAsync.whenOrNull(data: (logs) => logs
            .where((l) =>
                DateTime.tryParse(l.clearanceDate) != null &&
                DateTime.tryParse(l.clearanceDate)!.isAfter(now))
            .toList()) ??
        [];

    return FarmScaffold(
      drawer: null,
      appBar: FarmAppBar(title: 'Harvest Record', subtitle: batchName),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePaddingHorizontal,
            AppSpacing.md,
            AppSpacing.pagePaddingHorizontal,
            AppSpacing.xxl + 80,
          ),
          children: [
            // ── Withdrawal warning ─────────────────────────────────────────
            if (withdrawalLogs.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(20),
                  borderRadius: AppRadius.card,
                  border: Border.all(color: AppColors.error),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.dangerous_outlined,
                        color: AppColors.error, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Withdrawal Period Active',
                            style: TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${withdrawalLogs.length} medication${withdrawalLogs.length == 1 ? '' : 's'} still in withdrawal period. '
                            'Do NOT harvest until all clearance dates have passed.',
                            style: const TextStyle(
                                color: AppColors.error, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // ── 1. Harvest Date ────────────────────────────────────────────
            _FormSection(
              title: 'Harvest Date',
              icon: Icons.calendar_today_outlined,
              child: InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm, horizontal: AppSpacing.md),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant
                          .withAlpha(160),
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event, size: 20,
                          color: AppColors.poultryColor),
                      const SizedBox(width: AppSpacing.sm),
                      Text(dateLabel,
                          style: Theme.of(context).textTheme.bodyMedium),
                      const Spacer(),
                      const Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── 2. Birds & Weight ──────────────────────────────────────────
            _FormSection(
              title: 'Birds & Weight',
              icon: Icons.set_meal_outlined,
              child: Column(
                children: [
                  FarmTextField(
                    controller: _birdsHarvestedCtrl,
                    label: 'Birds Harvested',
                    hint: 'e.g. 480',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (int.tryParse(v) == null) return 'Enter a whole number';
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FarmTextField(
                    controller: _totalLiveWeightCtrl,
                    label: 'Total Live Weight (kg)',
                    hint: 'e.g. 1152.5',
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'))
                    ],
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Enter a number';
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  if (_avgHarvestWeight != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _ComputedRow(
                      label: 'Avg Harvest Weight',
                      value:
                          '${_avgHarvestWeight!.toStringAsFixed(3)} kg / bird',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── 3. Processor ───────────────────────────────────────────────
            _FormSection(
              title: 'Processor',
              icon: Icons.factory_outlined,
              child: FarmTextField(
                controller: _processorNameCtrl,
                label: 'Processor Name',
                hint: 'e.g. Rainbow Chickens',
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── 4. Grading ─────────────────────────────────────────────────
            _FormSection(
              title: 'Carcass Grading',
              icon: Icons.grading_outlined,
              child: Column(
                children: [
                  FarmTextField(
                    controller: _gradeACtrl,
                    label: 'Carcass Grade A (%)',
                    hint: '0 – 100',
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,1}'))
                    ],
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      final d = double.tryParse(v);
                      if (d == null || d < 0 || d > 100) {
                        return 'Enter 0–100';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FarmTextField(
                    controller: _condemnationCtrl,
                    label: 'Condemnation Rate (%)',
                    hint: '0 – 100',
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,1}'))
                    ],
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      final d = double.tryParse(v);
                      if (d == null || d < 0 || d > 100) {
                        return 'Enter 0–100';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── 5. Financials (role-gated) ─────────────────────────────────
            if (canFinancials) ...[
              _FormSection(
                title: 'Financials',
                icon: Icons.payments_outlined,
                child: Column(
                  children: [
                    FarmTextField(
                      controller: _pricePerKgCtrl,
                      label: 'Price per kg (ZAR)',
                      hint: 'e.g. 24.50',
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'))
                      ],
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => setState(() {}),
                    ),
                    if (_totalRevenue != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _ComputedRow(
                        label: 'Total Revenue',
                        value:
                            'R ${NumberFormat('#,##0.00').format(_totalRevenue)}',
                        highlight: true,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],

            // ── 6. Notes ───────────────────────────────────────────────────
            _FormSection(
              title: 'Notes',
              icon: Icons.notes_outlined,
              child: FarmTextField(
                controller: _notesCtrl,
                label: 'Additional Notes',
                hint: 'Transport issues, bird condition, etc.',
                minLines: 3,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Submit ─────────────────────────────────────────────────────
            PrimaryButton(
              label: 'Save Harvest Record',
              onPressed: _isSubmitting ? null : _submit,
              isLoading: _isSubmitting,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Computed display row ──────────────────────────────────────────────────────

class _ComputedRow extends StatelessWidget {
  const _ComputedRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.poultryColor.withAlpha(18)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: highlight
            ? Border.all(color: AppColors.poultryColor.withAlpha(60))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              )),
          Text(value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: highlight ? AppColors.poultryColor : null,
              )),
        ],
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
