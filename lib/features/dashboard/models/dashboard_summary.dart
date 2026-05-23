import 'package:flutter/material.dart';

// ── Activity item model ───────────────────────────────────────────────────────

enum ActivityType { health, weight, milk, breeding, registration, feed, general }

class ActivityItem {
  const ActivityItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timestamp,
  });

  final ActivityType type;
  final String title;
  final String subtitle;
  final String timestamp;

  IconData get icon => switch (type) {
        ActivityType.health => Icons.health_and_safety_rounded,
        ActivityType.weight => Icons.monitor_weight_rounded,
        ActivityType.milk => Icons.water_drop_rounded,
        ActivityType.breeding => Icons.favorite_rounded,
        ActivityType.registration => Icons.add_circle_rounded,
        ActivityType.feed => Icons.grass_rounded,
        ActivityType.general => Icons.event_note_rounded,
      };

  Color get iconColor => switch (type) {
        ActivityType.health => const Color(0xFF388E3C),
        ActivityType.weight => const Color(0xFF0277BD),
        ActivityType.milk => const Color(0xFF2E7D32),
        ActivityType.breeding => const Color(0xFFE91E63),
        ActivityType.registration => const Color(0xFFF57F17),
        ActivityType.feed => const Color(0xFF16A34A),
        ActivityType.general => const Color(0xFF6750A4),
      };

  Color get iconBg => switch (type) {
        ActivityType.health => const Color(0xFFC8E6C9),
        ActivityType.weight => const Color(0xFFB3E5FC),
        ActivityType.milk => const Color(0xFFA5D6A7),
        ActivityType.breeding => const Color(0xFFFCE4EC),
        ActivityType.registration => const Color(0xFFFFE0B2),
        ActivityType.feed => const Color(0xFFDCFCE7),
        ActivityType.general => const Color(0xFFEDE7F6),
      };
}

// ── Dashboard summary ─────────────────────────────────────────────────────────

/// Aggregated data for the dashboard overview.
class DashboardSummary {
  const DashboardSummary({
    required this.farmName,
    required this.farmLocation,
    required this.speciesSummaries,
    required this.totalAnimals,
    required this.recentHealthAlerts,
    required this.recentBreedingEvents,
    this.pendingTaskCount = 0,
    this.weatherTemp = '--',
    this.weatherCondition = '',
    this.recentActivity = const [],
  });

  final String farmName;
  final String farmLocation;
  final List<SpeciesSummary> speciesSummaries;
  final int totalAnimals;
  final int recentHealthAlerts;
  final int recentBreedingEvents;
  final int pendingTaskCount;
  final String weatherTemp;
  final String weatherCondition;
  final List<ActivityItem> recentActivity;

  int get speciesCount => speciesSummaries.length;
}

// ── Species summary ───────────────────────────────────────────────────────────

class SpeciesSummary {
  const SpeciesSummary({
    required this.species,
    required this.headCount,
    required this.activeCount,
    required this.alertCount,
  });

  final String species;
  final int headCount;
  final int activeCount;
  final int alertCount;
}
