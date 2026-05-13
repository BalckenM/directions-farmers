import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/goat_records.dart';
import '../providers/goat_providers.dart';

class GoatSalesScreen extends ConsumerStatefulWidget {
  const GoatSalesScreen({super.key});

  @override
  ConsumerState<GoatSalesScreen> createState() => _GoatSalesScreenState();
}

class _GoatSalesScreenState extends ConsumerState<GoatSalesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _animalIdController = TextEditingController();
  final _saleDateController = TextEditingController();
  final _buyerController = TextEditingController();
  final _weightController = TextEditingController();
  final _pricePerKgController = TextEditingController();
  final _totalController = TextEditingController();
  final _invoiceController = TextEditingController();
  final _notesController = TextEditingController();

  bool _showForm = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _animalIdController.dispose();
    _saleDateController.dispose();
    _buyerController.dispose();
    _weightController.dispose();
    _pricePerKgController.dispose();
    _totalController.dispose();
    _invoiceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final animalId = _animalIdController.text.trim();
    final record = GoatSaleRecord(
      id: 'sale_${DateTime.now().millisecondsSinceEpoch}',
      animalId: animalId,
      saleDate: _saleDateController.text.trim(),
      buyerName: _buyerController.text.trim(),
      saleWeightKg: double.tryParse(_weightController.text.trim()),
      pricePerKg: double.tryParse(_pricePerKgController.text.trim()),
      totalRevenue: double.tryParse(_totalController.text.trim()),
      invoiceRef: _invoiceController.text.trim().isEmpty
          ? null
          : _invoiceController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    ref.read(newSaleRecordProvider.notifier).addRecord(animalId, record);
    _animalIdController.clear();
    _saleDateController.clear();
    _buyerController.clear();
    _weightController.clear();
    _pricePerKgController.clear();
    _totalController.clear();
    _invoiceController.clear();
    _notesController.clear();
    setState(() {
      _isSaving = false;
      _showForm = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final salesAsync = ref.watch(allGoatSaleRecordsProvider);

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Sales',
        subtitle: 'All goat transactions',
        actions: [
          IconButton(
            icon: Icon(
                _showForm ? Icons.close_rounded : Icons.add_rounded),
            onPressed: () =>
                setState(() => _showForm = !_showForm),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showForm)
            Card(
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Record Sale',
                          style:
                              Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _animalIdController,
                            decoration: const InputDecoration(
                                labelText: 'Animal Tag / ID *'),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Animal ID required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _saleDateController,
                            decoration: const InputDecoration(
                                labelText: 'Sale Date *',
                                hintText: 'YYYY-MM-DD'),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Date required'
                                : null,
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _buyerController,
                        decoration: const InputDecoration(
                            labelText: 'Buyer Name *'),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Buyer required'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _weightController,
                            decoration: const InputDecoration(
                                labelText: 'Weight (kg)',
                                suffixText: 'kg'),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _pricePerKgController,
                            decoration: const InputDecoration(
                                labelText: 'Price/kg (R)',
                                prefixText: 'R'),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _totalController,
                            decoration: const InputDecoration(
                                labelText: 'Total Revenue (R)',
                                prefixText: 'R'),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _invoiceController,
                            decoration: const InputDecoration(
                                labelText: 'Invoice Ref'),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                            labelText: 'Notes (optional)'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          child: _isSaving
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2))
                              : const Text('Save Sale Record'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: salesAsync.when(
              loading: () => const LoadingShimmer(),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (sales) {
                if (sales.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sell_outlined,
                            size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('No sale records'),
                      ],
                    ),
                  );
                }
                final total = sales.fold<double>(
                    0, (s, r) => s + (r.totalRevenue ?? 0));
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Text('${sales.length} sale(s)',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall),
                          const Spacer(),
                          Text(
                            'Total: R${total.toStringAsFixed(0)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16),
                        itemCount: sales.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final s = sales[i];
                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                          Icons.sell_rounded,
                                          size: 18),
                                      const SizedBox(width: 6),
                                      Text(s.saleDate,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall),
                                      const Spacer(),
                                      Text(
                                        'R${(s.totalRevenue ?? 0).toStringAsFixed(0)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                                color: Theme.of(
                                                        context)
                                                    .colorScheme
                                                    .primary),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text('Animal: ${s.animalId}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                  Text('Buyer: ${s.buyerName}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                  if (s.saleWeightKg != null)
                                    Text(
                                        'Weight: ${s.saleWeightKg!.toStringAsFixed(1)} kg'
                                        '${s.pricePerKg != null ? ' Â· R${s.pricePerKg!.toStringAsFixed(0)}/kg' : ''}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall),
                                  if (s.invoiceRef != null)
                                    Text('Ref: ${s.invoiceRef}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
