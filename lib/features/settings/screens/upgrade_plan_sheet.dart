import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/providers/auth_provider.dart';

// ── Entry-point ───────────────────────────────────────────────────────────────

void showUpgradePlanSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _UpgradePlanSheet(),
  );
}

// ── Sheet ─────────────────────────────────────────────────────────────────────

class _UpgradePlanSheet extends ConsumerStatefulWidget {
  const _UpgradePlanSheet();

  @override
  ConsumerState<_UpgradePlanSheet> createState() => _UpgradePlanSheetState();
}

class _UpgradePlanSheetState extends ConsumerState<_UpgradePlanSheet> {
  String? _selectedId; // plan being confirmed, null = none selected
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final currentPlanId =
        ref.watch(currentUserProvider)?.subscriptionPlan ?? 'starter';

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.6,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            // handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            // header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withAlpha(20),
                      borderRadius: AppRadius.button,
                    ),
                    child: Icon(Icons.star_rounded,
                        color: AppColors.secondary, size: 22),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Upgrade Your Plan',
                            style: tt.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700)),
                        Text('Choose the plan that fits your farm',
                            style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(height: 24),

            // plan cards
            Expanded(
              child: ListView.separated(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
                itemCount: kSubscriptionPlans.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (_, i) {
                  final plan = kSubscriptionPlans[i];
                  final isCurrent = plan.id == currentPlanId;
                  final isSelected = _selectedId == plan.id;
                  return _PlanCard(
                    plan: plan,
                    isCurrent: isCurrent,
                    isSelected: isSelected,
                    loading: _loading && isSelected,
                    onSelect: isCurrent || _loading
                        ? null
                        : () => _confirmUpgrade(plan.id, plan.label),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmUpgrade(String planId, String planLabel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Upgrade to $planLabel?'),
        content: Text(
          'Your plan will be updated to $planLabel. '
          'Billing changes take effect at the start of the next cycle.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    setState(() {
      _selectedId = planId;
      _loading = true;
    });

    // Mock: simulate network call
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pop(); // close sheet

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Plan upgraded to $planLabel successfully!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
      ),
    );
  }
}

// ── Plan card ─────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isCurrent,
    required this.isSelected,
    required this.loading,
    required this.onSelect,
  });

  final SubscriptionPlan plan;
  final bool isCurrent;
  final bool isSelected;
  final bool loading;
  final VoidCallback? onSelect;

  static const _planColors = {
    'starter': Color(0xFF5C6BC0), // indigo
    'growth': Color(0xFF00897B), // teal
    'enterprise': Color(0xFFE65100), // deep orange
  };

  static const _planIcons = {
    'starter': Icons.eco_rounded,
    'growth': Icons.trending_up_rounded,
    'enterprise': Icons.rocket_launch_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = _planColors[plan.id] ?? AppColors.primary;
    final icon = _planIcons[plan.id] ?? Icons.star_rounded;
    final isPopular = plan.id == 'growth';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        border: Border.all(
          color: isCurrent
              ? AppColors.success
              : isSelected
                  ? color
                  : cs.outlineVariant,
          width: isCurrent || isSelected ? 2 : 1,
        ),
        borderRadius: AppRadius.card,
        color: isCurrent
            ? AppColors.success.withAlpha(8)
            : isSelected
                ? color.withAlpha(10)
                : cs.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── card header ─────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: color.withAlpha(15),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.md - 1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withAlpha(24),
                    borderRadius: AppRadius.button,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(plan.label,
                              style: tt.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: color)),
                          if (isPopular) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withAlpha(20),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text('Popular',
                                  style: tt.labelSmall?.copyWith(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ],
                      ),
                      Text(plan.tagline,
                          style: tt.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('R${plan.price}',
                        style: tt.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800, color: color)),
                    Text('/ month',
                        style: tt.labelSmall
                            ?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),

          // ── features ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...plan.features.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              size: 16, color: color),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(f, style: tt.bodySmall),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: AppSpacing.sm),

                // ── action button ────────────────────────────────────────────
                if (isCurrent)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.check_circle_rounded, size: 16),
                      label: const Text('Current Plan'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.success,
                        side: const BorderSide(color: AppColors.success),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onSelect,
                      style: FilledButton.styleFrom(
                        backgroundColor: color,
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white),
                            )
                          : Text('Select ${plan.label}'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
