import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_text_field.dart';

// ── Step metadata ─────────────────────────────────────────────────────────────

class _StepMeta {
  const _StepMeta({
    required this.heroColor,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final Color heroColor;
  final IconData icon;
  final String title;
  final String subtitle;
}

const _stepData = [
  _StepMeta(
    heroColor: AppColors.primary,
    icon: Icons.agriculture_rounded,
    title: 'Smart Farm\nManagement',
    subtitle:
        'Track livestock, health events, production records, and more — all in one place.',
  ),
  _StepMeta(
    heroColor: AppColors.tertiary,
    icon: Icons.home_work_rounded,
    title: 'Tell us about\nyour farm',
    subtitle: 'Set up your farm profile to personalise your experience.',
  ),
  _StepMeta(
    heroColor: AppColors.secondary,
    icon: Icons.pets_rounded,
    title: 'What do you\nraise?',
    subtitle: 'Select the species you manage — you can change this anytime.',
  ),
  _StepMeta(
    heroColor: AppColors.success,
    icon: Icons.check_circle_rounded,
    title: "You're all set!",
    subtitle:
        "Your farm profile is ready. Let's start managing your livestock.",
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;
  bool _loading = false;

  final _farmNameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final Set<String> _selectedSpecies = {'Cattle', 'Poultry'};

  @override
  void dispose() {
    _pageCtrl.dispose();
    _farmNameCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _stepData.length - 1) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeInOutCubic);
      setState(() => _page++);
    }
  }

  void _back() {
    if (_page > 0) {
      _pageCtrl.previousPage(
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeInOutCubic);
      setState(() => _page--);
    }
  }

  Future<void> _finish() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    ref.read(authProvider.notifier).markOnboardingDone();
    ref.read(authProvider.notifier).logIn();
    context.go(AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final step = _stepData[_page];
    return Scaffold(
      backgroundColor: step.heroColor,
      body: Column(
        children: [
          // ── Animated hero area ──────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeInOutCubic,
            color: step.heroColor,
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.34,
                width: double.infinity,
                child: _HeroArea(step: step),
              ),
            ),
          ),
          // ── Content card ────────────────────────────────────────────────
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  _StepDots(
                      current: _page,
                      total: _stepData.length,
                      activeColor: step.heroColor),
                  Expanded(
                    child: PageView(
                      controller: _pageCtrl,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _WelcomePage(step: _stepData[0]),
                        _FarmDetailsPage(
                          step: _stepData[1],
                          nameCtrl: _farmNameCtrl,
                          locationCtrl: _locationCtrl,
                        ),
                        _SpeciesPage(
                          step: _stepData[2],
                          selected: _selectedSpecies,
                          onToggle: (s) => setState(() {
                            if (_selectedSpecies.contains(s)) {
                              if (_selectedSpecies.length > 1) {
                                _selectedSpecies.remove(s);
                              }
                            } else {
                              _selectedSpecies.add(s);
                            }
                          }),
                        ),
                        _DonePage(
                          step: _stepData[3],
                          farmName: _farmNameCtrl.text.isEmpty
                              ? 'Your Farm'
                              : _farmNameCtrl.text,
                        ),
                      ],
                    ),
                  ),
                  _OnboardingControls(
                    page: _page,
                    total: _stepData.length,
                    isLoading: _loading,
                    activeColor: step.heroColor,
                    onBack: _back,
                    onNext: _next,
                    onFinish: _finish,
                    onSignIn: _page == 0 ? () => context.go(AppRoutes.login) : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero area ─────────────────────────────────────────────────────────────────

class _HeroArea extends StatelessWidget {
  const _HeroArea({required this.step});
  final _StepMeta step;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          top: -40,
          right: -40,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withAlpha(12),
            ),
          ),
        ),
        Positioned(
          bottom: -30,
          left: -20,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withAlpha(8),
            ),
          ),
        ),
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(25),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withAlpha(50),
              width: 1.5,
            ),
          ),
          child: Icon(step.icon, size: 52, color: Colors.white),
        ),
      ],
    );
  }
}

// ── Step dots ─────────────────────────────────────────────────────────────────

class _StepDots extends StatelessWidget {
  const _StepDots(
      {required this.current,
      required this.total,
      required this.activeColor});
  final int current;
  final int total;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < total; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            width: i == current ? 24 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: i == current
                  ? activeColor
                  : i < current
                      ? activeColor.withAlpha(80)
                      : cs.outlineVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}

// ── Page 1: Welcome ───────────────────────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.step});
  final _StepMeta step;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step.title,
            style: tt.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
              letterSpacing: -0.5,
              height: 1.15,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            step.subtitle,
            style:
                tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant, height: 1.55),
          ),
          const SizedBox(height: AppSpacing.xl),
          _FeatureBullet(
            icon: Icons.pets_rounded,
            color: AppColors.primary,
            label: 'All livestock species in one place',
          ),
          const SizedBox(height: AppSpacing.md),
          _FeatureBullet(
            icon: Icons.medical_services_rounded,
            color: AppColors.error,
            label: 'Health events, alerts & vet records',
          ),
          const SizedBox(height: AppSpacing.md),
          _FeatureBullet(
            icon: Icons.bar_chart_rounded,
            color: AppColors.tertiary,
            label: 'Production records & reports',
          ),
        ],
      ),
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  const _FeatureBullet(
      {required this.icon, required this.color, required this.label});
  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(label,
              style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}

// ── Page 2: Farm Details ──────────────────────────────────────────────────────

class _FarmDetailsPage extends StatelessWidget {
  const _FarmDetailsPage({
    required this.step,
    required this.nameCtrl,
    required this.locationCtrl,
  });
  final _StepMeta step;
  final TextEditingController nameCtrl;
  final TextEditingController locationCtrl;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step.title,
            style: tt.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
              letterSpacing: -0.5,
              height: 1.15,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(step.subtitle,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: AppSpacing.xl),
          FarmTextField(
            controller: nameCtrl,
            label: 'Farm name',
            hint: 'e.g. Sunrise Ranch',
            prefixIcon:
                Icon(Icons.home_work_outlined, color: cs.onSurfaceVariant),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          FarmTextField(
            controller: locationCtrl,
            label: 'Location',
            hint: 'e.g. Nairobi County, Kenya',
            prefixIcon:
                Icon(Icons.location_on_outlined, color: cs.onSurfaceVariant),
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }
}

// ── Page 3: Species ───────────────────────────────────────────────────────────

class _SpeciesPage extends StatelessWidget {
  const _SpeciesPage({
    required this.step,
    required this.selected,
    required this.onToggle,
  });
  final _StepMeta step;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  static const _options = [
    (name: 'Cattle', icon: Icons.hive_rounded, color: AppColors.cattleColor),
    (name: 'Goats', icon: Icons.hive_rounded, color: AppColors.goatColor),
    (name: 'Sheep', icon: Icons.hive_rounded, color: AppColors.sheepColor),
    (name: 'Pigs', icon: Icons.hive_rounded, color: AppColors.pigColor),
    (
      name: 'Poultry',
      icon: Icons.egg_rounded,
      color: AppColors.poultryColor
    ),
    (
      name: 'Horses',
      icon: Icons.hive_rounded,
      color: AppColors.horseColor
    ),
    (
      name: 'Rabbits',
      icon: Icons.cruelty_free_rounded,
      color: AppColors.rabbitColor
    ),
    (
      name: 'Fish',
      icon: Icons.water_rounded,
      color: AppColors.aquacultureColor
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step.title,
            style: tt.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
              letterSpacing: -0.5,
              height: 1.15,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(step.subtitle,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final sp in _options)
                _SpeciesChip(
                  name: sp.name,
                  icon: sp.icon,
                  color: sp.color,
                  isSelected: selected.contains(sp.name),
                  onTap: () => onToggle(sp.name),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpeciesChip extends StatelessWidget {
  const _SpeciesChip({
    required this.name,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });
  final String name;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(20) : cs.surfaceContainerLow,
          borderRadius: AppRadius.chip,
          border: Border.all(
            color: isSelected ? color : cs.outlineVariant,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: isSelected ? color : cs.onSurfaceVariant),
            const SizedBox(width: AppSpacing.xs),
            Text(
              name,
              style: tt.labelMedium?.copyWith(
                color: isSelected ? color : cs.onSurface,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: AppSpacing.xs),
              Icon(Icons.check_rounded, size: 14, color: color),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Page 4: Done ──────────────────────────────────────────────────────────────

class _DonePage extends StatelessWidget {
  const _DonePage({required this.step, required this.farmName});
  final _StepMeta step;
  final String farmName;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step.title,
            style: tt.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
              letterSpacing: -0.5,
              height: 1.15,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            step.subtitle,
            style:
                tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant, height: 1.55),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(15),
              borderRadius: AppRadius.card,
              border: Border.all(
                  color: AppColors.success.withAlpha(60), width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.home_work_rounded,
                      color: AppColors.success, size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(farmName,
                          style: tt.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      Text('Farm profile created',
                          style: tt.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.success),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Navigation controls ───────────────────────────────────────────────────────

class _OnboardingControls extends StatelessWidget {
  const _OnboardingControls({
    required this.page,
    required this.total,
    required this.isLoading,
    required this.activeColor,
    required this.onBack,
    required this.onNext,
    required this.onFinish,
    this.onSignIn,
  });
  final int page;
  final int total;
  final bool isLoading;
  final Color activeColor;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onFinish;
  final VoidCallback? onSignIn;

  @override
  Widget build(BuildContext context) {
    final isLast = page == total - 1;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (page > 0)
                  OutlinedButton(
                    onPressed: onBack,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(56, 52),
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.button),
                    ),
                    child: const Icon(Icons.arrow_back_rounded),
                  )
                else
                  const SizedBox.shrink(),
                const Spacer(),
                FilledButton(
                  onPressed: isLoading ? null : (isLast ? onFinish : onNext),
                  style: FilledButton.styleFrom(
                    backgroundColor: activeColor,
                    minimumSize: const Size(148, 52),
                    shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.button),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(isLast ? 'Get Started' : 'Continue',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(width: AppSpacing.xs),
                            Icon(
                              isLast
                                  ? Icons.rocket_launch_rounded
                                  : Icons.arrow_forward_rounded,
                              size: 18,
                            ),
                          ],
                        ),
                ),
              ],
            ),
            if (onSignIn != null) ...[
              const SizedBox(height: AppSpacing.sm),
              GestureDetector(
                onTap: onSignIn,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: RichText(
                    text: TextSpan(
                      style: tt.bodySmall,
                      children: [
                        TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                        TextSpan(
                          text: 'Sign in',
                          style: TextStyle(
                            color: activeColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
