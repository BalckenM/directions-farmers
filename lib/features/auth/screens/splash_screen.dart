import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../providers/auth_provider.dart';

/// Cold-start splash shown for ~1.8 s, then routes based on auth state.
/// • Authenticated        → Dashboard
/// • New user (no intro)  → IntroScreen
/// • Returning user       → Login
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _progressCtrl;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;

  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _logoScale = Tween<double>(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack),
    );
    _logoOpacity = CurvedAnimation(
      parent: _logoCtrl,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _textOpacity = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut);
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));

    _logoCtrl.forward().then((_) {
      _textCtrl.forward();
      _progressCtrl.forward();
    });

    final delay = kIsWeb ? Duration.zero : const Duration(milliseconds: 1900);
    _navTimer = Timer(delay, _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final container = ProviderScope.containerOf(context);
    final authState = await container.read(authProvider.future);
    if (!mounted) return;
    if (authState.isAuthenticated) {
      context.go(AppRoutes.dashboard);
    } else {
      final hasSeenIntro = container.read(hasSeenIntroProvider);
      context.go(hasSeenIntro ? AppRoutes.login : AppRoutes.intro);
    }
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _logoCtrl.dispose();
    _pulseCtrl.dispose();
    _textCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final botPad = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF060F08),
      body: Stack(
        children: [
          // ── Radial gradient background ─────────────────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.1,
                  colors: [Color(0xFF0F2D1A), Color(0xFF060F08)],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
          ),

          // ── Pulsing rings ─────────────────────────────────────────────────
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, _) => CustomPaint(
                painter: _PulseRingPainter(_pulseCtrl.value),
              ),
            ),
          ),

          // ── Decorative corner glow ─────────────────────────────────────────
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF22C55E).withValues(alpha: 0.07),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF16A34A).withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Main content ──────────────────────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo badge
                FadeTransition(
                  opacity: _logoOpacity,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: _LogoBadge(),
                  ),
                ),
                const SizedBox(height: 36),

                // Brand name + tagline
                FadeTransition(
                  opacity: _textOpacity,
                  child: SlideTransition(
                    position: _textSlide,
                    child: const Column(
                      children: [
                        Text(
                          '4Directions',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.4,
                            height: 1.0,
                          ),
                        ),
                        SizedBox(height: 10),
                        _TaglinePill(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom — progress + credit ────────────────────────────────────
          Positioned(
            bottom: botPad + 28,
            left: 44,
            right: 44,
            child: AnimatedBuilder(
              animation: _progressCtrl,
              builder: (_, _) {
                return Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: _progressCtrl.value,
                        minHeight: 2,
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.07),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF4ADE80),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Powered by 4Directions',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.18),
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Logo badge ─────────────────────────────────────────────────────────────────

class _LogoBadge extends StatelessWidget {
  const _LogoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4ADE80), Color(0xFF15803D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22C55E).withValues(alpha: 0.30),
            blurRadius: 60,
            spreadRadius: 12,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.40),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(
        Icons.agriculture_rounded,
        size: 54,
        color: Colors.white,
      ),
    );
  }
}

// ── Tagline pill ───────────────────────────────────────────────────────────────

class _TaglinePill extends StatelessWidget {
  const _TaglinePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: const Color(0xFF4ADE80).withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Text(
        'SMART FARM PLATFORM',
        style: TextStyle(
          color: const Color(0xFF86EFAC).withValues(alpha: 0.90),
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.8,
        ),
      ),
    );
  }
}

// ── Pulse ring painter ─────────────────────────────────────────────────────────

class _PulseRingPainter extends CustomPainter {
  const _PulseRingPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.shortestSide * 0.52;

    for (int i = 0; i < 3; i++) {
      final phase = (progress + i * 0.333) % 1.0;
      final radius = maxRadius * (0.28 + phase * 0.72);
      final opacity = (1.0 - phase) * 0.13;

      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = const Color(0xFF4ADE80).withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }
  }

  @override
  bool shouldRepaint(_PulseRingPainter old) => old.progress != progress;
}
