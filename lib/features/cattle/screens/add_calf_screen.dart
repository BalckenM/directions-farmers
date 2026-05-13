import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/cattle_animal.dart';
import '../providers/cattle_providers.dart';

class AddCalfScreen extends ConsumerStatefulWidget {
  const AddCalfScreen({super.key, required this.damId});
  final String damId;

  @override
  ConsumerState<AddCalfScreen> createState() => _AddCalfScreenState();
}

class _AddCalfScreenState extends ConsumerState<AddCalfScreen> {
  final _formKey = GlobalKey<FormState>();

  final _tagController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _weightController = TextEditingController();
  final _sireIdController = TextEditingController();

  String _sex = 'calf_female';
  bool _isSaving = false;

  @override
  void dispose() {
    _tagController.dispose();
    _birthDateController.dispose();
    _weightController.dispose();
    _sireIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final damAsync = ref.watch(cattleDetailProvider(widget.damId));

    return damAsync.when(
      loading: () => FarmScaffold(
        appBar: const FarmAppBar(title: 'Register Calf'),
        body: const LoadingShimmer(),
      ),
      error: (e, _) => FarmScaffold(
        appBar: const FarmAppBar(title: 'Error'),
        body: Center(child: Text('$e')),
      ),
      data: (dam) {
        return FarmScaffold(
          appBar: FarmAppBar(
            title: 'Register Calf',
            subtitle: dam != null ? 'Dam: ${dam.displayName}' : null,
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (dam != null)
                  Card(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.female_rounded),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(dam.displayName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall),
                                Text(
                                    '${dam.breed} · ${dam.herdId}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _tagController,
                  decoration: const InputDecoration(
                    labelText: 'Tag Number *',
                    hintText: 'e.g. CALF-001',
                    prefixIcon: Icon(Icons.tag_rounded),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Tag required' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _sex,
                  decoration: const InputDecoration(
                    labelText: 'Sex *',
                    prefixIcon: Icon(Icons.wc_rounded),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'calf_female',
                        child: Text('Heifer Calf (Female)')),
                    DropdownMenuItem(
                        value: 'calf_male',
                        child: Text('Bull Calf (Male)')),
                  ],
                  onChanged: (v) => setState(() => _sex = v!),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _birthDateController,
                  decoration: const InputDecoration(
                    labelText: 'Birth Date *',
                    hintText: 'YYYY-MM-DD',
                    prefixIcon: Icon(Icons.cake_outlined),
                  ),
                  keyboardType: TextInputType.datetime,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Birth date required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _weightController,
                  decoration: const InputDecoration(
                    labelText: 'Birth Weight (kg)',
                    hintText: 'e.g. 28.0',
                    prefixIcon: Icon(Icons.monitor_weight_outlined),
                    suffixText: 'kg',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _sireIdController,
                  decoration: const InputDecoration(
                    labelText: 'Sire ID (optional)',
                    hintText: 'e.g. cattle-003',
                    prefixIcon: Icon(Icons.male_rounded),
                  ),
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
                      : const Text('Register Calf'),
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

    final damAsync = ref.read(cattleDetailProvider(widget.damId));
    final dam = damAsync.asData?.value;

    final calf = CattleAnimal(
      id: 'cattle-${DateTime.now().millisecondsSinceEpoch}',
      farmId: 'FARM-001',
      tagNumber: _tagController.text.trim(),
      breed: dam?.breed ?? 'Unknown',
      productionType: dam?.productionType ?? 'beef',
      sex: _sex,
      status: 'active',
      herdId: dam?.herdId ?? '',
      dateOfBirth: _birthDateController.text.trim(),
      currentWeightKg: double.tryParse(_weightController.text.trim()),
      isPregnant: false,
      isLactating: false,
      damId: widget.damId,
      sireId: _sireIdController.text.trim().isEmpty
          ? null
          : _sireIdController.text.trim(),
    );

    ref.read(addedCattleProvider.notifier).addAnimal(calf);
    setState(() => _isSaving = false);
    context.pop();
  }
}
