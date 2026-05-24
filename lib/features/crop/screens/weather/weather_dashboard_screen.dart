import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../models/farm_weather.dart';
import '../../models/weather_alert.dart';
import '../../providers/crop_providers.dart';

// Maps WeatherCondition to a Material icon for the current-conditions header.
IconData _conditionIcon(WeatherCondition c) => switch (c) {
      WeatherCondition.sunny => Icons.wb_sunny_rounded,
      WeatherCondition.partlyCloudy => Icons.wb_cloudy_rounded,
      WeatherCondition.cloudy => Icons.cloud_rounded,
      WeatherCondition.lightRain => Icons.grain_rounded,
      WeatherCondition.rain => Icons.water_drop_rounded,
      WeatherCondition.heavyRain => Icons.water_drop_rounded,
      WeatherCondition.thunderstorm => Icons.bolt_rounded,
      WeatherCondition.fog => Icons.cloud_outlined,
      WeatherCondition.windy => Icons.air_rounded,
      WeatherCondition.frosty => Icons.ac_unit_rounded,
    };

class WeatherDashboardScreen extends ConsumerWidget {
  const WeatherDashboardScreen({super.key});

  static const _farmId = 'FARM-001';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(currentWeatherProvider(_farmId));
    final forecastAsync = ref.watch(weatherForecastProvider(_farmId));
    final alertsAsync = ref.watch(agriculturalAlertsProvider(_farmId));

    return FarmScaffold(
      appBar: FarmAppBar(title: 'Weather & Alerts'),
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
              child: weatherAsync.when(
                loading: () => const LoadingShimmer(height: 160),
                error: (e, _) => _ErrorTile(message: 'Failed to load weather: $e'),
                data: (weather) => _CurrentConditionsCard(weather: weather),
              ),
            ),
          ),

          // ── 10-day Forecast ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: forecastAsync.when(
                loading: () => const LoadingShimmer(height: 100),
                error: (_, __) => const _ErrorTile(message: 'Failed to load forecast'),
                data: (days) => _ForecastRow(days: days),
              ),
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
                  style: const TextStyle(color: AppColors.error),
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
              child: weatherAsync.when(
                loading: () => const LoadingShimmer(height: 72),
                error: (_, __) =>
                    const _SpraySuitabilityCard(sprayWindow: SprayWindow.marginal),
                data: (weather) =>
                    _SpraySuitabilityCard(sprayWindow: weather.sprayWindow),
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
  const _CurrentConditionsCard({required this.weather});

  final FarmWeather weather;

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weather.locationName,
                    style: tt.labelMedium?.copyWith(
                      color: AppColors.onPrimary.withAlpha(217),
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'Updated ${DateFormat('HH:mm').format(weather.fetchedAt)}',
                    style: tt.labelSmall?.copyWith(
                      color: AppColors.onPrimary.withAlpha(153),
                    ),
                  ),
                ],
              ),
              Icon(
                _conditionIcon(weather.condition),
                color: AppColors.onPrimary,
                size: AppSpacing.iconLg,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${weather.tempC.round()}°C',
            style: tt.displaySmall?.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            weather.condition.label,
            style: tt.bodyLarge?.copyWith(color: AppColors.onPrimary),
          ),
          if (weather.feelsLikeC.round() != weather.tempC.round())
            Text(
              'Feels like ${weather.feelsLikeC.round()}°C',
              style: tt.bodySmall?.copyWith(
                color: AppColors.onPrimary.withAlpha(179),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              _ConditionChip(
                icon: Icons.water_drop_outlined,
                label: '${weather.humidity.round()}% Humidity',
              ),
              _ConditionChip(
                icon: Icons.air_rounded,
                label:
                    'Wind ${weather.windKmh.round()} km/h ${weather.windDirection}',
              ),
              if (weather.rainfallMm24h > 0)
                _ConditionChip(
                  icon: Icons.umbrella_rounded,
                  label: '${weather.rainfallMm24h}mm today',
                ),
              _ConditionChip(
                icon: Icons.wb_sunny_outlined,
                label: 'UV ${weather.uvIndex}',
              ),
              if (weather.frostRisk)
                const _ConditionChip(
                  icon: Icons.ac_unit_rounded,
                  label: 'Frost Risk',
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

// ── 10-day Forecast Row ───────────────────────────────────────────────────────

class _ForecastRow extends StatelessWidget {
  const _ForecastRow({required this.days});

  final List<WeatherForecastDay> days;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) => _ForecastCard(day: days[i]),
      ),
    );
  }
}

class _ForecastCard extends StatelessWidget {
  const _ForecastCard({required this.day});

  final WeatherForecastDay day;

  Color _iconColor(BuildContext context) => switch (day.condition) {
        WeatherCondition.sunny || WeatherCondition.partlyCloudy =>
          AppColors.secondary,
        WeatherCondition.lightRain ||
        WeatherCondition.rain ||
        WeatherCondition.heavyRain =>
          AppColors.tertiary,
        WeatherCondition.thunderstorm => AppColors.error,
        WeatherCondition.frosty => AppColors.primaryLight,
        _ => Theme.of(context).colorScheme.onSurfaceVariant,
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final today = DateTime.now();
    final isToday = DateUtils.isSameDay(day.date, today);
    final dayLabel =
        isToday ? 'Today' : DateFormat('E').format(day.date);

    return Container(
      width: 68,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isToday
            ? AppColors.primary.withAlpha(20)
            : cs.surfaceContainerLow,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: isToday
              ? AppColors.primary.withAlpha(102)
              : cs.outlineVariant,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dayLabel,
            style: tt.labelSmall?.copyWith(
              color: isToday ? AppColors.primary : cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Emoji icon — unambiguous across condition types
          Text(
            day.condition.icon,
            style: const TextStyle(fontSize: 20),
          ),
          if (day.frostRisk)
            Icon(Icons.ac_unit_rounded,
                size: 10, color: _iconColor(context)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${day.maxTempC.round()}°',
            style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            '${day.minTempC.round()}°',
            style: tt.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
          if (day.rainfallMm > 0)
            Text(
              '${day.rainfallMm.round()}mm',
              style: TextStyle(
                color: AppColors.tertiary,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
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
                  child:
                      Icon(_alertIcon, color: _severityColor, size: 22),
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
                    style: tt.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
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
  const _SpraySuitabilityCard({required this.sprayWindow});

  final SprayWindow sprayWindow;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    final (Color color, Color containerColor, IconData icon) = switch (
      sprayWindow
    ) {
      SprayWindow.suitable => (
          AppColors.success,
          AppColors.successContainer,
          Icons.check_circle_rounded,
        ),
      SprayWindow.unsuitable => (
          AppColors.error,
          AppColors.errorContainer,
          Icons.cancel_rounded,
        ),
      SprayWindow.marginal => (
          AppColors.warning,
          AppColors.warningContainer,
          Icons.warning_rounded,
        ),
    };

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sprayWindow.label,
                  style: tt.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (sprayWindow == SprayWindow.marginal)
                  Text(
                    'Check wind speed before starting',
                    style: tt.bodySmall
                        ?.copyWith(color: color.withAlpha(179)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error tile ────────────────────────────────────────────────────────────────

class _ErrorTile extends StatelessWidget {
  const _ErrorTile({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: AppRadius.card,
      ),
      child: Text(
        message,
        style: const TextStyle(color: AppColors.error),
      ),
    );
  }
}
