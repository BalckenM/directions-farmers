import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/farm_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/poultry_providers.dart';

class AddDeliveryScreen extends ConsumerStatefulWidget {
  const AddDeliveryScreen({super.key});

  @override
  ConsumerState<AddDeliveryScreen> createState() => _AddDeliveryScreenState();
}

class _AddDeliveryScreenState extends ConsumerState<AddDeliveryScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedItemId;
  final _quantityCtrl = TextEditingController();
  final _pricePerUnitCtrl = TextEditingController();
  final _supplierCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _deliveryDate = DateTime.now();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _pricePerUnitCtrl.dispose();
    _supplierCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deliveryDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _deliveryDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Delivery recorded successfully'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(inventoryProvider);
    final items = inventoryAsync.whenOrNull(data: (d) => d) ?? [];
    final theme = Theme.of(context);

    return FarmScaffold(
      drawer: null,
      appBar: const FarmAppBar(title: 'Record Delivery', subtitle: 'Add stock'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePaddingHorizontal,
            AppSpacing.md,
            AppSpacing.pagePaddingHorizontal,
            AppSpacing.xxl + 80,
          ),
          children: [
            // ── Item select ────────────────────────────────────────────────
            _FormSection(
              title: 'Inventory Item',
              icon: Icons.inventory_2_outlined,
              child: DropdownButtonFormField<String>(
                initialValue: _selectedItemId,
                hint: const Text('Select item'),
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(),
                ),
                items: items
                    .map((i) => DropdownMenuItem(
                          value: i.id,
                          child: Text(
                            '${i.name} (${i.unit})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedItemId = v;
                    // Pre-fill price from existing item
                    final item = items.firstWhere(
                      (i) => i.id == v,
                      orElse: () => items.first,
                    );
                    _pricePerUnitCtrl.text =
                        item.pricePerUnit.toStringAsFixed(2);
                  });
                },
                validator: (v) =>
                    v == null ? 'Please select an item' : null,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── Quantity ───────────────────────────────────────────────────
            _FormSection(
              title: 'Quantity Delivered',
              icon: Icons.scale_outlined,
              child: FarmTextField(
                controller: _quantityCtrl,
                label: 'Quantity',
                hint: 'e.g. 500',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                ],
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Enter a number';
                  if (double.parse(v) <= 0) return 'Must be > 0';
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── Price Per Unit ─────────────────────────────────────────────
            _FormSection(
              title: 'Price Per Unit',
              icon: Icons.payments_outlined,
              child: FarmTextField(
                controller: _pricePerUnitCtrl,
                label: 'Price per unit (R)',
                hint: 'e.g. 7.80',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                ],
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Enter a number';
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── Delivery Date ──────────────────────────────────────────────
            _FormSection(
              title: 'Delivery Date',
              icon: Icons.calendar_today_outlined,
              child: InkWell(
                onTap: _pickDate,
                borderRadius: AppRadius.card,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 18),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '${_deliveryDate.day.toString().padLeft(2, '0')}/'
                        '${_deliveryDate.month.toString().padLeft(2, '0')}/'
                        '${_deliveryDate.year}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── Supplier ───────────────────────────────────────────────────
            _FormSection(
              title: 'Supplier',
              icon: Icons.local_shipping_outlined,
              child: FarmTextField(
                controller: _supplierCtrl,
                label: 'Supplier name (optional)',
                hint: 'e.g. AgriFeeds Co.',
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── Notes ──────────────────────────────────────────────────────
            _FormSection(
              title: 'Notes',
              icon: Icons.notes_outlined,
              child: FarmTextField(
                controller: _notesCtrl,
                label: 'Notes (optional)',
                hint: 'e.g. Batch number, condition on arrival...',
                maxLines: 2,
                textInputAction: TextInputAction.done,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            PrimaryButton(
              label: 'Record Delivery',
              isLoading: _isSubmitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Form section wrapper ──────────────────────────────────────────────────────

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(80)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.poultryColor),
                const SizedBox(width: AppSpacing.xs),
                Text(title,
                    style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.poultryColor)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            child,
          ],
        ),
      ),
    );
  }
}
