import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../models/crop_expense.dart';
import '../../providers/crop_providers.dart';

class EditExpenseScreen extends ConsumerStatefulWidget {
  const EditExpenseScreen({super.key, required this.expense});

  final CropExpense expense;

  @override
  ConsumerState<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends ConsumerState<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;
  late final TextEditingController _supplierController;
  late final TextEditingController _quantityController;
  late final TextEditingController _unitController;

  late ExpenseCategory _category;
  late DateTime _date;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _category            = e.category;
    _date                = e.date;
    _descriptionController = TextEditingController(text: e.description);
    _amountController      = TextEditingController(
        text: e.amountZar.toStringAsFixed(2));
    _supplierController    = TextEditingController(text: e.supplier ?? '');
    _quantityController    = TextEditingController(
        text: e.quantity != null ? e.quantity.toString() : '');
    _unitController        = TextEditingController(text: e.unit ?? '');
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _supplierController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final repo    = ref.read(cropRepositoryProvider);
    final updated = widget.expense.copyWith(
      category:    _category,
      description: _descriptionController.text.trim(),
      amountZar:   double.parse(_amountController.text.trim()),
      date:        _date,
      supplier:    _supplierController.text.trim().isEmpty
          ? null
          : _supplierController.text.trim(),
      quantity: double.tryParse(_quantityController.text.trim()),
      unit:     _unitController.text.trim().isEmpty
          ? null
          : _unitController.text.trim(),
    );

    try {
      await repo.updateExpense(updated);
      ref.invalidate(cropExpensesProvider);
      ref.invalidate(totalExpensesProvider);
      ref.invalidate(grossMarginProvider);
    } catch (_) {}

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense updated')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy');

    return FarmScaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Edit Expense')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // ── Category ─────────────────────────────────────────────────
            DropdownButtonFormField<ExpenseCategory>(
              decoration: _dec('Category', Icons.category_outlined),
              initialValue: _category,
              items: ExpenseCategory.values
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            Icon(_catIcon(c),
                                size: AppSpacing.iconSm,
                                color: _catColor(c)),
                            const SizedBox(width: AppSpacing.sm),
                            Text(c.label),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? _category),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Description ──────────────────────────────────────────────
            TextFormField(
              controller: _descriptionController,
              decoration: _dec('Description', Icons.description_outlined),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Description is required'
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Amount ───────────────────────────────────────────────────
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount (ZAR)',
                prefixText: 'R ',
                prefixIcon: const Icon(Icons.payments_outlined),
                border: OutlineInputBorder(borderRadius: AppRadius.input),
                filled: true,
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Amount is required';
                final parsed = double.tryParse(v.replaceAll(',', '.'));
                if (parsed == null || parsed <= 0) {
                  return 'Enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Date ─────────────────────────────────────────────────────
            InkWell(
              onTap: _pickDate,
              borderRadius: AppRadius.input,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date',
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(borderRadius: AppRadius.input),
                  filled: true,
                  suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
                ),
                child: Text(dateFmt.format(_date)),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Supplier ─────────────────────────────────────────────────
            TextFormField(
              controller: _supplierController,
              decoration:
                  _dec('Supplier (optional)', Icons.store_outlined),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Quantity + Unit ──────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _quantityController,
                    decoration:
                        _dec('Quantity (opt.)', Icons.numbers_rounded),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d*')),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _unitController,
                    decoration: InputDecoration(
                      labelText: 'Unit (opt.)',
                      hintText: 'kg, L, bags…',
                      prefixIcon: const Icon(Icons.straighten_rounded),
                      border:
                          OutlineInputBorder(borderRadius: AppRadius.input),
                      filled: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Save ─────────────────────────────────────────────────────
            FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                minimumSize:
                    const Size.fromHeight(AppSpacing.minTouchTarget),
                shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.button),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.onPrimary),
                    )
                  : const Text('Update Expense'),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: AppRadius.input),
        filled: true,
      );
}

Color _catColor(ExpenseCategory cat) => switch (cat) {
      ExpenseCategory.seed       => AppColors.success,
      ExpenseCategory.fertilizer => const Color(0xFF8BC34A),
      ExpenseCategory.chemical   => AppColors.secondaryDark,
      ExpenseCategory.fuel       => AppColors.warning,
      ExpenseCategory.labor      => AppColors.tertiary,
      ExpenseCategory.machinery  => AppColors.rabbitColor,
      ExpenseCategory.irrigation => AppColors.aquacultureColor,
      ExpenseCategory.transport  => AppColors.sheepColor,
      ExpenseCategory.other      => AppColors.onSurfaceVariant,
    };

IconData _catIcon(ExpenseCategory cat) => switch (cat) {
      ExpenseCategory.seed       => Icons.grass_rounded,
      ExpenseCategory.fertilizer => Icons.science_rounded,
      ExpenseCategory.chemical   => Icons.bubble_chart_rounded,
      ExpenseCategory.fuel       => Icons.local_gas_station_rounded,
      ExpenseCategory.labor      => Icons.people_rounded,
      ExpenseCategory.machinery  => Icons.agriculture_rounded,
      ExpenseCategory.irrigation => Icons.water_rounded,
      ExpenseCategory.transport  => Icons.local_shipping_rounded,
      ExpenseCategory.other      => Icons.more_horiz_rounded,
    };
