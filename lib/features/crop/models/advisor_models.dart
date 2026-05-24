// AI Advisor models for the crop farming module.
// The advisor is data-driven and rule-based — no external LLM.

enum AdvisorTopic {
  planting,
  irrigation,
  fertilization,
  pestManagement,
  weatherPlanning,
  harvestReadiness,
  marketTiming,
  soilHealth,
  generalFarming,
}

extension AdvisorTopicX on AdvisorTopic {
  String get label => switch (this) {
        AdvisorTopic.planting => 'Planting',
        AdvisorTopic.irrigation => 'Irrigation',
        AdvisorTopic.fertilization => 'Fertilization',
        AdvisorTopic.pestManagement => 'Pest Management',
        AdvisorTopic.weatherPlanning => 'Weather Planning',
        AdvisorTopic.harvestReadiness => 'Harvest Readiness',
        AdvisorTopic.marketTiming => 'Market Timing',
        AdvisorTopic.soilHealth => 'Soil Health',
        AdvisorTopic.generalFarming => 'General Farming',
      };

  String get description => switch (this) {
        AdvisorTopic.planting =>
          'Best times and methods for planting your crops',
        AdvisorTopic.irrigation =>
          'Water management and irrigation scheduling',
        AdvisorTopic.fertilization =>
          'Fertilizer application timing and rates',
        AdvisorTopic.pestManagement =>
          'Pest and disease prevention and control',
        AdvisorTopic.weatherPlanning =>
          'Using weather forecasts to plan farm activities',
        AdvisorTopic.harvestReadiness =>
          'When and how to harvest for best results',
        AdvisorTopic.marketTiming =>
          'When to sell for the best price',
        AdvisorTopic.soilHealth =>
          'Maintaining and improving soil condition',
        AdvisorTopic.generalFarming =>
          'General farming best practices for SA',
      };
}

// ── Context passed to the advisor engine ─────────────────────────────────────

class AdvisorContext {
  const AdvisorContext({
    required this.farmId,
    this.cropType,
    this.fieldName,
    this.rainfallMm7d,
    this.currentTempC,
    this.frostRisk,
    this.sprayWindowLabel,
    this.daysToHarvest,
    this.activePestNames,
    this.seasonName,
    this.province,
  });

  final String farmId;
  final String? cropType;
  final String? fieldName;
  final double? rainfallMm7d;
  final double? currentTempC;
  final bool? frostRisk;

  /// 'suitable', 'unsuitable', or 'marginal'
  final String? sprayWindowLabel;
  final int? daysToHarvest;

  /// Names of currently active pest observations.
  final List<String>? activePestNames;
  final String? seasonName;
  final String? province;
}

// ── Query ────────────────────────────────────────────────────────────────────

class AdvisorQuery {
  AdvisorQuery({
    required this.id,
    required this.topic,
    required this.context,
    required this.askedAt,
    this.freeTextHint,
  });

  final String id;
  final AdvisorTopic topic;
  final AdvisorContext context;
  final DateTime askedAt;

  /// Optional natural-language hint entered by the farmer.
  final String? freeTextHint;
}

// ── Response ─────────────────────────────────────────────────────────────────

enum AdvisorConfidence { high, medium, low }

extension AdvisorConfidenceX on AdvisorConfidence {
  String get label => switch (this) {
        AdvisorConfidence.high => 'High Confidence',
        AdvisorConfidence.medium => 'Moderate Confidence',
        AdvisorConfidence.low => 'Low Confidence',
      };
}

enum AdvisorPriority { immediate, soon, planned }

extension AdvisorPriorityX on AdvisorPriority {
  String get label => switch (this) {
        AdvisorPriority.immediate => 'Do Now',
        AdvisorPriority.soon => 'This Week',
        AdvisorPriority.planned => 'Planned',
      };
}

class AdvisorRecommendation {
  const AdvisorRecommendation({
    required this.title,
    required this.action,
    required this.rationale,
    required this.priority,
    this.timing,
  });

  final String title;
  final String action;
  final String rationale;
  final AdvisorPriority priority;

  /// Human-readable timing hint — e.g. 'Next 48 hours', 'Before rain event'.
  final String? timing;
}

class AdvisorResponse {
  const AdvisorResponse({
    required this.queryId,
    required this.responseId,
    required this.topic,
    required this.headline,
    required this.explanation,
    required this.recommendations,
    required this.confidence,
    required this.generatedAt,
    this.disclaimer,
  });

  final String queryId;
  final String responseId;
  final AdvisorTopic topic;
  final String headline;
  final String explanation;
  final List<AdvisorRecommendation> recommendations;
  final AdvisorConfidence confidence;
  final DateTime generatedAt;

  /// Optional disclaimer for borderline advice.
  final String? disclaimer;
}
