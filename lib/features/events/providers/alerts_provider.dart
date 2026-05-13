import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/livestock_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/livestock/providers/livestock_providers.dart';
import '../../../features/poultry/providers/poultry_providers.dart';

// ── Alert model ───────────────────────────────────────────────────────────────

enum AlertSeverity { critical, warning, info }

class FarmAlert {
  const FarmAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.category,
    required this.dueDate,
    this.animalTag,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String description;
  final AlertSeverity severity;
  final String category;
  final String dueDate;
  final String? animalTag;
  final bool isRead;

  Color get severityColor => switch (severity) {
        AlertSeverity.critical => AppColors.error,
        AlertSeverity.warning => AppColors.warning,
        AlertSeverity.info => AppColors.info,
      };

  String get severityLabel => switch (severity) {
        AlertSeverity.critical => 'Critical',
        AlertSeverity.warning => 'Warning',
        AlertSeverity.info => 'Info',
      };

  IconData get categoryIcon => switch (category) {
        'health' => Icons.health_and_safety_rounded,
        'breeding' => Icons.favorite_rounded,
        'production' => Icons.egg_rounded,
        'weight' => Icons.monitor_weight_outlined,
        'vaccination' => Icons.vaccines_rounded,
        'inventory' => Icons.inventory_2_rounded,
        _ => Icons.notifications_rounded,
      };
}

// ── Provider ──────────────────────────────────────────────────────────────────

/// Unified alert list covering:
///  1. Livestock animal alerts (overdue vaccination, weight check, low BCS)
///  2. Poultry vaccination schedule alerts (overdue + upcoming ≤ 7 days)
///  3. Poultry inventory low-stock alerts
final alertsProvider = Provider<List<FarmAlert>>((ref) {
  final now = DateTime.now();
  final alerts = <FarmAlert>[];

  // ── 1. Livestock animal alerts ─────────────────────────────────────────────
  for (final sp in LivestockConstants.animalSpecies) {
    final animals = ref.watch(animalsProvider(sp)).value ?? [];

    for (final animal in animals) {
      // Critical: vaccination overdue
      if (animal.vaccinationStatus == 'overdue') {
        alerts.add(FarmAlert(
          id: 'vac-${animal.id}',
          title: 'Vaccination Overdue',
          description:
              '${animal.name} (${animal.tagNumber}) — vaccination is overdue',
          severity: AlertSeverity.critical,
          category: 'health',
          dueDate: 'Overdue',
          animalTag: animal.tagNumber,
        ));
      }

      // Info: no weight record in over 30 days
      if (animal.lastWeighedDate != null) {
        try {
          final last = DateTime.parse(animal.lastWeighedDate!);
          final daysSince = now.difference(last).inDays;
          if (daysSince > 30) {
            alerts.add(FarmAlert(
              id: 'wt-${animal.id}',
              title: 'Weight Check Due',
              description:
                  '${animal.name} (${animal.tagNumber}) — last weighed ${daysSince}d ago',
              severity: AlertSeverity.info,
              category: 'weight',
              dueDate: '${daysSince}d overdue',
              animalTag: animal.tagNumber,
            ));
          }
        } catch (_) {}
      }

      // Warning: BCS critically low (≤ 1)
      final bcs = animal.bodyConditionScore;
      if (bcs != null && bcs <= 1) {
        alerts.add(FarmAlert(
          id: 'bcs-${animal.id}',
          title: 'Low Body Condition',
          description:
              '${animal.name} (${animal.tagNumber}) — BCS $bcs (critically thin)',
          severity: AlertSeverity.warning,
          category: 'health',
          dueDate: 'Now',
          animalTag: animal.tagNumber,
        ));
      }
    }
  }

  // ── 2. Poultry vaccination schedule alerts ─────────────────────────────────
  final schedules = ref.watch(allVaccinationSchedulesProvider).value ?? [];
  final flockNames = <String, String>{};
  ref.watch(flocksProvider).value?.forEach((f) => flockNames[f.id] = f.batchName);

  for (final sched in schedules) {
    final batchName = flockNames[sched.flockId] ?? sched.flockId;
    for (final item in sched.schedule) {
      if (item.isOverdue) {
        alerts.add(FarmAlert(
          id: 'pvacc-overdue-${sched.flockId}-${item.vaccine}',
          title: '${item.vaccine} Overdue',
          description: 'Flock: $batchName — vaccination overdue',
          severity: AlertSeverity.critical,
          category: 'vaccination',
          dueDate: 'Overdue',
        ));
      } else if (item.isPending && item.dueDate != null) {
        try {
          final due = DateTime.parse(item.dueDate!);
          final diff = due.difference(now).inDays;
          if (diff >= 0 && diff <= 7) {
            final label =
                diff == 0 ? 'today' : 'in $diff day${diff == 1 ? '' : 's'}';
            alerts.add(FarmAlert(
              id: 'pvacc-pending-${sched.flockId}-${item.vaccine}',
              title: '${item.vaccine} due $label',
              description: 'Flock: $batchName',
              severity: AlertSeverity.warning,
              category: 'vaccination',
              dueDate: label,
            ));
          }
        } catch (_) {}
      }
    }
  }

  // ── 3. Poultry inventory low-stock alerts ──────────────────────────────────
  final invItems = ref.watch(inventoryProvider).value ?? [];
  for (final item in invItems) {
    if (item.isBelowThreshold) {
      alerts.add(FarmAlert(
        id: 'inv-${item.id}',
        title: 'Low Stock: ${item.name}',
        description:
            '${item.currentStock.toStringAsFixed(1)} ${item.unit} remaining — reorder now',
        severity: AlertSeverity.warning,
        category: 'inventory',
        dueDate: 'Reorder now',
      ));
    }
  }

  // Sort: critical → warning → info
  alerts.sort((a, b) => a.severity.index.compareTo(b.severity.index));
  return alerts;
});
