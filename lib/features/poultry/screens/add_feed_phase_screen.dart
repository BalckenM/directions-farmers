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
import '../providers/poultry_providers.dart';

class AddFeedPhaseScreen extends ConsumerStatefulWidget {
  const AddFeedPhaseScreen({super.key, required this.flockId});

  final String flockId;

  @override
  ConsumerState<AddFeedPhaseScreen> createState() => _AddFeedPhaseScreenState();
}

class _AddFeedPhaseScreenState extends ConsumerState<AddFeedPhaseScreen> {
  final _formKey = GlobalKey<FormState>();

  String _selectedPhaseType = FeedPhaseType.starter;
  final _feedProductCtrl = TextEditingController();
  final _dayStartCtrl = TextEditingController();
  final _dayEndCtrl = TextEditingController();
  final _targetIntakeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _feedProductCtrl.dispose();
    _dayStartCtrl.dispose();
    _dayEndCtrl.dispose();
    _targetIntakeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  List<String> get _phaseOptions {
    final flockAsync = ref.read(flockDetailProvider(widget.flockId));
    final productionType =
        flockAsync.whenOrNull(data: (f) => f?.productionType) ?? 'broiler';
    return FeedPhaseType.forProductionType(productionType);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${FeedPhaseType.label(_selectedPhaseType)} phase saved',
        ),
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

    return FarmScaffold(
      drawer: null,
      appBar: FarmAppBar(title: 'Add Feed Phase', subtitle: batchName),
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
            // ── Phase Type ─────────────────────────────────────────────────
            _FormSection(
              title: 'Phase Type',
              icon: Icons.grain_outlined,
              child: DropdownButtonFormField<String>(
                initialValue: _selectedPhaseType,
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(),
                ),
                items: _phaseOptions
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(FeedPhaseType.label(t)),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedPhaseType = v);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── Day Range ──────────────────────────────────────────────────
            _FormSection(
              title: 'Day Range',
              icon: Icons.date_range_outlined,
              child: Row(
                children: [
                  Expanded(
                    child: FarmTextField(
                      controller: _dayStartCtrl,
                      label: 'Day Start',
                      hint: 'e.g. 1',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (int.tryParse(v) == null) return 'Integer';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FarmTextField(
                      controller: _dayEndCtrl,
                      label: 'Day End',
                      hint: 'e.g. 14',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final start =
                            int.tryParse(_dayStartCtrl.text) ?? 0;
                        final end = int.tryParse(v);
                        if (end == null) return 'Integer';
                        if (end <= start) return '> start';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── Feed Product ───────────────────────────────────────────────
            _FormSection(
              title: 'Feed Product',
              icon: Icons.inventory_2_outlined,
              child: FarmTextField(
                controller: _feedProductCtrl,
                label: 'Feed Product Name',
                hint: 'e.g. Epol Broiler Starter',
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── Target Intake ──────────────────────────────────────────────
            _FormSection(
              title: 'Target Intake',
              icon: Icons.scale_outlined,
              child: FarmTextField(
                controller: _targetIntakeCtrl,
                label: 'Target Daily Intake (g/bird)',
                hint: 'e.g. 45',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,1}'))
                ],
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.isEmpty) return null; // optional
                  if (double.tryParse(v) == null) return 'Enter a number';
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── Notes ──────────────────────────────────────────────────────
            _FormSection(
              title: 'Notes',
              icon: Icons.notes_outlined,
              child: FarmTextField(
                controller: _notesCtrl,
                label: 'Notes (optional)',
                hint: 'Any additional observations...',
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            PrimaryButton(
              label: 'Save Feed Phase',
              isLoading: _isSubmitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Form section wrapper ──────────────────────────────────────────────────────

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
        side: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(80)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.poultryColor),
                const SizedBox(width: AppSpacing.xs),
                Text(title,
                    style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.poultryColor)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            child,
          ],
        ),
      ),
    );
  }
}
