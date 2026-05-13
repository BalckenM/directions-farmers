import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../models/crop.dart';
import '../../providers/crop_providers.dart';

// ── Month abbreviations ───────────────────────────────────────────────────────

const List<String> _monthAbbr = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

// ── Screen ────────────────────────────────────────────────────────────────────

class CropDetailScreen extends ConsumerWidget {
  const CropDetailScreen({super.key, required this.cropId});
  final String cropId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cropAsync = ref.watch(cropByIdProvider(cropId));

    return cropAsync.when(
      loading: () => FarmScaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text('Loading…'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: LoadingShimmer.list(count: 5, itemHeight: 80),
        ),
      ),
      error: (e, _) => FarmScaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text('Error'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 48, color: AppColors.error),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Unable to load crop details',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.error),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (crop) {
        if (crop == null) {
          return FarmScaffold(
            appBar: AppBar(
              elevation: 0,
              title: const Text('Not Found'),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: AppSpacing.iconXl,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withAlpha(80),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Crop not found',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return FarmScaffold(
          appBar: null,
          body: _CropDetailBody(crop: crop),
        );
      },
    );
  }
}

// ── Detail body ───────────────────────────────────────────────────────────────

class _CropDetailBody extends StatelessWidget {
  const _CropDetailBody({required this.crop});
  final Crop crop;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ── SliverAppBar hero ──────────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 160,
          pinned: true,
          backgroundColor: AppColors.cropGreen,
          foregroundColor: AppColors.onPrimary,
          leading: BackButton(color: AppColors.onPrimary),
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            title: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  crop.name,
                  style: const TextStyle(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                if (crop.scientificName != null)
                  Text(
                    crop.scientificName!,
                    style: TextStyle(
                      color: AppColors.onPrimary.withAlpha(204),
                      fontStyle: FontStyle.italic,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.cropGreen, AppColors.cropGreenDark],
                ),
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: _CategoryBadge(categoryId: crop.categoryId),
                ),
              ),
            ),
          ),
        ),

        // ── Body sections ──────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePaddingHorizontal,
            AppSpacing.md,
            AppSpacing.pagePaddingHorizontal,
            AppSpacing.xxl,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // 1. Planting Window
              _SectionTitle('Planting Window'),
              const SizedBox(height: AppSpacing.sm),
              _PlantingCalendarRow(crop: crop),
              const SizedBox(height: AppSpacing.lg),

              // 2. Key Stats
              _SectionTitle('Key Statistics'),
              const SizedBox(height: AppSpacing.sm),
              _KeyStatsRow(crop: crop),
              const SizedBox(height: AppSpacing.lg),

              // 3. Suitable Provinces
              _SectionTitle('Suitable Provinces'),
              const SizedBox(height: AppSpacing.sm),
              _ProvinceChips(provinces: crop.suitableProvinces),
              const SizedBox(height: AppSpacing.lg),

              // 4. Soil & Climate
              _SectionTitle('Soil & Climate'),
              const SizedBox(height: AppSpacing.sm),
              _SoilClimateGrid(crop: crop),
              const SizedBox(height: AppSpacing.lg),

              // 5. Common Pests & Diseases
              _SectionTitle('Pests & Diseases'),
              const SizedBox(height: AppSpacing.sm),
              _PestsDiseaseRow(
                pests: crop.commonPests,
                diseases: crop.commonDiseases,
              ),
              const SizedBox(height: AppSpacing.lg),

              // 6. Fertilizer guide (if available)
              if (crop.fertilizerNKgHa != null ||
                  crop.fertilizerPKgHa != null ||
                  crop.fertilizerKKgHa != null) ...[
                _SectionTitle('Fertilizer Guide'),
                const SizedBox(height: AppSpacing.sm),
                _FertilizerCard(crop: crop),
                const SizedBox(height: AppSpacing.lg),
              ],
            ]),
          ),
        ),
      ],
    );
  }
}

// ── Category badge ────────────────────────────────────────────────────────────

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.categoryId});
  final String categoryId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.onPrimary.withAlpha(30),
        borderRadius: AppRadius.chip,
        border: Border.all(color: AppColors.onPrimary.withAlpha(60)),
      ),
      child: Text(
        _capitalize(categoryId.replaceAll('_', ' ')),
        style: const TextStyle(
          color: AppColors.onPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ── Section title ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.cropGreen,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
        ),
      ],
    );
  }
}

// ── Planting calendar row ─────────────────────────────────────────────────────

class _PlantingCalendarRow extends StatelessWidget {
  const _PlantingCalendarRow({required this.crop});
  final Crop crop;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: AppRadius.card,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          // Legend
          Row(
            children: [
              _LegendItem(color: AppColors.cropGreen, label: 'Planting'),
              const SizedBox(width: AppSpacing.md),
              _LegendItem(color: AppColors.secondary, label: 'Harvest'),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Month grid
          Row(
            children: List.generate(12, (i) {
              final month = i + 1;
              final isPlanting = crop.plantingMonths.contains(month);
              final isHarvest = crop.harvestMonths.contains(month);

              Color bgColor;
              Color textColor;

              if (isPlanting && isHarvest) {
                bgColor = AppColors.cropGreen.withAlpha(60);
                textColor = AppColors.cropGreen;
              } else if (isPlanting) {
                bgColor = AppColors.cropGreen;
                textColor = AppColors.onPrimary;
              } else if (isHarvest) {
                bgColor = AppColors.secondary;
                textColor = AppColors.onSecondary;
              } else {
                bgColor = cs.surfaceContainerHighest;
                textColor = cs.onSurfaceVariant;
              }

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _monthAbbr[i].substring(0, 1),
                    textAlign: TextAlign.center,
                    style: tt.labelSmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Full month labels
          Row(
            children: List.generate(12, (i) {
              return Expanded(
                child: Text(
                  _monthAbbr[i].substring(0, 1),
                  textAlign: TextAlign.center,
                  style: tt.labelSmall?.copyWith(
                    fontSize: 8,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

// ── Key stats row ─────────────────────────────────────────────────────────────

class _KeyStatsRow extends StatelessWidget {
  const _KeyStatsRow({required this.crop});
  final Crop crop;

  @override
  Widget build(BuildContext context) {
    final yieldStr = crop.bestYieldTHa != null
        ? '${crop.bestYieldTHa!.toStringAsFixed(1)} t/ha'
        : 'N/A';

    return Row(
      children: [
        _StatCard(
          icon: Icons.schedule_rounded,
          label: 'Maturity',
          value: '${crop.maturityDaysMin}–${crop.maturityDaysMax}',
          sub: 'days',
          color: AppColors.cropGreen,
        ),
        const SizedBox(width: AppSpacing.sm),
        _StatCard(
          icon: Icons.water_drop_outlined,
          label: 'Water',
          value: _capitalize(crop.waterRequirement),
          sub: 'requirement',
          color: AppColors.tertiary,
        ),
        const SizedBox(width: AppSpacing.sm),
        _StatCard(
          icon: Icons.grass_rounded,
          label: 'Best Yield',
          value: yieldStr,
          sub: 'estimated',
          color: AppColors.secondary,
        ),
      ],
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: AppRadius.card,
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: tt.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: tt.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              sub,
              style: tt.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Province chips ────────────────────────────────────────────────────────────

class _ProvinceChips extends StatelessWidget {
  const _ProvinceChips({required this.provinces});
  final List<String> provinces;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (provinces.isEmpty) {
      return Text(
        'Province data not available',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
      );
    }
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: provinces.map((p) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.cropGreen.withAlpha(15),
            borderRadius: AppRadius.chip,
            border: Border.all(color: AppColors.cropGreen.withAlpha(50)),
          ),
          child: Text(
            p,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.cropGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Soil & climate grid ───────────────────────────────────────────────────────

class _SoilClimateGrid extends StatelessWidget {
  const _SoilClimateGrid({required this.crop});
  final Crop crop;

  @override
  Widget build(BuildContext context) {
    final soilLabel = crop.soilTypes.isEmpty
        ? 'N/A'
        : crop.soilTypes.join(', ');
    final tempLabel =
        '${crop.temperatureMinC.toStringAsFixed(0)}–${crop.temperatureMaxC.toStringAsFixed(0)} °C';
    final rainLabel = '${crop.rainfallMmMin}–${crop.rainfallMmMax} mm/yr';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _InfoBlock(
            icon: Icons.landscape_rounded,
            title: 'Soil Types',
            content: soilLabel,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            children: [
              _InfoBlock(
                icon: Icons.thermostat_rounded,
                title: 'Temperature',
                content: tempLabel,
                color: AppColors.error,
              ),
              const SizedBox(height: AppSpacing.sm),
              _InfoBlock(
                icon: Icons.water_rounded,
                title: 'Rainfall',
                content: rainLabel,
                color: AppColors.tertiary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
  });
  final IconData icon;
  final String title;
  final String content;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: AppRadius.card,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: AppSpacing.xs),
              Text(
                title,
                style: tt.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            content,
            style: tt.bodySmall?.copyWith(
              color: cs.onSurface,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pests & diseases row ──────────────────────────────────────────────────────

class _PestsDiseaseRow extends StatelessWidget {
  const _PestsDiseaseRow({
    required this.pests,
    required this.diseases,
  });
  final List<String> pests;
  final List<String> diseases;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _ListBlock(
            title: 'Common Pests',
            icon: Icons.bug_report_rounded,
            items: pests,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _ListBlock(
            title: 'Diseases',
            icon: Icons.coronavirus_rounded,
            items: diseases,
            color: AppColors.error,
          ),
        ),
      ],
    );
  }
}

class _ListBlock extends StatelessWidget {
  const _ListBlock({
    required this.title,
    required this.icon,
    required this.items,
    required this.color,
  });
  final String title;
  final IconData icon;
  final List<String> items;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: AppRadius.card,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  title,
                  style: tt.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          if (items.isEmpty)
            Text(
              'None recorded',
              style: tt.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontSize: 10,
              ),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: tt.labelSmall?.copyWith(
                        color: color,
                        fontSize: 10,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurface,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Fertilizer card ───────────────────────────────────────────────────────────

class _FertilizerCard extends StatelessWidget {
  const _FertilizerCard({required this.crop});
  final Crop crop;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.cropGreen.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science_rounded, size: 16, color: AppColors.cropGreen),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'NPK Recommendations (kg/ha)',
                style: tt.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.cropGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _NpkChip(
                label: 'N',
                value: crop.fertilizerNKgHa,
                color: AppColors.cropGreen,
              ),
              const SizedBox(width: AppSpacing.sm),
              _NpkChip(
                label: 'P',
                value: crop.fertilizerPKgHa,
                color: AppColors.secondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              _NpkChip(
                label: 'K',
                value: crop.fertilizerKKgHa,
                color: AppColors.tertiary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Values are indicative. Consult a certified agronomist for site-specific recommendations.',
            style: tt.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontSize: 9,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _NpkChip extends StatelessWidget {
  const _NpkChip({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final double? value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final display = value != null ? value!.toStringAsFixed(0) : 'N/A';

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: AppRadius.card,
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: tt.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            Text(
              display,
              style: tt.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
                fontSize: 13,
              ),
            ),
            Text(
              'kg/ha',
              style: tt.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

