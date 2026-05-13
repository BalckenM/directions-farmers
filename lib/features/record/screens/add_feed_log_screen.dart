import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/date_picker_field.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/farm_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import 'feed_log_screen.dart';

class AddFeedLogScreen extends ConsumerStatefulWidget {
  const AddFeedLogScreen({super.key});

  @override
  ConsumerState<AddFeedLogScreen> createState() => _AddFeedLogScreenState();
}

class _AddFeedLogScreenState extends ConsumerState<AddFeedLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _feedTypeCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String? _species;
  DateTime? _date = DateTime.now();
  bool _submitting = false;

  static const _speciesOptions = [
    'cattle',
    'sheep',
    'goats',
    'poultry',
    'pigs',
  ];

  static const _feedTypes = [
    'TMR (Total Mixed Ration)',
    'Calf Starter Pellets',
    'Lucerne',
    'Teff Hay',
    'High-Energy Concentrate',
    'Layer Mash',
    'Broiler Grower Pellets',
    'Creep Feed',
    'Browse & Veld Grazing',
    'Other',
  ];

  @override
  void dispose() {
    _feedTypeCtrl.dispose();
    _quantityCtrl.dispose();
    _costCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    ref.invalidate(feedLogsProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feed log recorded successfully'),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return FarmScaffold(
      appBar: const FarmAppBar(title: 'Log Feed'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            DatePickerField(
              label: 'Date *',
              value: _date,
              onChanged: (v) => setState(() => _date = v),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Species
            DropdownButtonFormField<String>(
              initialValue: _species,
              decoration: const InputDecoration(
                labelText: 'Species *',
                border: OutlineInputBorder(),
              ),
              items: _speciesOptions
                  .map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s[0].toUpperCase() + s.substring(1))))
                  .toList(),
              onChanged: (v) => setState(() => _species = v),
              validator: (v) => v == null ? 'Select a species' : null,
            ),
            const SizedBox(height: AppSpacing.sm),

            FarmTextField(
              controller: TextEditingController(),
              label: 'Group / Animal name',
              hint: 'e.g. Breeding Cows, Weaner Calves',
            ),
            const SizedBox(height: AppSpacing.sm),

            // Feed type
            DropdownButtonFormField<String>(
              initialValue: _feedTypeCtrl.text.isEmpty ? null : _feedTypeCtrl.text,
              decoration: const InputDecoration(
                labelText: 'Feed Type *',
                border: OutlineInputBorder(),
              ),
              items: _feedTypes
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (v) => setState(() => _feedTypeCtrl.text = v ?? ''),
              validator: (v) => v == null ? 'Select a feed type' : null,
            ),
            const SizedBox(height: AppSpacing.sm),

            FarmTextField(
              controller: _quantityCtrl,
              label: 'Quantity (kg)',
              hint: '0.0',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: AppSpacing.sm),

            FarmTextField(
              controller: _costCtrl,
              label: 'Cost (ZAR)',
              hint: '0.00',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: const Icon(Icons.currency_exchange_rounded),
            ),
            const SizedBox(height: AppSpacing.sm),

            FarmTextField(
              controller: _notesCtrl,
              label: 'Notes',
              hint: 'Additional details',
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.xl),

            PrimaryButton(
              label: 'Save Feed Log',
              isLoading: _submitting,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
