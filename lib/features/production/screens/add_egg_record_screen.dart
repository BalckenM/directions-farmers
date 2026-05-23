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
import '../../livestock/providers/groups_provider.dart';
import '../data/production_repository.dart';
import '../models/egg_record.dart';
import 'egg_records_screen.dart';

class AddEggRecordScreen extends ConsumerStatefulWidget {
  const AddEggRecordScreen({super.key});

  @override
  ConsumerState<AddEggRecordScreen> createState() =>
      _AddEggRecordScreenState();
}

class _AddEggRecordScreenState extends ConsumerState<AddEggRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _collectedCtrl = TextEditingController();
  final _brokenCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String? _selectedGroupId;
  DateTime? _collectionDate;
  String? _session;
  String? _grade;
  bool _submitting = false;

  static const _sessions = ['Morning', 'Afternoon', 'Evening'];
  static const _grades = ['Small', 'Medium', 'Large', 'Extra Large', 'Mixed'];

  @override
  void dispose() {
    _collectedCtrl.dispose();
    _brokenCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_collectionDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select a collection date')));
      return;
    }
    setState(() => _submitting = true);
    try {
      final record = EggRecord(
        id: 'ER-${DateTime.now().millisecondsSinceEpoch}',
        flockId: _selectedGroupId ?? '',
        collectionDate: DateFormat('yyyy-MM-dd').format(_collectionDate!),
        collectionSession: _session ?? 'Morning',
        eggsCollected: int.tryParse(_collectedCtrl.text) ?? 0,
        eggsBroken: _brokenCtrl.text.trim().isEmpty
            ? null
            : int.tryParse(_brokenCtrl.text),
      );
      await ref.read(productionRepositoryProvider).addEggRecord(record);
      ref.invalidate(eggRecordsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Egg record saved'),
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
        title: 'Add Egg Record',
        subtitle: 'Record egg collection',
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
              title: 'Flock',
              icon: Icons.egg_outlined,
              child: Consumer(
                builder: (context, ref, _) {
                  final groupsAsync = ref.watch(groupsProvider);
                  return groupsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (groups) {
                      final flocks = groups
                          .where((g) =>
                              g.species.toLowerCase() == 'poultry')
                          .toList();
                      return DropdownButtonFormField<String>(
                        value: _selectedGroupId,
                        decoration: const InputDecoration(
                          labelText: 'Select Flock *',
                          prefixIcon: Icon(Icons.group_outlined),
                        ),
                        hint: const Text('Choose flock'),
                        isExpanded: true,
                        items: (flocks.isEmpty ? groups : flocks)
                            .map((g) => DropdownMenuItem(
                                  value: g.id,
                                  child: Text(g.name),
                                ))
                            .toList(),
                        onChanged: (id) =>
                            setState(() => _selectedGroupId = id),
                        validator: (v) =>
                            v == null ? 'Select a flock' : null,
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _FormCard(
              title: 'Collection',
              icon: Icons.access_time_rounded,
              child: Column(
                children: [
                  _DateField(
                    label: 'Collection Date *',
                    icon: Icons.event_rounded,
                    value: _collectionDate,
                    onPicked: (d) => setState(() => _collectionDate = d),
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
              title: 'Count',
              icon: Icons.format_list_numbered_rounded,
              child: Column(
                children: [
                  FarmTextField(
                    controller: _collectedCtrl,
                    label: 'Eggs Collected *',
                    hint: 'e.g. 180',
                    prefixIcon: const Icon(Icons.egg_alt_outlined),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final n = int.tryParse(v);
                      if (n == null || n < 0) return 'Enter a valid count';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmTextField(
                    controller: _brokenCtrl,
                    label: 'Eggs Broken',
                    hint: 'e.g. 3',
                    prefixIcon: const Icon(Icons.egg_outlined),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _FormCard(
              title: 'Grade (Optional)',
              icon: Icons.grade_outlined,
              child: DropdownButtonFormField<String>(
                initialValue: _grade,
                decoration: const InputDecoration(
                  labelText: 'Egg Grade',
                  prefixIcon: Icon(Icons.star_outline_rounded),
                ),
                hint: const Text('Select grade'),
                isExpanded: true,
                items: _grades
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => _grade = v),
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
              label: 'Save Egg Record',
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
