import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/farm_text_field.dart';
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

  late final AnimationController _enterCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _enterCtrl,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));
    _enterCtrl.forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    FocusScope.of(context).unfocus();
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
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF0C1F12),
      body: Stack(
        children: [
          // Gradient background
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? const [Color(0xFF071409), Color(0xFF0F2716)]
                      : const [Color(0xFF0C1F12), Color(0xFF16472A)],
                ),
              ),
            ),
          ),

          // Decorative glows
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF22C55E).withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF16A34A).withValues(alpha: 0.07),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main layout
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Expanded(flex: 38, child: _BrandHero()),
                    Expanded(
                      flex: 62,
                      child: _FormCard(
                        formKey: _formKey,
                        emailCtrl: _emailCtrl,
                        passwordCtrl: _passwordCtrl,
                        loading: _loading,
                        isDark: isDark,
                        onSignIn: _signIn,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 4Directions compass-rose SVG logo mark ────────────────────────────────────
//
// Four elongated leaf petals pointing N / S / E / W represent the brand name.
// A central crosshair ring completes the compass motif.
const _kLogoSvg = '''
<svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
  <!-- Outer dashed guide ring -->
  <circle cx="50" cy="50" r="45"
    fill="none"
    stroke="rgba(255,255,255,0.14)"
    stroke-width="0.8"
    stroke-dasharray="3 6"/>

  <!-- North petal — primary, brightest -->
  <path d="M50 8
           C46 17 43 29 46 38
           L50 43 L54 38
           C57 29 54 17 50 8 Z"
    fill="rgba(255,255,255,0.96)"/>

  <!-- South petal -->
  <path d="M50 92
           C54 83 57 71 54 62
           L50 57 L46 62
           C43 71 46 83 50 92 Z"
    fill="rgba(255,255,255,0.76)"/>

  <!-- East petal -->
  <path d="M92 50
           C83 46 71 43 62 46
           L57 50 L62 54
           C71 57 83 54 92 50 Z"
    fill="rgba(255,255,255,0.76)"/>

  <!-- West petal -->
  <path d="M8 50
           C17 54 29 57 38 54
           L43 50 L38 46
           C29 43 17 46 8 50 Z"
    fill="rgba(255,255,255,0.76)"/>

  <!-- Diagonal accent ticks at 45-degree positions -->
  <line x1="63" y1="37" x2="67" y2="33"
    stroke="rgba(255,255,255,0.32)" stroke-width="1.2" stroke-linecap="round"/>
  <line x1="37" y1="37" x2="33" y2="33"
    stroke="rgba(255,255,255,0.32)" stroke-width="1.2" stroke-linecap="round"/>
  <line x1="37" y1="63" x2="33" y2="67"
    stroke="rgba(255,255,255,0.32)" stroke-width="1.2" stroke-linecap="round"/>
  <line x1="63" y1="63" x2="67" y2="67"
    stroke="rgba(255,255,255,0.32)" stroke-width="1.2" stroke-linecap="round"/>

  <!-- Centre fill disc -->
  <circle cx="50" cy="50" r="12"
    fill="rgba(255,255,255,0.16)"/>

  <!-- Centre ring -->
  <circle cx="50" cy="50" r="12"
    fill="none"
    stroke="rgba(255,255,255,0.65)"
    stroke-width="1.3"/>

  <!-- Centre crosshair -->
  <line x1="50" y1="43" x2="50" y2="57"
    stroke="white" stroke-width="1.6" stroke-linecap="round"/>
  <line x1="43" y1="50" x2="57" y2="50"
    stroke="white" stroke-width="1.6" stroke-linecap="round"/>

  <!-- Centre dot -->
  <circle cx="50" cy="50" r="2.8" fill="white"/>
</svg>
''';

// ── Brand hero ─────────────────────────────────────────────────────────────────

class _BrandHero extends StatefulWidget {
  const _BrandHero();

  @override
  State<_BrandHero> createState() => _BrandHeroState();
}

class _BrandHeroState extends State<_BrandHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    _glowAnim = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Subtle agricultural field-line background
        Positioned.fill(child: CustomPaint(painter: _FieldLinePainter())),

        // Centred brand content
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo badge with breathing glow
              AnimatedBuilder(
                animation: _glowAnim,
                builder: (_, child) {
                  return Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4ADE80), Color(0xFF15803D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        // Breathing outer glow
                        BoxShadow(
                          color: const Color(
                            0xFF22C55E,
                          ).withValues(alpha: 0.22 + _glowAnim.value * 0.22),
                          blurRadius: 30 + _glowAnim.value * 28,
                          spreadRadius: _glowAnim.value * 8,
                          offset: const Offset(0, 4),
                        ),
                        // Constant depth shadow
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.36),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: child,
                  );
                },
                // SVG rendered once — not rebuilt on every animation frame
                child: kIsWeb
                    ? const Icon(
                        Icons.agriculture_rounded,
                        size: 56,
                        color: Colors.white,
                      )
                    : Padding(
                        padding: const EdgeInsets.all(17),
                        child: SvgPicture.string(
                          _kLogoSvg,
                          fit: BoxFit.contain,
                        ),
                      ),
              ),
              const SizedBox(height: 20),

              // App name
              const Text(
                '4Directions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.1,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 10),

              // Feature pills row
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  _FeaturePill(label: 'Crops', icon: Icons.grass_rounded),
                  SizedBox(width: 6),
                  _FeaturePill(label: 'Livestock', icon: Icons.pets_rounded),
                  SizedBox(width: 6),
                  _FeaturePill(
                    label: 'Finance',
                    icon: Icons.trending_up_rounded,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Feature pill (in brand hero) ───────────────────────────────────────────────

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.13),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: const Color(0xFF86EFAC)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.70),
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Subtle agricultural field lines (background of hero) ──────────────────────

class _FieldLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Diagonal crop-row lines
    final diag = Paint()
      ..color = Colors.white.withValues(alpha: 0.026)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 24.0;
    for (double x = -size.height; x < size.width + size.height; x += spacing) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height * 0.85, 0),
        diag,
      );
    }

    // Faint horizontal horizon lines
    final horiz = Paint()
      ..color = Colors.white.withValues(alpha: 0.014)
      ..strokeWidth = 0.8;
    for (double y = 18; y < size.height; y += 34) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), horiz);
    }
  }

  @override
  bool shouldRepaint(_FieldLinePainter _) => false;
}

// ── Form card ──────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.formKey,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.loading,
    required this.isDark,
    required this.onSignIn,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final bool loading;
  final bool isDark;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final botPad = MediaQuery.paddingOf(context).bottom;
    final cardBg = isDark ? const Color(0xFF0E1B11) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.32),
            blurRadius: 48,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Padding(
          padding: EdgeInsets.fromLTRB(26, 0, 26, botPad > 0 ? botPad : 16),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 22),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.10)
                          : Colors.black.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header
                Text(
                  'Welcome back',
                  style: tt.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.7,
                    color: isDark ? Colors.white : const Color(0xFF0D1A10),
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sign in to manage your farm',
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                // Email field
                FarmTextField(
                  controller: emailCtrl,
                  label: 'Email address',
                  hint: 'you@example.com',
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: cs.onSurfaceVariant,
                    size: 20,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Password field
                FarmTextField(
                  controller: passwordCtrl,
                  label: 'Password',
                  hint: 'Enter your password',
                  prefixIcon: Icon(
                    Icons.lock_outline_rounded,
                    color: cs.onSurfaceVariant,
                    size: 20,
                  ),
                  textInputAction: TextInputAction.done,
                  obscureText: true,
                  onFieldSubmitted: (_) => onSignIn(),
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Minimum 6 characters'
                      : null,
                ),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push(AppRoutes.forgotPassword),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),

                // Sign in button
                _SignInButton(isLoading: loading, onPressed: onSignIn),

                const SizedBox(height: 14),

                // ── Dev quick-login panel ─────────────────────────────────
                if (AppConstants.useMockData) ...[
                  _DevQuickLogin(
                    onSelect: (email, password) {
                      emailCtrl.text = email;
                      passwordCtrl.text = password;
                      onSignIn();
                    },
                  ),
                  const SizedBox(height: 8),
                ],

                // OR divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: cs.outlineVariant.withValues(alpha: 0.40),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'or continue with',
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: cs.outlineVariant.withValues(alpha: 0.40),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Social auth
                SocialAuthRow(
                  onGoogle: () {},
                  onApple: () {},
                  onFacebook: () {},
                ),

                const SizedBox(height: 12),

                // Sign-up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.register),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Sign up',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ), // end Column
          ), // end SingleChildScrollView
        ),
      ),
    );
  }
}

// ── Dev quick-login panel ──────────────────────────────────────────────────────

class _DevQuickLogin extends StatelessWidget {
  const _DevQuickLogin({required this.onSelect});

  final void Function(String email, String password) onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF86EFAC), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.developer_mode_rounded,
                size: 13,
                color: Color(0xFF15803D),
              ),
              const SizedBox(width: 5),
              const Text(
                'DEV · Quick Login',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF15803D),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _QuickBtn(
                  name: 'Thabo Nkosi',
                  label: 'Enterprise Farmer',
                  icon: Icons.domain_rounded,
                  color: Color(0xFF6A1B9A),
                  onTap: () => onSelect('enterprise@4dfarmer.com', 'demo1234'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _QuickBtn(
                  name: 'Sipho Ndlovu',
                  label: 'Farm Manager',
                  icon: Icons.manage_accounts_rounded,
                  color: Color(0xFF00695C),
                  onTap: () => onSelect('manager@greenvalley.com', 'staff1234'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickBtn extends StatelessWidget {
  const _QuickBtn({
    required this.name,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String name;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.28)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 9,
                      color: color.withValues(alpha: 0.70),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sign-in button ─────────────────────────────────────────────────────────────

class _SignInButton extends StatelessWidget {
  const _SignInButton({required this.isLoading, required this.onPressed});
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isLoading
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF22C55E), Color(0xFF166534)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: isLoading ? AppColors.primary.withValues(alpha: 0.45) : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isLoading
              ? null
              : [
                  BoxShadow(
                    color: const Color(0xFF16A34A).withValues(alpha: 0.40),
                    blurRadius: 22,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.0,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sign In',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15.5,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 17),
                  ],
                ),
        ),
      ),
    );
  }
}
