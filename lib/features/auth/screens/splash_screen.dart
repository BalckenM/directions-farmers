import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../providers/auth_provider.dart';

/// Shown on cold start for ~1.8 s, then routes based on auth state.
/// If logged in  → Dashboard
/// If not logged in + never seen intro → IntroScreen
/// If not logged in + seen intro       → Login
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final AnimationController _orbitCtrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _taglineAnim;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _scaleAnim = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(
        parent: _animCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _taglineAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
    );

    _animCtrl.forward();

    final delay = kIsWeb ? Duration.zero : const Duration(milliseconds: 1800);
    _navTimer = Timer(delay, _navigateAfterSplash);
  }

  Future<void> _navigateAfterSplash() async {
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
    _animCtrl.dispose();
    _orbitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1B5E20),
      body: Stack(
        children: [
          // ── Gradient background ─────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1B5E20),
                  Color(0xFF2E7D32),
                  Color(0xFF1565C0),
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          ),
          // ── Orbiting decorative ring ────────────────────────────────────────
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _orbitCtrl,
              builder: (_, _) {
                return CustomPaint(
                  painter: _OrbitPainter(
                    progress: _orbitCtrl.value,
                    color: Colors.white.withAlpha(16),
                    radius: size.width * 0.42,
                  ),
                );
              },
            ),
          ),
          // ── Decor circles ───────────────────────────────────────────────────
          Positioned(
            top: -size.height * 0.1,
            right: -size.width * 0.15,
            child: Container(
              width: size.width * 0.65,
              height: size.width * 0.65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(10),
              ),
            ),
          ),
          Positioned(
            bottom: -size.height * 0.05,
            left: -size.width * 0.2,
            child: Container(
              width: size.width * 0.55,
              height: size.width * 0.55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1565C0).withAlpha(25),
              ),
            ),
          ),
          // ── Main content ────────────────────────────────────────────────────
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon with glow ring
                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withAlpha(18),
                        border: Border.all(
                          color: const Color(0xFF81C784).withAlpha(100),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF81C784).withAlpha(80),
                            blurRadius: 40,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.agriculture_rounded,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Title
                    const Text(
                      '4Directions',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Animated tagline
                    FadeTransition(
                      opacity: _taglineAnim,
                      child: SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0, 0.4),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _animCtrl,
                                curve: const Interval(
                                  0.45,
                                  1.0,
                                  curve: Curves.easeOut,
                                ),
                              ),
                            ),
                        child: Text(
                          'Farm Management',
                          style: TextStyle(
                            color: const Color(0xFF81C784).withAlpha(220),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 64),
                    // Dots loader
                    _DotsLoader(color: Colors.white.withAlpha(160)),
                  ],
                ),
              ),
            ),
          ),
          // ── Bottom version tag ──────────────────────────────────────────────
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _taglineAnim,
              child: Text(
                'Powered by 4Directions',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withAlpha(80),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dots loader ───────────────────────────────────────────────────────────────

class _DotsLoader extends StatefulWidget {
  const _DotsLoader({required this.color});
  final Color color;

  @override
  State<_DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<_DotsLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3.0;
            final value = math
                .sin((_ctrl.value - delay) * 2 * math.pi)
                .clamp(-1.0, 1.0);
            final scale = 0.5 + (value + 1) * 0.25;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ── Orbit painter ─────────────────────────────────────────────────────────────

class _OrbitPainter extends CustomPainter {
  _OrbitPainter({
    required this.progress,
    required this.color,
    required this.radius,
  });
  final double progress;
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius, paint);
    // Orbiting dot
    final angle = progress * 2 * math.pi;
    final dx = center.dx + math.cos(angle) * radius;
    final dy = center.dy + math.sin(angle) * radius;
    canvas.drawCircle(
      Offset(dx, dy),
      5.5,
      Paint()..color = color.withAlpha(180),
    );
  }

  @override
  bool shouldRepaint(_OrbitPainter old) => old.progress != progress;
}
