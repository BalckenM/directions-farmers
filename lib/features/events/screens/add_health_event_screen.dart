import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/constants/livestock_constants.dart';
import '../../../shared/widgets/dag_score_selector.dart';
import '../../../shared/widgets/famacha_score_selector.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/farm_text_field.dart';
import '../../../shared/widgets/notifiable_disease_prompt.dart';
import '../../../shared/widgets/primary_button.dart';

// â”€â”€ Screen â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class AddHealthEventScreen extends ConsumerStatefulWidget {
  const AddHealthEventScreen({super.key});

  @override
  ConsumerState<AddHealthEventScreen> createState() =>
      _AddHealthEventScreenState();
}

class _AddHealthEventScreenState
    extends ConsumerState<AddHealthEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tagCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _nextDueCtrl = TextEditingController();
  final _productCtrl = TextEditingController();
  final _withdrawalDaysCtrl = TextEditingController();

  String? _eventType;
  String? _species;
  DateTime? _eventDate;
  int? _famachaScore;
  int? _dagScore;
  bool _submitting = false;

  static const _speciesOptions = [
    'cattle', 'sheep', 'goats', 'pigs', 'horses', 'poultry',
  ];

  bool get _isSheepOrGoats =>
      _species == 'sheep' || _species == 'goats';

  void _onEventTypeChanged(String? type) {
    setState(() => _eventType = type);
    if (type == null || _species == null) return;
    // Check if this event type maps to a notifiable disease for the species
    final diseasesBySpecies =
        LivestockConstants.notifiableDiseasesBySpecies[_species];
    if (diseasesBySpecies == null) return;
    final typeKey = type.toLowerCase().replaceAll(' ', '_');
    final diseaseKey = diseasesBySpecies
        .cast<String?>()
        .firstWhere(
          (d) => d != null && d.contains(typeKey),
          orElse: () => null,
        );
    if (diseaseKey != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        NotifiableDiseasePrompt.show(
          context,
          diseaseKey: diseaseKey,
          onConfirm: () {},
          onDismiss: () {},
        );
      });
    }
  }

  static const _eventTypes = [
    'Vaccination',
    'Treatment',
    'Diagnosis',
    'Routine Check',
    'Deworming',
    'Dipping',
    'Other',
  ];

  @override
  void dispose() {
    _tagCtrl.dispose();
    _notesCtrl.dispose();
    _nextDueCtrl.dispose();
    _productCtrl.dispose();
    _withdrawalDaysCtrl.dispose();
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
        content: const Text('Health event recorded'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm)),
      ),
    );
    context.pop();
  }

  String _calcWithdrawalEnd() {
    final days = int.tryParse(_withdrawalDaysCtrl.text);
    if (days == null || _eventDate == null) {
      return 'select event date first';
    }
    final end = _eventDate!.add(Duration(days: days));
    return '${end.day.toString().padLeft(2, '0')}/${end.month.toString().padLeft(2, '0')}/${end.year}';
  }

  @override
  Widget build(BuildContext context) {
    return FarmScaffold(
      appBar: const FarmAppBar(
        title: 'Add Health Event',
        subtitle: 'Record a treatment or vaccination',
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
              child: Column(
                children: [
                  FarmTextField(
                    controller: _tagCtrl,
                    label: 'Animal Tag / ID *',
                    hint: 'e.g. A-001',
                    prefixIcon: const Icon(Icons.tag_rounded),
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: _species,
                    decoration: const InputDecoration(
                      labelText: 'Species',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    hint: const Text('Select species'),
                    isExpanded: true,
                    items: _speciesOptions
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s[0].toUpperCase() + s.substring(1)),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _species = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _FormCard(
              title: 'Event Details',
              icon: Icons.medical_services_outlined,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _eventType,
                    decoration: const InputDecoration(
                      labelText: 'Event Type *',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    hint: const Text('Select type'),
                    isExpanded: true,
                    items: _eventTypes
                        .map((t) =>
                            DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: _onEventTypeChanged,
                    validator: (v) =>
                        v == null ? 'Please select event type' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _DateField(
                    label: 'Event Date *',
                    icon: Icons.event_rounded,
                    value: _eventDate,
                    onPicked: (d) => setState(() => _eventDate = d),
                    isRequired: true,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmTextField(
                    controller: _productCtrl,
                    label: 'Product / Drug Used',
                    hint: 'e.g. Ivermectin 1%',
                    prefixIcon: const Icon(Icons.vaccines_outlined),
                    textInputAction: TextInputAction.next,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // SA: Withdrawal period
            _FormCard(
              title: 'Withdrawal Period',
              icon: Icons.timer_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FarmTextField(
                    controller: _withdrawalDaysCtrl,
                    label: 'Withdrawal Days',
                    hint: 'Days before slaughter/milk use',
                    prefixIcon: const Icon(Icons.timer_outlined),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                  ),
                  if (_withdrawalDaysCtrl.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Text(
                        'Withdrawal ends: ${_calcWithdrawalEnd()}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // SA: FAMACHA (sheep / goats)
            if (_isSheepOrGoats) ...[  
              const SizedBox(height: AppSpacing.md),
              _FormCard(
                title: 'FAMACHA Score',
                icon: Icons.visibility_outlined,
                child: FamachaScoreSelector(
                  value: _famachaScore,
                  onChanged: (s) => setState(() => _famachaScore = s),
                ),
              ),
            ],
            // SA: DAG score (sheep only)
            if (_species == 'sheep') ...[  
              const SizedBox(height: AppSpacing.md),
              _FormCard(
                title: 'DAG Score (Dags)',
                icon: Icons.grain_rounded,
                child: DagScoreSelector(
                  value: _dagScore,
                  onChanged: (s) => setState(() => _dagScore = s),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            _FormCard(
              title: 'Follow-up',
              icon: Icons.schedule_rounded,
              child: Column(
                children: [
                  _DateField(
                    label: 'Next Due Date',
                    icon: Icons.calendar_today_outlined,
                    value: _nextDueCtrl.text.isNotEmpty
                        ? DateTime.tryParse(_nextDueCtrl.text)
                        : null,
                    onPicked: (d) => setState(() {
                      _nextDueCtrl.text =
                          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                    }),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmTextField(
                    controller: _notesCtrl,
                    label: 'Notes',
                    hint: 'Observations, dosage detailsâ€¦',
                    maxLines: 3,
                    minLines: 2,
                    textInputAction: TextInputAction.done,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              onPressed: _submit,
              label: 'Save Health Event',
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
    bool isRequired = false,
    bool allowFuture = false,
  }) : super(
          initialValue: value,
          validator: (v) {
            if (isRequired && v == null) return 'Please select a date';
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
