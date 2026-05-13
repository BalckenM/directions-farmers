import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../models/inventory_item.dart';
import '../providers/poultry_providers.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(inventoryProvider);

    return FarmScaffold(
      drawer: null,
      appBar: const FarmAppBar(title: 'Farm Inventory', subtitle: 'Stock levels'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addDelivery),
        backgroundColor: AppColors.poultryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Record Delivery'),
      ),
      body: inventoryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) => _InventoryBody(items: items),
      ),
    );
  }
}

class _InventoryBody extends StatelessWidget {
  const _InventoryBody({required this.items});

  final List<InventoryItem> items;

  @override
  Widget build(BuildContext context) {
    // Count low-stock items
    final lowCount = items.where((i) => i.isBelowThreshold).length;

    // Group by category
    final Map<InventoryCategory, List<InventoryItem>> grouped = {};
    for (final item in items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    final sortedCategories = grouped.keys.toList()
      ..sort((a, b) => a.label.compareTo(b.label));

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePaddingHorizontal,
        AppSpacing.md,
        AppSpacing.pagePaddingHorizontal,
        AppSpacing.xxl + 80,
      ),
      children: [
        // ── Low stock banner ─────────────────────────────────────────────
        if (lowCount > 0)
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.warning.withAlpha(31),
              borderRadius: AppRadius.card,
              border: Border.all(color: AppColors.warning),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_outlined,
                    color: AppColors.warning, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '$lowCount item${lowCount == 1 ? '' : 's'} below minimum stock level',
                  style: const TextStyle(
                      color: AppColors.warning, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

        // ── Summary strip ────────────────────────────────────────────────
        _SummaryStrip(items: items),
        const SizedBox(height: AppSpacing.lg),

        // ── Grouped lists ────────────────────────────────────────────────
        for (final cat in sortedCategories) ...[
          _CategoryHeader(category: cat),
          const SizedBox(height: AppSpacing.xs),
          for (final item in grouped[cat]!) ...[
            _InventoryTile(item: item),
            const SizedBox(height: AppSpacing.xs),
          ],
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.items});
  final List<InventoryItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lowCount = items.where((i) => i.isBelowThreshold).length;
    final okCount = items.length - lowCount;

    return Row(
      children: [
        Expanded(
          child: _StripCard(
            label: 'Total Items',
            value: '${items.length}',
            icon: Icons.inventory_2_outlined,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StripCard(
            label: 'Sufficient',
            value: '$okCount',
            icon: Icons.check_circle_outline,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StripCard(
            label: 'Low Stock',
            value: '$lowCount',
            icon: Icons.warning_amber_outlined,
            color: lowCount > 0 ? AppColors.warning : AppColors.success,
          ),
        ),
      ],
    );
  }
}

class _StripCard extends StatelessWidget {
  const _StripCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(color: color.withAlpha(77)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 2),
            Text(value,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.category});
  final InventoryCategory category;

  static const Map<InventoryCategory, IconData> _icons = {
    InventoryCategory.feed: Icons.grain_outlined,
    InventoryCategory.vaccine: Icons.vaccines_outlined,
    InventoryCategory.medication: Icons.medication_outlined,
    InventoryCategory.equipment: Icons.handyman_outlined,
    InventoryCategory.bedding: Icons.layers_outlined,
    InventoryCategory.other: Icons.inventory_2_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(_icons[category] ?? Icons.inventory_2_outlined,
            size: 16, color: AppColors.poultryColor),
        const SizedBox(width: AppSpacing.xs),
        Text(category.label,
            style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.poultryColor)),
      ],
    );
  }
}

class _InventoryTile extends ConsumerWidget {
  const _InventoryTile({required this.item});
  final InventoryItem item;

  void _showEditSheet(BuildContext context, WidgetRef ref) {
    final qtyCtrl = TextEditingController(
        text: item.currentStock.toStringAsFixed(0));
    final formKey = GlobalKey<FormState>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.pagePaddingHorizontal,
          right: AppSpacing.pagePaddingHorizontal,
          top: AppSpacing.lg,
          bottom: MediaQuery.viewInsetsOf(ctx).bottom + AppSpacing.lg,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit: ${item.name}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: qtyCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Stock Quantity (${item.unit})',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => (double.tryParse(v ?? '') == null)
                    ? 'Enter a valid number'
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.poultryColor,
                    minimumSize: const Size.fromHeight(48)),
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    ref
                        .read(inventoryEditProvider.notifier)
                        .update(item.id, double.parse(qtyCtrl.text.trim()));
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${item.name} updated')),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLow = item.isBelowThreshold;
    final accentColor = isLow ? AppColors.warning : AppColors.success;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(
          color: isLow
              ? AppColors.warning.withAlpha(153)
              : theme.colorScheme.outlineVariant.withAlpha(80),
          width: isLow ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Stock indicator
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                          isLow
                              ? Icons.warning_amber_outlined
                              : Icons.check_circle_outline,
                          size: 12,
                          color: accentColor),
                      const SizedBox(width: 4),
                      Text(
                        '${item.currentStock.toStringAsFixed(0)} ${item.unit}'
                        ' / min ${item.minThreshold.toStringAsFixed(0)} ${item.unit}',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  if (item.notes != null) ...[
                    const SizedBox(height: 2),
                    Text(item.notes!,
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: AppColors.warning)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'R${item.pricePerUnit.toStringAsFixed(2)}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'per ${item.unit}',
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.xs),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit_outlined,
                      size: 16, color: AppColors.poultryColor),
                  tooltip: 'Edit quantity',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _showEditSheet(context, ref),
                ),
                const SizedBox(height: 4),
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      size: 16, color: theme.colorScheme.error.withAlpha(180)),
                  tooltip: 'Delete item',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Remove Item'),
                        content: Text('Remove "${item.name}" from inventory?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(
                                  foregroundColor: theme.colorScheme.error),
                              child: const Text('Remove')),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      ref
                          .read(inventoryDeleteProvider.notifier)
                          .delete(item.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${item.name} removed')),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
