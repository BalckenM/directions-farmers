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
import '../models/group.dart';
import '../providers/groups_provider.dart';

class AddEditGroupScreen extends ConsumerStatefulWidget {
  const AddEditGroupScreen({super.key, this.groupId});
  final String? groupId;

  @override
  ConsumerState<AddEditGroupScreen> createState() => _AddEditGroupScreenState();
}

class _AddEditGroupScreenState extends ConsumerState<AddEditGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  String? _species;
  String? _purpose;
  bool _submitting = false;
  Group? _existing;

  static const _speciesOptions = [
    'cattle', 'goats', 'sheep', 'pigs', 'poultry',
    'horses', 'rabbits', 'aquaculture', 'bees',
  ];

  static const _purposeOptions = [
    'dairy', 'beef', 'breeding', 'meat', 'egg_production',
    'wool', 'honey', 'aquaculture', 'mixed',
  ];

  bool get _isEdit => widget.groupId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
    }
  }

  void _loadExisting() {
    final localStore = ref.read(localGroupStoreProvider);
    final existing = localStore[widget.groupId];
    if (existing != null) {
      _existing = existing;
      _populate(existing);
    }
  }

  void _populate(Group g) {
    _nameCtrl.text = g.name;
    _locationCtrl.text = g.location ?? '';
    _descriptionCtrl.text = g.description ?? '';
    setState(() {
      _species = g.species;
      _purpose = g.purpose;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    final store = ref.read(localGroupStoreProvider.notifier);
    final id = _existing?.id ??
        'grp_${DateTime.now().millisecondsSinceEpoch}';
    final group = Group(
      id: id,
      farmId: _existing?.farmId ?? 'farm_001',
      name: _nameCtrl.text.trim(),
      species: _species!,
      animalCount: _existing?.animalCount ?? 0,
      purpose: _purpose,
      location: _locationCtrl.text.trim().isEmpty
          ? null
          : _locationCtrl.text.trim(),
      description: _descriptionCtrl.text.trim().isEmpty
          ? null
          : _descriptionCtrl.text.trim(),
      avgWeightKg: _existing?.avgWeightKg,
      avgAgeMonths: _existing?.avgAgeMonths,
    );

    if (_isEdit) {
      store.updateGroup(group);
    } else {
      store.addGroup(group);
    }

    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEdit ? 'Group updated' : 'Group created'),
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
      appBar: FarmAppBar(
        title: _isEdit ? 'Edit Group' : 'New Group',
        subtitle: _isEdit ? 'Update group details' : 'Create an animal group',
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
              title: 'Basic Info',
              icon: Icons.info_outline_rounded,
              child: Column(
                children: [
                  FarmTextField(
                    controller: _nameCtrl,
                    label: 'Group Name *',
                    hint: 'e.g. Dairy Herd A',
                    prefixIcon: const Icon(Icons.group_rounded),
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: _species,
                    decoration: const InputDecoration(
                      labelText: 'Species *',
                      prefixIcon: Icon(Icons.pets_rounded),
                    ),
                    hint: const Text('Select species'),
                    isExpanded: true,
                    items: _speciesOptions
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(
                                  s[0].toUpperCase() + s.substring(1)),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _species = v),
                    validator: (v) =>
                        v == null ? 'Please select species' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _FormCard(
              title: 'Details',
              icon: Icons.tune_rounded,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _purpose,
                    decoration: const InputDecoration(
                      labelText: 'Purpose',
                      prefixIcon: Icon(Icons.flag_outlined),
                    ),
                    hint: const Text('Select purpose'),
                    isExpanded: true,
                    items: _purposeOptions
                        .map((p) => DropdownMenuItem(
                              value: p,
                              child: Text(p
                                  .replaceAll('_', ' ')
                                  .split(' ')
                                  .map((w) =>
                                      w[0].toUpperCase() + w.substring(1))
                                  .join(' ')),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _purpose = v),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmTextField(
                    controller: _locationCtrl,
                    label: 'Location / Paddock',
                    hint: 'e.g. North Paddock',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    textInputAction: TextInputAction.next,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _FormCard(
              title: 'Description',
              icon: Icons.notes_rounded,
              child: FarmTextField(
                controller: _descriptionCtrl,
                label: 'Description',
                hint: 'Any notes about this group…',
                maxLines: 3,
                minLines: 2,
                textInputAction: TextInputAction.done,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              onPressed: _submit,
              label: _isEdit ? 'Update Group' : 'Create Group',
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
