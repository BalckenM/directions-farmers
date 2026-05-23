import '../../theme/payroll_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../models/pay_group.dart';
import '../../providers/payroll_providers.dart';


class PayGroupsScreen extends ConsumerWidget {
  const PayGroupsScreen({super.key});

  static Color _freqColor(PayFrequency f) => switch (f) {
        PayFrequency.monthly   => PayrollTokens.teal,
        PayFrequency.biweekly  => PayrollTokens.navy,
        PayFrequency.weekly    => PayrollTokens.amber,
        PayFrequency.daily     => const Color.fromARGB(255, 106, 27, 154),
      };

  static String _payDayLabel(PayGroup g) {
    switch (g.frequency) {
      case PayFrequency.monthly:
        return 'Day ${g.payDayOffset} of month';
      case PayFrequency.weekly:
      case PayFrequency.biweekly:
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final idx = g.payDayOffset.clamp(1, 7) - 1;
        return 'Every ${days[idx]}';
      case PayFrequency.daily:
        return 'End of day';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(payGroupsProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return FarmScaffold(
      appBar: const FarmAppBar(title: 'Pay Groups'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.payrollAddPayGroup),
        backgroundColor: PayrollTokens.teal,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: groups.isEmpty
          ? const EmptyState(
              icon: Icon(Icons.group_outlined),
              title: 'No pay groups',
              subtitle: 'Create pay groups to organise your payroll cycles.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: groups.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, i) {
                final g = groups[i];
                final freqColor = _freqColor(g.frequency);
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
                            color: freqColor,
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
                                    color: freqColor.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(Icons.group_outlined,
                                      color: freqColor, size: 22),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        g.name,
                                        style: tt.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _payDayLabel(g),
                                        style: tt.bodySmall?.copyWith(
                                            color: cs.onSurfaceVariant),
                                      ),
                                      if (g.description != null) ...
                                        [
                                          const SizedBox(height: 2),
                                          Text(
                                            g.description!,
                                            style: tt.bodySmall?.copyWith(
                                                color: cs.onSurfaceVariant),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          StatusChip(
                                            label: g.frequencyLabel,
                                            color: freqColor,
                                            small: true,
                                          ),
                                          const SizedBox(width: AppSpacing.xs),
                                          StatusChip(
                                            label: g.isActive ? 'Active' : 'Inactive',
                                            color: g.isActive ? PayrollTokens.green : Colors.grey,
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
                                  onPressed: () => context
                                      .push(AppRoutes.payrollEditPayGroup(g.id)),
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
