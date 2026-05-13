import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/farm_text_field.dart';
import '../../../shared/widgets/primary_button.dart';

class AddBreedingEventScreen extends ConsumerStatefulWidget {
  const AddBreedingEventScreen({super.key});

  @override
  ConsumerState<AddBreedingEventScreen> createState() =>
      _AddBreedingEventScreenState();
}

class _AddBreedingEventScreenState
    extends ConsumerState<AddBreedingEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _animalIdCtrl = TextEditingController();
  final _sireIdCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime? _breedingDate;
  DateTime? _expectedBirthDate;
  String? _breedingMethod;
  bool _submitting = false;

  static const _methods = [
    'Natural',
    'Artificial Insemination',
    'Embryo Transfer',
  ];

  @override
  void dispose() {
    _animalIdCtrl.dispose();
    _sireIdCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Breeding event saved'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm)),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return FarmScaffold(
      appBar: const FarmAppBar(
        title: 'Add Breeding Event',
        subtitle: 'Record breeding activity',
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
            _FormCard(
              title: 'Animal',
              icon: Icons.pets_rounded,
              child: FarmTextField(
                controller: _animalIdCtrl,
                label: 'Animal ID *',
                hint: 'e.g. C-001',
                prefixIcon: const Icon(Icons.tag_rounded),
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _FormCard(
              title: 'Breeding Details',
              icon: Icons.favorite_outline_rounded,
              child: Column(
                children: [
                  _DateField(
                    label: 'Breeding Date *',
                    icon: Icons.event_rounded,
                    value: _breedingDate,
                    onPicked: (d) => setState(() => _breedingDate = d),
                    required: true,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: _breedingMethod,
                    decoration: const InputDecoration(
                      labelText: 'Breeding Method',
                      prefixIcon: Icon(Icons.science_outlined),
                    ),
                    hint: const Text('Select method'),
                    isExpanded: true,
                    items: _methods
                        .map((m) =>
                            DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) => setState(() => _breedingMethod = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _FormCard(
              title: 'Sire (Optional)',
              icon: Icons.male_rounded,
              child: FarmTextField(
                controller: _sireIdCtrl,
                label: 'Sire ID',
                hint: 'e.g. B-007',
                prefixIcon: const Icon(Icons.tag_rounded),
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _FormCard(
              title: 'Expected Birth',
              icon: Icons.child_care_outlined,
              child: _DateField(
                label: 'Expected Birth Date',
                icon: Icons.event_available_rounded,
                value: _expectedBirthDate,
                onPicked: (d) => setState(() => _expectedBirthDate = d),
                required: false,
                allowFuture: true,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _FormCard(
              title: 'Notes',
              icon: Icons.notes_rounded,
              child: FarmTextField(
                controller: _notesCtrl,
                label: 'Notes',
                hint: 'Any observations…',
                maxLines: 3,
                minLines: 2,
                textInputAction: TextInputAction.done,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              onPressed: _submit,
              label: 'Save Breeding Event',
              icon: const Icon(Icons.save_rounded, size: 18),
              isLoading: _submitting,
            ),
          ],
        ),
      ),
    );
  }
}

// ── _FormCard ─────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  const _FormCard({
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
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ── _DateField ────────────────────────────────────────────────────────────────

class _DateField extends FormField<DateTime> {
  _DateField({
    required String label,
    required IconData icon,
    required DateTime? value,
    required ValueChanged<DateTime> onPicked,
    required bool required,
    bool allowFuture = false,
  }) : super(
          initialValue: value,
          validator: (v) {
            if (required && v == null) return 'Please select a date';
            return null;
          },
          builder: (state) {
            final context = state.context;
            final theme = Theme.of(context);
            final text = state.value == null
                ? null
                : '${state.value!.day.toString().padLeft(2, '0')}/'
                    '${state.value!.month.toString().padLeft(2, '0')}/'
                    '${state.value!.year}';

            return InputDecorator(
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: Icon(icon),
                errorText: state.errorText,
                suffixIcon: const Icon(Icons.calendar_today_outlined),
              ),
              isEmpty: state.value == null,
              child: GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: state.value ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: allowFuture
                        ? DateTime.now().add(const Duration(days: 730))
                        : DateTime.now(),
                  );
                  if (picked != null) {
                    state.didChange(picked);
                    onPicked(picked);
                  }
                },
                child: Text(
                  text ?? '',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            );
          },
        );
}
