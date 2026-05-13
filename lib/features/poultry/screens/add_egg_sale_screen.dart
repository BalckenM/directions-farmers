import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../models/flock.dart';
import '../providers/poultry_providers.dart';

class AddEggSaleScreen extends ConsumerStatefulWidget {
  const AddEggSaleScreen({super.key, required this.flockId});

  final String flockId;

  @override
  ConsumerState<AddEggSaleScreen> createState() => _AddEggSaleScreenState();
}

class _AddEggSaleScreenState extends ConsumerState<AddEggSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _buyerController = TextEditingController();
  final _dozensController = TextEditingController();
  final _priceController = TextEditingController();
  final _invoiceController = TextEditingController();
  final _notesController = TextEditingController();

  // Grade breakdown controllers (dozens per grade)
  final _jumboCtrl = TextEditingController(text: '0');
  final _extraLargeCtrl = TextEditingController(text: '0');
  final _largeCtrl = TextEditingController(text: '0');
  final _mediumCtrl = TextEditingController(text: '0');
  final _smallCtrl = TextEditingController(text: '0');

  DateTime _date = DateTime.now();
  bool _submitting = false;

  @override
  void dispose() {
    _buyerController.dispose();
    _dozensController.dispose();
    _priceController.dispose();
    _invoiceController.dispose();
    _notesController.dispose();
    _jumboCtrl.dispose();
    _extraLargeCtrl.dispose();
    _largeCtrl.dispose();
    _mediumCtrl.dispose();
    _smallCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  String get _dateLabel =>
      '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    final gradeBreakdown = <String, int>{};
    void addGrade(String key, TextEditingController ctrl) {
      final v = int.tryParse(ctrl.text.trim()) ?? 0;
      if (v > 0) gradeBreakdown[key] = v;
    }

    addGrade('jumbo', _jumboCtrl);
    addGrade('extra_large', _extraLargeCtrl);
    addGrade('large', _largeCtrl);
    addGrade('medium', _mediumCtrl);
    addGrade('small', _smallCtrl);

    final sale = EggSale(
      id: 'es-${DateTime.now().millisecondsSinceEpoch}',
      flockId: widget.flockId,
      date: _dateLabel,
      buyerName: _buyerController.text.trim(),
      dozensTotal: double.parse(_dozensController.text.trim()),
      pricePerDozen: double.parse(_priceController.text.trim()),
      gradeBreakdown: gradeBreakdown,
      invoiceRef: _invoiceController.text.trim().isEmpty
          ? null
          : _invoiceController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    ref.read(eggSaleNotifierProvider.notifier).add(sale);

    setState(() => _submitting = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Egg sale recorded — R${sale.totalRevenue.toStringAsFixed(2)}',
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
      appBar: const FarmAppBar(title: 'Record Egg Sale'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePaddingHorizontal,
            vertical: AppSpacing.pagePaddingVertical,
          ),
          children: [
            // ── Date ─────────────────────────────────────────────────────────
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Sale Date'),
              subtitle: Text(_dateLabel),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _pickDate,
            ),
            const Divider(),
            const SizedBox(height: AppSpacing.md),

            // ── Buyer ─────────────────────────────────────────────────────────
            TextFormField(
              controller: _buyerController,
              decoration: const InputDecoration(
                labelText: 'Buyer / Customer *',
                hintText: 'e.g. Greenfields Supermarket',
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Quantity & Price ──────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dozensController,
                    decoration: const InputDecoration(
                      labelText: 'Dozens Sold *',
                      hintText: '0.0',
                      suffixText: 'doz',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (double.tryParse(v.trim()) == null ||
                          double.parse(v.trim()) <= 0) {
                        return 'Enter valid amount';
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
                      labelText: 'Price / Dozen *',
                      hintText: '0.00',
                      prefixText: 'R ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
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
              valueListenable: _dozensController,
              builder: (context, _, _) => ValueListenableBuilder(
                valueListenable: _priceController,
                builder: (context, _, _) {
                  final dozens =
                      double.tryParse(_dozensController.text.trim()) ?? 0;
                  final price =
                      double.tryParse(_priceController.text.trim()) ?? 0;
                  final total = dozens * price;
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
                                'R ${total.toStringAsFixed(2)}',
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

            // ── Grade Breakdown ───────────────────────────────────────────────
            Text(
              'Grade Breakdown (dozens)',
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            _GradeRow(label: 'Jumbo', ctrl: _jumboCtrl),
            _GradeRow(label: 'Extra Large', ctrl: _extraLargeCtrl),
            _GradeRow(label: 'Large', ctrl: _largeCtrl),
            _GradeRow(label: 'Medium', ctrl: _mediumCtrl),
            _GradeRow(label: 'Small', ctrl: _smallCtrl),
            const SizedBox(height: AppSpacing.md),

            // ── Invoice Reference ─────────────────────────────────────────────
            TextFormField(
              controller: _invoiceController,
              decoration: const InputDecoration(
                labelText: 'Invoice / Order Reference',
                hintText: 'Optional',
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Notes ─────────────────────────────────────────────────────────
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Quality notes, delivery info, etc.',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Submit ────────────────────────────────────────────────────────
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Record Sale'),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

// ── Helper widget ─────────────────────────────────────────────────────────────

class _GradeRow extends StatelessWidget {
  const _GradeRow({required this.label, required this.ctrl});

  final String label;
  final TextEditingController ctrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: TextFormField(
              controller: ctrl,
              decoration: const InputDecoration(
                isDense: true,
                suffixText: 'doz',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                if (int.tryParse(v.trim()) == null) return 'Whole number';
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}
