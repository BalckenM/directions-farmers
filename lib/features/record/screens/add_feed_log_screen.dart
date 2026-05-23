import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/date_picker_field.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/farm_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../livestock/providers/groups_provider.dart';
import '../data/record_repository.dart';
import '../models/feed_log.dart';
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
  String? _selectedGroupId;
  String? _selectedGroupName;
  int _animalCount = 0;
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
    if (_selectedGroupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a group')));
      return;
    }
    setState(() => _submitting = true);
    try {
      final log = FeedLog(
        id: 'FL-${DateTime.now().millisecondsSinceEpoch}',
        date: DateFormat('yyyy-MM-dd').format(_date ?? DateTime.now()),
        species: _species ?? 'cattle',
        groupId: _selectedGroupId!,
        groupName: _selectedGroupName ?? _selectedGroupId!,
        animalCount: _animalCount,
        feedType: _feedTypeCtrl.text.trim(),
        quantityKg: double.tryParse(_quantityCtrl.text) ?? 0.0,
        costZar: double.tryParse(_costCtrl.text) ?? 0.0,
        recordedBy: 'Farmer',
        notes:
            _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      await ref.read(recordRepositoryProvider).addFeedLog(log);
      ref.invalidate(feedLogsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feed log recorded successfully'),
          backgroundColor: Color(0xFF2E7D32),
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
              value: _species,
              decoration: const InputDecoration(
                labelText: 'Species *',
                border: OutlineInputBorder(),
              ),
              items: _speciesOptions
                  .map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s[0].toUpperCase() + s.substring(1))))
                  .toList(),
              onChanged: (v) => setState(() {
                _species = v;
                _selectedGroupId = null;
                _selectedGroupName = null;
                _animalCount = 0;
              }),
              validator: (v) => v == null ? 'Select a species' : null,
            ),
            const SizedBox(height: AppSpacing.sm),

            // Group picker
            Consumer(
              builder: (context, ref, _) {
                final groupsAsync = ref.watch(groupsProvider);
                return groupsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (groups) {
                    final filtered = _species == null
                        ? groups
                        : groups
                            .where((g) =>
                                g.species.toLowerCase() ==
                                _species!.toLowerCase())
                            .toList();
                    return DropdownButtonFormField<String>(
                      value: _selectedGroupId,
                      decoration: const InputDecoration(
                        labelText: 'Group *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.group_outlined),
                      ),
                      hint: const Text('Select group'),
                      isExpanded: true,
                      items: filtered
                          .map((g) => DropdownMenuItem(
                                value: g.id,
                                child: Text(g.name),
                              ))
                          .toList(),
                      onChanged: (id) {
                        final g = filtered.firstWhere((g) => g.id == id,
                            orElse: () => filtered.first);
                        setState(() {
                          _selectedGroupId = id;
                          _selectedGroupName = g.name;
                          _animalCount = g.animalCount;
                        });
                      },
                      validator: (v) =>
                          v == null ? 'Select a group' : null,
                    );
                  },
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),

            // Feed type
            DropdownButtonFormField<String>(
              value: _feedTypeCtrl.text.isEmpty ? null : _feedTypeCtrl.text,
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
