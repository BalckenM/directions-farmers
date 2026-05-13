import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../models/weather_alert.dart';
import '../../providers/crop_providers.dart';

class WeatherDashboardScreen extends ConsumerWidget {
  const WeatherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(weatherAlertsProvider(null));

    return FarmScaffold(
      appBar: AppBar(
        title: const Text('Weather & Alerts'),
      ),
      body: CustomScrollView(
        slivers: [
          // ── Current Conditions ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: _CurrentConditionsCard(),
            ),
          ),

          // ── 5-day Forecast ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: _ForecastRow(),
            ),
          ),

          // ── Farm Alerts ────────────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Farm Alerts'),
          ),

          alertsAsync.when(
            loading: () => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: LoadingShimmer.list(count: 3, itemHeight: 90),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'Failed to load alerts: $e',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ),
            data: (alerts) {
              if (alerts.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      'No active alerts.',
                      style: TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    child: _AlertCard(alert: alerts[index]),
                  ),
                  childCount: alerts.length,
                ),
              );
            },
          ),

          // ── Spray Suitability ──────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Spray Suitability'),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.xl,
              ),
              child: alertsAsync.when(
                loading: () => const LoadingShimmer(height: 72),
                error: (_, _) => const _SpraySuitabilityCard(suitable: true),
                data: (alerts) {
                  final unsuitable = alerts.any(
                    (a) =>
                        a.alertType == WeatherAlertType.sprayUnsuitable &&
                        a.isActive,
                  );
                  return _SpraySuitabilityCard(suitable: !unsuitable);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Current Conditions Card ──────────────────────────────────────────────────

class _CurrentConditionsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.card,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(89),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Conditions',
                style: tt.labelMedium?.copyWith(
                  color: AppColors.onPrimary.withAlpha(217),
                  letterSpacing: 0.5,
                ),
              ),
              const Icon(
                Icons.wb_sunny_rounded,
                color: AppColors.onPrimary,
                size: AppSpacing.iconLg,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '28°C',
            style: tt.displaySmall?.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Mostly Sunny',
            style: tt.bodyLarge?.copyWith(color: AppColors.onPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _ConditionChip(
                icon: Icons.water_drop_outlined,
                label: '62% Humidity',
              ),
              const SizedBox(width: AppSpacing.sm),
              _ConditionChip(
                icon: Icons.air_rounded,
                label: 'Wind 12 km/h SW',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConditionChip extends StatelessWidget {
  const _ConditionChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.onPrimary.withAlpha(46),
        borderRadius: AppRadius.chip,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSpacing.iconSm, color: AppColors.onPrimary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.onPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 5-day Forecast Row ────────────────────────────────────────────────────────

class _ForecastRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const forecastDays = [
      _ForecastDay('Mon', Icons.wb_sunny_rounded, '31°', '18°'),
      _ForecastDay('Tue', Icons.cloud_outlined, '28°', '16°'),
      _ForecastDay('Wed', Icons.water_drop_rounded, '22°', '15°'),
      _ForecastDay('Thu', Icons.cloud_rounded, '24°', '14°'),
      _ForecastDay('Fri', Icons.wb_sunny_rounded, '29°', '17°'),
    ];

    return Row(
      children: forecastDays
          .map((d) => Expanded(child: _ForecastCard(day: d)))
          .toList(),
    );
  }
}

class _ForecastDay {
  const _ForecastDay(this.day, this.icon, this.tempMax, this.tempMin);
  final String day;
  final IconData icon;
  final String tempMax;
  final String tempMin;
}

class _ForecastCard extends StatelessWidget {
  const _ForecastCard({required this.day});
  final _ForecastDay day;

  Color get _iconColor {
    if (day.icon == Icons.water_drop_rounded) return AppColors.tertiary;
    if (day.icon == Icons.cloud_rounded) return AppColors.onSurfaceVariant;
    return AppColors.secondary;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: AppRadius.card,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            day.day,
            style: tt.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Icon(day.icon, size: 20, color: _iconColor),
          const SizedBox(height: AppSpacing.xs),
          Text(
            day.tempMax,
            style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            day.tempMin,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ── Alert Card ────────────────────────────────────────────────────────────────

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert});
  final WeatherAlert alert;

  Color get _severityColor => switch (alert.severity) {
        'critical' => AppColors.error,
        'high' => AppColors.secondaryDark,
        'medium' => AppColors.warning,
        _ => AppColors.tertiary,
      };

  Color get _severityContainerColor => switch (alert.severity) {
        'critical' => AppColors.errorContainer,
        'high' => AppColors.secondaryContainer,
        'medium' => AppColors.warningContainer,
        _ => AppColors.tertiaryContainer,
      };

  IconData get _alertIcon => switch (alert.alertType) {
        WeatherAlertType.frostWarning => Icons.ac_unit_rounded,
        WeatherAlertType.heatStress => Icons.thermostat_rounded,
        WeatherAlertType.rainForecast => Icons.water_drop_rounded,
        WeatherAlertType.droughtWarning => Icons.wb_sunny_rounded,
        WeatherAlertType.sprayUnsuitable => Icons.science_rounded,
        WeatherAlertType.spraySuitable => Icons.science_rounded,
        WeatherAlertType.plantingOpportunity => Icons.spa_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final dateFmt = DateFormat('dd MMM yyyy');

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(color: _severityColor.withAlpha(76)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Severity + icon column
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: _severityContainerColor,
                    borderRadius: AppRadius.card,
                  ),
                  child: Icon(_alertIcon, color: _severityColor, size: 22),
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _severityColor,
                    borderRadius: AppRadius.chip,
                  ),
                  child: Text(
                    alert.severity.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.onPrimary,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    alert.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      if (alert.actionRequired) ...[
                        Chip(
                          label: const Text('Action Required'),
                          labelStyle: const TextStyle(
                            color: AppColors.onError,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          backgroundColor: AppColors.error,
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Text(
                        'Until ${dateFmt.format(alert.validUntil)}',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Spray Suitability Card ────────────────────────────────────────────────────

class _SpraySuitabilityCard extends StatelessWidget {
  const _SpraySuitabilityCard({required this.suitable});
  final bool suitable;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final color = suitable ? AppColors.success : AppColors.error;
    final containerColor =
        suitable ? AppColors.successContainer : AppColors.errorContainer;
    final icon = suitable ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final label = suitable
        ? 'Conditions Suitable for Spraying'
        : 'Conditions Unsuitable for Spraying';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: AppRadius.card,
        border: Border.all(color: color.withAlpha(102)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: AppSpacing.iconLg),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: tt.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
