import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/date_picker_field.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_dropdown.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/farm_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../data/traceability_repository.dart';
import '../models/movement_record.dart';
import 'movement_records_screen.dart';

class AddMovementRecordScreen extends ConsumerStatefulWidget {
  const AddMovementRecordScreen({super.key});

  @override
  ConsumerState<AddMovementRecordScreen> createState() =>
      _AddMovementRecordScreenState();
}

class _AddMovementRecordScreenState
    extends ConsumerState<AddMovementRecordScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _fromLocationCtrl = TextEditingController();
  final _toLocationCtrl = TextEditingController();
  final _fromRegNoCtrl = TextEditingController();
  final _toRegNoCtrl = TextEditingController();
  final _transporterCtrl = TextEditingController();
  final _vehicleRegCtrl = TextEditingController();
  final _permitNoCtrl = TextEditingController();
  final _vetCertCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // State
  DateTime? _movementDate;
  String? _species;
  MovementType? _movementType;
  bool _rmisSubmitted = false;
  bool _submitting = false;

  static const _speciesOptions = [
    'cattle',
    'sheep',
    'goats',
    'pigs',
    'horses',
    'poultry',
  ];

  bool get _requiresVetCert =>
      _movementType == MovementType.farmToAuction ||
      _movementType == MovementType.exportToAbroad ||
      _movementType == MovementType.importFromAbroad;

  @override
  void dispose() {
    _fromLocationCtrl.dispose();
    _toLocationCtrl.dispose();
    _fromRegNoCtrl.dispose();
    _toRegNoCtrl.dispose();
    _transporterCtrl.dispose();
    _vehicleRegCtrl.dispose();
    _permitNoCtrl.dispose();
    _vetCertCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_movementDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a movement date')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final record = MovementRecord(
        id: 'MR-${DateTime.now().millisecondsSinceEpoch}',
        farmId: 'FARM-001',
        movementDate: DateFormat('yyyy-MM-dd').format(_movementDate!),
        species: _species ?? 'cattle',
        animalIds: const [],
        movementType: _movementType!,
        fromLocation: _fromLocationCtrl.text.trim(),
        toLocation: _toLocationCtrl.text.trim(),
        fromFarmRegistrationNo: _fromRegNoCtrl.text.trim().isEmpty
            ? null
            : _fromRegNoCtrl.text.trim(),
        toFarmRegistrationNo:
            _toRegNoCtrl.text.trim().isEmpty ? null : _toRegNoCtrl.text.trim(),
        transporterName: _transporterCtrl.text.trim().isEmpty
            ? null
            : _transporterCtrl.text.trim(),
        vehicleRegNo: _vehicleRegCtrl.text.trim().isEmpty
            ? null
            : _vehicleRegCtrl.text.trim(),
        permitNumber: _permitNoCtrl.text.trim().isEmpty
            ? null
            : _permitNoCtrl.text.trim(),
        veterinaryHealthCertRef: _vetCertCtrl.text.trim().isEmpty
            ? null
            : _vetCertCtrl.text.trim(),
        rmisSubmitted: _rmisSubmitted,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      await ref
          .read(traceabilityRepositoryProvider)
          .addMovementRecord(record);
      ref.invalidate(movementRecordsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('B313 movement record saved'),
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FarmScaffold(
      appBar: const FarmAppBar(
        title: 'New B313 Movement Permit',
        subtitle: 'SA livestock movement record',
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
            // RMIS notice
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.tertiaryContainer,
                borderRadius: AppRadius.card,
                border: Border.all(color: AppColors.tertiary.withAlpha(77)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: AppColors.tertiary),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'All movements must be submitted to RMIS per the Animal Diseases Act 35/1984.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.tertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Movement details
            _FormCard(
              title: 'Movement Details',
              icon: Icons.swap_horiz_rounded,
              child: Column(
                children: [
                  DatePickerField(
                    label: 'Movement Date *',
                    value: _movementDate,
                    onChanged: (d) => setState(() => _movementDate = d),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmDropdown<String>(
                    label: 'Species *',
                    value: _species,
                    items: _speciesOptions
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(
                                s[0].toUpperCase() + s.substring(1),
                              ),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _species = v),
                    validator: (v) =>
                        v == null ? 'Please select species' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmDropdown<MovementType>(
                    label: 'Movement Type *',
                    value: _movementType,
                    items: const [
                      DropdownMenuItem(
                        value: MovementType.farmToFarm,
                        child: Text('Farm to Farm'),
                      ),
                      DropdownMenuItem(
                        value: MovementType.farmToAbattoir,
                        child: Text('Farm to Abattoir'),
                      ),
                      DropdownMenuItem(
                        value: MovementType.farmToAuction,
                        child: Text('Farm to Auction'),
                      ),
                      DropdownMenuItem(
                        value: MovementType.auctionToFarm,
                        child: Text('Auction to Farm'),
                      ),
                      DropdownMenuItem(
                        value: MovementType.importFromAbroad,
                        child: Text('Import from Abroad'),
                      ),
                      DropdownMenuItem(
                        value: MovementType.exportToAbroad,
                        child: Text('Export to Abroad'),
                      ),
                    ],
                    onChanged: (v) => setState(() => _movementType = v),
                    validator: (v) =>
                        v == null ? 'Please select movement type' : null,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // From / To locations
            _FormCard(
              title: 'Locations',
              icon: Icons.place_rounded,
              child: Column(
                children: [
                  FarmTextField(
                    controller: _fromLocationCtrl,
                    label: 'From Location *',
                    hint: 'Farm name or auction',
                    prefixIcon: const Icon(Icons.arrow_upward_rounded),
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmTextField(
                    controller: _fromRegNoCtrl,
                    label: 'From Farm Reg. No. (DLRD)',
                    hint: 'e.g. LP-CR-0042',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmTextField(
                    controller: _toLocationCtrl,
                    label: 'To Location *',
                    hint: 'Farm name, abattoir or auction',
                    prefixIcon: const Icon(Icons.arrow_downward_rounded),
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmTextField(
                    controller: _toRegNoCtrl,
                    label: 'To Farm Reg. No. (DLRD)',
                    hint: 'e.g. LP-LM-0179',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    textInputAction: TextInputAction.next,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Transport
            _FormCard(
              title: 'Transport',
              icon: Icons.local_shipping_rounded,
              child: Column(
                children: [
                  FarmTextField(
                    controller: _transporterCtrl,
                    label: 'Transporter Name',
                    hint: 'Company or individual',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmTextField(
                    controller: _vehicleRegCtrl,
                    label: 'Vehicle Reg. No.',
                    hint: 'e.g. HH 23456 LP',
                    prefixIcon: const Icon(Icons.directions_car_outlined),
                    textInputAction: TextInputAction.next,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Permit & certification
            _FormCard(
              title: 'Permit & Certification',
              icon: Icons.receipt_long_outlined,
              child: Column(
                children: [
                  FarmTextField(
                    controller: _permitNoCtrl,
                    label: 'B313 Permit Number',
                    hint: 'e.g. B313-2025-LP-001234',
                    prefixIcon: const Icon(Icons.article_outlined),
                    textInputAction: TextInputAction.next,
                  ),
                  if (_requiresVetCert) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.warningContainer,
                        borderRadius: AppRadius.fromRadius(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              size: 14, color: AppColors.warning),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'A Veterinary Health Certificate is required for this movement type.',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FarmTextField(
                      controller: _vetCertCtrl,
                      label: 'Vet Health Certificate Ref',
                      hint: 'e.g. VHC-LP-2025-0456',
                      prefixIcon: const Icon(Icons.verified_outlined),
                      textInputAction: TextInputAction.next,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  SwitchListTile(
                    value: _rmisSubmitted,
                    onChanged: (v) => setState(() => _rmisSubmitted = v),
                    title: const Text('Submitted to RMIS'),
                    subtitle: Text(
                      _rmisSubmitted
                          ? 'Movement recorded in RMIS'
                          : 'Pending RMIS submission',
                      style: theme.textTheme.bodySmall,
                    ),
                    contentPadding: EdgeInsets.zero,
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
                hint: 'Health status, conditions, observations...',
                maxLines: 4,
                minLines: 2,
                textInputAction: TextInputAction.newline,
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: 'Save Movement Record',
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
