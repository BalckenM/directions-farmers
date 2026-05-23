import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

enum _ExportModule {
  livestock,
  payroll,
  financial,
  crop,
  health,
  movements,
}

enum _ExportFormat { csv, pdf }

// ── Helpers ───────────────────────────────────────────────────────────────────

String _moduleLabel(_ExportModule m) => switch (m) {
      _ExportModule.livestock => 'Livestock Records',
      _ExportModule.payroll => 'Payroll Records',
      _ExportModule.financial => 'Financial Records',
      _ExportModule.crop => 'Crop & Field Data',
      _ExportModule.health => 'Health & Treatments',
      _ExportModule.movements => 'Movement Certificates',
    };

IconData _moduleIcon(_ExportModule m) => switch (m) {
      _ExportModule.livestock => Icons.pets_rounded,
      _ExportModule.payroll => Icons.payments_rounded,
      _ExportModule.financial => Icons.account_balance_wallet_rounded,
      _ExportModule.crop => Icons.grass_rounded,
      _ExportModule.health => Icons.medical_services_rounded,
      _ExportModule.movements => Icons.route_rounded,
    };

Color _moduleColor(_ExportModule m) => switch (m) {
      _ExportModule.livestock => AppColors.primary,
      _ExportModule.payroll => AppColors.secondary,
      _ExportModule.financial => AppColors.success,
      _ExportModule.crop => const Color(0xFF33691E),
      _ExportModule.health => AppColors.error,
      _ExportModule.movements => AppColors.info,
    };

String _recordCount(_ExportModule m) => switch (m) {
      _ExportModule.livestock => '346 animals',
      _ExportModule.payroll => '12 employees, 3 payslip runs',
      _ExportModule.financial => '47 transactions',
      _ExportModule.crop => '3 fields, 5 planted plans',
      _ExportModule.health => '128 treatment records',
      _ExportModule.movements => '22 movements',
    };

// ── State ─────────────────────────────────────────────────────────────────────

class _ExportState {
  final Set<_ExportModule> selectedModules;
  final _ExportFormat format;
  final String dateFrom;
  final String dateTo;
  final bool isExporting;

  const _ExportState({
    this.selectedModules = const {},
    this.format = _ExportFormat.csv,
    this.dateFrom = '01/01/2024',
    this.dateTo = '31/03/2024',
    this.isExporting = false,
  });

  _ExportState copyWith({
    Set<_ExportModule>? selectedModules,
    _ExportFormat? format,
    String? dateFrom,
    String? dateTo,
    bool? isExporting,
  }) =>
      _ExportState(
        selectedModules: selectedModules ?? this.selectedModules,
        format: format ?? this.format,
        dateFrom: dateFrom ?? this.dateFrom,
        dateTo: dateTo ?? this.dateTo,
        isExporting: isExporting ?? this.isExporting,
      );
}

class _ExportNotifier extends Notifier<_ExportState> {
  @override
  _ExportState build() => const _ExportState();

  void toggleModule(_ExportModule m) {
    final current = Set<_ExportModule>.from(state.selectedModules);
    if (current.contains(m)) {
      current.remove(m);
    } else {
      current.add(m);
    }
    state = state.copyWith(selectedModules: current);
  }

  void setFormat(_ExportFormat f) => state = state.copyWith(format: f);

  Future<void> export(BuildContext context) async {
    if (state.selectedModules.isEmpty) return;
    state = state.copyWith(isExporting: true);
    await Future.delayed(const Duration(seconds: 2));
    state = state.copyWith(isExporting: false);
    if (context.mounted) {
      final ext = state.format == _ExportFormat.csv ? 'CSV' : 'PDF';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${state.selectedModules.length} dataset(s) exported as $ext'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      );
    }
  }
}

final _exportProvider =
    NotifierProvider<_ExportNotifier, _ExportState>(
        _ExportNotifier.new);

// ── Screen ────────────────────────────────────────────────────────────────────

class ExportDataScreen extends ConsumerWidget {
  const ExportDataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_exportProvider);
    final notifier = ref.read(_exportProvider.notifier);
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
                  child: Row(children: [
                    const Icon(Icons.dataset_rounded,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Select Data Modules',
                        style: tt.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text(
                      '${state.selectedModules.length} selected',
                      style: tt.labelSmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ]),
                ),
                const Divider(height: 1),
                ..._ExportModule.values.map((m) {
                  final selected = state.selectedModules.contains(m);
                  final color = _moduleColor(m);
                  return CheckboxListTile(
                    secondary: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.withAlpha(20),
                        borderRadius:
                            BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(_moduleIcon(m), color: color, size: 18),
                    ),
                    title: Text(_moduleLabel(m)),
                    subtitle: Text(_recordCount(m),
                        style: tt.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant)),
                    value: selected,
                    onChanged: (_) => notifier.toggleModule(m),
                    activeColor: AppColors.primary,
                    checkboxShape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.xs),
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
                  child: Row(children: [
                    const Icon(Icons.date_range_rounded,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Date Range',
                        style: tt.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ]),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(children: [
                    Expanded(
                      child: _DateField(
                          label: 'From', value: state.dateFrom),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child:
                          _DateField(label: 'To', value: state.dateTo),
                    ),
                  ]),
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
                  child: Row(children: [
                    const Icon(Icons.file_present_rounded,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Export Format',
                        style: tt.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ]),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(children: [
                    Expanded(
                      child: _FormatButton(
                        icon: Icons.table_chart_rounded,
                        label: 'CSV',
                        sublabel: 'Spreadsheet compatible',
                        selected:
                            state.format == _ExportFormat.csv,
                        color: AppColors.success,
                        onTap: () =>
                            notifier.setFormat(_ExportFormat.csv),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _FormatButton(
                        icon: Icons.picture_as_pdf_rounded,
                        label: 'PDF',
                        sublabel: 'Print-ready document',
                        selected:
                            state.format == _ExportFormat.pdf,
                        color: AppColors.error,
                        onTap: () =>
                            notifier.setFormat(_ExportFormat.pdf),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: state.isExporting
                ? 'Exporting…'
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

// ── Sub-widgets ───────────────────────────────────────────────────────────────

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
          horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border.all(color: cs.outlineVariant),
        borderRadius: AppRadius.input,
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded,
              size: 16, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: tt.labelSmall
                      ?.copyWith(color: cs.onSurfaceVariant)),
              Text(value,
                  style: tt.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
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
            Icon(icon,
                color: selected ? color : cs.onSurfaceVariant,
                size: 22),
            const SizedBox(height: AppSpacing.sm),
            Text(label,
                style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: selected ? color : cs.onSurface)),
            Text(sublabel,
                style: tt.bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
