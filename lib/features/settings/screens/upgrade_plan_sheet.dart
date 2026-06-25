// ignore_for_file: avoid_web_libraries_in_flutter
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:js_interop';

import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_radius.dart';
import 'package:mobile_app/core/theme/app_spacing.dart';
import 'package:mobile_app/features/auth/providers/auth_provider.dart';
import 'package:mobile_app/features/billing/models/plan.dart';
import 'package:mobile_app/features/billing/providers/billing_providers.dart';

// Entry-point
void showUpgradePlanSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _UpgradePlanSheet(),
  );
}

class _UpgradePlanSheet extends ConsumerStatefulWidget {
  const _UpgradePlanSheet();
  @override
  ConsumerState<_UpgradePlanSheet> createState() => _UpgradePlanSheetState();
}

class _UpgradePlanSheetState extends ConsumerState<_UpgradePlanSheet> {
  String? _loadingSlug;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final plansAsync = ref.watch(plansProvider);
    final currentPlanSlug =
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
                            style: tt.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        Text('Choose the plan that fits your business',
                            style: tt.bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant)),
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
            Expanded(
              child: plansAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Could not load plans.'),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref.invalidate(plansProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (plans) => ListView.separated(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
                  itemCount: plans.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (_, i) {
                    final plan = plans[i];
                    final isCurrent = plan.slug == currentPlanSlug;
                    final isLoading = _loadingSlug == plan.slug;
                    return _PlanCard(
                      plan: plan,
                      isCurrent: isCurrent,
                      loading: isLoading,
                      onSelect: (isCurrent || _loadingSlug != null)
                          ? null
                          : () => _startCheckout(plan),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startCheckout(BillingPlan plan) async {
    if (!mounted) return;
    setState(() => _loadingSlug = plan.slug);
    try {
      final ds = ref.read(billingDataSourceProvider);
      final result = await ds.initiateCheckout(planSlug: plan.slug);
      final redirectUrl = result['redirectUrl'] ?? '';
      if (!mounted) return;
      setState(() => _loadingSlug = null);
      if (redirectUrl.isEmpty) {
        _showError('No checkout URL returned. Please contact support.');
        return;
      }
      if (kIsWeb) {
        _assignUrl(redirectUrl);
      } else {
        _showUrlDialog(redirectUrl);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingSlug = null);
      _showError(_extractError(e));
    }
  }

  void _showUrlDialog(String url) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Complete Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Open this link in your browser to complete payment:'),
            const SizedBox(height: 12),
            SelectableText(url,
                style:
                    const TextStyle(fontSize: 12, color: Colors.blueAccent)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
    ));
  }

  String _extractError(Object e) {
    final match = RegExp(r'"message"\s*:\s*"([^"]+)"').firstMatch(e.toString());
    return match?.group(1) ?? 'Please try again later';
  }
}

@JS('window.location.assign')
external void _assignUrl(String url);

// Plan card widget
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isCurrent,
    required this.loading,
    required this.onSelect,
  });

  final BillingPlan plan;
  final bool isCurrent;
  final bool loading;
  final VoidCallback? onSelect;

  static const _planColors = {
    'starter': Color(0xFF5C6BC0),
    'growth': Color(0xFF00897B),
    'enterprise': Color(0xFFE65100),
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
    final color = _planColors[plan.slug] ?? AppColors.primary;
    final icon = _planIcons[plan.slug] ?? Icons.star_rounded;
    final isPopular = plan.slug == 'growth';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        border: Border.all(
          color: isCurrent ? AppColors.success : cs.outlineVariant,
          width: isCurrent ? 2 : 1,
        ),
        borderRadius: AppRadius.card,
        color: isCurrent ? AppColors.success.withAlpha(8) : cs.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                  child: Row(
                    children: [
                      Text(plan.name,
                          style: tt.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700, color: color)),
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
                ),
                Text(plan.priceLabel,
                    style: tt.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800, color: color)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (plan.features.isNotEmpty)
                  ...plan.features.map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check_circle_rounded,
                                size: 16, color: color),
                            const SizedBox(width: 8),
                            Expanded(child: Text(f, style: tt.bodySmall)),
                          ],
                        ),
                      )),
                const SizedBox(height: AppSpacing.sm),
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
                      style: FilledButton.styleFrom(backgroundColor: color),
                      child: loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text('Upgrade to ${plan.name}'),
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