import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ── Crop type resolution ──────────────────────────────────────────────────────

enum CropType {
  cabbage,
  tomato,
  carrot,
  maize,
  wheat,
  sunflower,
  potato,
  onion,
  beans,
  leafy,
  generic,
}

CropType cropTypeFromName(String name) {
  final n = name.toLowerCase();
  if (n.contains('cabbage') || n.contains('kale') || n.contains('kohlrabi')) return CropType.cabbage;
  if (n.contains('tomato')) return CropType.tomato;
  if (n.contains('carrot') || n.contains('parsnip') || n.contains('beetroot') || n.contains('beet') || n.contains('radish') || n.contains('turnip')) return CropType.carrot;
  if (n.contains('maize') || n.contains('corn')) return CropType.maize;
  if (n.contains('wheat') || n.contains('barley') || n.contains('oat') || n.contains('rye') || n.contains('sorghum') || n.contains('grain') || n.contains('rice') || n.contains('teff') || n.contains('millet')) return CropType.wheat;
  if (n.contains('sunflower')) return CropType.sunflower;
  if (n.contains('potato') || n.contains('sweet potato') || n.contains('yam') || n.contains('cassava')) return CropType.potato;
  if (n.contains('onion') || n.contains('garlic') || n.contains('leek') || n.contains('shallot') || n.contains('chive')) return CropType.onion;
  if (n.contains('bean') || n.contains('soy') || n.contains('pea') || n.contains('lentil') || n.contains('chickpea') || n.contains('groundnut') || n.contains('peanut') || n.contains('cowpea') || n.contains('lupin')) return CropType.beans;
  if (n.contains('spinach') || n.contains('lettuce') || n.contains('chard') || n.contains('salad') || n.contains('mustard') || n.contains('arugula') || n.contains('rocket') || n.contains('watercress') || n.contains('pak choi') || n.contains('celery')) return CropType.leafy;
  if (n.contains('sugar cane') || n.contains('sugarcane') || n.contains('pepper') || n.contains('chilli') || n.contains('cucumber') || n.contains('pumpkin') || n.contains('squash') || n.contains('watermelon') || n.contains('melon') || n.contains('mango') || n.contains('avocado') || n.contains('citrus') || n.contains('orange') || n.contains('lemon') || n.contains('banana') || n.contains('grape') || n.contains('apple') || n.contains('eggplant') || n.contains('brinjal')) return CropType.generic;
  return CropType.generic;
}

// ── Growth stage ──────────────────────────────────────────────────────────────

enum GrowthStage { seed, seedling, vegetative, flowering, harvest }

GrowthStage stageFromProgress(double p) {
  if (p < 0.15) return GrowthStage.seed;
  if (p < 0.38) return GrowthStage.seedling;
  if (p < 0.62) return GrowthStage.vegetative;
  if (p < 0.85) return GrowthStage.flowering;
  return GrowthStage.harvest;
}

String stageLabel(GrowthStage s) => switch (s) {
      GrowthStage.seed      => 'Germination',
      GrowthStage.seedling  => 'Seedling',
      GrowthStage.vegetative => 'Vegetative',
      GrowthStage.flowering => 'Flowering',
      GrowthStage.harvest   => 'Harvest Ready',
    };

Color stageColor(GrowthStage s) => switch (s) {
      GrowthStage.seed      => const Color(0xFF8D6E63),
      GrowthStage.seedling  => const Color(0xFF66BB6A),
      GrowthStage.vegetative => const Color(0xFF2E7D32),
      GrowthStage.flowering => const Color(0xFFFB8C00),
      GrowthStage.harvest   => const Color(0xFFE53935),
    };

// ── SVG asset path resolution ─────────────────────────────────────────────────

String _cropTypeName(CropType type) => switch (type) {
      CropType.cabbage   => 'cabbage',
      CropType.tomato    => 'tomato',
      CropType.carrot    => 'carrot',
      CropType.maize     => 'maize',
      CropType.wheat     => 'wheat',
      CropType.sunflower => 'sunflower',
      CropType.potato    => 'potato',
      CropType.onion     => 'onion',
      CropType.beans     => 'beans',
      CropType.leafy     => 'leafy',
      CropType.generic   => 'generic',
    };

String _stageName(GrowthStage stage) => switch (stage) {
      GrowthStage.seed       => 'seed',
      GrowthStage.seedling   => 'seedling',
      GrowthStage.vegetative => 'vegetative',
      GrowthStage.flowering  => 'flowering',
      GrowthStage.harvest    => 'harvest',
    };

String svgAssetPath(CropType type, GrowthStage stage) =>
    'assets/icons/crops/${_cropTypeName(type)}_${_stageName(stage)}.svg';

// ── CropIllustration widget ───────────────────────────────────────────────────

/// Renders a professional SVG botanical illustration of a crop plant at a
/// given growth progress (0.0 = just planted, 1.0 = harvest ready).
/// Uses pre-drawn SVG assets for each crop type × growth stage combination.
class CropIllustration extends StatelessWidget {
  const CropIllustration({
    super.key,
    required this.cropName,
    this.growthProgress = 1.0,
    this.size = 120.0,
    this.showLabel = false,
    this.showSoil = true,
  });

  final String cropName;
  final double growthProgress;
  final double size;
  final bool showLabel;
  /// showSoil is retained for API compatibility — SVGs always include soil.
  final bool showSoil;

  @override
  Widget build(BuildContext context) {
    final type  = cropTypeFromName(cropName);
    final stage = stageFromProgress(growthProgress.clamp(0.0, 1.0));
    final path  = svgAssetPath(type, stage);
    final color = stageColor(stage);
    final tt    = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Builder(builder: (context) {
          try {
            return SvgPicture.asset(
              path,
              width: size,
              height: size,
              fit: BoxFit.contain,
              placeholderBuilder: (_) => SizedBox(
                width: size,
                height: size,
                child: Center(
                  child: Icon(Icons.eco_rounded, size: size * 0.5, color: const Color(0xFF388E3C)),
                ),
              ),
            );
          } catch (_) {
            return SizedBox(
              width: size,
              height: size,
              child: Center(
                child: Icon(Icons.eco_rounded, size: size * 0.5, color: const Color(0xFF388E3C)),
              ),
            );
          }
        }),
        if (showLabel) ...[
          const SizedBox(height: 4),
          Text(
            cropName,
            style: tt.labelSmall?.copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withAlpha(80)),
            ),
            child: Text(
              stageLabel(stage),
              style: TextStyle(
                fontSize: 9,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Growth stage bar ──────────────────────────────────────────────────────────

class GrowthStageBar extends StatelessWidget {
  const GrowthStageBar({
    super.key,
    required this.progress,
    this.cropName = '',
  });

  final double progress;
  final String cropName;

  @override
  Widget build(BuildContext context) {
    final stage = stageFromProgress(progress.clamp(0.0, 1.0));
    final color = stageColor(stage);
    final tt    = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Growth Stage',
              style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withAlpha(80)),
              ),
              child: Text(
                stageLabel(stage),
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Segmented stage track
        Row(
          children: GrowthStage.values.map((s) {
            final idx        = GrowthStage.values.indexOf(s);
            final stageEnd   = (idx + 1) / GrowthStage.values.length;
            final stageStart = idx / GrowthStage.values.length;
            final filled     = progress >= stageEnd;
            final active     = stage == s;
            final partial    = active
                ? ((progress - stageStart) / (stageEnd - stageStart)).clamp(0.0, 1.0)
                : 0.0;
            final sc         = stageColor(s);

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.5),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        height: 10,
                        child: Stack(
                          children: [
                            Container(color: sc.withAlpha(30)),
                            FractionallySizedBox(
                              widthFactor: filled ? 1.0 : partial,
                              child: Container(color: sc),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stageLabel(s).split(' ').first,
                      style: TextStyle(
                        fontSize: 8.5,
                        color: filled || active ? sc : Colors.grey,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).round()}% complete',
          style: tt.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
