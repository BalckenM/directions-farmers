import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/date_picker_field.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_dropdown.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/farm_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../models/wool_record.dart';

class AddWoolRecordScreen extends ConsumerStatefulWidget {
  const AddWoolRecordScreen({super.key});

  @override
  ConsumerState<AddWoolRecordScreen> createState() =>
      _AddWoolRecordScreenState();
}

class _AddWoolRecordScreenState extends ConsumerState<AddWoolRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _animalIdCtrl = TextEditingController();
  final _gfwCtrl = TextEditingController();
  final _skirtedCtrl = TextEditingController();
  final _micronCtrl = TextEditingController();
  final _stapleLenCtrl = TextEditingController();
  final _stapleStrCtrl = TextEditingController();
  final _vmCtrl = TextEditingController();
  final _yieldCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _baleCtrl = TextEditingController();
  final _teamCertCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // State
  DateTime? _shearingDate;
  WoolColorGrade? _colorGrade;
  WoolBuyer? _woolBuyer;
  bool _isMohair = false;
  bool _submitting = false;

  @override
  void dispose() {
    _animalIdCtrl.dispose();
    _gfwCtrl.dispose();
    _skirtedCtrl.dispose();
    _micronCtrl.dispose();
    _stapleLenCtrl.dispose();
    _stapleStrCtrl.dispose();
    _vmCtrl.dispose();
    _yieldCtrl.dispose();
    _priceCtrl.dispose();
    _baleCtrl.dispose();
    _teamCertCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_shearingDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a shearing date')),
      );
      return;
    }
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(_isMohair ? 'Mohair record saved' : 'Wool record saved'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FarmScaffold(
      appBar: FarmAppBar(
        title: _isMohair ? 'Add Mohair Record' : 'Add Wool Record',
        subtitle: 'Shearing & grading details',
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
            // Type toggle
            _FormCard(
              title: 'Fleece Type',
              icon: Icons.content_cut_rounded,
              child: SwitchListTile(
                value: _isMohair,
                onChanged: (v) => setState(() => _isMohair = v),
                title: const Text('Mohair record'),
                subtitle: Text(
                  _isMohair
                      ? 'Angora goat mohair'
                      : 'Sheep wool (Merino, Dohne, etc.)',
                  style: theme.textTheme.bodySmall,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Animal / Date
            _FormCard(
              title: 'Animal & Date',
              icon: Icons.pets_rounded,
              child: Column(
                children: [
                  FarmTextField(
                    controller: _animalIdCtrl,
                    label: 'Animal Tag / ID',
                    hint: 'e.g. S-042 or leave blank for group',
                    prefixIcon: const Icon(Icons.tag_rounded),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DatePickerField(
                    label: 'Shearing Date *',
                    value: _shearingDate,
                    onChanged: (d) => setState(() => _shearingDate = d),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Fleece weight
            _FormCard(
              title: 'Fleece Weight',
              icon: Icons.scale_rounded,
              child: Column(
                children: [
                  FarmTextField(
                    controller: _gfwCtrl,
                    label: 'Greasy Fleece Weight (kg) *',
                    hint: 'e.g. 4.8',
                    prefixIcon: const Icon(Icons.scale_rounded),
                    textInputAction: TextInputAction.next,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final n = double.tryParse(v);
                      if (n == null || n <= 0) return 'Enter a valid weight';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmTextField(
                    controller: _skirtedCtrl,
                    label: 'Skirted Weight (kg)',
                    hint: 'e.g. 4.2',
                    prefixIcon: const Icon(Icons.scale_outlined),
                    textInputAction: TextInputAction.next,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Quality metrics
            _FormCard(
              title: 'Quality Metrics',
              icon: Icons.science_outlined,
              child: Column(
                children: [
                  FarmTextField(
                    controller: _micronCtrl,
                    label: _isMohair
                        ? 'Mean Fibre Diameter (µm)'
                        : 'Wool Micron (µm)',
                    hint: _isMohair ? 'e.g. 23.5' : 'e.g. 19.5',
                    prefixIcon: const Icon(Icons.blur_on_rounded),
                    textInputAction: TextInputAction.next,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmTextField(
                    controller: _stapleLenCtrl,
                    label: 'Staple Length (mm)',
                    hint: 'e.g. 78',
                    prefixIcon: const Icon(Icons.straighten_rounded),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmTextField(
                    controller: _stapleStrCtrl,
                    label: 'Staple Strength (N/ktex)',
                    hint: 'e.g. 38',
                    prefixIcon: const Icon(Icons.fitness_center_rounded),
                    textInputAction: TextInputAction.next,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmTextField(
                    controller: _vmCtrl,
                    label: 'Vegetable Matter (%)',
                    hint: 'e.g. 0.4',
                    prefixIcon: const Icon(Icons.grass_rounded),
                    textInputAction: TextInputAction.next,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmTextField(
                    controller: _yieldCtrl,
                    label: 'Yield (%)',
                    hint: 'e.g. 64.5',
                    prefixIcon: const Icon(Icons.percent_rounded),
                    textInputAction: TextInputAction.next,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmDropdown<WoolColorGrade>(
                    label: 'Colour Grade',
                    value: _colorGrade,
                    items: const [
                      DropdownMenuItem(
                        value: WoolColorGrade.aa,
                        child: Text('AA — Best white'),
                      ),
                      DropdownMenuItem(
                        value: WoolColorGrade.a,
                        child: Text('A — White'),
                      ),
                      DropdownMenuItem(
                        value: WoolColorGrade.b,
                        child: Text('B — Slight discolouration'),
                      ),
                      DropdownMenuItem(
                        value: WoolColorGrade.c,
                        child: Text('C — Discoloured'),
                      ),
                    ],
                    onChanged: (v) => setState(() => _colorGrade = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Sale details
            _FormCard(
              title: 'Sale Details',
              icon: Icons.payments_rounded,
              child: Column(
                children: [
                  FarmDropdown<WoolBuyer>(
                    label: 'Wool Buyer',
                    value: _woolBuyer,
                    items: const [
                      DropdownMenuItem(
                          value: WoolBuyer.bkb, child: Text('BKB')),
                      DropdownMenuItem(
                          value: WoolBuyer.capeWoolsSa,
                          child: Text('Cape Wools SA')),
                      DropdownMenuItem(
                          value: WoolBuyer.agriBest,
                          child: Text('Agri-Best')),
                      DropdownMenuItem(
                          value: WoolBuyer.nedwool,
                          child: Text('Nedwool')),
                      DropdownMenuItem(
                          value: WoolBuyer.capeMohairAuction,
                          child: Text('Cape Mohair Auction')),
                      DropdownMenuItem(
                          value: WoolBuyer.samcra,
                          child: Text('SAMCRA')),
                      DropdownMenuItem(
                          value: WoolBuyer.other, child: Text('Other')),
                    ],
                    onChanged: (v) => setState(() => _woolBuyer = v),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmTextField(
                    controller: _priceCtrl,
                    label: 'Price per kg (ZAR)',
                    hint: 'e.g. 132.50',
                    prefixIcon: const Icon(Icons.currency_exchange_rounded),
                    textInputAction: TextInputAction.next,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmTextField(
                    controller: _baleCtrl,
                    label: 'Bale Number',
                    hint: 'e.g. BL-2025-001',
                    prefixIcon: const Icon(Icons.inventory_2_outlined),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmTextField(
                    controller: _teamCertCtrl,
                    label: 'TEAM Certification Ref',
                    hint: 'Cape Wools SA TEAM ref',
                    prefixIcon: const Icon(Icons.verified_outlined),
                    textInputAction: TextInputAction.next,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Notes
            _FormCard(
              title: 'Notes',
              icon: Icons.notes_rounded,
              child: FarmTextField(
                controller: _notesCtrl,
                label: 'Notes',
                hint: 'Any additional observations...',
                maxLines: 4,
                minLines: 2,
                textInputAction: TextInputAction.newline,
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: _isMohair ? 'Save Mohair Record' : 'Save Wool Record',
              onPressed: _submit,
              isLoading: _submitting,
              isExpanded: true,
              icon: const Icon(Icons.save_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Form card helper ──────────────────────────────────────────────────────────

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
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.primary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
