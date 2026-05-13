import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
      GrowthStage.seed       => 'Germination',
      GrowthStage.seedling   => 'Seedling',
      GrowthStage.vegetative => 'Vegetative',
      GrowthStage.flowering  => 'Flowering',
      GrowthStage.harvest    => 'Harvest Ready',
    };

Color stageColor(GrowthStage s) => switch (s) {
      GrowthStage.seed       => const Color(0xFF8D6E63),
      GrowthStage.seedling   => const Color(0xFF66BB6A),
      GrowthStage.vegetative => const Color(0xFF2E7D32),
      GrowthStage.flowering  => const Color(0xFFFB8C00),
      GrowthStage.harvest    => const Color(0xFFE53935),
    };

// ── Real crop photo URLs (Unsplash) ───────────────────────────────────────────

String cropImageUrl(CropType type) => switch (type) {
      CropType.maize     => 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=400&q=80&fit=crop',
      CropType.wheat     => 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400&q=80&fit=crop',
      CropType.tomato    => 'https://images.unsplash.com/photo-1592841200221-a6898f307baa?w=400&q=80&fit=crop',
      CropType.cabbage   => 'https://images.unsplash.com/photo-1551754655-cd27e38d2076?w=400&q=80&fit=crop',
      CropType.carrot    => 'https://images.unsplash.com/photo-1447175008436-054170c2e979?w=400&q=80&fit=crop',
      CropType.potato    => 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=400&q=80&fit=crop',
      CropType.onion     => 'https://images.unsplash.com/photo-1508747703725-719777637510?w=400&q=80&fit=crop',
      CropType.sunflower => 'https://images.unsplash.com/photo-1597848212624-a19eb35e2651?w=400&q=80&fit=crop',
      CropType.beans     => 'https://images.unsplash.com/photo-1590165482129-1b8b27698780?w=400&q=80&fit=crop',
      CropType.leafy     => 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400&q=80&fit=crop',
      CropType.generic   => 'https://images.unsplash.com/photo-1500595046743-cd271d694d30?w=400&q=80&fit=crop',
    };

// ── Crop icon fallback per type ───────────────────────────────────────────────

IconData _cropIcon(CropType type) => switch (type) {
      CropType.maize     => Icons.grain,
      CropType.wheat     => Icons.grain,
      CropType.sunflower => Icons.filter_vintage_outlined,
      CropType.beans     => Icons.spa_outlined,
      CropType.leafy     => Icons.eco_outlined,
      _                  => Icons.local_florist_outlined,
    };

Color _cropColor(CropType type) => switch (type) {
      CropType.maize     => const Color(0xFFF9A825),
      CropType.wheat     => const Color(0xFFFFB300),
      CropType.tomato    => const Color(0xFFE53935),
      CropType.cabbage   => const Color(0xFF43A047),
      CropType.carrot    => const Color(0xFFFF6D00),
      CropType.potato    => const Color(0xFF8D6E63),
      CropType.onion     => const Color(0xFF7B1FA2),
      CropType.sunflower => const Color(0xFFFDD835),
      CropType.beans     => const Color(0xFF2E7D32),
      CropType.leafy     => const Color(0xFF1B5E20),
      CropType.generic   => const Color(0xFF388E3C),
    };

// ── CropIllustration widget ───────────────────────────────────────────────────

/// Shows a real crop photo thumbnail.
/// Falls back to a coloured avatar with crop icon if image is unavailable.
class CropIllustration extends StatelessWidget {
  const CropIllustration({
    super.key,
    required this.cropName,
    this.growthProgress = 1.0,
    this.size = 120.0,
    this.showLabel = false,
    this.showSoil = true, // retained for API compatibility
  });

  final String cropName;
  final double growthProgress;
  final double size;
  final bool showLabel;
  final bool showSoil;

  @override
  Widget build(BuildContext context) {
    final type  = cropTypeFromName(cropName);
    final stage = stageFromProgress(growthProgress.clamp(0.0, 1.0));
    final color = stageColor(stage);
    final bg    = _cropColor(type);
    final url   = cropImageUrl(type);
    final radius = size * 0.2;
    final tt    = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: CachedNetworkImage(
            imageUrl: url,
            width: size,
            height: size,
            fit: BoxFit.cover,
            fadeInDuration: const Duration(milliseconds: 200),
            placeholder: (_, __) => _Fallback(size: size, bg: bg, type: type),
            errorWidget:  (_, __, ___) => _Fallback(size: size, bg: bg, type: type),
          ),
        ),
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

class _Fallback extends StatelessWidget {
  const _Fallback({required this.size, required this.bg, required this.type});
  final double size;
  final Color bg;
  final CropType type;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        color: bg.withAlpha(40),
        child: Icon(
          _cropIcon(type),
          size: size * 0.45,
          color: bg,
        ),
      );
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
            final sc = stageColor(s);

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
