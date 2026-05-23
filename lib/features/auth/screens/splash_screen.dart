import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

/// Shown on cold start for ~1.8 s, then routes based on auth state.
/// If logged in  → Dashboard
/// If not logged in → Onboarding (first use) / Login (returning)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnim = Tween<double>(
      begin: 0.72,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack));
    _fadeAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _animCtrl.forward();

    // On web the HTML splash already covered the branding — navigate as soon
    // as auth resolves (no extra delay).  On mobile keep the 1800 ms for UX.
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
      final hasOnboarded = container.read(onboardingDoneProvider);
      context.go(hasOnboarded ? AppRoutes.login : AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App icon
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(28),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withAlpha(60),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.agriculture_rounded,
                    size: 52,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                // App name
                const Text(
                  '4Directions',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Farm Management',
                  style: TextStyle(
                    color: Colors.white.withAlpha(200),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 60),
                // Loading indicator
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withAlpha(160),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
