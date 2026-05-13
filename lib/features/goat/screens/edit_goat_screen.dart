import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../providers/goat_providers.dart';

class EditGoatScreen extends ConsumerStatefulWidget {
  const EditGoatScreen({super.key, required this.goatId});
  final String goatId;

  @override
  ConsumerState<EditGoatScreen> createState() => _EditGoatScreenState();
}

class _EditGoatScreenState extends ConsumerState<EditGoatScreen> {
  final _formKey = GlobalKey<FormState>();

  final _tagController = TextEditingController();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _herdController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  bool _loaded = false;
  bool _isSaving = false;
  double? _bcs;

  @override
  void dispose() {
    _tagController.dispose();
    _nameController.dispose();
    _breedController.dispose();
    _herdController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animalAsync = ref.watch(animalDetailProvider(widget.goatId));

    return animalAsync.when(
      loading: () => FarmScaffold(
        appBar: const FarmAppBar(title: 'Edit Goat'),
        body: const LoadingShimmer(),
      ),
      error: (e, _) => FarmScaffold(
        appBar: const FarmAppBar(title: 'Error'),
        body: Center(child: Text('$e')),
      ),
      data: (animal) {
        if (animal == null) {
          return FarmScaffold(
            appBar: const FarmAppBar(title: 'Not Found'),
            body: const Center(child: Text('Goat not found')),
          );
        }

        if (!_loaded) {
          _tagController.text = animal.tagNumber;
          _nameController.text = animal.name ?? '';
          _breedController.text = animal.breed;
          _herdController.text = animal.herdId;
          _weightController.text =
              animal.currentWeightKg?.toStringAsFixed(1) ?? '';
          _notesController.text = animal.notes ?? '';
          _bcs = animal.bodyConditionScore?.toDouble();
          _loaded = true;
        }

        return FarmScaffold(
          appBar: FarmAppBar(title: 'Edit ${animal.displayName}'),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _tagController,
                  decoration: const InputDecoration(
                    labelText: 'Tag Number *',
                    prefixIcon: Icon(Icons.tag_rounded),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Tag required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.label_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _breedController,
                  decoration: const InputDecoration(
                    labelText: 'Breed *',
                    prefixIcon: Icon(Icons.pets_rounded),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Breed required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _herdController,
                  decoration: const InputDecoration(
                    labelText: 'Herd ID *',
                    prefixIcon: Icon(Icons.group_outlined),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Herd required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _weightController,
                  decoration: const InputDecoration(
                    labelText: 'Current Weight (kg)',
                    prefixIcon: Icon(Icons.monitor_weight_outlined),
                    suffixText: 'kg',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Body Condition Score: '),
                    Expanded(
                      child: Slider(
                        value: _bcs ?? 3,
                        min: 1,
                        max: 5,
                        divisions: 8,
                        label: _bcs?.toStringAsFixed(1),
                        onChanged: (v) => setState(() => _bcs = v),
                      ),
                    ),
                    Text((_bcs ?? 3).toStringAsFixed(1)),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Changes'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final edits = <String, dynamic>{
      'tagNumber': _tagController.text.trim(),
      'breed': _breedController.text.trim(),
      'herdId': _herdController.text.trim(),
      if (_nameController.text.trim().isNotEmpty)
        'name': _nameController.text.trim(),
      if (_weightController.text.trim().isNotEmpty)
        'currentWeightKg': double.tryParse(_weightController.text.trim()),
      if (_bcs != null) 'bodyConditionScore': _bcs,
      if (_notesController.text.trim().isNotEmpty)
        'notes': _notesController.text.trim(),
    };

    ref.read(animalEditProvider.notifier).applyEdit(widget.goatId, edits);
    setState(() => _isSaving = false);
    context.pop();
  }
}
