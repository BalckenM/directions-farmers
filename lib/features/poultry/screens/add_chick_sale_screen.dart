import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../models/flock.dart';
import '../providers/poultry_providers.dart';

class AddChickSaleScreen extends ConsumerStatefulWidget {
  const AddChickSaleScreen({super.key, required this.flockId});

  final String flockId;

  @override
  ConsumerState<AddChickSaleScreen> createState() => _AddChickSaleScreenState();
}

class _AddChickSaleScreenState extends ConsumerState<AddChickSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _buyerController = TextEditingController();
  final _batchNoController = TextEditingController();
  final _chickCountController = TextEditingController();
  final _priceController = TextEditingController();
  final _eggsSetController = TextEditingController();
  final _fertilityController = TextEditingController();
  final _hatchabilityController = TextEditingController();
  final _avgWeightController = TextEditingController();
  final _invoiceController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _saleDate = DateTime.now();
  DateTime _hatchDate = DateTime.now();
  String _chickSex = 'straight_run';
  bool _submitting = false;

  static const _sexOptions = [
    ('straight_run', 'Straight Run'),
    ('male', 'Male Only'),
    ('female', 'Female Only'),
  ];

  @override
  void dispose() {
    _buyerController.dispose();
    _batchNoController.dispose();
    _chickCountController.dispose();
    _priceController.dispose();
    _eggsSetController.dispose();
    _fertilityController.dispose();
    _hatchabilityController.dispose();
    _avgWeightController.dispose();
    _invoiceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isSale) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isSale ? _saleDate : _hatchDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (picked != null) {
      setState(() {
        if (isSale) {
          _saleDate = picked;
        } else {
          _hatchDate = picked;
        }
      });
    }
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    final count = int.parse(_chickCountController.text.trim());
    final price = double.parse(_priceController.text.trim());

    final sale = ChickSale(
      id: 'chk-${DateTime.now().millisecondsSinceEpoch}',
      flockId: widget.flockId,
      batchNo: _batchNoController.text.trim().isEmpty
          ? null
          : _batchNoController.text.trim(),
      hatchDate: _fmt(_hatchDate),
      saleDate: _fmt(_saleDate),
      buyerName: _buyerController.text.trim(),
      chickCount: count,
      pricePerChick: price,
      totalAmount: count * price,
      chickSex: _chickSex,
      eggsSet: int.tryParse(_eggsSetController.text.trim()),
      fertilityPct: double.tryParse(_fertilityController.text.trim()),
      hatchabilityPct: double.tryParse(_hatchabilityController.text.trim()),
      avgChickWeightG: double.tryParse(_avgWeightController.text.trim()),
      invoiceRef: _invoiceController.text.trim().isEmpty
          ? null
          : _invoiceController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    ref.read(chickSaleNotifierProvider.notifier).add(sale);

    setState(() => _submitting = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Chick sale recorded — \$${sale.totalAmount.toStringAsFixed(2)}',
        ),
        backgroundColor: AppColors.success,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FarmScaffold(
      drawer: null,
      appBar: const FarmAppBar(title: 'Record Chick Sale'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePaddingHorizontal,
            vertical: AppSpacing.pagePaddingVertical,
          ),
          children: [
            // ── Dates ─────────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Hatch Date'),
                    subtitle: Text(_fmt(_hatchDate)),
                    trailing: const Icon(Icons.egg_outlined),
                    onTap: () => _pickDate(false),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Sale Date'),
                    subtitle: Text(_fmt(_saleDate)),
                    trailing: const Icon(Icons.calendar_today_outlined),
                    onTap: () => _pickDate(true),
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: AppSpacing.md),

            // ── Buyer ─────────────────────────────────────────────────────────
            TextFormField(
              controller: _buyerController,
              decoration: const InputDecoration(
                labelText: 'Buyer / Customer *',
                hintText: 'e.g. Sunrise Poultry Farm',
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Batch No ──────────────────────────────────────────────────────
            TextFormField(
              controller: _batchNoController,
              decoration: const InputDecoration(
                labelText: 'Batch / Hatch Number',
                hintText: 'e.g. HATCH-2025-0042 (optional)',
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Count & Price ─────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _chickCountController,
                    decoration: const InputDecoration(
                      labelText: 'DOC Count *',
                      hintText: '0',
                      suffixText: 'chicks',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (int.tryParse(v.trim()) == null ||
                          int.parse(v.trim()) <= 0) {
                        return 'Enter valid count';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price / Chick *',
                      hintText: '0.00',
                      prefixText: '\$ ',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (double.tryParse(v.trim()) == null ||
                          double.parse(v.trim()) <= 0) {
                        return 'Enter valid price';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Total preview ─────────────────────────────────────────────────
            ValueListenableBuilder(
              valueListenable: _chickCountController,
              builder: (context, _, _) => ValueListenableBuilder(
                valueListenable: _priceController,
                builder: (context, _, _) {
                  final count =
                      int.tryParse(_chickCountController.text.trim()) ?? 0;
                  final price =
                      double.tryParse(_priceController.text.trim()) ?? 0;
                  final total = count * price;
                  return total > 0
                      ? Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.success.withAlpha(26),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Revenue',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '\$ ${total.toStringAsFixed(2)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink();
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Chick Sex ─────────────────────────────────────────────────────
            Text('Chick Sex', style: theme.textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<String>(
              segments: _sexOptions
                  .map((o) => ButtonSegment(value: o.$1, label: Text(o.$2)))
                  .toList(),
              selected: {_chickSex},
              onSelectionChanged: (s) =>
                  setState(() => _chickSex = s.first),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Hatch Stats ───────────────────────────────────────────────────
            Text('Hatch Statistics (optional)', style: theme.textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _eggsSetController,
                    decoration: const InputDecoration(
                      labelText: 'Eggs Set',
                      hintText: '0',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      if (int.tryParse(v.trim()) == null) return 'Whole number';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextFormField(
                    controller: _avgWeightController,
                    decoration: const InputDecoration(
                      labelText: 'Avg Chick Wt',
                      hintText: '42.0',
                      suffixText: 'g',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _fertilityController,
                    decoration: const InputDecoration(
                      labelText: 'Fertility %',
                      hintText: '0.0',
                      suffixText: '%',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      final d = double.tryParse(v.trim());
                      if (d == null || d < 0 || d > 100) return '0–100';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextFormField(
                    controller: _hatchabilityController,
                    decoration: const InputDecoration(
                      labelText: 'Hatchability %',
                      hintText: '0.0',
                      suffixText: '%',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      final d = double.tryParse(v.trim());
                      if (d == null || d < 0 || d > 100) return '0–100';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Invoice & Notes ───────────────────────────────────────────────
            TextFormField(
              controller: _invoiceController,
              decoration: const InputDecoration(
                labelText: 'Invoice / Order Reference',
                hintText: 'Optional',
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Transport, health certificate, buyer contact…',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Submit ────────────────────────────────────────────────────────
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.poultryColor,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Record Chick Sale'),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
