import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';

// ── Units & Measurements ──────────────────────────────────────────────────────

class UnitsState {
  final bool useImperial;
  final String currency;
  final String dateFormat;
  final bool useFahrenheit;
  final bool useInches;
  final bool useAcres;

  const UnitsState({
    this.useImperial = false,
    this.currency = 'ZAR',
    this.dateFormat = 'DD/MM/YYYY',
    this.useFahrenheit = false,
    this.useInches = false,
    this.useAcres = false,
  });

  UnitsState copyWith({
    bool? useImperial,
    String? currency,
    String? dateFormat,
    bool? useFahrenheit,
    bool? useInches,
    bool? useAcres,
  }) => UnitsState(
    useImperial: useImperial ?? this.useImperial,
    currency: currency ?? this.currency,
    dateFormat: dateFormat ?? this.dateFormat,
    useFahrenheit: useFahrenheit ?? this.useFahrenheit,
    useInches: useInches ?? this.useInches,
    useAcres: useAcres ?? this.useAcres,
  );
}

class UnitsNotifier extends Notifier<UnitsState> {
  @override
  UnitsState build() => const UnitsState();

  void toggle(String field) {
    switch (field) {
      case 'imperial':
        state = state.copyWith(
          useImperial: !state.useImperial,
          useFahrenheit: !state.useImperial,
          useInches: !state.useImperial,
          useAcres: !state.useImperial,
        );
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

  void setDateFormat(String fmt) => state = state.copyWith(dateFormat: fmt);
}

final unitsProvider = NotifierProvider<UnitsNotifier, UnitsState>(
  UnitsNotifier.new,
);

// ── Accent colour ─────────────────────────────────────────────────────────────

class AccentNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void set(int value) => state = value;
}

final accentProvider = NotifierProvider<AccentNotifier, int>(
  AccentNotifier.new,
);

final accentOptions = [
  (label: 'Forest Green', color: AppColors.primary),
  (label: 'Sky Blue', color: AppColors.info),
  (label: 'Amber Gold', color: AppColors.secondary),
  (label: 'Plum', color: const Color(0xFF6A1B9A)),
];

// ── Species selector ──────────────────────────────────────────────────────────

class SpeciesNotifier extends Notifier<String> {
  @override
  String build() => 'Cattle';
  void set(String v) => state = v;
}

final selectedSpeciesProvider = NotifierProvider<SpeciesNotifier, String>(
  SpeciesNotifier.new,
);

// ── Activity log filter ───────────────────────────────────────────────────────

enum ActivityCategory { livestock, payroll, financial, crop, settings }

class ActivityFilterNotifier extends Notifier<ActivityCategory?> {
  @override
  ActivityCategory? build() => null;
  void set(ActivityCategory? v) => state = v;
}

final activityFilterProvider =
    NotifierProvider<ActivityFilterNotifier, ActivityCategory?>(
      ActivityFilterNotifier.new,
    );

// ── Export data ───────────────────────────────────────────────────────────────

enum ExportModule { livestock, payroll, financial, crop, health, movements }

enum ExportFormat { csv, pdf }

class ExportState {
  final Set<ExportModule> selectedModules;
  final ExportFormat format;
  final String dateFrom;
  final String dateTo;
  final bool isExporting;

  const ExportState({
    this.selectedModules = const {},
    this.format = ExportFormat.csv,
    this.dateFrom = '01/01/2024',
    this.dateTo = '31/03/2024',
    this.isExporting = false,
  });

  ExportState copyWith({
    Set<ExportModule>? selectedModules,
    ExportFormat? format,
    String? dateFrom,
    String? dateTo,
    bool? isExporting,
  }) => ExportState(
    selectedModules: selectedModules ?? this.selectedModules,
    format: format ?? this.format,
    dateFrom: dateFrom ?? this.dateFrom,
    dateTo: dateTo ?? this.dateTo,
    isExporting: isExporting ?? this.isExporting,
  );
}

class ExportNotifier extends Notifier<ExportState> {
  @override
  ExportState build() => const ExportState();

  void toggleModule(ExportModule m) {
    final current = Set<ExportModule>.from(state.selectedModules);
    if (current.contains(m)) {
      current.remove(m);
    } else {
      current.add(m);
    }
    state = state.copyWith(selectedModules: current);
  }

  void setFormat(ExportFormat f) => state = state.copyWith(format: f);

  Future<void> export(BuildContext context) async {
    if (state.selectedModules.isEmpty) return;
    state = state.copyWith(isExporting: true);
    await Future.delayed(const Duration(seconds: 2));
    state = state.copyWith(isExporting: false);
    if (context.mounted) {
      final ext = state.format == ExportFormat.csv ? 'CSV' : 'PDF';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${state.selectedModules.length} dataset(s) exported as $ext',
          ),
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

final exportProvider = NotifierProvider<ExportNotifier, ExportState>(
  ExportNotifier.new,
);

// ── Sync & Backup ─────────────────────────────────────────────────────────────

class SyncState {
  final bool isSyncing;
  final bool autoBackup;
  final bool wifiOnly;
  final DateTime? lastSync;

  const SyncState({
    this.isSyncing = false,
    this.autoBackup = true,
    this.wifiOnly = true,
    this.lastSync,
  });

  SyncState copyWith({
    bool? isSyncing,
    bool? autoBackup,
    bool? wifiOnly,
    DateTime? lastSync,
  }) => SyncState(
    isSyncing: isSyncing ?? this.isSyncing,
    autoBackup: autoBackup ?? this.autoBackup,
    wifiOnly: wifiOnly ?? this.wifiOnly,
    lastSync: lastSync ?? this.lastSync,
  );
}

class SyncNotifier extends Notifier<SyncState> {
  @override
  SyncState build() =>
      SyncState(lastSync: DateTime.now().subtract(const Duration(hours: 6)));

  Future<void> syncNow() async {
    state = state.copyWith(isSyncing: true);
    await Future.delayed(const Duration(seconds: 2));
    state = state.copyWith(isSyncing: false, lastSync: DateTime.now());
  }

  void toggleAutoBackup() =>
      state = state.copyWith(autoBackup: !state.autoBackup);

  void toggleWifiOnly() => state = state.copyWith(wifiOnly: !state.wifiOnly);
}

final syncProvider = NotifierProvider<SyncNotifier, SyncState>(
  SyncNotifier.new,
);
