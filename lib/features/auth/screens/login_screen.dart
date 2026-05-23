import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/social_auth_buttons.dart';
import '../models/auth_state.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  late final AnimationController _animCtrl;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.22),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _fadeAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.15, 1.0, curve: Curves.easeOut),
    );
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final container = ProviderScope.containerOf(context);
    await container
        .read(authProvider.notifier)
        .signIn(email: _emailCtrl.text.trim(), password: _passwordCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);
    final authState = container.read(authProvider).value;
    if (authState is AuthAuthenticated) {
      context.go(AppRoutes.dashboard);
    } else if (authState is AuthMfaRequired) {
      context.go(AppRoutes.mfaChallenge, extra: authState);
    } else if (authState is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.message),
          // L7: use AppColors tokens instead of raw Colors.red
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? cs.surface : const Color(0xFF1B5E20),
      body: Stack(
        children: [
          // ── Decorative background ─────────────────────────────────────────
          if (!isDark) ...[
            // Gradient overlay for richer hero
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.sizeOf(context).height * 0.46,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1B5E20),
                      Color(0xFF2E7D32),
                      Color(0xFF1565C0),
                    ],
                    stops: [0.0, 0.65, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(10),
                ),
              ),
            ),
            Positioned(
              top: 60,
              left: -80,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(8),
                ),
              ),
            ),
          ] else ...[
            // L9: dark mode gets a subtle gradient overlay in the hero area
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.sizeOf(context).height * 0.40,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.darkPrimaryContainer.withAlpha(180),
                      cs.surface,
                    ],
                  ),
                ),
              ),
            ),
          ],
          SafeArea(
            child: Column(
              children: [
                // ── Brand hero (top 38%) ──────────────────────────────────────
                Expanded(
                  flex: 38,
                  child: _BrandHero(tt: tt, isDark: isDark, cs: cs),
                ),
                // ── Slide-up form card (bottom 62%) ──────────────────────────
                Expanded(
                  flex: 62,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark ? cs.surfaceContainerLow : Colors.white,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(28),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(40),
                              blurRadius: 48,
                              offset: const Offset(0, -12),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.xl,
                            AppSpacing.lg,
                            AppSpacing.xl,
                            AppSpacing.xxl,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SocialAuthButton(
                                  label: 'Continue with Google',
                                  provider: SocialProvider.google,
                                  onPressed: () {
                                    // TODO: wire up Google Sign-In
                                  },
                                ),
                                const SizedBox(height: 12),
                                SocialAuthButton(
                                  label: 'Continue with Apple',
                                  provider: SocialProvider.apple,
                                  onPressed: () {
                                    // TODO: wire up Apple Sign-In
                                  },
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                const SocialAuthDivider(),
                                const SizedBox(height: AppSpacing.md),
                                FarmTextField(
                                  controller: _emailCtrl,
                                  label: 'Email address',
                                  hint: 'you@example.com',
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: cs.onSurfaceVariant,
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Email is required';
                                    }
                                    if (!RegExp(
                                      r'^[^@]+@[^@]+\.[^@]+',
                                    ).hasMatch(v.trim())) {
                                      return 'Enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppSpacing.md),
                                // L2: password field now uses FarmTextField's
                                // built-in obscureText toggle (visibility icon)
                                FarmTextField(
                                  controller: _passwordCtrl,
                                  label: 'Password',
                                  hint: '••••••••',
                                  prefixIcon: Icon(
                                    Icons.lock_outline_rounded,
                                    color: cs.onSurfaceVariant,
                                  ),
                                  textInputAction: TextInputAction.done,
                                  obscureText: true,
                                  onFieldSubmitted: (_) => _signIn(),
                                  validator: (v) => (v == null || v.length < 6)
                                      ? 'Minimum 6 characters'
                                      : null,
                                ),
                                // L1: forgot password now navigates to the
                                // ForgotPasswordScreen instead of doing nothing
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () =>
                                        context.push(AppRoutes.forgotPassword),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm,
                                        vertical: AppSpacing.xs,
                                      ),
                                    ),
                                    child: const Text('Forgot password?'),
                                  ),
                                ),
                                PrimaryButton(
                                  label: 'Sign In',
                                  onPressed: _signIn,
                                  icon: const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18,
                                  ),
                                  isLoading: _loading,
                                  isExpanded: true,
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                // L4: removed misleading "or" divider that implied
                                // social login; replaced with clear register prompt
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account?",
                                      style: tt.bodyMedium?.copyWith(
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          context.go(AppRoutes.register),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.sm,
                                        ),
                                      ),
                                      child: const Text('Sign up'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Brand hero widget ─────────────────────────────────────────────────────────

class _BrandHero extends StatelessWidget {
  const _BrandHero({required this.tt, required this.isDark, required this.cs});
  final TextTheme tt;
  final bool isDark;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isDark
                      ? cs.primaryContainer
                      : Colors.white.withAlpha(22),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? cs.primary
                        : Colors.white.withAlpha(70),
                    width: 1.5,
                  ),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withAlpha(30),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Icon(
                  Icons.agriculture_rounded,
                  size: 30,
                  color: isDark ? cs.onPrimaryContainer : Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '4Directions',
                    style: tt.titleLarge?.copyWith(
                      color: isDark ? cs.onSurface : Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'Farm Management',
                    style: tt.bodySmall?.copyWith(
                      color: isDark
                          ? cs.onSurfaceVariant
                          : Colors.white.withAlpha(190),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Welcome back',
            style: tt.headlineMedium?.copyWith(
              color: isDark ? cs.onSurface : Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Sign in to manage your farm',
            style: tt.bodyMedium?.copyWith(
              color: isDark
                  ? cs.onSurfaceVariant
                  : Colors.white.withAlpha(190),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Feature pills
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: const [
              _FeaturePill(label: 'Livestock', icon: Icons.pets_rounded),
              _FeaturePill(label: 'Crops', icon: Icons.grass_rounded),
              _FeaturePill(label: 'Payroll', icon: Icons.payments_rounded),
              _FeaturePill(label: 'Analytics', icon: Icons.bar_chart_rounded),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? cs.primaryContainer.withAlpha(80)
            : Colors.white.withAlpha(22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? cs.primary.withAlpha(60) : Colors.white.withAlpha(60),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isDark ? cs.primary : Colors.white.withAlpha(200),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: isDark ? cs.onPrimaryContainer : Colors.white.withAlpha(210),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
