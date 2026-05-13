import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';

/// Events hub: shows entry cards for Health, Weight, and Breeding sub-sections.
class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FarmScaffold(
      appBar: const FarmAppBar(
        title: 'Events',
        subtitle: 'Track herd activities',
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePaddingHorizontal),
        children: [
          _EventHubCard(
            icon: Icons.health_and_safety_rounded,
            color: AppColors.error,
            title: 'Health Events',
            subtitle: 'Vaccinations, treatments, and vet visits',
            onTap: () => context.push(AppRoutes.recordHealth),
          ),
          const SizedBox(height: AppSpacing.md),
          _EventHubCard(
            icon: Icons.monitor_weight_rounded,
            color: AppColors.tertiary,
            title: 'Weight Records',
            subtitle: 'Track growth and body weight over time',
            onTap: () => context.push(AppRoutes.recordWeight),
          ),
          const SizedBox(height: AppSpacing.md),
          _EventHubCard(
            icon: Icons.favorite_rounded,
            color: AppColors.secondary,
            title: 'Breeding Events',
            subtitle: 'Mating, pregnancies, and births',
            onTap: () => context.push(AppRoutes.recordBreeding),
          ),
          const SizedBox(height: AppSpacing.md),
          _EventHubCard(
            icon: Icons.notifications_active_rounded,
            color: AppColors.warning,
            title: 'Alerts & Reminders',
            subtitle: 'Critical notices and upcoming tasks',
            onTap: () => context.push(AppRoutes.recordAlerts),
          ),
        ],
      ),
    );
  }
}

class _EventHubCard extends StatelessWidget {
  const _EventHubCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: cs.surface,
      borderRadius: AppRadius.card,
      shadowColor: Colors.black12,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: AppRadius.card,
            boxShadow: AppShadows.level1,
            color: cs.surface,
            border: Border.all(color: cs.outlineVariant, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: AppRadius.button,
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: tt.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: tt.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: AppRadius.button,
                ),
                child: Icon(Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
