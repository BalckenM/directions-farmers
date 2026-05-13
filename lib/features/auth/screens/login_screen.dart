import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_text_field.dart';
import '../../../shared/widgets/primary_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
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
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _loading = false);
    ref.read(authProvider.notifier).logIn();
    context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? cs.surface : const Color(0xFF1B5E20),
      body: Stack(
        children: [
          // Decorative background circles (light mode only)
          if (!isDark) ...[
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
                  color: const Color(0xFF2E7D32).withAlpha(120),
                ),
              ),
            ),
          ],
          SafeArea(
            child: Column(
              children: [
                // ── Brand hero (top 38%) ──────────────────────────────────
                Expanded(
                  flex: 38,
                  child: _BrandHero(tt: tt, isDark: isDark, cs: cs),
                ),
                // ── Slide-up form card (bottom 62%) ──────────────────────
                Expanded(
                  flex: 62,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color:
                              isDark ? cs.surfaceContainerLow : Colors.white,
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
                                // Drag handle
                                Center(
                                  child: Container(
                                    width: 36,
                                    height: 4,
                                    margin: const EdgeInsets.only(
                                        bottom: AppSpacing.lg),
                                    decoration: BoxDecoration(
                                      color: cs.outlineVariant,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                                Text(
                                  'Welcome back',
                                  style: tt.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? cs.onSurface
                                        : AppColors.primary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Sign in to manage your farm',
                                  style: tt.bodyMedium
                                      ?.copyWith(color: cs.onSurfaceVariant),
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                FarmTextField(
                                  controller: _emailCtrl,
                                  label: 'Email address',
                                  hint: 'you@example.com',
                                  prefixIcon: Icon(Icons.email_outlined,
                                      color: cs.onSurfaceVariant),
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Email is required';
                                    }
                                    if (!v.contains('@')) {
                                      return 'Enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppSpacing.md),
                                FarmTextField(
                                  controller: _passwordCtrl,
                                  label: 'Password',
                                  hint: '••••••••',
                                  prefixIcon: Icon(
                                      Icons.lock_outline_rounded,
                                      color: cs.onSurfaceVariant),
                                  textInputAction: TextInputAction.done,
                                  obscureText: true,
                                  onFieldSubmitted: (_) => _signIn(),
                                  validator: (v) =>
                                      (v == null || v.length < 6)
                                          ? 'Minimum 6 characters'
                                          : null,
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
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
                                      size: 18),
                                  isLoading: _loading,
                                  isExpanded: true,
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                Row(
                                  children: [
                                    Expanded(
                                        child: Divider(
                                            color: cs.outlineVariant)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.md),
                                      child: Text('or',
                                          style: tt.bodySmall?.copyWith(
                                              color: cs.onSurfaceVariant)),
                                    ),
                                    Expanded(
                                        child: Divider(
                                            color: cs.outlineVariant)),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      context.go(AppRoutes.onboarding),
                                  icon: const Icon(
                                      Icons.add_business_outlined),
                                  label: const Text('Create a farm account'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: AppRadius.button,
                                    ),
                                  ),
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
  const _BrandHero(
      {required this.tt, required this.isDark, required this.cs});
  final TextTheme tt;
  final bool isDark;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDark
                  ? cs.primaryContainer
                  : Colors.white.withAlpha(28),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? cs.primary : Colors.white.withAlpha(60),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.agriculture_rounded,
              size: 32,
              color: isDark ? cs.onPrimaryContainer : Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Farm Manager',
            style: tt.headlineMedium?.copyWith(
              color: isDark ? cs.onSurface : Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Complete livestock & production tracking',
            style: tt.bodyMedium?.copyWith(
              color: isDark
                  ? cs.onSurfaceVariant
                  : Colors.white.withAlpha(180),
            ),
          ),
        ],
      ),
    );
  }
}

