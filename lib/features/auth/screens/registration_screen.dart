import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_dropdown.dart';
import '../../../shared/widgets/farm_text_field.dart';
import '../../../shared/widgets/social_auth_buttons.dart';
import '../../../shared/widgets/primary_button.dart';
import '../models/auth_state.dart';
import '../providers/auth_provider.dart';

// ── Step enum ─────────────────────────────────────────────────────────────────

enum _RegStep { account, farm, plan, modules }

// ── Screen ────────────────────────────────────────────────────────────────────

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageCtrl = PageController();
  _RegStep _step = _RegStep.account;

  // ── Controllers ──────────────────────────────────────────────────────────
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _farmNameCtrl = TextEditingController();

  bool _loading = false;

  // ── Selections ────────────────────────────────────────────────────────────
  String _country = 'South Africa';
  String _province = kCountryProvinces['South Africa']!.first;
  late SubscriptionPlan _plan = kSubscriptionPlans[1];
  late Set<String> _selectedModules = {...kSubscriptionPlans[1].includedModules};

  @override
  void dispose() {
    _pageCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _farmNameCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _goToStep(_RegStep s) {
    setState(() => _step = s);
    _pageCtrl.animateToPage(
      s.index,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
    );
  }

  bool _validateCurrentStep() {
    switch (_step) {
      case _RegStep.account:
        return _formKey.currentState?.validate() ?? false;
      case _RegStep.farm:
        // R8: validate farm name via formState too
        return _farmNameCtrl.text.trim().isNotEmpty;
      case _RegStep.plan:
        return true;
      case _RegStep.modules:
        return _selectedModules.isNotEmpty;
    }
  }

  void _next() {
    if (!_validateCurrentStep()) {
      if (_step == _RegStep.farm && _farmNameCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enter your farm name.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }
    if (_step.index < _RegStep.values.length - 1) {
      _goToStep(_RegStep.values[_step.index + 1]);
    }
  }

  void _back() {
    if (_step.index > 0) {
      _goToStep(_RegStep.values[_step.index - 1]);
    } else {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.login);
      }
    }
  }

  Future<void> _register() async {
    if (_selectedModules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one module.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _loading = true);
    await ref.read(authProvider.notifier).register(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          firstName: _firstNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
          farmName: _farmNameCtrl.text.trim(),
          country: _country,
          province: _province,
          subscriptionPlan: _plan.id,
          activatedModules: _selectedModules.toList(),
          phone: _phoneCtrl.text.trim().isEmpty
              ? null
              : _phoneCtrl.text.trim(),
        );
    if (!mounted) return;
    setState(() => _loading = false);

    final authState = ref.read(authProvider).value;
    if (authState is AuthAuthenticated) {
      // R7: navigate to WelcomeScreen instead of going directly to dashboard
      context.go(
        AppRoutes.welcome,
        extra: {
          'firstName': _firstNameCtrl.text.trim(),
          'farmName': _farmNameCtrl.text.trim(),
        },
      );
    } else if (authState is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.message),
          backgroundColor: AppColors.error,
        ),
      );
      _goToStep(_RegStep.account);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: _back,
        ),
        title: Text(
          _stepTitle(_step),
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // R1: progress bar with distinct completed / current / upcoming states
          _StepProgressBar(
            current: _step.index,
            total: _RegStep.values.length,
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _AccountStep(
                    firstNameCtrl: _firstNameCtrl,
                    lastNameCtrl: _lastNameCtrl,
                    emailCtrl: _emailCtrl,
                    phoneCtrl: _phoneCtrl,
                    passwordCtrl: _passwordCtrl,
                    confirmCtrl: _confirmCtrl,
                  ),
                  _FarmStep(
                    farmNameCtrl: _farmNameCtrl,
                    selectedCountry: _country,
                    selectedProvince: _province,
                    onCountryChanged: (c) => setState(() {
                      _country = c;
                      _province = kCountryProvinces[c]!.first;
                    }),
                    onProvinceChanged: (p) => setState(() => _province = p),
                  ),
                  _PlanStep(
                    selected: _plan,
                    onSelect: (p) => setState(() {
                      _plan = p;
                      _selectedModules = {...p.includedModules};
                    }),
                  ),
                  _ModulesStep(
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
          ),
          _RegistrationFooter(
            step: _step,
            loading: _loading,
            onNext: _next,
            onRegister: _register,
          ),
        ],
      ),
    );
  }

  String _stepTitle(_RegStep s) => switch (s) {
        _RegStep.account => 'Create Account',
        _RegStep.farm => 'Your Farm',
        _RegStep.plan => 'Choose a Plan',
        _RegStep.modules => 'Activate Modules',
      };
}

// ── R1: Progress bar with three visual states ─────────────────────────────────

class _StepProgressBar extends StatelessWidget {
  const _StepProgressBar({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: List.generate(total, (i) {
          final isCompleted = i < current;
          final isCurrent = i == current;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.primary
                          : isCurrent
                              ? AppColors.primaryLight
                              : AppColors.primary.withAlpha(30),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Step 1: Account details ───────────────────────────────────────────────────

class _AccountStep extends StatelessWidget {
  const _AccountStep({
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.passwordCtrl,
    required this.confirmCtrl,
  });

  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SocialAuthButton(
            label: 'Sign up with Google',
            provider: SocialProvider.google,
            onPressed: () {
              // TODO: wire up Google Sign-In
            },
          ),
          const SizedBox(height: 12),
          SocialAuthButton(
            label: 'Sign up with Apple',
            provider: SocialProvider.apple,
            onPressed: () {
              // TODO: wire up Apple Sign-In
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          const SocialAuthDivider(),
          const SizedBox(height: AppSpacing.md),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: FarmTextField(
                  controller: firstNameCtrl,
                  label: 'First Name',
                  hint: 'John',
                  // R3: added prefix icons to name fields for visual consistency
                  prefixIcon: Icon(Icons.person_outline_rounded,
                      color: cs.onSurfaceVariant),
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FarmTextField(
                  controller: lastNameCtrl,
                  label: 'Last Name',
                  hint: 'Dlamini',
                  prefixIcon: Icon(Icons.person_outline_rounded,
                      color: cs.onSurfaceVariant),
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          FarmTextField(
            controller: emailCtrl,
            label: 'Email address',
            hint: 'you@example.com',
            prefixIcon:
                Icon(Icons.email_outlined, color: cs.onSurfaceVariant),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          FarmTextField(
            controller: phoneCtrl,
            label: 'Phone (optional)',
            hint: '+27 82 000 0000',
            prefixIcon:
                Icon(Icons.phone_outlined, color: cs.onSurfaceVariant),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          // R2: obscureText: true enables FarmTextField's built-in visibility
          // toggle; minimum raised to 8 characters
          FarmTextField(
            controller: passwordCtrl,
            label: 'Password',
            hint: 'At least 8 characters',
            prefixIcon:
                Icon(Icons.lock_outline, color: cs.onSurfaceVariant),
            obscureText: true,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 8) return 'Minimum 8 characters';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xs),
          // R2: password strength indicator
          _PasswordStrengthBar(controller: passwordCtrl),
          const SizedBox(height: AppSpacing.md),
          FarmTextField(
            controller: confirmCtrl,
            label: 'Confirm Password',
            hint: 'Repeat your password',
            prefixIcon:
                Icon(Icons.lock_outline, color: cs.onSurfaceVariant),
            obscureText: true,
            textInputAction: TextInputAction.done,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm your password';
              if (v != passwordCtrl.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

// ── R2: Password strength indicator ──────────────────────────────────────────

class _PasswordStrengthBar extends StatefulWidget {
  const _PasswordStrengthBar({required this.controller});
  final TextEditingController controller;

  @override
  State<_PasswordStrengthBar> createState() => _PasswordStrengthBarState();
}

class _PasswordStrengthBarState extends State<_PasswordStrengthBar> {
  String _password = '';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() => _password = widget.controller.text);
  }

  // Returns 0–4
  int get _strength {
    if (_password.isEmpty) return 0;
    int score = 0;
    if (_password.length >= 8) score++;
    if (_password.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(_password)) score++;
    if (RegExp(r'[0-9]').hasMatch(_password)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(_password)) score++;
    return score.clamp(0, 4);
  }

  @override
  Widget build(BuildContext context) {
    if (_password.isEmpty) return const SizedBox.shrink();

    final tt = Theme.of(context).textTheme;
    final strength = _strength;
    final (label, color) = switch (strength) {
      0 || 1 => ('Weak', AppColors.error),
      2 => ('Fair', AppColors.warning),
      3 => ('Good', AppColors.secondary),
      _ => ('Strong', AppColors.success),
    };

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          ...List.generate(4, (i) {
            final filled = i < strength;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 3,
                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                decoration: BoxDecoration(
                  color: filled ? color : color.withAlpha(30),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 2: Farm details ──────────────────────────────────────────────────────

class _FarmStep extends StatelessWidget {
  const _FarmStep({
    required this.farmNameCtrl,
    required this.selectedCountry,
    required this.selectedProvince,
    required this.onCountryChanged,
    required this.onProvinceChanged,
  });

  final TextEditingController farmNameCtrl;
  final String selectedCountry;
  final String selectedProvince;
  final ValueChanged<String> onCountryChanged;
  final ValueChanged<String> onProvinceChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provinces = kCountryProvinces[selectedCountry] ?? ['N/A'];

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
            prefixIcon: Icon(Icons.home_work_outlined,
                color: cs.onSurfaceVariant),
            textInputAction: TextInputAction.next,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Farm name is required'
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          // R4: replaced local _DropdownField with shared FarmDropdown widget
          FarmDropdown<String>(
            label: 'Country',
            value: selectedCountry,
            prefixIcon:
                Icon(Icons.public_outlined, color: cs.onSurfaceVariant),
            items: kCountryProvinces.keys
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => v != null ? onCountryChanged(v) : null,
          ),
          const SizedBox(height: AppSpacing.md),
          FarmDropdown<String>(
            label: selectedCountry == 'South Africa'
                ? 'Province'
                : 'Region / Province',
            value: provinces.contains(selectedProvince)
                ? selectedProvince
                : provinces.first,
            prefixIcon: Icon(Icons.location_on_outlined,
                color: cs.onSurfaceVariant),
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

// ── Step 3: Plan selection ────────────────────────────────────────────────────

class _PlanStep extends StatelessWidget {
  const _PlanStep({required this.selected, required this.onSelect});
  final SubscriptionPlan selected;
  final ValueChanged<SubscriptionPlan> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
      children: [
        ...kSubscriptionPlans.map(
          (plan) => _PlanCard(
            plan: plan,
            isSelected: plan.id == selected.id,
            onTap: () => onSelect(plan),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: Text(
            '* 30-day free trial. Cancel anytime.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
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

    // R5: Growth plan gets a "Most Popular" badge
    final isPopular = plan.id == 'growth';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? accent.withAlpha(18) : cs.surfaceContainerLowest,
          border: Border.all(
            color: isSelected ? accent : cs.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // R5: popular badge top-right
            if (isPopular)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(14),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Most Popular',
                    style: tt.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.label,
                              style: tt.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: isSelected ? accent : cs.onSurface,
                              ),
                            ),
                            Text(
                              plan.tagline,
                              style: tt.bodySmall
                                  ?.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      // Extra right padding on popular card to avoid badge overlap
                      SizedBox(width: isPopular ? 80 : 0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${plan.currency} ${plan.price}',
                            style: tt.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: isSelected ? accent : cs.onSurface,
                            ),
                          ),
                          Text(
                            '/month',
                            style: tt.labelSmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Icon(Icons.check_circle_rounded,
                            color: accent, size: 22),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...plan.features.map(
                    (f) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Row(
                        children: [
                          Icon(Icons.check_rounded,
                              size: 15,
                              color: isSelected
                                  ? accent
                                  : cs.onSurfaceVariant),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              f,
                              style: tt.bodySmall?.copyWith(
                                color: isSelected
                                    ? cs.onSurface
                                    : cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
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

// ── Step 4: Module selection ──────────────────────────────────────────────────

const _moduleInfo = <String, ({String label, IconData icon})>{
  FarmerModules.cattle: (
    label: 'Cattle Management',
    icon: Icons.agriculture_rounded
  ),
  FarmerModules.goat: (
    label: 'Goat Management',
    icon: Icons.pets_rounded
  ),
  FarmerModules.poultry: (
    label: 'Poultry Management',
    icon: Icons.egg_alt_rounded
  ),
  FarmerModules.pigs: (
    label: 'Pig Management',
    icon: Icons.set_meal_rounded
  ),
  FarmerModules.aquaculture: (
    label: 'Aquaculture',
    icon: Icons.water_rounded
  ),
  FarmerModules.apiculture: (
    label: 'Apiculture (Bees)',
    icon: Icons.emoji_nature_rounded
  ),
  FarmerModules.crop: (
    label: 'Crop Farming',
    icon: Icons.grass_rounded
  ),
  FarmerModules.financial: (
    label: 'Financial Records',
    icon: Icons.account_balance_wallet_rounded
  ),
  FarmerModules.insights: (
    label: 'Analytics & Insights',
    icon: Icons.bar_chart_rounded
  ),
  FarmerModules.traceability: (
    label: 'Animal Traceability',
    icon: Icons.route_rounded
  ),
  FarmerModules.reports: (
    label: 'Reports',
    icon: Icons.description_rounded
  ),
};

class _ModulesStep extends StatelessWidget {
  const _ModulesStep({
    required this.plan,
    required this.selectedModules,
    required this.onToggle,
  });

  final SubscriptionPlan plan;
  final Set<String> selectedModules;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
      children: [
        Text(
          'Your ${plan.label} plan includes:',
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...plan.includedModules.map((m) {
          final info = _moduleInfo[m];
          if (info == null) return const SizedBox.shrink();
          final isOn = selectedModules.contains(m);
          return CheckboxListTile(
            value: isOn,
            onChanged: (_) => onToggle(m),
            secondary: CircleAvatar(
              radius: 18,
              backgroundColor: isOn
                  ? AppColors.primary.withAlpha(20)
                  : cs.surfaceContainerLow,
              child: Icon(
                info.icon,
                size: 18,
                color: isOn ? AppColors.primary : cs.onSurfaceVariant,
              ),
            ),
            title: Text(
              info.label,
              style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            // R6: restored standard content padding so secondary icon has proper inset
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 0),
            controlAffinity: ListTileControlAffinity.trailing,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          );
        }),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

// ── Footer CTA ────────────────────────────────────────────────────────────────

class _RegistrationFooter extends StatelessWidget {
  const _RegistrationFooter({
    required this.step,
    required this.loading,
    required this.onNext,
    required this.onRegister,
  });

  final _RegStep step;
  final bool loading;
  final VoidCallback onNext;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLast = step == _RegStep.modules;

    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xxl),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
            top: BorderSide(color: cs.outlineVariant.withAlpha(60))),
      ),
      child: PrimaryButton(
        label: isLast ? 'Create Account' : 'Next',
        icon: Icon(
          isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
          size: 18,
          color: Colors.white,
        ),
        isLoading: loading,
        onPressed: loading ? null : (isLast ? onRegister : onNext),
      ),
    );
  }
}
