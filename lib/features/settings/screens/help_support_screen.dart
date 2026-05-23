import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';

// ── FAQ data ──────────────────────────────────────────────────────────────────

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});
}

const _faqs = [
  _FaqItem(
    question: 'How do I add a new animal to my livestock records?',
    answer:
        'Navigate to Livestock from the bottom menu, then tap the + button on the herd overview screen. Fill in the tag number, species, breed, date of birth, and any purchase details. You can also record vaccinations and treatments from the animal\'s detail page.',
  ),
  _FaqItem(
    question: 'How do I run a payroll for my farm workers?',
    answer:
        'Go to the Payroll module from the bottom navigation. Ensure all workers are added under Team settings. On the Payroll screen, tap "Run Payroll" and select the pay period. The app will calculate PAYE, UIF, and SDL automatically. Review and confirm to generate payslips.',
  ),
  _FaqItem(
    question: 'Can I export data to share with my accountant?',
    answer:
        'Yes — go to Settings → Export Data. Select the modules you want to export (e.g. Payroll, Financial), choose your date range, and pick the format (CSV or PDF). Tap "Export" to generate the files.',
  ),
  _FaqItem(
    question: 'How do I manage paddock and grazing rotation?',
    answer:
        'Under Settings → Paddocks, you can view and manage your paddocks — including which animals are currently grazing in each camp. You can mark paddocks as occupied, resting, or empty, and record carrying capacity.',
  ),
  _FaqItem(
    question: 'How do I register livestock breeds for my farm?',
    answer:
        'Under Settings → Breed Registry, you can browse all supported breeds by species. The breed registry provides breed origin, purpose, and description to help you understand and document your herd composition.',
  ),
  _FaqItem(
    question: 'What does the regulatory reports section cover?',
    answer:
        'Settings → Regulatory Reports provides templates and tracking for South African compliance documents including IRP5 / EMP201 (SARS payroll), livestock movement certificates (LPA/DAFF), vet health certificates, and COIDA returns.',
  ),
  _FaqItem(
    question: 'How do I back up my farm data?',
    answer:
        'In Settings → Sync & Backup, you can enable automatic daily backups and choose whether to sync on Wi-Fi only. You can also trigger a manual sync at any time. A history of recent backups is shown in the same screen.',
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return FarmScaffold(
      appBar: const FarmAppBar(
        title: 'Help & Support',
        subtitle: 'Guides, FAQs and contact',
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // FAQ section
          Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: AppRadius.card,
              boxShadow: AppShadows.level1,
            ),
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(children: [
                    const Icon(Icons.help_outline_rounded,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Frequently Asked Questions',
                        style: tt.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ]),
                ),
                const Divider(height: 1),
                ..._faqs.map((faq) => _FaqTile(item: faq)),
              ],
            ),
          ),

          // Contact section
          Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: AppRadius.card,
              boxShadow: AppShadows.level1,
            ),
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(children: [
                    const Icon(Icons.support_agent_rounded,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Contact Support',
                        style: tt.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ]),
                ),
                const Divider(height: 1),
                _ContactTile(
                  icon: Icons.email_rounded,
                  iconColor: AppColors.primary,
                  label: 'Email Support',
                  value: 'support@4directions.co.za',
                  onTap: () => _showContact(context,
                      'support@4directions.co.za', 'email'),
                ),
                const Divider(height: 1, indent: 68),
                _ContactTile(
                  icon: Icons.phone_rounded,
                  iconColor: AppColors.success,
                  label: 'Phone Support',
                  value: '+27 21 000 0000',
                  onTap: () =>
                      _showContact(context, '+27 21 000 0000', 'phone'),
                ),
                const Divider(height: 1, indent: 68),
                _ContactTile(
                  icon: Icons.language_rounded,
                  iconColor: AppColors.info,
                  label: 'Website',
                  value: 'www.4directions.co.za',
                  onTap: () => _showContact(
                      context, 'www.4directions.co.za', 'website'),
                ),
                const Divider(height: 1, indent: 68),
                _ContactTile(
                  icon: Icons.access_time_rounded,
                  iconColor: AppColors.secondary,
                  label: 'Business Hours',
                  value: 'Mon–Fri, 08:00–17:00 SAST',
                  onTap: null,
                ),
              ],
            ),
          ),

          // App info section
          Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: AppRadius.card,
              boxShadow: AppShadows.level1,
            ),
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Text('App Information',
                        style: tt.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ]),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius:
                          BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(Icons.star_rounded,
                        color: AppColors.primary, size: 18),
                  ),
                  title: const Text('Rate the App'),
                  subtitle: const Text('Share your feedback on the app store'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Opening app store review…'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 68),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.info.withAlpha(20),
                      borderRadius:
                          BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(Icons.description_rounded,
                        color: AppColors.info, size: 18),
                  ),
                  title: const Text('Documentation'),
                  subtitle: const Text('User guides and tutorials'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening documentation…'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 68),
                ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius:
                          BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(Icons.tag_rounded,
                        color: cs.onSurfaceVariant, size: 18),
                  ),
                  title: const Text('App Version'),
                  subtitle: const Text('v1.0.0 (build 100)'),
                  onTap: null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showContact(BuildContext context, String value, String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening $type: $value'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.item});
  final _FaqItem item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Theme(
      data: Theme.of(context)
          .copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(Icons.circle_rounded,
            size: 8, color: AppColors.primary),
        title: Text(
          item.question,
          style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 0, AppSpacing.md, AppSpacing.md),
            child: Text(
              item.answer,
              style: tt.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withAlpha(20),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(label),
      subtitle: Text(value),
      trailing: onTap != null
          ? const Icon(Icons.chevron_right_rounded)
          : null,
      onTap: onTap,
    );
  }
}
