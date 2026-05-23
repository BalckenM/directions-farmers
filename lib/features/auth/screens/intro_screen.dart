import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../providers/auth_provider.dart';

// ── Slide data ────────────────────────────────────────────────────────────────

class _Slide {
  const _Slide({
    required this.imageUrl,
    required this.accentColor,
    required this.title,
    required this.body,
    required this.tag,
  });
  final String imageUrl;
  final Color accentColor;
  final String title;
  final String body;
  final String tag;
}

const _slides = [
  _Slide(
    imageUrl:
        'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=900&q=80',
    accentColor: Color(0xFF81C784),
    title: 'Smart Farm\nManagement',
    body:
        'Everything you need to run a profitable farm — livestock, crops, payroll, and more — in one powerful app.',
    tag: 'FARM MANAGEMENT',
  ),
  _Slide(
    imageUrl:
        'https://images.unsplash.com/photo-1570042225831-d98fa7577f1e?w=900&q=80',
    accentColor: Color(0xFF4FC3F7),
    title: 'Track Livestock\n& Crops',
    body:
        'Monitor health events, vaccinations, breeding, production, and field data for all species and crops.',
    tag: 'TRACKING & RECORDS',
  ),
  _Slide(
    imageUrl:
        'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=900&q=80',
    accentColor: Color(0xFFFFCC80),
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

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Full-bleed photo background ─────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 700),
            child: CachedNetworkImage(
              key: ValueKey(_page),
              imageUrl: slide.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (_, __) => Container(color: Colors.black),
              errorWidget: (_, __, ___) => Container(
                color: const Color(0xFF1B4332),
                child: const Icon(
                  Icons.landscape_rounded,
                  size: 80,
                  color: Colors.white24,
                ),
              ),
            ),
          ),

          // ── Dark gradient overlay ───────────────────────────────────────
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x33000000),
                  Color(0x88000000),
                  Color(0xEE000000),
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // ── Main content ────────────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Skip button ───────────────────────────────────────────
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 20, 0),
                    child: TextButton(
                      onPressed: _done,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        backgroundColor: Colors.black38,
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

                const Spacer(),

                // ── Tag chip ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _TagChip(
                        key: ValueKey('tag$_page'),
                        label: slide.tag,
                        accentColor: slide.accentColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── PageView — title + body ───────────────────────────────
                SizedBox(
                  height: 190,
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
                                const EdgeInsets.symmetric(horizontal: 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    height: 1.15,
                                    letterSpacing: -0.8,
                                    shadows: [
                                      Shadow(
                                        color: Color(0x99000000),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  s.body,
                                  style: const TextStyle(
                                    color: Color(0xDDFFFFFF),
                                    fontSize: 15,
                                    height: 1.6,
                                    fontWeight: FontWeight.w400,
                                    shadows: [
                                      Shadow(
                                        color: Color(0x66000000),
                                        blurRadius: 8,
                                      ),
                                    ],
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

                const SizedBox(height: 24),
                // ── Dots ─────────────────────────────────────────────────
                _DotIndicator(count: _slides.length, current: _page),
                const SizedBox(height: 28),

                // ── CTAs ──────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton(
                        onPressed: _next,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
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
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isLast
                                  ? Icons.rocket_launch_rounded
                                  : Icons.arrow_forward_rounded,
                              size: 18,
                              color: Colors.black87,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
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
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _TagChip extends StatelessWidget {
  const _TagChip({super.key, required this.label, required this.accentColor});
  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withAlpha(180), width: 1.5),
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
