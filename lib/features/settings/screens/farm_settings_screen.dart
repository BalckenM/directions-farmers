import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/farm_text_field.dart';
import '../../../shared/widgets/primary_button.dart';

class FarmSettingsScreen extends ConsumerStatefulWidget {
  const FarmSettingsScreen({super.key});

  @override
  ConsumerState<FarmSettingsScreen> createState() => _FarmSettingsScreenState();
}

class _FarmSettingsScreenState extends ConsumerState<FarmSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(text: 'Thornhill Cattle Farm');
  final _locationCtrl = TextEditingController(text: 'Limpopo Province, South Africa');
  final _ownerCtrl = TextEditingController(text: 'Thabo Nkosi');
  final _phoneCtrl = TextEditingController(text: '+27 82 000 1001');
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _ownerCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Farm profile saved'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return FarmScaffold(
      appBar: const FarmAppBar(
        title: 'Farm Profile',
        subtitle: 'Name, location, and details',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePaddingHorizontal,
            AppSpacing.md,
            AppSpacing.pagePaddingHorizontal,
            AppSpacing.xxl + 32,
          ),
          children: [
            _FormCard(
              title: 'Farm Details',
              icon: Icons.agriculture_rounded,
              child: Column(
                children: [
                  FarmTextField(
                    controller: _nameCtrl,
                    label: 'Farm Name',
                    hint: 'e.g. Green Valleys Farm',
                    prefixIcon: const Icon(Icons.home_rounded),
                    textInputAction: TextInputAction.next,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Farm name is required' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmTextField(
                    controller: _locationCtrl,
                    label: 'Location',
                    hint: 'County / Region',
                    prefixIcon: const Icon(Icons.location_on_rounded),
                    textInputAction: TextInputAction.next,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _FormCard(
              title: 'Contact',
              icon: Icons.person_rounded,
              child: Column(
                children: [
                  FarmTextField(
                    controller: _ownerCtrl,
                    label: 'Farm Owner',
                    hint: 'Full name',
                    prefixIcon: const Icon(Icons.badge_rounded),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmTextField(
                    controller: _phoneCtrl,
                    label: 'Phone Number',
                    hint: '+254 700 000 000',
                    prefixIcon: const Icon(Icons.phone_rounded),
                    textInputAction: TextInputAction.done,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Save Changes',
              onPressed: _save,
              icon: const Icon(Icons.save_rounded),
              isLoading: _submitting,
              isExpanded: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(title,
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: child,
          ),
        ],
      ),
    );
  }
}
