import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../models/goat_animal.dart';
import '../providers/goat_providers.dart';

class AddGoatScreen extends ConsumerStatefulWidget {
  const AddGoatScreen({super.key});

  @override
  ConsumerState<AddGoatScreen> createState() => _AddGoatScreenState();
}

class _AddGoatScreenState extends ConsumerState<AddGoatScreen> {
  final _formKey = GlobalKey<FormState>();

  final _tagController = TextEditingController();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _herdController = TextEditingController();
  final _dobController = TextEditingController();
  final _weightController = TextEditingController();

  String _sex = 'doe';
  String _productionType = 'meat';
  bool _isSaving = false;

  @override
  void dispose() {
    _tagController.dispose();
    _nameController.dispose();
    _breedController.dispose();
    _herdController.dispose();
    _dobController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FarmScaffold(
      appBar: const FarmAppBar(title: 'Add Goat'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _tagController,
              decoration: const InputDecoration(
                labelText: 'Tag Number *',
                hintText: 'e.g. BC-015',
                prefixIcon: Icon(Icons.tag_rounded),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Tag number required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name (optional)',
                hintText: 'e.g. Bella',
                prefixIcon: Icon(Icons.label_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _breedController,
              decoration: const InputDecoration(
                labelText: 'Breed *',
                hintText: 'e.g. Boer',
                prefixIcon: Icon(Icons.pets_rounded),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Breed required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _sex,
              decoration: const InputDecoration(
                labelText: 'Sex',
                prefixIcon: Icon(Icons.wc_rounded),
              ),
              items: const [
                DropdownMenuItem(value: 'doe', child: Text('Doe (Female)')),
                DropdownMenuItem(value: 'buck', child: Text('Buck (Male)')),
                DropdownMenuItem(value: 'wether', child: Text('Wether (Castrated)')),
              ],
              onChanged: (v) => setState(() => _sex = v!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _productionType,
              decoration: const InputDecoration(
                labelText: 'Production Type',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 'meat', child: Text('Meat')),
                DropdownMenuItem(value: 'dairy', child: Text('Dairy')),
                DropdownMenuItem(value: 'fiber', child: Text('Fiber')),
                DropdownMenuItem(value: 'breeding', child: Text('Breeding')),
                DropdownMenuItem(value: 'communal', child: Text('Communal')),
              ],
              onChanged: (v) => setState(() => _productionType = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _herdController,
              decoration: const InputDecoration(
                labelText: 'Herd ID *',
                hintText: 'e.g. herd-a',
                prefixIcon: Icon(Icons.group_outlined),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Herd ID required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _dobController,
              decoration: const InputDecoration(
                labelText: 'Date of Birth',
                hintText: 'YYYY-MM-DD',
                prefixIcon: Icon(Icons.cake_outlined),
              ),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Current Weight (kg)',
                hintText: 'e.g. 45.5',
                prefixIcon: Icon(Icons.monitor_weight_outlined),
                suffixText: 'kg',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 24),
            if (ref.watch(canManageAnimalsProvider))
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add Goat'),
              ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final animal = GoatAnimal(
      id: 'goat-${DateTime.now().millisecondsSinceEpoch}',
      farmId: 'FARM-001',
      tagNumber: _tagController.text.trim(),
      name: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      breed: _breedController.text.trim(),
      productionType: _productionType,
      sex: _sex,
      status: 'active',
      herdId: _herdController.text.trim(),
      dateOfBirth:
          _dobController.text.trim().isEmpty ? '2000-01-01' : _dobController.text.trim(),
      currentWeightKg: double.tryParse(_weightController.text.trim()),
      isPregnant: false,
      isLactating: false,
    );

    ref.read(addedAnimalsProvider.notifier).addAnimal(animal);
    setState(() => _isSaving = false);
    context.go(AppRoutes.goatList);
  }
}
