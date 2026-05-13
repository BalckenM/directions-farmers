import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/farm_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/poultry_providers.dart';

// â”€â”€ Disease name constants â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _Diseases {
  static const List<String> values = [
    'HPAI (Avian Influenza)',
    'Newcastle Disease',
    'Gumboro (IBD)',
    'Coccidiosis',
    "Marek's Disease",
    'Fowl Cholera',
    'Mycoplasma',
    'Infectious Bronchitis',
    'Fowl Pox',
    'Other',
  ];

  /// Notifiable diseases that require authorities to be contacted.
  static const Set<String> notifiable = {
    'HPAI (Avian Influenza)',
    'Newcastle Disease',
  };
}

class AddDiseaseEventScreen extends ConsumerStatefulWidget {
  const AddDiseaseEventScreen({super.key, required this.flockId});

  final String flockId;

  @override
  ConsumerState<AddDiseaseEventScreen> createState() =>
      _AddDiseaseEventScreenState();
}

class _AddDiseaseEventScreenState
    extends ConsumerState<AddDiseaseEventScreen> {
  final _formKey = GlobalKey<FormState>();

  String _selectedDisease = _Diseases.values.first;
  String _selectedSeverity = 'medium';
  final _affectedCountCtrl = TextEditingController();
  final _symptomsCtrl = TextEditingController();
  final _diagnosticTestCtrl = TextEditingController();
  final _testResultCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _isNotifiable = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _isNotifiable = _Diseases.notifiable.contains(_selectedDisease);
  }

  @override
  void dispose() {
    _affectedCountCtrl.dispose();
    _symptomsCtrl.dispose();
    _diagnosticTestCtrl.dispose();
    _testResultCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _onDiseaseChanged(String? v) {
    if (v == null) return;
    setState(() {
      _selectedDisease = v;
      _isNotifiable = _Diseases.notifiable.contains(v);
    });

    // HPAI emergency overlay
    if (v == 'HPAI (Avian Influenza)') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showHpaiEmergencyDialog();
      });
    }
  }

  void _showHpaiEmergencyDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.error.withAlpha(13),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: const BorderSide(color: AppColors.error, width: 2),
        ),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded,
                color: AppColors.error, size: 28),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'NOTIFIABLE DISEASE',
                style: TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Text(
          'Highly Pathogenic Avian Influenza (HPAI) is a NOTIFIABLE disease.\n\n'
          'â€¢ You MUST report this to the State Veterinarian immediately.\n'
          'â€¢ Implement strict biosecurity and quarantine.\n'
          'â€¢ Do NOT move birds off the property.\n'
          'â€¢ Contact DALRRD: 012 319 7000\n\n'
          'Continue to record the event for traceability.',
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context),
            child: const Text('I Understand â€” Continue Recording'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Second confirmation if notifiable
    if (_isNotifiable) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Notifiable Disease Confirmation'),
          content: Text(
            '$_selectedDisease is a notifiable disease. '
            'Have you reported this to your State Veterinarian?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Not yet'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes, reported'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Disease event recorded: $_selectedDisease'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final flockAsync = ref.watch(flockDetailProvider(widget.flockId));
    final batchName =
        flockAsync.whenOrNull(data: (f) => f?.batchName) ?? 'Flock';

    return FarmScaffold(
      drawer: null,
      appBar: FarmAppBar(title: 'Report Disease Event', subtitle: batchName),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePaddingHorizontal,
            AppSpacing.md,
            AppSpacing.pagePaddingHorizontal,
            AppSpacing.xxl + 80,
          ),
          children: [
            // Notifiable warning banner
            if (_isNotifiable)
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(26),
                  borderRadius: AppRadius.card,
                  border: Border.all(color: AppColors.error),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.error, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'NOTIFIABLE DISEASE â€” Report to State Veterinarian immediately',
                        style: TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                            fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            // â”€â”€ Disease â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _FormSection(
              title: 'Disease / Condition',
              icon: Icons.coronavirus_outlined,
              child: DropdownButtonFormField<String>(
                initialValue: _selectedDisease,
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(),
                ),
                items: _Diseases.values
                    .map((d) => DropdownMenuItem(
                          value: d,
                          child: Row(
                            children: [
                              if (_Diseases.notifiable.contains(d))
                                const Padding(
                                  padding: EdgeInsets.only(right: 6),
                                  child: Icon(Icons.warning_amber,
                                      size: 14, color: AppColors.error),
                                ),
                              Text(d),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: _onDiseaseChanged,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // â”€â”€ Severity â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _FormSection(
              title: 'Severity',
              icon: Icons.thermostat_outlined,
              child: DropdownButtonFormField<String>(
                initialValue: _selectedSeverity,
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                  DropdownMenuItem(
                      value: 'emergency', child: Text('Emergency')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _selectedSeverity = v);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // â”€â”€ Affected Count â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _FormSection(
              title: 'Affected Birds',
              icon: Icons.group_outlined,
              child: FarmTextField(
                controller: _affectedCountCtrl,
                label: 'Number of Birds Affected',
                hint: 'e.g. 12',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (int.tryParse(v) == null) return 'Enter a number';
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // â”€â”€ Symptoms â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _FormSection(
              title: 'Clinical Signs / Symptoms',
              icon: Icons.notes_outlined,
              child: FarmTextField(
                controller: _symptomsCtrl,
                label: 'Observed symptoms',
                hint:
                    'e.g. Reduced appetite, respiratory distress, ruffled feathers...',
                maxLines: 3,
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // â”€â”€ Diagnostic Test â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _FormSection(
              title: 'Diagnostic Test (optional)',
              icon: Icons.science_outlined,
              child: Column(
                children: [
                  FarmTextField(
                    controller: _diagnosticTestCtrl,
                    label: 'Test Type',
                    hint: 'e.g. PCR, serology, post-mortem',
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FarmTextField(
                    controller: _testResultCtrl,
                    label: 'Test Result',
                    hint: 'e.g. Positive â€” H5N1',
                    textInputAction: TextInputAction.next,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // â”€â”€ Notes â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _FormSection(
              title: 'Notes',
              icon: Icons.edit_note_outlined,
              child: FarmTextField(
                controller: _notesCtrl,
                label: 'Additional notes (optional)',
                hint: 'Treatment actions taken, vet consulted...',
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            PrimaryButton(
              label: 'Record Disease Event',
              isLoading: _isSubmitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€ Form section wrapper â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _FormSection extends StatelessWidget {
  const _FormSection({
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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(80)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.poultryColor),
                const SizedBox(width: AppSpacing.xs),
                Text(title,
                    style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.poultryColor)),
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
