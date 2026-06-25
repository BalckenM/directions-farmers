import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile_app/core/router/app_routes.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_spacing.dart';
import 'package:mobile_app/shared/widgets/farm_dropdown.dart';
import 'package:mobile_app/shared/widgets/farm_text_field.dart';
import 'package:mobile_app/features/auth/data/subscription_data.dart';
import 'package:mobile_app/features/auth/providers/auth_provider.dart';

/// Module display metadata (mirrors _moduleInfo in registration_screen.dart).
const _moduleInfo = <String, ({String label, IconData icon})>{
  FarmerModules.cattle: (label: 'Cattle', icon: Icons.agriculture_rounded),
  FarmerModules.goat: (label: 'Goats', icon: Icons.pets_rounded),
  FarmerModules.poultry: (label: 'Poultry', icon: Icons.egg_alt_rounded),
  FarmerModules.pigs: (label: 'Pigs', icon: Icons.set_meal_rounded),
  FarmerModules.apiculture: (
    label: 'Apiculture',
    icon: Icons.emoji_nature_rounded,
  ),
  FarmerModules.crop: (label: 'Crop Farming', icon: Icons.grass_rounded),
  FarmerModules.financial: (
    label: 'Financials',
    icon: Icons.account_balance_wallet_rounded,
  ),
  FarmerModules.insights: (label: 'Analytics', icon: Icons.bar_chart_rounded),
  FarmerModules.traceability: (
    label: 'Traceability',
    icon: Icons.route_rounded,
  ),
  FarmerModules.reports: (label: 'Reports', icon: Icons.description_rounded),
};

/// Farm setup wizard shown after social login for new users.
/// Collects farm name, country/province, plan, and modules — then updates profile.
class FarmSetupScreen extends ConsumerStatefulWidget {
  const FarmSetupScreen({super.key});

  @override
  ConsumerState<FarmSetupScreen> createState() => _FarmSetupScreenState();
}

enum _SetupStep { farm, plan, modules }

class _FarmSetupScreenState extends ConsumerState<FarmSetupScreen> {
  final _pageCtrl = PageController();
  _SetupStep _step = _SetupStep.farm;
  bool _loading = false;

  final _farmNameCtrl = TextEditingController();

  String _country = 'South Africa';
  String _province = kCountryProvinces['South Africa']!.first;
  SubscriptionPlan _plan = kSubscriptionPlans[1]; // Growth default
  Set<String> _selectedModules = {...kSubscriptionPlans[1].includedModules};

  @override
  void dispose() {
    _pageCtrl.dispose();
    _farmNameCtrl.dispose();
    super.dispose();
  }

  void _goToStep(_SetupStep s) {
    setState(() => _step = s);
    _pageCtrl.animateToPage(
      s.index,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
    );
  }

  void _next() {
    switch (_step) {
      case _SetupStep.farm:
        if (_farmNameCtrl.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter your farm name.'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
        _goToStep(_SetupStep.plan);
      case _SetupStep.plan:
        _goToStep(_SetupStep.modules);
      case _SetupStep.modules:
        _completeFarmSetup();
    }
  }

  void _back() {
    if (_step.index > 0) {
      _goToStep(_SetupStep.values[_step.index - 1]);
    }
  }

  Future<void> _completeFarmSetup() async {
    if (_selectedModules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one module.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _loading = true);

    try {
      final ds = ref.read(authRemoteDataSourceProvider);

      // 1. Update profile with farm details
      await ds.updateProfile({
        'farmName': _farmNameCtrl.text.trim(),
        'country': _country,
        'province': _province,
      });

      // 2. Create/upgrade subscription plan (also activates modules)
      await ds.upgradePlan(_plan.id);

      // 3. Refresh auth state to pick up new profile + modules
      await ref.read(authProvider.notifier).refreshSession();

      if (!mounted) return;
      context.go(AppRoutes.dashboard);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Setup failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Complete Farm Setup'),
        leading: _step.index > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _back,
              )
            : null,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Step indicator
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: List.generate(3, (i) {
                final isActive = i <= _step.index;
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : cs.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Pages
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _FarmDetailsPage(
                  farmNameCtrl: _farmNameCtrl,
                  country: _country,
                  province: _province,
                  onCountryChanged: (v) => setState(() {
                    _country = v;
                    _province = kCountryProvinces[v]!.first;
                  }),
                  onProvinceChanged: (v) => setState(() => _province = v),
                ),
                _PlanPage(
                  selectedPlan: _plan,
                  onPlanChanged: (p) => setState(() {
                    _plan = p;
                    _selectedModules = {...p.includedModules};
                  }),
                ),
                _ModulesPage(
                  plan: _plan,
                  selectedModules: _selectedModules,
                  onToggle: (m) => setState(() {
                    if (_selectedModules.contains(m)) {
                      if (_selectedModules.length > 1) {
                        _selectedModules.remove(m);
                      }
                    } else {
                      _selectedModules.add(m);
                    }
                  }),
                ),
              ],
            ),
          ),

          // Next / Complete button
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _loading ? null : _next,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _step == _SetupStep.modules
                            ? 'Complete Setup'
                            : 'Next',
                        style: tt.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
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

// ── Farm Details Page ──────────────────────────────────────────────────────────

class _FarmDetailsPage extends StatelessWidget {
  const _FarmDetailsPage({
    required this.farmNameCtrl,
    required this.country,
    required this.province,
    required this.onCountryChanged,
    required this.onProvinceChanged,
  });

  final TextEditingController farmNameCtrl;
  final String country;
  final String province;
  final ValueChanged<String> onCountryChanged;
  final ValueChanged<String> onProvinceChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provinces = kCountryProvinces[country] ?? ['N/A'];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.sm),
          FarmTextField(
            controller: farmNameCtrl,
            label: 'Farm Name',
            hint: 'e.g. Green Valley Farm',
            prefixIcon: Icon(
              Icons.home_work_outlined,
              color: cs.onSurfaceVariant,
            ),
            textInputAction: TextInputAction.next,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Farm name is required'
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          FarmDropdown<String>(
            label: 'Country',
            value: country,
            prefixIcon: Icon(Icons.public_outlined, color: cs.onSurfaceVariant),
            items: kCountryProvinces.keys
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => v != null ? onCountryChanged(v) : null,
          ),
          const SizedBox(height: AppSpacing.md),
          FarmDropdown<String>(
            label: country == 'South Africa' ? 'Province' : 'Region / Province',
            value: provinces.contains(province) ? province : provinces.first,
            prefixIcon: Icon(
              Icons.location_on_outlined,
              color: cs.onSurfaceVariant,
            ),
            items: provinces
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: (v) => v != null ? onProvinceChanged(v) : null,
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

// ── Plan Selection Page ────────────────────────────────────────────────────────

class _PlanPage extends StatelessWidget {
  const _PlanPage({required this.selectedPlan, required this.onPlanChanged});

  final SubscriptionPlan selectedPlan;
  final ValueChanged<SubscriptionPlan> onPlanChanged;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.sm,
      ),
      children: [
        Text(
          'Choose Your Plan',
          style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Start with a 30-day free trial — cancel anytime.',
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        ...kSubscriptionPlans.map(
          (plan) => _PlanCard(
            plan: plan,
            isSelected: plan.id == selectedPlan.id,
            onTap: () => onPlanChanged(plan),
          ),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  final SubscriptionPlan plan;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final accent = switch (plan.id) {
      'starter' => AppColors.secondary,
      'growth' => AppColors.primary,
      'enterprise' => const Color(0xFF6750A4),
      _ => AppColors.primary,
    };

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? accent.withAlpha(18)
              : cs.surfaceContainerLowest,
          border: Border.all(
            color: isSelected ? accent : cs.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.label,
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSelected ? accent : cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plan.tagline,
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${plan.currency} ${plan.price}/month',
                    style: tt.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? accent : cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: accent, size: 24),
          ],
        ),
      ),
    );
  }
}

// ── Module Selection Page ──────────────────────────────────────────────────────

class _ModulesPage extends StatelessWidget {
  const _ModulesPage({
    required this.plan,
    required this.selectedModules,
    required this.onToggle,
  });

  final SubscriptionPlan plan;
  final Set<String> selectedModules;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileW =
            (constraints.maxWidth - AppSpacing.xl * 2 - AppSpacing.sm) / 2;

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.sm,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          children: [
            Text(
              'Activate Modules',
              style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Your ${plan.label} plan includes these features. '
              'Toggle any you don\'t need.',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: plan.includedModules.map((m) {
                final info = _moduleInfo[m];
                if (info == null) return const SizedBox.shrink();
                final isOn = selectedModules.contains(m);
                return _ModuleTile(
                  info: info,
                  isSelected: isOn,
                  width: tileW,
                  onTap: () => onToggle(m),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({
    required this.info,
    required this.isSelected,
    required this.width,
    required this.onTap,
  });

  final ({String label, IconData icon}) info;
  final bool isSelected;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withAlpha(14)
              : cs.surfaceContainerLowest,
          border: Border.all(
            color: isSelected ? AppColors.primary : cs.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withAlpha(20)
                    : cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                info.icon,
                size: 20,
                color: isSelected ? AppColors.primary : cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              info.label,
              style: tt.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.primary : cs.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2,
              width: isSelected ? 24 : 0,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
