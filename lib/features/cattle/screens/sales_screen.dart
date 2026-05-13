import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/cattle_records.dart';
import '../providers/cattle_providers.dart';

class CattleSalesScreen extends ConsumerStatefulWidget {
  const CattleSalesScreen({super.key});

  @override
  ConsumerState<CattleSalesScreen> createState() =>
      _CattleSalesScreenState();
}

class _CattleSalesScreenState extends ConsumerState<CattleSalesScreen> {
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
    final record = CattleSaleRecord(
      id: 'sale_${DateTime.now().millisecondsSinceEpoch}',
      animalId: animalId,
      saleDate: _saleDateController.text.trim(),
      buyerName: _buyerController.text.trim(),
      saleWeightKg: double.tryParse(_weightController.text.trim()),
      pricePerKg: double.tryParse(_pricePerKgController.text.trim()),
      totalAmount: double.tryParse(_totalController.text.trim()),
      invoiceRef: _invoiceController.text.trim().isEmpty
          ? null
          : _invoiceController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );
    ref
        .read(newCattleSaleRecordProvider.notifier)
        .addRecord(animalId, record);
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
    final salesAsync = ref.watch(allCattleSaleRecordsProvider);

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Sales',
        subtitle: 'All cattle transactions',
        actions: [
          IconButton(
            icon: Icon(
                _showForm ? Icons.close_rounded : Icons.add_rounded),
            onPressed: () => setState(() => _showForm = !_showForm),
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
                          style: Theme.of(context).textTheme.titleSmall),
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
                                labelText: 'Weight (kg)', suffixText: 'kg'),
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
                        child: FilledButton(
                          onPressed: _isSaving ? null : _save,
                          child: _isSaving
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2))
                              : const Text('Record Sale'),
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
              data: (records) => records.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sell_rounded,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('No sales recorded'),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: records.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final r = records[i];
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: const Icon(Icons.receipt_long_rounded,
                                color: Colors.blue),
                            title: Text(r.saleDate),
                            subtitle: Text(
                              '${r.animalId} · ${(r.saleWeightKg ?? 0).toStringAsFixed(1)} kg · ${r.buyerName}',
                            ),
                            trailing: Text(
                              'R${(r.totalAmount ?? 0).toStringAsFixed(0)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                      fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
