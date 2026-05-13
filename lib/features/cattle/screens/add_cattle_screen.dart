import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../models/cattle_animal.dart';
import '../providers/cattle_providers.dart';

class AddCattleScreen extends ConsumerStatefulWidget {
  const AddCattleScreen({super.key});

  @override
  ConsumerState<AddCattleScreen> createState() => _AddCattleScreenState();
}

class _AddCattleScreenState extends ConsumerState<AddCattleScreen> {
  final _formKey = GlobalKey<FormState>();

  final _tagController = TextEditingController();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _herdController = TextEditingController();
  final _dobController = TextEditingController();
  final _weightController = TextEditingController();
  final _niisController = TextEditingController();

  String _sex = 'cow';
  String _productionType = 'beef';
  bool _isSaving = false;

  @override
  void dispose() {
    _tagController.dispose();
    _nameController.dispose();
    _breedController.dispose();
    _herdController.dispose();
    _dobController.dispose();
    _weightController.dispose();
    _niisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FarmScaffold(
      appBar: const FarmAppBar(title: 'Add Cattle'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _tagController,
              decoration: const InputDecoration(
                labelText: 'Tag Number *',
                hintText: 'e.g. NG-001',
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
                hintText: 'e.g. Nguni',
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
                DropdownMenuItem(value: 'cow', child: Text('Cow (Female)')),
                DropdownMenuItem(value: 'bull', child: Text('Bull (Male)')),
                DropdownMenuItem(
                    value: 'heifer', child: Text('Heifer (Young Female)')),
                DropdownMenuItem(
                    value: 'steer', child: Text('Steer (Castrated)')),
                DropdownMenuItem(
                    value: 'calf_female', child: Text('Calf (Female)')),
                DropdownMenuItem(
                    value: 'calf_male', child: Text('Calf (Male)')),
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
                DropdownMenuItem(value: 'beef', child: Text('Beef')),
                DropdownMenuItem(value: 'dairy', child: Text('Dairy')),
                DropdownMenuItem(value: 'breeding', child: Text('Breeding')),
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
                hintText: 'e.g. 350.0',
                prefixIcon: Icon(Icons.monitor_weight_outlined),
                suffixText: 'kg',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _niisController,
              decoration: const InputDecoration(
                labelText: 'NIIS/EID Number (optional)',
                hintText: 'e.g. ZA123456789',
                prefixIcon: Icon(Icons.credit_card_outlined),
              ),
            ),
            const SizedBox(height: 24),
            if (ref.watch(canManageCattleProvider))
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add Cattle'),
              ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final animal = CattleAnimal(
      id: 'cattle-${DateTime.now().millisecondsSinceEpoch}',
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
      dateOfBirth: _dobController.text.trim().isEmpty
          ? '2000-01-01'
          : _dobController.text.trim(),
      currentWeightKg: double.tryParse(_weightController.text.trim()),
      isPregnant: false,
      isLactating: false,
      niisEidNumber: _niisController.text.trim().isEmpty
          ? null
          : _niisController.text.trim(),
    );

    ref.read(addedCattleProvider.notifier).addAnimal(animal);
    setState(() => _isSaving = false);
    context.go(AppRoutes.cattleList);
  }
}
