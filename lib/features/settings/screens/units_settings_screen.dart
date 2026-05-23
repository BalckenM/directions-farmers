import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';

// ── State model ───────────────────────────────────────────────────────────────

class _UnitsState {
  final bool useImperial; // false = metric
  final String currency; // ZAR, USD, EUR, GBP
  final String dateFormat; // DD/MM/YYYY, MM/DD/YYYY, YYYY-MM-DD
  final bool useFahrenheit; // false = Celsius
  final bool useInches; // false = mm for rainfall
  final bool useAcres; // false = hectares

  const _UnitsState({
    this.useImperial = false,
    this.currency = 'ZAR',
    this.dateFormat = 'DD/MM/YYYY',
    this.useFahrenheit = false,
    this.useInches = false,
    this.useAcres = false,
  });

  _UnitsState copyWith({
    bool? useImperial,
    String? currency,
    String? dateFormat,
    bool? useFahrenheit,
    bool? useInches,
    bool? useAcres,
  }) =>
      _UnitsState(
        useImperial: useImperial ?? this.useImperial,
        currency: currency ?? this.currency,
        dateFormat: dateFormat ?? this.dateFormat,
        useFahrenheit: useFahrenheit ?? this.useFahrenheit,
        useInches: useInches ?? this.useInches,
        useAcres: useAcres ?? this.useAcres,
      );
}

class _UnitsNotifier extends Notifier<_UnitsState> {
  @override
  _UnitsState build() => const _UnitsState();

  void toggle(String field) {
    switch (field) {
      case 'imperial':
        state = state.copyWith(
            useImperial: !state.useImperial,
            useFahrenheit: !state.useImperial,
            useInches: !state.useImperial,
            useAcres: !state.useImperial);
      case 'fahrenheit':
        state = state.copyWith(useFahrenheit: !state.useFahrenheit);
      case 'inches':
        state = state.copyWith(useInches: !state.useInches);
      case 'acres':
        state = state.copyWith(useAcres: !state.useAcres);
    }
  }

  void setCurrency(String currency) =>
      state = state.copyWith(currency: currency);

  void setDateFormat(String fmt) =>
      state = state.copyWith(dateFormat: fmt);
}

final _unitsProvider =
    NotifierProvider<_UnitsNotifier, _UnitsState>(
        _UnitsNotifier.new);

// ── Screen ────────────────────────────────────────────────────────────────────

class UnitsSettingsScreen extends ConsumerWidget {
  const UnitsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_unitsProvider);
    final notifier = ref.read(_unitsProvider.notifier);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return FarmScaffold(
      appBar: const FarmAppBar(
        title: 'Units & Measurements',
        subtitle: 'Display preferences',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePaddingHorizontal,
          AppSpacing.md,
          AppSpacing.pagePaddingHorizontal,
          AppSpacing.xxl + 32,
        ),
        children: [
          // Quick preset: Metric vs Imperial
          _SectionCard(
            title: 'Measurement System',
            icon: Icons.straighten_rounded,
            cs: cs,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Switch between metric and imperial as a group, or customise individually below.',
                  style: tt.bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _ModeButton(
                        label: 'Metric',
                        sublabel: 'kg, ha, mm, °C',
                        selected: !state.useImperial,
                        color: AppColors.primary,
                        onTap: () {
                          if (state.useImperial) notifier.toggle('imperial');
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _ModeButton(
                        label: 'Imperial',
                        sublabel: 'lb, ac, in, °F',
                        selected: state.useImperial,
                        color: AppColors.info,
                        onTap: () {
                          if (!state.useImperial) notifier.toggle('imperial');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Individual overrides
          _SectionCard(
            title: 'Individual Settings',
            icon: Icons.tune_rounded,
            cs: cs,
            child: Column(
              children: [
                _ToggleRow(
                  icon: Icons.monitor_weight_outlined,
                  iconColor: AppColors.secondary,
                  label: 'Weight',
                  valueLabel: state.useImperial ? 'Pounds (lb)' : 'Kilograms (kg)',
                  value: state.useImperial,
                  onChanged: (v) => notifier.toggle('imperial'),
                ),
                const Divider(height: 1),
                _ToggleRow(
                  icon: Icons.landscape_rounded,
                  iconColor: AppColors.primary,
                  label: 'Area',
                  valueLabel:
                      state.useAcres ? 'Acres (ac)' : 'Hectares (ha)',
                  value: state.useAcres,
                  onChanged: (_) => notifier.toggle('acres'),
                ),
                const Divider(height: 1),
                _ToggleRow(
                  icon: Icons.thermostat_rounded,
                  iconColor: AppColors.error,
                  label: 'Temperature',
                  valueLabel:
                      state.useFahrenheit ? 'Fahrenheit (°F)' : 'Celsius (°C)',
                  value: state.useFahrenheit,
                  onChanged: (_) => notifier.toggle('fahrenheit'),
                ),
                const Divider(height: 1),
                _ToggleRow(
                  icon: Icons.water_drop_outlined,
                  iconColor: AppColors.info,
                  label: 'Rainfall',
                  valueLabel:
                      state.useInches ? 'Inches (in)' : 'Millimetres (mm)',
                  value: state.useInches,
                  onChanged: (_) => notifier.toggle('inches'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Currency
          _SectionCard(
            title: 'Currency',
            icon: Icons.attach_money_rounded,
            cs: cs,
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: ['ZAR', 'USD', 'EUR', 'GBP'].map((c) {
                final selected = state.currency == c;
                return GestureDetector(
                  onTap: () => notifier.setCurrency(c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : AppColors.primary.withAlpha(18),
                      borderRadius: AppRadius.chip,
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : cs.outlineVariant,
                      ),
                    ),
                    child: Text(
                      c,
                      style: TextStyle(
                        color:
                            selected ? Colors.white : AppColors.primary,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Date format
          _SectionCard(
            title: 'Date Format',
            icon: Icons.calendar_today_rounded,
            cs: cs,
            child: Column(
              children: ['DD/MM/YYYY', 'MM/DD/YYYY', 'YYYY-MM-DD']
                  .map((fmt) => RadioListTile<String>(
                        title: Text(fmt, style: tt.bodyMedium),
                        subtitle: Text(
                          _formatSample(fmt),
                          style: tt.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                        value: fmt,
                        groupValue: state.dateFormat,
                        onChanged: (v) =>
                            notifier.setDateFormat(v ?? fmt),
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Save Preferences',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Unit preferences saved'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.success,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              );
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.save_rounded),
            isExpanded: true,
          ),
        ],
      ),
    );
  }
}

String _formatSample(String fmt) => switch (fmt) {
      'DD/MM/YYYY' => 'e.g. 28/03/2024',
      'MM/DD/YYYY' => 'e.g. 03/28/2024',
      _ => 'e.g. 2024-03-28',
    };

// ── Shared widgets ────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    required this.cs,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

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
            child: Row(children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(title,
                  style:
                      tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            ]),
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

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.sublabel,
    required this.selected,
    required this.color,
    required this.onTap,
  });

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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? color.withAlpha(30) : cs.surfaceContainerHighest,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: selected ? color : cs.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selected)
              Icon(Icons.check_circle_rounded, color: color, size: 20),
            if (!selected)
              Icon(Icons.radio_button_unchecked_rounded,
                  color: cs.onSurfaceVariant, size: 20),
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

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String valueLabel;
  final bool value;
  final ValueChanged<bool> onChanged;

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
      subtitle: Text(valueLabel),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
