import 'package:flutter/material.dart';
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
import '../data/events_repository.dart';
import '../models/breeding_event.dart';
import 'breeding_events_screen.dart';

class AddBreedingEventScreen extends ConsumerStatefulWidget {
  const AddBreedingEventScreen({super.key});

  @override
  ConsumerState<AddBreedingEventScreen> createState() =>
      _AddBreedingEventScreenState();
}

class _AddBreedingEventScreenState
    extends ConsumerState<AddBreedingEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tagCtrl = TextEditingController();
  final _sireIdCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String? _species;
  String? _selectedAnimalId;
  DateTime? _breedingDate;
  DateTime? _expectedBirthDate;
  String? _breedingMethod;
  bool _submitting = false;

  static const _speciesOptions = [
    'cattle', 'sheep', 'goats', 'pigs', 'horses',
  ];

  static const _methods = [
    'Natural',
    'Artificial Insemination',
    'Embryo Transfer',
  ];

  @override
  void dispose() {
    _tagCtrl.dispose();
    _sireIdCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_breedingDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select a breeding date')));
      return;
    }
    setState(() => _submitting = true);
    try {
      final event = BreedingEvent(
        id: 'BE-${DateTime.now().millisecondsSinceEpoch}',
        animalId: _selectedAnimalId ?? _tagCtrl.text.trim(),
        animalType: _species ?? 'cattle',
        eventType: 'mating',
        serviceDate: DateFormat('yyyy-MM-dd').format(_breedingDate!),
        serviceMethod: _breedingMethod,
        sireName: _sireIdCtrl.text.trim().isEmpty
            ? null
            : _sireIdCtrl.text.trim(),
        expectedBirthDate: _expectedBirthDate == null
            ? null
            : DateFormat('yyyy-MM-dd').format(_expectedBirthDate!),
        notes:
            _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      await ref.read(eventsRepositoryProvider).addBreedingEvent(event);
      ref.invalidate(breedingEventsProvider);
      if (_species != null) {
        ref.invalidate(breedingEventsBySpeciesProvider(_species!));
      }
      if (!mounted) return;
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _species,
                    decoration: const InputDecoration(
                      labelText: 'Species *',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    hint: const Text('Select species'),
                    isExpanded: true,
                    items: _speciesOptions
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child:
                                  Text(s[0].toUpperCase() + s.substring(1)),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() {
                      _species = v;
                      _selectedAnimalId = null;
                    }),
                    validator: (v) => v == null ? 'Select species' : null,
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
                        final animalsAsync =
                            ref.watch(animalsProvider(_species!));
                        return animalsAsync.when(
                          loading: () => const Center(
                              child: CircularProgressIndicator()),
                          error: (_, __) => FarmTextField(
                            controller: _tagCtrl,
                            label: 'Animal Tag / ID *',
                            hint: 'e.g. A-001',
                            prefixIcon: const Icon(Icons.tag_rounded),
                            textInputAction: TextInputAction.next,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                          data: (animals) => DropdownButtonFormField<String>(
                            value: _selectedAnimalId,
                            decoration: const InputDecoration(
                              labelText: 'Select Animal *',
                              prefixIcon: Icon(Icons.tag_rounded),
                            ),
                            hint: const Text('Choose animal'),
                            isExpanded: true,
                            items: animals
                                .map((a) => DropdownMenuItem(
                                      value: a.id,
                                      child: Text(
                                          '${a.tagNumber} — ${a.name}'),
                                    ))
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
