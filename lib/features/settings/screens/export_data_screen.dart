import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/settings_ui_providers.dart';

// â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

String _moduleLabel(ExportModule m) => switch (m) {
  ExportModule.livestock => 'Livestock Records',
  ExportModule.payroll => 'Payroll Records',
  ExportModule.financial => 'Financial Records',
  ExportModule.crop => 'Crop & Field Data',
  ExportModule.health => 'Health & Treatments',
  ExportModule.movements => 'Movement Certificates',
};

IconData _moduleIcon(ExportModule m) => switch (m) {
  ExportModule.livestock => Icons.pets_rounded,
  ExportModule.payroll => Icons.payments_rounded,
  ExportModule.financial => Icons.account_balance_wallet_rounded,
  ExportModule.crop => Icons.grass_rounded,
  ExportModule.health => Icons.medical_services_rounded,
  ExportModule.movements => Icons.route_rounded,
};

Color _moduleColor(ExportModule m) => switch (m) {
  ExportModule.livestock => AppColors.primary,
  ExportModule.payroll => AppColors.secondary,
  ExportModule.financial => AppColors.success,
  ExportModule.crop => const Color(0xFF33691E),
  ExportModule.health => AppColors.error,
  ExportModule.movements => AppColors.info,
};

String _recordCount(ExportModule m) => switch (m) {
  ExportModule.livestock => '346 animals',
  ExportModule.payroll => '12 employees, 3 payslip runs',
  ExportModule.financial => '47 transactions',
  ExportModule.crop => '3 fields, 5 planted plans',
  ExportModule.health => '128 treatment records',
  ExportModule.movements => '22 movements',
};

// â”€â”€ Screen â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class ExportDataScreen extends ConsumerWidget {
  const ExportDataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exportProvider);
    final notifier = ref.read(exportProvider.notifier);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return FarmScaffold(
      appBar: const FarmAppBar(
        title: 'Export Data',
        subtitle: 'Download your farm records',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePaddingHorizontal,
          AppSpacing.md,
          AppSpacing.pagePaddingHorizontal,
          AppSpacing.xxl + 32,
        ),
        children: [
          // Module selector
          Container(
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
                      const Icon(
                        Icons.dataset_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Select Data Modules',
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${state.selectedModules.length} selected',
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ...ExportModule.values.map((m) {
                  final selected = state.selectedModules.contains(m);
                  final color = _moduleColor(m);
                  return CheckboxListTile(
                    secondary: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.withAlpha(20),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(_moduleIcon(m), color: color, size: 18),
                    ),
                    title: Text(_moduleLabel(m)),
                    subtitle: Text(
                      _recordCount(m),
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    value: selected,
                    onChanged: (_) => notifier.toggleModule(m),
                    activeColor: AppColors.primary,
                    checkboxShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Date range
          Container(
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
                      const Icon(
                        Icons.date_range_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Date Range',
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: _DateField(label: 'From', value: state.dateFrom),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _DateField(label: 'To', value: state.dateTo),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Format selector
          Container(
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
                      const Icon(
                        Icons.file_present_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Export Format',
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: _FormatButton(
                          icon: Icons.table_chart_rounded,
                          label: 'CSV',
                          sublabel: 'Spreadsheet compatible',
                          selected: state.format == ExportFormat.csv,
                          color: AppColors.success,
                          onTap: () => notifier.setFormat(ExportFormat.csv),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _FormatButton(
                          icon: Icons.picture_as_pdf_rounded,
                          label: 'PDF',
                          sublabel: 'Print-ready document',
                          selected: state.format == ExportFormat.pdf,
                          color: AppColors.error,
                          onTap: () => notifier.setFormat(ExportFormat.pdf),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: state.isExporting
                ? 'Exportingâ€¦'
                : state.selectedModules.isEmpty
                ? 'Select a module to export'
                : 'Export ${state.selectedModules.length} Dataset(s)',
            onPressed: (state.selectedModules.isEmpty || state.isExporting)
                ? null
                : () => notifier.export(context),
            icon: const Icon(Icons.download_rounded),
            isLoading: state.isExporting,
            isExpanded: true,
          ),
        ],
      ),
    );
  }
}

// â”€â”€ Sub-widgets â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _DateField extends StatelessWidget {
  const _DateField({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: cs.outlineVariant),
        borderRadius: AppRadius.input,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today_rounded,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              Text(
                value,
                style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormatButton extends StatelessWidget {
  const _FormatButton({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? color.withAlpha(25) : cs.surfaceContainerHighest,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: selected ? color : cs.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: selected ? color : cs.onSurfaceVariant, size: 22),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: tt.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: selected ? color : cs.onSurface,
              ),
            ),
            Text(
              sublabel,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
