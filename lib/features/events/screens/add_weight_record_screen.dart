import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/farm_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../livestock/providers/livestock_providers.dart';
import '../models/weight_record.dart';
import '../providers/events_action_providers.dart';

class AddWeightRecordScreen extends ConsumerStatefulWidget {
  const AddWeightRecordScreen({super.key});

  @override
  ConsumerState<AddWeightRecordScreen> createState() =>
      _AddWeightRecordScreenState();
}

class _AddWeightRecordScreenState extends ConsumerState<AddWeightRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tagCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  static const _speciesOptions = [
    'cattle',
    'sheep',
    'goats',
    'pigs',
    'horses',
    'poultry',
  ];

  String? _species;
  String? _selectedAnimalId;
  DateTime? _weighDate;
  bool _submitting = false;

  @override
  void dispose() {
    _tagCtrl.dispose();
    _weightCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final record = WeightRecord(
        id: 'WR-${DateTime.now().millisecondsSinceEpoch}',
        animalId: _selectedAnimalId ?? _tagCtrl.text.trim(),
        animalType: _species ?? 'cattle',
        weighDate: _weighDate != null
            ? DateFormat('yyyy-MM-dd').format(_weighDate!)
            : DateFormat('yyyy-MM-dd').format(DateTime.now()),
        weightKg: double.tryParse(_weightCtrl.text) ?? 0.0,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      await ref.read(eventsActionProvider.notifier).addWeightRecord(record);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Weight record saved'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FarmScaffold(
      appBar: const FarmAppBar(
        title: 'Add Weight Record',
        subtitle: 'Record body weight',
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
                  DropdownButtonFormField<String>(
                    initialValue: _species,
                    decoration: const InputDecoration(
                      labelText: 'Species',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    hint: const Text('Select species'),
                    isExpanded: true,
                    items: _speciesOptions
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(s[0].toUpperCase() + s.substring(1)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() {
                      _species = v;
                      _selectedAnimalId = null;
                    }),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_species == null)
                    FarmTextField(
                      controller: _tagCtrl,
                      label: 'Animal Tag / ID *',
                      hint: 'Select species first',
                      prefixIcon: const Icon(Icons.tag_rounded),
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    )
                  else
                    Consumer(
                      builder: (context, ref, _) {
                        final animalsAsync = ref.watch(
                          animalsProvider(_species!),
                        );
                        return animalsAsync.when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (_, _) => FarmTextField(
                            controller: _tagCtrl,
                            label: 'Animal Tag / ID *',
                            hint: 'e.g. C-001',
                            prefixIcon: const Icon(Icons.tag_rounded),
                            textInputAction: TextInputAction.next,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                          data: (animals) => DropdownButtonFormField<String>(
                            initialValue: _selectedAnimalId,
                            decoration: const InputDecoration(
                              labelText: 'Select Animal *',
                              prefixIcon: Icon(Icons.tag_rounded),
                            ),
                            hint: const Text('Choose animal'),
                            isExpanded: true,
                            items: animals
                                .map(
                                  (a) => DropdownMenuItem(
                                    value: a.id,
                                    child: Text('${a.tagNumber} — ${a.name}'),
                                  ),
                                )
                                .toList(),
                            onChanged: (id) => setState(() {
                              _selectedAnimalId = id;
                              _tagCtrl.text = id ?? '';
                            }),
                            validator: (v) =>
                                v == null ? 'Select an animal' : null,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _FormCard(
              title: 'Weigh-In',
              icon: Icons.monitor_weight_outlined,
              child: Column(
                children: [
                  _DateField(
                    label: 'Date *',
                    icon: Icons.event_rounded,
                    value: _weighDate,
                    onPicked: (d) => setState(() => _weighDate = d),
                    required: true,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmTextField(
                    controller: _weightCtrl,
                    label: 'Weight (kg) *',
                    hint: 'e.g. 245.5',
                    prefixIcon: const Icon(Icons.scale_rounded),
                    textInputAction: TextInputAction.next,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                    ],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final n = double.tryParse(v);
                      if (n == null || n <= 0) return 'Enter a valid weight';
                      return null;
                    },
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
              label: 'Save Weight Record',
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
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(padding: const EdgeInsets.all(AppSpacing.md), child: child),
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
               child: Text(text ?? '', style: theme.textTheme.bodyMedium),
             ),
           );
         },
       );
}
