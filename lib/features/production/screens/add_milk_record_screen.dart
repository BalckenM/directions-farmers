import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class AddMilkRecordScreen extends ConsumerStatefulWidget {
  const AddMilkRecordScreen({super.key});

  @override
  ConsumerState<AddMilkRecordScreen> createState() =>
      _AddMilkRecordScreenState();
}

class _AddMilkRecordScreenState extends ConsumerState<AddMilkRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tagCtrl = TextEditingController();
  final _yieldCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _sccCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime? _sessionDate;
  String? _session;
  bool _submitting = false;

  static const _sessions = ['Morning', 'Afternoon', 'Evening'];

  @override
  void dispose() {
    _tagCtrl.dispose();
    _yieldCtrl.dispose();
    _fatCtrl.dispose();
    _proteinCtrl.dispose();
    _sccCtrl.dispose();
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
        content: const Text('Milk record saved'),
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
        title: 'Add Milk Record',
        subtitle: 'Record a milking session',
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
                controller: _tagCtrl,
                label: 'Animal Tag / ID *',
                hint: 'e.g. C-001',
                prefixIcon: const Icon(Icons.tag_rounded),
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _FormCard(
              title: 'Session',
              icon: Icons.access_time_rounded,
              child: Column(
                children: [
                  _DateField(
                    label: 'Session Date *',
                    icon: Icons.event_rounded,
                    value: _sessionDate,
                    onPicked: (d) => setState(() => _sessionDate = d),
                    required: true,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: _session,
                    decoration: const InputDecoration(
                      labelText: 'Session *',
                      prefixIcon: Icon(Icons.wb_sunny_outlined),
                    ),
                    hint: const Text('Select session'),
                    isExpanded: true,
                    items: _sessions
                        .map((s) =>
                            DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _session = v),
                    validator: (v) => v == null ? 'Please select session' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _FormCard(
              title: 'Yield',
              icon: Icons.opacity_rounded,
              child: FarmTextField(
                controller: _yieldCtrl,
                label: 'Yield (Litres) *',
                hint: 'e.g. 12.5',
                prefixIcon: const Icon(Icons.local_drink_outlined),
                textInputAction: TextInputAction.next,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                ],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final n = double.tryParse(v);
                  if (n == null || n <= 0) return 'Enter a valid yield';
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _FormCard(
              title: 'Quality (Optional)',
              icon: Icons.science_outlined,
              child: Column(
                children: [
                  FarmTextField(
                    controller: _fatCtrl,
                    label: 'Fat %',
                    hint: 'e.g. 3.8',
                    prefixIcon: const Icon(Icons.percent_rounded),
                    textInputAction: TextInputAction.next,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmTextField(
                    controller: _proteinCtrl,
                    label: 'Protein %',
                    hint: 'e.g. 3.3',
                    prefixIcon: const Icon(Icons.percent_rounded),
                    textInputAction: TextInputAction.next,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmTextField(
                    controller: _sccCtrl,
                    label: 'SCC (cells/mL)',
                    hint: 'e.g. 150000',
                    prefixIcon: const Icon(Icons.biotech_outlined),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ],
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
              label: 'Save Milk Record',
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
