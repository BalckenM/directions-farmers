import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

// ── Slide data ────────────────────────────────────────────────────────────────

class _Slide {
  const _Slide({
    required this.imageUrl,
    required this.accentColor,
    required this.title,
    required this.body,
    required this.tag,
    required this.tagIcon,
  });
  final String imageUrl;
  final Color accentColor;
  final String title;
  final String body;
  final String tag;
  final IconData tagIcon;
}

const _slides = [
  _Slide(
    imageUrl:
        'https://images.unsplash.com/photo-1589923188900-85dae523342b?w=900&q=85',
    accentColor: Color(0xFF43A047),
    title: 'Smart Farm\nManagement',
    body:
        'Everything you need to run a profitable farm — livestock, crops, payroll, and compliance — in one powerful app.',
    tag: 'FARM MANAGEMENT',
    tagIcon: Icons.agriculture_rounded,
  ),
  _Slide(
    imageUrl:
        'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=900&q=85',
    accentColor: Color(0xFF1E88E5),
    title: 'Track Livestock\n& Crops',
    body:
        'Monitor health events, vaccinations, breeding, production, and field data across all species and crops.',
    tag: 'TRACKING & RECORDS',
    tagIcon: Icons.monitor_heart_outlined,
  ),
  _Slide(
    imageUrl:
        'https://images.unsplash.com/photo-1574943320219-553eb213f72d?w=900&q=85',
    accentColor: Color(0xFFFB8C00),
    title: 'Insights &\nSmart Reports',
    body:
        'Real-time analytics, financial tracking, payroll, and compliance — make data-driven decisions every day.',
    tag: 'ANALYTICS & PAYROLL',
    tagIcon: Icons.bar_chart_rounded,
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
        .map(
          (c) => CurvedAnimation(
            parent: c,
            curve: const Interval(0.1, 1.0, curve: Curves.easeOut),
          ),
        )
        .toList();
    _slideAnims = _slideCtrl
        .map(
          (c) => Tween<Offset>(
            begin: const Offset(0, 0.12),
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
    final screenH = MediaQuery.sizeOf(context).height;
    final topPad = MediaQuery.paddingOf(context).top;
    final botPad = MediaQuery.paddingOf(context).bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final panelColor = isDark ? const Color(0xFF1A1E1A) : Colors.white;
    final panelTop = screenH * 0.50;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── 1. Full-bleed photo ───────────────────────────────────────────
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 700),
              child: CachedNetworkImage(
                key: ValueKey(_page),
                imageUrl: slide.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                placeholder: (_, _) => Container(color: Colors.black87),
                errorWidget: (_, _, _) => Container(
                  color: const Color(0xFF1B4332),
                  child: const Icon(
                    Icons.landscape_rounded,
                    size: 80,
                    color: Colors.white24,
                  ),
                ),
              ),
            ),
          ),

          // ── 2. Top gradient (status bar softening) ────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 180,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(110),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── 3. Accent-mist gradient (image → panel) ───────────────────────
          Positioned(
            top: panelTop - screenH * 0.18,
            left: 0,
            right: 0,
            height: screenH * 0.22,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    slide.accentColor.withAlpha(110),
                    slide.accentColor.withAlpha(55),
                    panelColor.withAlpha(230),
                    panelColor,
                  ],
                  stops: const [0.0, 0.25, 0.50, 0.78, 1.0],
                ),
              ),
            ),
          ),

          // ── 4. Content panel ──────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: panelTop,
            child: Container(
              decoration: BoxDecoration(
                color: panelColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(70),
                    blurRadius: 48,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Grab handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 20),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Swipeable slide content
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 28),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Counter + tag row
                                  Row(
                                    children: [
                                      _TagChip(
                                        label: s.tag,
                                        accentColor: s.accentColor,
                                        icon: s.tagIcon,
                                      ),
                                      const Spacer(),
                                      Text(
                                        '${(i + 1).toString().padLeft(2, '0')} / ${_slides.length.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white38
                                              : Colors.black26,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    s.title,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF111111),
                                      fontSize: 34,
                                      fontWeight: FontWeight.w900,
                                      height: 1.08,
                                      letterSpacing: -0.9,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    s.body,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white60
                                          : const Color(0xFF555555),
                                      fontSize: 14.5,
                                      height: 1.62,
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

                  // Accent-matched dot indicator
                  _DotIndicator(
                    count: _slides.length,
                    current: _page,
                    accentColor: slide.accentColor,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),

                  // Primary CTA — gradient button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _GradientButton(
                      label: isLast ? 'Get Started' : 'Next',
                      icon: isLast
                          ? Icons.rocket_launch_rounded
                          : Icons.arrow_forward_rounded,
                      onPressed: _next,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Secondary CTA
                  if (isLast)
                    TextButton(
                      onPressed: () => context.go(AppRoutes.login),
                      style: TextButton.styleFrom(
                        foregroundColor:
                            isDark ? Colors.white54 : Colors.black45,
                        minimumSize: const Size.fromHeight(44),
                      ),
                      child: const Text(
                        'Already have an account? Sign in',
                        style:
                            TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    )
                  else
                    TextButton(
                      onPressed: _done,
                      style: TextButton.styleFrom(
                        foregroundColor:
                            isDark ? Colors.white54 : Colors.black45,
                        minimumSize: const Size.fromHeight(44),
                      ),
                      child: const Text(
                        'Skip intro',
                        style:
                            TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  SizedBox(height: botPad + 8),
                ],
              ),
            ),
          ),

          // ── 5. Brand badge — top-centre, glassmorphism ────────────────────
          Positioned(
            top: topPad + 16,
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(22),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: Colors.white.withAlpha(60),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF66BB6A), Color(0xFF1B5E20)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.agriculture_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '4Directions',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Farm',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.65),
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── 6. Skip button — top-right, glassmorphism ─────────────────────
          Positioned(
            top: topPad + 14,
            right: 20,
            child: AnimatedOpacity(
              opacity: isLast ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: IgnorePointer(
                ignoring: isLast,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: TextButton(
                      onPressed: _done,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.white.withAlpha(28),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.accentColor,
    required this.icon,
  });
  final String label;
  final Color accentColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: accentColor.withAlpha(22),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accentColor.withAlpha(100), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: accentColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: accentColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({
    required this.count,
    required this.current,
    required this.accentColor,
    required this.isDark,
  });
  final int count;
  final int current;
  final Color accentColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final inactiveColor =
        isDark ? Colors.white.withAlpha(30) : Colors.black.withAlpha(18);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? accentColor : inactiveColor,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(90),
            blurRadius: 22,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, size: 18, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
