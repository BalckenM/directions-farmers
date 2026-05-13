import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'crop_illustration.dart';

// ── Field Visualization Widget ─────────────────────────────────────────────────
//
// Full-bleed real crop photo header with dark gradient overlay and info badges.

class FieldVisualizationWidget extends StatelessWidget {
  const FieldVisualizationWidget({
    super.key,
    required this.cropName,
    required this.growthProgress,
    this.height = 240.0,
    this.fieldName,
  });

  final String cropName;
  final double growthProgress;
  final double height;
  final String? fieldName;

  @override
  Widget build(BuildContext context) {
    final type  = cropTypeFromName(cropName);
    final stage = stageFromProgress(growthProgress.clamp(0.0, 1.0));
    final color = stageColor(stage);
    final bg    = _cropColor(type);
    final url   = _fieldImageUrl(type);

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft:  Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [

            // ── Layer 1: Real crop photo ────────────────────────────────────
            CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 300),
              placeholder: (_, __) => Container(color: bg.withAlpha(60)),
              errorWidget: (_, __, ___) => _FallbackBackground(color: bg, cropName: cropName),
            ),

            // ── Layer 2: Gradient overlay — top & bottom readability ────────
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.35, 0.65, 1.0],
                  colors: [
                    Colors.black.withAlpha(140),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withAlpha(160),
                  ],
                ),
              ),
            ),

            // ── Layer 3: Field name badge (top-left) ────────────────────────
            if (fieldName != null)
              Positioned(
                top: 12,
                left: 16,
                child: _Badge(
                  icon: Icons.crop_square_rounded,
                  label: fieldName!,
                  bg: Colors.black.withAlpha(130),
                  fg: Colors.white,
                ),
              ),

            // ── Layer 4: Growth stage badge (bottom-right) ──────────────────
            Positioned(
              bottom: 12,
              right: 16,
              child: _Badge(
                icon: Icons.eco_rounded,
                label: stageLabel(stage),
                bg: color,
                fg: Colors.white,
                shadow: BoxShadow(
                  color: color.withAlpha(90),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ),
            ),

            // ── Layer 5: Crop name badge (bottom-left) ──────────────────────
            Positioned(
              bottom: 12,
              left: 16,
              child: _Badge(
                label: cropName,
                bg: Colors.black.withAlpha(130),
                fg: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Field-size image URLs (wider crop, higher res than thumbnail) ─────────────

String _fieldImageUrl(CropType type) => switch (type) {
      CropType.maize     => 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=900&h=400&fit=crop&q=85',
      CropType.wheat     => 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=900&h=400&fit=crop&q=85',
      CropType.tomato    => 'https://images.unsplash.com/photo-1592841200221-a6898f307baa?w=900&h=400&fit=crop&q=85',
      CropType.cabbage   => 'https://images.unsplash.com/photo-1551754655-cd27e38d2076?w=900&h=400&fit=crop&q=85',
      CropType.carrot    => 'https://images.unsplash.com/photo-1447175008436-054170c2e979?w=900&h=400&fit=crop&q=85',
      CropType.potato    => 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=900&h=400&fit=crop&q=85',
      CropType.onion     => 'https://images.unsplash.com/photo-1508747703725-719777637510?w=900&h=400&fit=crop&q=85',
      CropType.sunflower => 'https://images.unsplash.com/photo-1597848212624-a19eb35e2651?w=900&h=400&fit=crop&q=85',
      CropType.beans     => 'https://images.unsplash.com/photo-1590165482129-1b8b27698780?w=900&h=400&fit=crop&q=85',
      CropType.leafy     => 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=900&h=400&fit=crop&q=85',
      CropType.generic   => 'https://images.unsplash.com/photo-1500595046743-cd271d694d30?w=900&h=400&fit=crop&q=85',
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

// ── Shared badge widget ───────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.bg,
    required this.fg,
    this.icon,
    this.shadow,
  });

  final String label;
  final Color bg;
  final Color fg;
  final IconData? icon;
  final BoxShadow? shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: shadow != null ? [shadow!] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: fg, size: 13),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: icon != null ? 11 : 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Fallback when image fails to load ────────────────────────────────────────

class _FallbackBackground extends StatelessWidget {
  const _FallbackBackground({required this.color, required this.cropName});
  final Color color;
  final String cropName;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withAlpha(200), color.withAlpha(120)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.agriculture_rounded, size: 56, color: Colors.white.withAlpha(180)),
            const SizedBox(height: 8),
            Text(
              cropName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
