import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/core/router/app_routes.dart';
import 'package:mobile_app/core/theme/app_radius.dart';
import 'package:mobile_app/core/theme/app_spacing.dart';
import 'package:mobile_app/shared/widgets/farm_scaffold.dart';
import 'package:mobile_app/shared/widgets/farm_app_bar.dart';
import 'package:mobile_app/shared/widgets/empty_state.dart';
import 'package:mobile_app/shared/widgets/status_chip.dart';
import 'package:mobile_app/features/payroll/models/pay_structure.dart';
import 'package:mobile_app/features/payroll/providers/payroll_providers.dart';
import 'package:mobile_app/features/payroll/widgets/pr_amount_badge.dart';


class PayStructuresScreen extends ConsumerWidget {
  const PayStructuresScreen({super.key});

  static Color _wageColor(WageType w) => switch (w) {
        WageType.monthlySalary => AppColors.success,
        WageType.hourlyRate    => AppColors.primary,
        WageType.dailyRate     => AppColors.warning,
        WageType.piecework     => const Color.fromARGB(255, 106, 27, 154),
      };

  static String _rateLabel(WageType w) => switch (w) {
        WageType.monthlySalary => '/mo',
        WageType.hourlyRate    => '/hr',
        WageType.dailyRate     => '/day',
        WageType.piecework     => '/unit',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final structures = ref.watch(payStructuresProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final zar = NumberFormat.currency(locale: 'en_ZA', symbol: 'R ', decimalDigits: 2);

    return FarmScaffold(
      appBar: const FarmAppBar(title: 'Pay Structures'),
      floatingActionButton: FloatingActionButton(heroTag: null, 
        onPressed: () => context.push(AppRoutes.payrollAddPayStructure),
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: structures.isEmpty
          ? const EmptyState(
              icon: Icon(Icons.layers_outlined),
              title: 'No pay structures',
              subtitle: 'Create pay structures to define wage components.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: structures.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, i) {
                final s = structures[i];
                final wageColor = _wageColor(s.wageType);
                return Container(
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: AppRadius.card,
                    border: Border.all(color: cs.outlineVariant),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left accent bar
                        Container(
                          width: 4,
                          decoration: BoxDecoration(
                            color: wageColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                          ),
                        ),
                        // Content
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Row(
                              children: [
                                // Icon circle
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: wageColor.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(Icons.layers_outlined,
                                      color: wageColor, size: 22),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              s.name,
                                              style: tt.titleSmall?.copyWith(
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                          PrAmountBadge(
                                            amount:
                                                '${zar.format(s.baseRate)}${_rateLabel(s.wageType)}',
                                            backgroundColor:
                                                wageColor.withValues(alpha: 0.12),
                                            textColor: wageColor,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${s.overtimeMultiplier}x OT · '
                                        '${s.sundayMultiplier}x Sun · '
                                        '${s.publicHolidayMultiplier}x PH',
                                        style: tt.bodySmall?.copyWith(
                                            color: cs.onSurfaceVariant),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          StatusChip(
                                            label: s.wageTypeLabel,
                                            color: wageColor,
                                            small: true,
                                          ),
                                          const SizedBox(width: AppSpacing.xs),
                                          StatusChip(
                                            label: s.nmwaEnforced
                                                ? 'NMWA ✓'
                                                : 'Custom Rate',
                                            color: s.nmwaEnforced ? AppColors.success : AppColors.warning,
                                            small: true,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit_outlined,
                                      size: 18, color: cs.onSurfaceVariant),
                                  onPressed: () => context.push(
                                      AppRoutes.payrollEditPayStructure(s.id)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
