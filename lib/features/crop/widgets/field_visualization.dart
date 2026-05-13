import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'crop_illustration.dart';

// ── Field Visualization Widget ─────────────────────────────────────────────────
//
// A scenic field header showing sky, sun, clouds, rolling hills, furrowed soil,
// and a row of professional SVG crop illustrations at their current growth stage.

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
    final path  = svgAssetPath(type, stage);
    final color = stageColor(stage);

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

            // ── Layer 1: Scenic landscape (sky + sun + hills + soil) ────────────
            CustomPaint(
              painter: _LandscapePainter(),
            ),

            // ── Layer 2: Crop row — 5 SVG plants on the soil line ──────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: height * 0.62,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(5, (i) {
                  // Slight size variation for natural depth
                  final scale = i == 2 ? 1.0 : (i == 1 || i == 3 ? 0.88 : 0.76);
                  final cropH = height * 0.56 * scale;
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: Builder(builder: (_) {
                      try {
                        return SvgPicture.asset(
                          path,
                          height: cropH,
                          width: cropH * 0.75,
                          fit: BoxFit.contain,
                          placeholderBuilder: (__) => SizedBox(
                            height: cropH,
                            width: cropH * 0.75,
                            child: Icon(Icons.eco_rounded,
                                size: cropH * 0.5,
                                color: const Color(0xFF388E3C)),
                          ),
                        );
                      } catch (_) {
                        return SizedBox(
                          height: cropH,
                          width: cropH * 0.75,
                          child: Icon(Icons.eco_rounded,
                              size: cropH * 0.5,
                              color: const Color(0xFF388E3C)),
                        );
                      }
                    }),
                  );
                }),
              ),
            ),

            // ── Layer 3: Field name badge (top-left) ───────────────────────────
            if (fieldName != null)
              Positioned(
                top: 12,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(110),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.crop_square_rounded, color: Colors.white, size: 13),
                      const SizedBox(width: 5),
                      Text(
                        fieldName!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Layer 4: Growth stage badge (bottom-right) ─────────────────────
            Positioned(
              bottom: 12,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: color.withAlpha(80), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.eco_rounded, color: Colors.white, size: 13),
                    const SizedBox(width: 5),
                    Text(
                      stageLabel(stage),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Layer 5: Crop name badge (bottom-left) ─────────────────────────
            Positioned(
              bottom: 12,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(110),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  cropName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Landscape CustomPainter — sky, sun, clouds, hills, soil ───────────────────
// Does NOT draw crops — those are SVG widgets overlaid in the Stack above.

class _LandscapePainter extends CustomPainter {
  const _LandscapePainter();

  @override
  void paint(Canvas canvas, Size size) {
    _drawSky(canvas, size);
    _drawSun(canvas, size);
    _drawClouds(canvas, size);
    _drawDistantHills(canvas, size);
    _drawGrassMiddleGround(canvas, size);
    _drawFurrowedSoil(canvas, size);
    _drawFence(canvas, size);
  }

  void _drawSky(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 0.65);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.6],
          colors: [Color(0xFF1E88E5), Color(0xFF90CAF9)],
        ).createShader(rect),
    );
  }

  void _drawSun(Canvas canvas, Size size) {
    final cx = size.width * 0.83;
    final cy = size.height * 0.12;
    final r  = size.width * 0.065;

    // Outer glow
    canvas.drawCircle(Offset(cx, cy), r * 2.0, Paint()..color = const Color(0xFFFFF9C4).withAlpha(50));
    canvas.drawCircle(Offset(cx, cy), r * 1.5, Paint()..color = const Color(0xFFFFF176).withAlpha(70));

    // Rays
    final rayP = Paint()
      ..color       = const Color(0xFFFDD835).withAlpha(170)
      ..strokeWidth = 2.0
      ..style       = PaintingStyle.stroke
      ..strokeCap   = StrokeCap.round;
    for (int i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      canvas.drawLine(
        Offset(cx + math.cos(a) * r * 1.45, cy + math.sin(a) * r * 1.45),
        Offset(cx + math.cos(a) * r * 2.05, cy + math.sin(a) * r * 2.05),
        rayP,
      );
    }

    // Sun disc
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = const Color(0xFFFDD835));
    // Highlight
    canvas.drawCircle(
      Offset(cx - r * 0.3, cy - r * 0.3),
      r * 0.3,
      Paint()..color = const Color(0xFFFFF176).withAlpha(180),
    );
  }

  void _drawClouds(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withAlpha(215);
    _cloud(canvas, size.width * 0.11, size.height * 0.09, size.width * 0.10, paint);
    _cloud(canvas, size.width * 0.47, size.height * 0.07, size.width * 0.13, paint);
  }

  void _cloud(Canvas canvas, double cx, double cy, double r, Paint paint) {
    canvas.drawCircle(Offset(cx,              cy),           r * 0.65, paint);
    canvas.drawCircle(Offset(cx + r * 0.70,   cy + r * 0.15), r * 0.55, paint);
    canvas.drawCircle(Offset(cx - r * 0.55,   cy + r * 0.18), r * 0.48, paint);
    canvas.drawCircle(Offset(cx + r * 0.22,   cy + r * 0.36), r * 0.50, paint);
  }

  void _drawDistantHills(Canvas canvas, Size size) {
    final gl = size.height * 0.50;

    // Far hills — hazy blue-green
    final farPath = Path()
      ..moveTo(0, gl)
      ..quadraticBezierTo(size.width * 0.20, size.height * 0.34, size.width * 0.42, size.height * 0.43)
      ..quadraticBezierTo(size.width * 0.65, size.height * 0.52, size.width * 0.86, size.height * 0.39)
      ..quadraticBezierTo(size.width * 0.94, size.height * 0.33, size.width, size.height * 0.41)
      ..lineTo(size.width, gl)
      ..close();
    canvas.drawPath(farPath, Paint()..color = const Color(0xFF81C784).withAlpha(130));

    // Near hills — rich green
    final nearPath = Path()
      ..moveTo(0, gl)
      ..quadraticBezierTo(size.width * 0.14, size.height * 0.40, size.width * 0.36, size.height * 0.47)
      ..quadraticBezierTo(size.width * 0.56, size.height * 0.54, size.width * 0.79, size.height * 0.44)
      ..quadraticBezierTo(size.width * 0.91, size.height * 0.38, size.width, size.height * 0.46)
      ..lineTo(size.width, gl)
      ..close();
    canvas.drawPath(nearPath, Paint()..color = const Color(0xFF4CAF50).withAlpha(170));
  }

  void _drawGrassMiddleGround(Canvas canvas, Size size) {
    final top    = size.height * 0.50;
    final bottom = size.height * 0.63;
    final rect   = Rect.fromLTWH(0, top, size.width, bottom - top);

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF66BB6A), Color(0xFF8BC34A)],
        ).createShader(rect),
    );

    // Distant row texture
    final rowP = Paint()
      ..color       = const Color(0xFF43A047)
      ..strokeWidth = 1.0
      ..style       = PaintingStyle.stroke;
    for (int i = 0; i < 5; i++) {
      final y = top + (bottom - top) * ((i + 0.5) / 5);
      canvas.drawLine(Offset(size.width * 0.03, y), Offset(size.width * 0.97, y), rowP);
    }
  }

  void _drawFurrowedSoil(Canvas canvas, Size size) {
    final soilTop = size.height * 0.63;
    final rect    = Rect.fromLTWH(0, soilTop, size.width, size.height - soilTop);

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0xFF6D4C41), Color(0xFF3E2723)],
        ).createShader(rect),
    );

    // Furrow ridges
    final furrowP = Paint()
      ..color       = const Color(0xFF5D4037)
      ..strokeWidth = 2.0
      ..style       = PaintingStyle.stroke;
    for (int i = 1; i <= 3; i++) {
      final y = soilTop + (size.height - soilTop) * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), furrowP);
    }

    // Soil pebbles
    final dotP = Paint()..color = const Color(0xFF8D6E63).withAlpha(100);
    final rng  = math.Random(99);
    for (int i = 0; i < 28; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, soilTop + rng.nextDouble() * (size.height - soilTop)),
        rng.nextDouble() * 2.0 + 0.4,
        dotP,
      );
    }
  }

  void _drawFence(Canvas canvas, Size size) {
    final y1 = size.height * 0.58;
    final y2 = size.height * 0.64;
    final postP = Paint()..color = const Color(0xFF8D6E63)..strokeWidth = 3.0..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final wireP = Paint()..color = const Color(0xFFA1887F)..strokeWidth = 1.0..style = PaintingStyle.stroke;

    // Posts at fixed x positions
    for (final x in [0.04, 0.22, 0.40, 0.58, 0.76, 0.94]) {
      final px = size.width * x;
      canvas.drawLine(Offset(px, y1 - 12), Offset(px, y2 + 4), postP);
    }

    // Two wire strands
    canvas.drawLine(Offset(0, y1 - 6), Offset(size.width, y1 - 6), wireP);
    canvas.drawLine(Offset(0, y1 + 2), Offset(size.width, y1 + 2), wireP);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
