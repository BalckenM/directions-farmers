import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../models/crop_sale.dart';
import '../../providers/crop_providers.dart';

class SaleDetailScreen extends ConsumerWidget {
  const SaleDetailScreen({super.key, required this.sale});

  final CropSale sale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cropsAsync = ref.watch(cropsProvider(null));

    final cropName = (cropsAsync.value ?? [])
        .where((c) => c.id == sale.cropId)
        .map((c) => c.name)
        .firstOrNull ?? sale.cropId;

    final dateFmt     = DateFormat('dd MMM yyyy');
    final currencyFmt =
        NumberFormat.currency(locale: 'en_ZA', symbol: 'R ', decimalDigits: 2);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final statusColor = sale.isPaid ? AppColors.success : AppColors.warning;

    return FarmScaffold(
      body: CustomScrollView(
        slivers: [
          // ── App Bar ───────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppColors.tertiary,
            foregroundColor: AppColors.onPrimary,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                tooltip: 'Edit',
                onPressed: () =>
                    context.push(AppRoutes.editCropSale, extra: sale),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                cropName,
                style: const TextStyle(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.tertiary.withAlpha(230),
                      AppColors.tertiary,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md, AppSpacing.sm, AppSpacing.md, 48),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Icon(Icons.sell_rounded,
                            color: AppColors.onPrimary, size: 18),
                        const SizedBox(width: AppSpacing.xs),
                        Text(dateFmt.format(sale.saleDate),
                            style: TextStyle(
                                color: AppColors.onPrimary.withAlpha(204),
                                fontSize: 12)),
                        const SizedBox(width: AppSpacing.sm),
                        StatusChip(
                            label: sale.paymentStatus.toUpperCase(),
                            color: statusColor,
                            small: true),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xxl),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Revenue KPIs ─────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _KpiCard(
                        icon: Icons.payments_rounded,
                        label: 'Total',
                        value: currencyFmt.format(sale.totalAmountZar),
                        color: AppColors.tertiary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _KpiCard(
                        icon: Icons.scale_rounded,
                        label: 'Qty (t)',
                        value: '${sale.quantityTons.toStringAsFixed(2)} t',
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _KpiCard(
                        icon: Icons.price_change_rounded,
                        label: 'Price/t',
                        value: 'R${sale.pricePerTonZar.toStringAsFixed(0)}',
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Details card ─────────────────────────────────────────
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.card),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        _Row(
                          icon: Icons.calendar_today_outlined,
                          label: 'Sale Date',
                          value: dateFmt.format(sale.saleDate),
                        ),
                        const Divider(height: AppSpacing.md),
                        _Row(
                          icon: Icons.spa_rounded,
                          label: 'Crop',
                          value: cropName,
                        ),
                        if (sale.buyer != null) ...[
                          const Divider(height: AppSpacing.md),
                          _Row(
                            icon: Icons.business_rounded,
                            label: 'Buyer',
                            value: sale.buyer!,
                          ),
                        ],
                        const Divider(height: AppSpacing.md),
                        _Row(
                          icon: Icons.receipt_rounded,
                          label: 'Payment',
                          value: sale.paymentStatus.toUpperCase(),
                          valueColor: statusColor,
                        ),
                        const Divider(height: AppSpacing.md),
                        _Row(
                          icon: Icons.payments_outlined,
                          label: 'Total Revenue',
                          value: currencyFmt.format(sale.totalAmountZar),
                          valueColor: AppColors.tertiary,
                        ),
                        const Divider(height: AppSpacing.md),
                        _Row(
                          icon: Icons.scale_rounded,
                          label: 'Quantity',
                          value:
                              '${sale.quantityTons.toStringAsFixed(3)} tons',
                        ),
                        const Divider(height: AppSpacing.md),
                        _Row(
                          icon: Icons.price_change_outlined,
                          label: 'Price / ton',
                          value: currencyFmt.format(sale.pricePerTonZar),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: AppRadius.card,
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: AppSpacing.iconSm),
          const SizedBox(height: AppSpacing.xs),
          Text(value,
              textAlign: TextAlign.center,
              style: tt.labelMedium
                  ?.copyWith(fontWeight: FontWeight.w800, color: color)),
          Text(label,
              style: tt.labelSmall
                  ?.copyWith(color: cs.onSurfaceVariant, fontSize: 9)),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: AppSpacing.iconSm, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(label,
            style:
                tt.bodySmall?.copyWith(color: AppColors.onSurfaceVariant)),
        const Spacer(),
        Text(value,
            style: tt.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600, color: valueColor)),
      ],
    );
  }
}
