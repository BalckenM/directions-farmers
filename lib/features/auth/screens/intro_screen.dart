import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../providers/auth_provider.dart';

// ── Slide data ────────────────────────────────────────────────────────────────

class _Slide {
  const _Slide({
    required this.gradientStart,
    required this.gradientEnd,
    required this.accentColor,
    required this.icon,
    required this.title,
    required this.body,
    required this.tag,
  });
  final Color gradientStart;
  final Color gradientEnd;
  final Color accentColor;
  final IconData icon;
  final String title;
  final String body;
  final String tag;
}

const _slides = [
  _Slide(
    gradientStart: Color(0xFF1B5E20),
    gradientEnd: Color(0xFF2E7D32),
    accentColor: Color(0xFF81C784),
    icon: Icons.agriculture_rounded,
    title: 'Smart Farm\nManagement',
    body:
        'Everything you need to run a profitable farm — livestock, crops, payroll, and more — in one powerful app.',
    tag: 'FARM MANAGEMENT',
  ),
  _Slide(
    gradientStart: Color(0xFF01579B),
    gradientEnd: Color(0xFF0277BD),
    accentColor: Color(0xFF4FC3F7),
    icon: Icons.pets_rounded,
    title: 'Track Livestock\n& Crops',
    body:
        'Monitor health events, vaccinations, breeding, production, and field data for all species and crops.',
    tag: 'TRACKING & RECORDS',
  ),
  _Slide(
    gradientStart: Color(0xFFE65100),
    gradientEnd: Color(0xFFF57F17),
    accentColor: Color(0xFFFFCC80),
    icon: Icons.bar_chart_rounded,
    title: 'Insights &\nSmart Reports',
    body:
        'Real-time analytics, financial tracking, payroll, and compliance — make data-driven decisions every day.',
    tag: 'ANALYTICS & PAYROLL',
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _page = 0;

  late final List<AnimationController> _slideCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  @override
  void initState() {
    super.initState();
    _slideCtrl = List.generate(
      _slides.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );
    _fadeAnims = _slideCtrl
        .map((c) => CurvedAnimation(
              parent: c,
              curve: const Interval(0.1, 1.0, curve: Curves.easeOut),
            ))
        .toList();
    _slideAnims = _slideCtrl
        .map(
          (c) => Tween<Offset>(
            begin: const Offset(0, 0.14),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic)),
        )
        .toList();
    _slideCtrl[0].forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    for (final c in _slideCtrl) {
      c.dispose();
    }
    super.dispose();
  }

  void _goTo(int index) {
    if (index == _page) return;
    _pageCtrl.animateToPage(
      index,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
    );
    _slideCtrl[index].reset();
    setState(() => _page = index);
  }

  void _next() {
    if (_page < _slides.length - 1) {
      _goTo(_page + 1);
    } else {
      _done();
    }
  }

  void _done() {
    ref.read(authProvider.notifier).markIntroSeen();
    ref.read(authProvider.notifier).markOnboardingDone();
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_page];
    final isLast = _page == _slides.length - 1;
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [slide.gradientStart, slide.gradientEnd],
          ),
        ),
        child: Stack(
          children: [
            // ── Decorative background circles ─────────────────────────────────
            Positioned(
              top: -size.height * 0.12,
              right: -size.width * 0.18,
              child: _DecorCircle(
                size: size.width * 0.72,
                color: Colors.white.withAlpha(12),
              ),
            ),
            Positioned(
              bottom: size.height * 0.28,
              left: -size.width * 0.22,
              child: _DecorCircle(
                size: size.width * 0.56,
                color: Colors.white.withAlpha(8),
              ),
            ),
            Positioned(
              top: size.height * 0.32,
              right: -size.width * 0.32,
              child: _DecorCircle(
                size: size.width * 0.64,
                color: slide.accentColor.withAlpha(20),
              ),
            ),
            // ── Floating orb behind icon ──────────────────────────────────────
            Positioned(
              top: size.height * 0.12,
              left: 0,
              right: 0,
              child: Center(
                child: _GlowOrb(
                  size: size.width * 0.52,
                  color: slide.accentColor,
                ),
              ),
            ),
            // ── Main content ──────────────────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  // ── Skip button ─────────────────────────────────────────────
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 12, 20, 0),
                      child: TextButton(
                        onPressed: _done,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white.withAlpha(200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Hero icon area ───────────────────────────────────────────
                  SizedBox(height: size.height * 0.04),
                  _AnimatedIcon(
                    icon: slide.icon,
                    accentColor: slide.accentColor,
                    page: _page,
                  ),

                  // ── Tag label ────────────────────────────────────────────────
                  const SizedBox(height: 28),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: _TagChip(
                      key: ValueKey('tag$_page'),
                      label: slide.tag,
                      accentColor: slide.accentColor,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── PageView for title + body ─────────────────────────────────
                  Expanded(
                    child: PageView.builder(
                      controller: _pageCtrl,
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: (i) {
                        _slideCtrl[i].reset();
                        _slideCtrl[i].forward();
                        setState(() => _page = i);
                      },
                      itemCount: _slides.length,
                      itemBuilder: (_, i) {
                        final s = _slides[i];
                        return FadeTransition(
                          opacity: _fadeAnims[i],
                          child: SlideTransition(
                            position: _slideAnims[i],
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      height: 1.15,
                                      letterSpacing: -0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    s.body,
                                    style: TextStyle(
                                      color: Colors.white.withAlpha(210),
                                      fontSize: 15,
                                      height: 1.6,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // ── Dots ─────────────────────────────────────────────────────
                  _DotIndicator(count: _slides.length, current: _page),
                  const SizedBox(height: 32),

                  // ── CTAs ──────────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Primary CTA
                        FilledButton(
                          onPressed: _next,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: slide.gradientStart,
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isLast ? 'Get Started' : 'Next',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: slide.gradientStart,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isLast
                                    ? Icons.rocket_launch_rounded
                                    : Icons.arrow_forward_rounded,
                                size: 18,
                                color: slide.gradientStart,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Secondary CTA — only on last slide
                        if (isLast)
                          TextButton(
                            onPressed: () => context.go(AppRoutes.login),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white.withAlpha(200),
                              minimumSize: const Size.fromHeight(44),
                            ),
                            child: const Text(
                              'I already have an account',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _DecorCircle extends StatelessWidget {
  const _DecorCircle({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withAlpha(14),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(70),
            blurRadius: 60,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }
}

class _AnimatedIcon extends StatefulWidget {
  const _AnimatedIcon({
    required this.icon,
    required this.accentColor,
    required this.page,
  });
  final IconData icon;
  final Color accentColor;
  final int page;

  @override
  State<_AnimatedIcon> createState() => _AnimatedIconState();
}

class _AnimatedIconState extends State<_AnimatedIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    _rotateAnim = Tween<double>(begin: -0.08, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_AnimatedIcon old) {
    super.didUpdateWidget(old);
    if (old.page != widget.page) {
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: AnimatedBuilder(
        animation: _rotateAnim,
        builder: (_, child) => Transform.rotate(
          angle: _rotateAnim.value * math.pi,
          child: child,
        ),
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withAlpha(22),
            border: Border.all(
              color: widget.accentColor.withAlpha(120),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withAlpha(60),
                blurRadius: 28,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            size: 52,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({super.key, required this.label, required this.accentColor});
  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withAlpha(100), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accentColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.count, required this.current});
  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active
                ? Colors.white
                : Colors.white.withAlpha(80),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
