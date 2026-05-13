import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../models/poultry_flock.dart';
import '../providers/poultry_providers.dart';

class EditFlockScreen extends ConsumerStatefulWidget {
  const EditFlockScreen({super.key, required this.flockId});

  final String flockId;

  @override
  ConsumerState<EditFlockScreen> createState() => _EditFlockScreenState();
}

class _EditFlockScreenState extends ConsumerState<EditFlockScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _batchNameCtrl;
  late TextEditingController _strainCtrl;
  late TextEditingController _houseIdCtrl;
  late TextEditingController _placementDateCtrl;
  late TextEditingController _projectedSlaughterCtrl;
  late TextEditingController _targetWeightCtrl;

  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _batchNameCtrl.dispose();
    _strainCtrl.dispose();
    _houseIdCtrl.dispose();
    _placementDateCtrl.dispose();
    _projectedSlaughterCtrl.dispose();
    _targetWeightCtrl.dispose();
    super.dispose();
  }

  void _initControllers(PoultryFlock flock) {
    if (_initialized) return;
    _initialized = true;
    _batchNameCtrl = TextEditingController(text: flock.batchName);
    _strainCtrl = TextEditingController(text: flock.strain);
    _houseIdCtrl = TextEditingController(text: flock.houseId);
    _placementDateCtrl = TextEditingController(text: flock.placementDate);
    _projectedSlaughterCtrl = TextEditingController(
        text: flock.projectedSlaughterDate ?? '');
    _targetWeightCtrl = TextEditingController(
        text: flock.targetSlaughterWeightG?.toString() ?? '');
  }

  Future<void> _pickDate({
    required TextEditingController ctrl,
    required String helpText,
  }) async {
    final init = DateTime.tryParse(ctrl.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1825)),
      helpText: helpText,
    );
    if (picked != null) {
      ctrl.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final fields = <String, dynamic>{
      'batchName': _batchNameCtrl.text.trim(),
      'strain': _strainCtrl.text.trim(),
      'houseId': _houseIdCtrl.text.trim(),
      'placementDate': _placementDateCtrl.text.trim(),
    };

    final slaughter = _projectedSlaughterCtrl.text.trim();
    if (slaughter.isNotEmpty) fields['projectedSlaughterDate'] = slaughter;

    final targetWt = int.tryParse(_targetWeightCtrl.text.trim());
    if (targetWt != null) fields['targetSlaughterWeightG'] = targetWt;

    ref.read(flockEditProvider.notifier).update(widget.flockId, fields);

    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Flock details updated'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncFlock =
        ref.watch(flockDetailProvider(widget.flockId));

    return asyncFlock.when(
      loading: () => FarmScaffold(
        drawer: null,
        appBar: const FarmAppBar(title: 'Edit Flock'),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => FarmScaffold(
        drawer: null,
        appBar: const FarmAppBar(title: 'Edit Flock'),
        body: Center(child: Text('Error: $e')),
      ),
      data: (flock) {
        if (flock == null) {
          return FarmScaffold(
            drawer: null,
            appBar: const FarmAppBar(title: 'Edit Flock'),
            body: const Center(child: Text('Flock not found')),
          );
        }
        _initControllers(flock);

        return FarmScaffold(
          drawer: null,
          appBar: FarmAppBar(
            title: 'Edit Flock',
            subtitle: flock.batchName,
            actions: [
              TextButton(
                onPressed: _saving ? null : _save,
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: AppColors.poultryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePaddingHorizontal,
                vertical: 16,
              ),
              children: [
                // ── Identity ────────────────────────────────────────────────
                _SectionHeader(label: 'Identity'),
                const SizedBox(height: 12),
                _FieldCard(
                  child: Column(
                    children: [
                      _FormField(
                        controller: _batchNameCtrl,
                        label: 'Batch / Flock Name',
                        icon: Icons.label_outline,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Name is required'
                                : null,
                      ),
                      const _Divider(),
                      _FormField(
                        controller: _strainCtrl,
                        label: 'Strain / Breed',
                        icon: Icons.biotech_outlined,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Strain is required'
                                : null,
                      ),
                    ],
                  ),
                ),

                // ── Read-only info ──────────────────────────────────────────
                const SizedBox(height: 16),
                _SectionHeader(label: 'Production Info'),
                const SizedBox(height: 12),
                _FieldCard(
                  child: Column(
                    children: [
                      _ReadOnlyTile(
                        label: 'Production Type',
                        value: flock.productionType,
                        icon: Icons.category_outlined,
                      ),
                      const _Divider(),
                      _ReadOnlyTile(
                        label: 'Species',
                        value: flock.species,
                        icon: Icons.pets_outlined,
                      ),
                      const _Divider(),
                      _ReadOnlyTile(
                        label: 'Placement Count',
                        value: '${flock.placementCount} birds',
                        icon: Icons.numbers_outlined,
                      ),
                    ],
                  ),
                ),

                // ── Housing ─────────────────────────────────────────────────
                const SizedBox(height: 16),
                _SectionHeader(label: 'Housing'),
                const SizedBox(height: 12),
                _FieldCard(
                  child: _FormField(
                    controller: _houseIdCtrl,
                    label: 'House / Pen ID',
                    icon: Icons.home_work_outlined,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'House ID is required'
                            : null,
                  ),
                ),

                // ── Dates ───────────────────────────────────────────────────
                const SizedBox(height: 16),
                _SectionHeader(label: 'Dates'),
                const SizedBox(height: 12),
                _FieldCard(
                  child: Column(
                    children: [
                      _DateField(
                        controller: _placementDateCtrl,
                        label: 'Placement Date',
                        icon: Icons.event_outlined,
                        helpText: 'Select placement date',
                        onTap: () => _pickDate(
                          ctrl: _placementDateCtrl,
                          helpText: 'Select placement date',
                        ),
                      ),
                      const _Divider(),
                      _DateField(
                        controller: _projectedSlaughterCtrl,
                        label: 'Projected Slaughter / Close Date',
                        icon: Icons.event_available_outlined,
                        helpText: 'Select projected date',
                        optional: true,
                        onTap: () => _pickDate(
                          ctrl: _projectedSlaughterCtrl,
                          helpText: 'Select projected slaughter date',
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Targets ─────────────────────────────────────────────────
                const SizedBox(height: 16),
                _SectionHeader(label: 'Targets'),
                const SizedBox(height: 12),
                _FieldCard(
                  child: _FormField(
                    controller: _targetWeightCtrl,
                    label: 'Target Slaughter Weight (g)',
                    icon: Icons.monitor_weight_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    optional: true,
                  ),
                ),

                const SizedBox(height: 32),

                // ── Save ────────────────────────────────────────────────────
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.poultryColor,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.card),
                  ),
                  onPressed: _saving ? null : _save,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save Changes',
                      style: TextStyle(fontSize: 16)),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: child,
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: Theme.of(context).colorScheme.outlineVariant.withAlpha(128),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.optional = false,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: optional ? '$label (optional)' : label,
          prefixIcon: Icon(icon, size: 20),
          border: InputBorder.none,
          isDense: true,
        ),
        validator: validator,
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.helpText,
    required this.onTap,
    this.optional = false,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String helpText;
  final VoidCallback onTap;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: optional ? '$label (optional)' : label,
          prefixIcon: Icon(icon, size: 20),
          suffixIcon:
              const Icon(Icons.calendar_today_outlined, size: 16),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}

class _ReadOnlyTile extends StatelessWidget {
  const _ReadOnlyTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Icon(Icons.lock_outline,
              size: 14, color: theme.colorScheme.outlineVariant),
        ],
      ),
    );
  }
}
