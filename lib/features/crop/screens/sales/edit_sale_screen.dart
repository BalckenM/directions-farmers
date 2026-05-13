import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../models/crop_sale.dart';
import '../../providers/crop_providers.dart';

class EditSaleScreen extends ConsumerStatefulWidget {
  const EditSaleScreen({super.key, required this.sale});

  final CropSale sale;

  @override
  ConsumerState<EditSaleScreen> createState() => _EditSaleScreenState();
}

class _EditSaleScreenState extends ConsumerState<EditSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _quantityCtrl =
      TextEditingController(text: widget.sale.quantityTons.toString());
  late final _priceCtrl =
      TextEditingController(text: widget.sale.pricePerTonZar.toString());
  late final _buyerCtrl =
      TextEditingController(text: widget.sale.buyer ?? '');

  late String _selectedCrop = widget.sale.cropId;
  late DateTime _saleDate = widget.sale.saleDate;
  late String _paymentStatus = widget.sale.paymentStatus;
  bool _saving = false;

  static const _statuses = ['paid', 'partial', 'pending'];

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _priceCtrl.dispose();
    _buyerCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, {String? suffix, IconData? icon}) =>
      InputDecoration(
        labelText: label,
        suffixText: suffix,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: AppRadius.input),
      );

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _saleDate,
      firstDate: DateTime(2015),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _saleDate = picked);
  }

  double get _total {
    final qty = double.tryParse(_quantityCtrl.text.trim()) ?? 0;
    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
    return qty * price;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final qty = double.parse(_quantityCtrl.text.trim());
    final price = double.parse(_priceCtrl.text.trim());

    final updated = CropSale(
      id: widget.sale.id,
      harvestId: widget.sale.harvestId,
      farmId: widget.sale.farmId,
      cropId: _selectedCrop,
      saleDate: _saleDate,
      quantityTons: qty,
      pricePerTonZar: price,
      totalAmountZar: qty * price,
      buyer: _buyerCtrl.text.trim().isEmpty ? null : _buyerCtrl.text.trim(),
      paymentStatus: _paymentStatus,
    );

    try {
      await ref.read(cropRepositoryProvider).updateSale(updated);
      ref.invalidate(cropSalesProvider);
      ref.invalidate(totalRevenueProvider);
      ref.invalidate(grossMarginProvider);
    } catch (_) {}

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sale updated')),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final cropsAsync = ref.watch(cropsProvider(null));
    final crops = cropsAsync.value ?? [];
    final dateFmt = DateFormat('dd MMM yyyy');
    final currencyFmt =
        NumberFormat.currency(locale: 'en_ZA', symbol: 'R ', decimalDigits: 2);

    return FarmScaffold(
      resizeToAvoidBottomInset: true,
      appBar: const FarmAppBar(title: 'Edit Sale'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePaddingHorizontal,
            vertical: AppSpacing.pagePaddingVertical,
          ),
          children: [
            Text('Crop',
                style: tt.titleSmall?.copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<String>(
              initialValue: _selectedCrop,
              decoration: _dec('Select crop', icon: Icons.grass_rounded),
              items: crops
                  .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedCrop = v);
              },
              validator: (v) => v == null ? 'Please select a crop' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            Text('Sale Date',
                style: tt.titleSmall?.copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.xs),
            InkWell(
              onTap: _pickDate,
              borderRadius: AppRadius.input,
              child: InputDecorator(
                decoration: _dec('Date', icon: Icons.calendar_today_rounded),
                child: Text(dateFmt.format(_saleDate), style: tt.bodyMedium),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            Text('Sale Details',
                style: tt.titleSmall?.copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.xs),
            TextFormField(
              controller: _quantityCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
              ],
              decoration:
                  _dec('Quantity', suffix: 'tons', icon: Icons.scale_rounded),
              onChanged: (_) => setState(() {}),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (double.tryParse(v.trim()) == null) return 'Invalid number';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _priceCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
              ],
              decoration: _dec('Price per ton',
                  suffix: 'ZAR', icon: Icons.payments_rounded),
              onChanged: (_) => setState(() {}),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (double.tryParse(v.trim()) == null) return 'Invalid number';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.sm),

            if (_total > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(26),
                  borderRadius: AppRadius.card,
                  border: Border.all(color: AppColors.success.withAlpha(76)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calculate_rounded,
                        color: AppColors.success, size: 18),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Total: ${currencyFmt.format(_total)}',
                      style: tt.titleSmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],

            TextFormField(
              controller: _buyerCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: _dec('Buyer (optional)', icon: Icons.store_rounded),
            ),
            const SizedBox(height: AppSpacing.md),

            Text('Payment Status',
                style: tt.titleSmall?.copyWith(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.xs),
            SegmentedButton<String>(
              segments: _statuses
                  .map((s) => ButtonSegment(
                        value: s,
                        label: Text(_statusLabel(s)),
                        icon: Icon(_statusIcon(s), size: 16),
                      ))
                  .toList(),
              selected: {_paymentStatus},
              onSelectionChanged: (sel) =>
                  setState(() => _paymentStatus = sel.first),
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: cs.primaryContainer,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            SizedBox(
              width: double.infinity,
              height: AppSpacing.minTouchTarget,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(_saving ? 'Saving…' : 'Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  shape:
                      RoundedRectangleBorder(borderRadius: AppRadius.button),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  String _statusLabel(String s) => switch (s) {
        'paid' => 'Paid',
        'partial' => 'Partial',
        _ => 'Pending',
      };

  IconData _statusIcon(String s) => switch (s) {
        'paid' => Icons.check_circle_rounded,
        'partial' => Icons.pending_rounded,
        _ => Icons.hourglass_empty_rounded,
      };
}
