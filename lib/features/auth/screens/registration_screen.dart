import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile_app/core/router/app_routes.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_radius.dart';
import 'package:mobile_app/core/theme/app_spacing.dart';
import 'package:mobile_app/shared/widgets/farm_text_field.dart';
import 'package:mobile_app/features/billing/models/plan.dart';
import 'package:mobile_app/features/billing/providers/billing_providers.dart';
import 'package:mobile_app/features/auth/models/auth_state.dart';
import 'package:mobile_app/features/auth/providers/auth_provider.dart';

// ── Registration type ────────────────────────────────────────────────────────

enum _RegistrationType { owner, staff }

// ── Step enum ─────────────────────────────────────────────────────────────────

enum _RegStep { account, company, plan }

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
  _RegistrationType _regType = _RegistrationType.owner;

  // ── Controllers ──────────────────────────────────────────────────────────
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _farmNameCtrl = TextEditingController();
  final _inviteCodeCtrl = TextEditingController();

  bool _loading = false;

  // ── Selections ────────────────────────────────────────────────────────────
  BillingPlan? _selectedPlan;

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
    _inviteCodeCtrl.dispose();
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
      case _RegStep.company:
        return _farmNameCtrl.text.trim().isNotEmpty;
      case _RegStep.plan:
        return _selectedPlan != null;
    }
  }

  void _next() {
    if (!_validateCurrentStep()) {
      if (_step == _RegStep.company && _farmNameCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your company name.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      if (_step == _RegStep.plan && _selectedPlan == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a plan to continue.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }
    // Staff flow: account step → register as staff immediately
    if (_regType == _RegistrationType.staff && _step == _RegStep.account) {
      _registerAsStaff();
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

  Future<void> _registerAsStaff() async {
    final inviteCode = _inviteCodeCtrl.text.trim();
    if (inviteCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your farm invite code.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final ds = ref.read(authRemoteDataSourceProvider);
      await ds.acceptInvite(
        token: inviteCode,
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (!mounted) return;
      // Refresh auth state so the router can redirect to the correct dashboard
      await ref.read(authProvider.notifier).refreshSession();
      if (!mounted) return;
      setState(() => _loading = false);
      final authState = ref.read(authProvider).value;
      if (authState is AuthAuthenticated) {
        context.go(
          AppRoutes.welcome,
          extra: {
            'firstName': _firstNameCtrl.text.trim(),
            'farmName': authState.user.farmName,
          },
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to accept invite: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _register() async {
    if (_selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a plan to continue.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _loading = true);
    await ref
        .read(authProvider.notifier)
        .register(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          firstName: _firstNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
          companyName: _farmNameCtrl.text.trim(),
          planSlug: _selectedPlan!.slug,
          phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        );
    if (!mounted) return;
    setState(() => _loading = false);

    final authState = ref.read(authProvider).value;
    if (authState is AuthAuthenticated) {
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

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: _RegHeader(
        stepIndex: _step.index,
        stepTotal: _RegStep.values.length,
        onBack: _back,
      ),
      body: Column(
        children: [
          // Visual step progress
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              AppSpacing.sm,
            ),
            child: _VisualStepper(
              current: _step.index,
              labels: _regType == _RegistrationType.staff
                  ? const ['Account']
                  : const ['Account', 'Company', 'Plan'],
            ),
          ),

          // Step pages
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Step 1: Account
                  _StepPage(
                    hero: const _StepHero(
                      icon: Icons.person_outline_rounded,
                      title: 'Account Details',
                      subtitle: 'Create your secure login credentials',
                    ),
                    child: _AccountStep(
                      firstNameCtrl: _firstNameCtrl,
                      lastNameCtrl: _lastNameCtrl,
                      emailCtrl: _emailCtrl,
                      phoneCtrl: _phoneCtrl,
                      passwordCtrl: _passwordCtrl,
                      confirmCtrl: _confirmCtrl,
                      regType: _regType,
                      inviteCodeCtrl: _inviteCodeCtrl,
                      onRegTypeChanged: (t) => setState(() => _regType = t),
                    ),
                  ),

                  // Step 2: Company
                  _StepPage(
                    hero: const _StepHero(
                      icon: Icons.business_outlined,
                      title: 'Company Details',
                      subtitle: 'What is the name of your business?',
                    ),
                    child: _CompanyStep(companyNameCtrl: _farmNameCtrl),
                  ),

                  // Step 3: Plan (loaded from API)
                  _StepPage(
                    hero: const _StepHero(
                      icon: Icons.workspace_premium_outlined,
                      title: 'Choose a Plan',
                      subtitle: 'Start with a free trial — cancel anytime',
                    ),
                    child: _ApiPlanStep(
                      selectedPlan: _selectedPlan,
                      onSelect: (p) => setState(() => _selectedPlan = p),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Footer CTA
          _RegistrationFooter(
            step: _step,
            loading: _loading,
            onNext: _next,
            onRegister: _register,
            regType: _regType,
          ),
        ],
      ),
    );
  }
}

// ── Custom AppBar ─────────────────────────────────────────────────────────────

class _RegHeader extends StatelessWidget implements PreferredSizeWidget {
  const _RegHeader({
    required this.stepIndex,
    required this.stepTotal,
    required this.onBack,
  });

  final int stepIndex;
  final int stepTotal;
  final VoidCallback onBack;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return AppBar(
      backgroundColor: cs.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: onBack,
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF1B5E20)],
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
          const SizedBox(width: 7),
          Text(
            '4Directions',
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: AppSpacing.md),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(14),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withAlpha(50)),
          ),
          child: Text(
            '${stepIndex + 1} / $stepTotal',
            style: tt.labelSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Visual step indicator ─────────────────────────────────────────────────────

class _VisualStepper extends StatelessWidget {
  const _VisualStepper({required this.current, required this.labels});
  final int current;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final total = labels.length;
    return Row(
      children: List.generate(total * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector line
          final leftDone = (i ~/ 2) < current;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              height: 2,
              decoration: BoxDecoration(
                color: leftDone
                    ? AppColors.primary
                    : AppColors.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          );
        }

        final idx = i ~/ 2;
        final isDone = idx < current;
        final isCurrent = idx == current;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDone
                    ? AppColors.primary
                    : isCurrent
                    ? AppColors.primary.withAlpha(15)
                    : Theme.of(context).colorScheme.surfaceContainerLow,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone || isCurrent
                      ? AppColors.primary
                      : Theme.of(context).colorScheme.outlineVariant,
                  width: isCurrent ? 2 : 1,
                ),
              ),
              child: Center(
                child: isDone
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      )
                    : Text(
                        '${idx + 1}',
                        style: TextStyle(
                          color: isCurrent
                              ? AppColors.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              labels[idx],
              style: TextStyle(
                color: isDone || isCurrent
                    ? AppColors.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 9,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ── Step hero card ────────────────────────────────────────────────────────────

class _StepHero extends StatelessWidget {
  const _StepHero({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withAlpha(10),
            AppColors.primaryContainer.withAlpha(28),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withAlpha(30)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(60),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step page wrapper ─────────────────────────────────────────────────────────

class _StepPage extends StatelessWidget {
  const _StepPage({required this.hero, required this.child});
  final Widget hero;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        hero,
        Expanded(child: child),
      ],
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
    required this.regType,
    required this.inviteCodeCtrl,
    required this.onRegTypeChanged,
  });

  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;
  final _RegistrationType regType;
  final TextEditingController inviteCodeCtrl;
  final ValueChanged<_RegistrationType> onRegTypeChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isStaff = regType == _RegistrationType.staff;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Owner / Staff toggle
          Row(
            children: [
              Expanded(
                child: _RegTypeCard(
                  icon: Icons.agriculture_rounded,
                  title: 'Farm Owner',
                  subtitle: 'Create a new farm account',
                  selected: !isStaff,
                  onTap: () => onRegTypeChanged(_RegistrationType.owner),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _RegTypeCard(
                  icon: Icons.badge_rounded,
                  title: 'Staff Member',
                  subtitle: 'Join an existing farm',
                  selected: isStaff,
                  onTap: () => onRegTypeChanged(_RegistrationType.staff),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          Row(
            children: [
              Expanded(
                child: FarmTextField(
                  controller: firstNameCtrl,
                  label: 'First Name',
                  hint: 'John',
                  prefixIcon: Icon(
                    Icons.person_outline_rounded,
                    color: cs.onSurfaceVariant,
                  ),
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
                  prefixIcon: Icon(
                    Icons.person_outline_rounded,
                    color: cs.onSurfaceVariant,
                  ),
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
            prefixIcon: Icon(Icons.email_outlined, color: cs.onSurfaceVariant),
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
            prefixIcon: Icon(Icons.phone_outlined, color: cs.onSurfaceVariant),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          FarmTextField(
            controller: passwordCtrl,
            label: 'Password',
            hint: 'At least 8 characters',
            prefixIcon: Icon(Icons.lock_outline, color: cs.onSurfaceVariant),
            obscureText: true,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 8) return 'Minimum 8 characters';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xs),
          _PasswordStrengthBar(controller: passwordCtrl),
          const SizedBox(height: AppSpacing.md),
          FarmTextField(
            controller: confirmCtrl,
            label: 'Confirm Password',
            hint: 'Repeat your password',
            prefixIcon: Icon(Icons.lock_outline, color: cs.onSurfaceVariant),
            obscureText: true,
            textInputAction: isStaff
                ? TextInputAction.next
                : TextInputAction.done,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm your password';
              if (v != passwordCtrl.text) return 'Passwords do not match';
              return null;
            },
          ),

          // Staff-only: invite code field
          if (isStaff) ...[
            const SizedBox(height: AppSpacing.md),
            FarmTextField(
              controller: inviteCodeCtrl,
              label: 'Farm Invite Code',
              hint: 'e.g. FARM-AB12',
              prefixIcon: Icon(
                Icons.vpn_key_outlined,
                color: cs.onSurfaceVariant,
              ),
              textInputAction: TextInputAction.done,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Invite code is required'
                  : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Ask your farm owner for the invite code.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

// ── Registration type card ────────────────────────────────────────────────────

class _RegTypeCard extends StatelessWidget {
  const _RegTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : cs.surfaceContainerHighest,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: selected
                ? AppColors.primary
                : cs.outline.withValues(alpha: 0.4),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: selected ? AppColors.primary : cs.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              title,
              style: tt.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.primary : cs.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Password strength bar ─────────────────────────────────────────────────────

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

// ── Step 2: Company details ───────────────────────────────────────────────────

class _CompanyStep extends StatelessWidget {
  const _CompanyStep({required this.companyNameCtrl});

  final TextEditingController companyNameCtrl;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.sm),
          FarmTextField(
            controller: companyNameCtrl,
            label: 'Company Name',
            hint: 'e.g. Sunshine Payroll (Pty) Ltd',
            prefixIcon: Icon(
              Icons.business_outlined,
              color: cs.onSurfaceVariant,
            ),
            textInputAction: TextInputAction.done,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Company name is required'
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'This is the trading name your employees will see on their payslips.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

// ── Step 3: Plan selection from API ──────────────────────────────────────────

class _ApiPlanStep extends ConsumerWidget {
  const _ApiPlanStep({required this.selectedPlan, required this.onSelect});

  final BillingPlan? selectedPlan;
  final ValueChanged<BillingPlan> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(plansProvider);

    return plansAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 48),
              const SizedBox(height: AppSpacing.md),
              const Text('Could not load plans. Please try again.'),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () => ref.invalidate(plansProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (plans) => plans.isEmpty
          ? const Center(child: Text('No plans available'))
          : ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.sm,
              ),
              children: [
                ...plans.map(
                  (plan) => _BillingPlanCard(
                    plan: plan,
                    isSelected: plan.slug == selectedPlan?.slug,
                    onTap: () => onSelect(plan),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    plan_trial_note(plans),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
    );
  }

  static String plan_trial_note(List<BillingPlan> plans) {
    final trialDays = plans
        .where((p) => p.trialEnabled)
        .fold(0, (d, p) => p.trialDays);
    if (trialDays > 0) return '* $trialDays-day free trial. Cancel anytime.';
    return '* No credit card required to get started.';
  }
}

class _BillingPlanCard extends StatelessWidget {
  const _BillingPlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  final BillingPlan plan;
  final bool isSelected;
  final VoidCallback onTap;

  static const _accents = <String, Color>{
    'starter': Color(0xFF5C6BC0),
    'growth': Color(0xFF2E7D32),
    'enterprise': Color(0xFF6750A4),
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final accent = _accents[plan.slug] ?? AppColors.primary;
    final isPopular = plan.slug == 'growth';

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
            if (isPopular)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accent,
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
                              plan.name,
                              style: tt.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: isSelected ? accent : cs.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isPopular) const SizedBox(width: 80),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            plan.priceLabel,
                            style: tt.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: isSelected ? accent : cs.onSurface,
                            ),
                          ),
                        ],
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Icon(
                          Icons.check_circle_rounded,
                          color: accent,
                          size: 22,
                        ),
                      ],
                    ],
                  ),
                  if (plan.features.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    ...plan.features
                        .take(4)
                        .map(
                          (f) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.xs,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_rounded,
                                  size: 15,
                                  color: isSelected
                                      ? accent
                                      : cs.onSurfaceVariant,
                                ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegistrationFooter extends StatelessWidget {
  const _RegistrationFooter({
    required this.step,
    required this.loading,
    required this.onNext,
    required this.onRegister,
    required this.regType,
  });

  final _RegStep step;
  final bool loading;
  final VoidCallback onNext;
  final VoidCallback onRegister;
  final _RegistrationType regType;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isStaff = regType == _RegistrationType.staff;
    final isLast = step == _RegStep.plan;
    final isStaffJoin = isStaff && step == _RegStep.account;
    final botPad = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        botPad + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isLast && !isStaffJoin) ...[
            Text(
              'Step ${step.index + 1} of ${_RegStep.values.length}',
              style: tt.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          _GradientCTA(
            label: isStaffJoin
                ? 'Join Farm'
                : (isLast ? 'Create Account' : 'Continue'),
            icon: isStaffJoin
                ? Icons.group_add_rounded
                : (isLast ? Icons.check_rounded : Icons.arrow_forward_rounded),
            isLoading: loading,
            onPressed: loading ? null : (isLast ? onRegister : onNext),
          ),
        ],
      ),
    );
  }
}

class _GradientCTA extends StatelessWidget {
  const _GradientCTA({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: onPressed == null || isLoading
            ? null
            : const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF1B5E20)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: onPressed == null || isLoading
            ? AppColors.primary.withAlpha(100)
            : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: onPressed == null || isLoading
            ? []
            : [
                BoxShadow(
                  color: AppColors.primary.withAlpha(80),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
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
