import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../data/crop_repository.dart';
import '../../models/crop_sale.dart';
import '../../providers/crop_providers.dart';

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
  @override
  Widget build(BuildContext context) {
    final salesAsync = ref.watch(cropSalesProvider(null));
    final cropsAsync = ref.watch(cropsProvider(null));
    final cropNames = <String, String>{
      for (final c in cropsAsync.value ?? []) c.id: c.name,
    };
    final currencyFmt =
        NumberFormat.currency(locale: 'en_ZA', symbol: 'R ', decimalDigits: 2);

    return FarmScaffold(
      appBar: AppBar(title: const Text('Crop Sales')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addCropSale),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Record Sale'),
      ),
      body: salesAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: LoadingShimmer(height: 140),
        ),
        error: (e, _) => Center(
          child: Text(
            'Failed to load sales: $e',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
        data: (sales) {
          final totalRevenue =
              sales.fold<double>(0.0, (sum, s) => sum + s.totalAmountZar);
          final paid = sales.where((s) => s.isPaid).length;
          final pending = sales.length - paid;

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // ── Summary card ──────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: _SummaryCard(
                        totalRevenue: totalRevenue,
                        paid: paid,
                        pending: pending,
                        currencyFmt: currencyFmt,
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SectionHeader(title: 'All Sales'),
                  ),

                  if (sales.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          'No sales recorded yet.',
                          style: TextStyle(color: AppColors.onSurfaceVariant),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.xs,
                        AppSpacing.md,
                        120,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final sale = sales[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm),
                              child: Dismissible(
                                key: ValueKey(sale.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(
                                      right: AppSpacing.lg),
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    borderRadius: AppRadius.card,
                                  ),
                                  child: const Icon(Icons.delete_rounded,
                                      color: Colors.white),
                                ),
                                confirmDismiss: (_) async {
                                  return await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete Sale'),
                                      content: const Text(
                                          'Delete this sale record? This cannot be undone.'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text('Cancel')),
                                        FilledButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          style: FilledButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.error),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                onDismissed: (_) async {
                                  await ref
                                      .read(cropRepositoryProvider)
                                      .deleteSale(sale.id);
                                  ref.invalidate(cropSalesProvider);
                                  ref.invalidate(totalRevenueProvider);
                                  ref.invalidate(grossMarginProvider);
                                },
                                child: GestureDetector(
                                  onLongPress: () => context.push(
                                      AppRoutes.editCropSale,
                                      extra: sale),
                                  child: _SaleCard(
                                    sale: sale,
                                    cropName: cropNames[sale.cropId],
                                    currencyFmt: currencyFmt,
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: sales.length,
                        ),
                      ),
                    ),
                ],
              ),

              // ── Fixed total footer ─────────────────────────────────────────
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _TotalFooter(
                    totalRevenue: totalRevenue, currencyFmt: currencyFmt),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Summary Card ──────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalRevenue,
    required this.paid,
    required this.pending,
    required this.currencyFmt,
  });

  final double totalRevenue;
  final int paid;
  final int pending;
  final NumberFormat currencyFmt;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), AppColors.success],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.card,
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withAlpha(76),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Revenue',
            style: tt.labelMedium
                ?.copyWith(color: AppColors.onPrimary.withAlpha(204)),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            currencyFmt.format(totalRevenue),
            style: tt.headlineMedium?.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _StatBadge(
                label: '$paid Paid',
                icon: Icons.check_circle_rounded,
                color: AppColors.onPrimary.withAlpha(204),
              ),
              const SizedBox(width: AppSpacing.md),
              if (pending > 0)
                _StatBadge(
                  label: '$pending Pending',
                  icon: Icons.pending_rounded,
                  color: AppColors.warning,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ── Sale Card ─────────────────────────────────────────────────────────────────

class _SaleCard extends StatelessWidget {
  const _SaleCard({
    required this.sale,
    required this.currencyFmt,
    this.cropName,
  });

  final CropSale sale;
  final String? cropName;
  final NumberFormat currencyFmt;

  Color _statusColor(String status) => switch (status) {
        'paid' => AppColors.success,
        'partial' => AppColors.warning,
        _ => AppColors.onSurfaceVariant,
      };

  String _statusLabel(String status) => switch (status) {
        'paid' => 'Paid',
        'partial' => 'Partial',
        _ => 'Pending',
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final dateFmt = DateFormat('dd MMM yyyy');
    final statusColor = _statusColor(sale.paymentStatus);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(31),
                    borderRadius: AppRadius.card,
                  ),
                  child: const Icon(
                    Icons.sell_rounded,
                    color: AppColors.success,
                    size: AppSpacing.iconMd,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cropName ?? sale.cropId,
                        style: tt.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (sale.buyer != null)
                        Text(
                          sale.buyer!,
                          style: tt.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                // Status chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(31),
                    borderRadius: AppRadius.chip,
                    border: Border.all(color: statusColor.withAlpha(76)),
                  ),
                  child: Text(
                    _statusLabel(sale.paymentStatus),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            const Divider(height: 1, color: AppColors.outlineVariant),
            const SizedBox(height: AppSpacing.sm),

            // Details row
            Row(
              children: [
                Expanded(
                  child: _Detail(
                    label: 'Quantity',
                    value: '${sale.quantityTons.toStringAsFixed(1)} t',
                  ),
                ),
                Expanded(
                  child: _Detail(
                    label: 'Price / ton',
                    value: currencyFmt.format(sale.pricePerTonZar),
                  ),
                ),
                Expanded(
                  child: _Detail(
                    label: 'Total',
                    value: currencyFmt.format(sale.totalAmountZar),
                    valueColor: cs.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  dateFmt.format(sale.saleDate),
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: tt.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? cs.onSurface,
          ),
        ),
      ],
    );
  }
}

// ── Total Footer ──────────────────────────────────────────────────────────────

class _TotalFooter extends StatelessWidget {
  const _TotalFooter({required this.totalRevenue, required this.currencyFmt});

  final double totalRevenue;
  final NumberFormat currencyFmt;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Revenue',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            currencyFmt.format(totalRevenue),
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}
