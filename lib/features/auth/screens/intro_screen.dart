import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

// Slide data
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
    accentColor: Color(0xFF22C55E),
    title: 'Smart Farm\nManagement',
    body:
        'Everything you need to run a profitable farm — livestock, crops, payroll, and compliance — in one powerful app.',
    tag: 'FARM MANAGEMENT',
    tagIcon: Icons.agriculture_rounded,
  ),
  _Slide(
    imageUrl:
        'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=900&q=85',
    accentColor: Color(0xFF3B82F6),
    title: 'Track Livestock\n& Crops',
    body:
        'Monitor health events, vaccinations, breeding, production, and field data across all species and crops.',
    tag: 'TRACKING & RECORDS',
    tagIcon: Icons.monitor_heart_outlined,
  ),
  _Slide(
    imageUrl:
        'https://images.unsplash.com/photo-1574943320219-553eb213f72d?w=900&q=85',
    accentColor: Color(0xFFF97316),
    title: 'Insights &\nSmart Reports',
    body:
        'Real-time analytics, financial tracking, payroll, and compliance — make data-driven decisions every day.',
    tag: 'ANALYTICS & PAYROLL',
    tagIcon: Icons.bar_chart_rounded,
  ),
];

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
        duration: const Duration(milliseconds: 550),
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
            begin: const Offset(0, 0.10),
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
      duration: const Duration(milliseconds: 400),
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
    final topPad = MediaQuery.paddingOf(context).top;
    final botPad = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full-bleed background photo
          Positioned.fill(
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
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  child: CachedNetworkImage(
                    key: ValueKey(i),
                    imageUrl: s.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (_, _) =>
                        Container(color: const Color(0xFF0F1F13)),
                    errorWidget: (_, _, _) => Container(
                      color: const Color(0xFF0F1F13),
                      child: const Icon(
                        Icons.landscape_rounded,
                        size: 80,
                        color: Colors.white24,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Top gradient — status bar softening
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 160,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.65),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Bottom gradient — content area
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.sizeOf(context).height * 0.60,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.88),
                    Colors.black.withValues(alpha: 0.96),
                  ],
                  stops: const [0.0, 0.3, 0.65, 1.0],
                ),
              ),
            ),
          ),

          // Content overlay — positioned at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnims[_page],
              child: SlideTransition(
                position: _slideAnims[_page],
                child: Padding(
                  padding: EdgeInsets.fromLTRB(28, 0, 28, botPad + 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tag chip + counter row
                      Row(
                        children: [
                          _TagChip(
                            label: slide.tag,
                            accentColor: slide.accentColor,
                            icon: slide.tagIcon,
                          ),
                          const Spacer(),
                          Text(
                            '${(_page + 1).toString().padLeft(2, '0')} / ${_slides.length.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.45),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.6,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        slide.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          height: 1.06,
                          letterSpacing: -1.2,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Body
                      Text(
                        slide.body,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.70),
                          fontSize: 15,
                          height: 1.60,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Dot indicators
                      _DotIndicator(
                        count: _slides.length,
                        current: _page,
                        accentColor: slide.accentColor,
                      ),
                      const SizedBox(height: 22),

                      // Primary CTA
                      _GradientButton(
                        label: isLast ? 'Get Started' : 'Next',
                        icon: isLast
                            ? Icons.rocket_launch_rounded
                            : Icons.arrow_forward_rounded,
                        accentColor: slide.accentColor,
                        onPressed: _next,
                      ),
                      const SizedBox(height: 8),

                      // Secondary CTA
                      Center(
                        child: TextButton(
                          onPressed: isLast
                              ? () => context.go(AppRoutes.login)
                              : _done,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white.withValues(alpha: 0.55),
                            minimumSize: const Size.fromHeight(44),
                          ),
                          child: Text(
                            isLast
                                ? 'Already have an account? Sign in'
                                : 'Skip intro',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Brand badge — top-left, glassmorphism
          Positioned(
            top: topPad + 16,
            left: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4ADE80), Color(0xFF166534)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.agriculture_rounded,
                          size: 15,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '4Directions',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Skip button — top-right
          if (!isLast)
            Positioned(
              top: topPad + 16,
              right: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: TextButton(
                    onPressed: _done,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.white.withValues(alpha: 0.14),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Skip',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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

// Supporting widgets

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
        color: accentColor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.40),
          width: 1,
        ),
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
              letterSpacing: 1.1,
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
  });
  final int count;
  final int current;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          margin: const EdgeInsets.only(right: 6),
          width: active ? 26 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active
                ? accentColor
                : Colors.white.withValues(alpha: 0.28),
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
    required this.accentColor,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accentColor,
              Color.lerp(accentColor, Colors.black, 0.35)!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
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
      ),
    );
  }
}
