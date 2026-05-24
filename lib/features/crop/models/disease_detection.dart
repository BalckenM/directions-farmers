// Disease detection models for the crop farming module.
// Used by both the mock on-device scanner and the future TFLite remote engine.

enum DiseaseCategory {
  fungal,
  bacterial,
  viral,
  pest,
  nutrientDeficiency,
  healthy,
}

extension DiseaseCategoryX on DiseaseCategory {
  String get label => switch (this) {
        DiseaseCategory.fungal => 'Fungal Disease',
        DiseaseCategory.bacterial => 'Bacterial Disease',
        DiseaseCategory.viral => 'Viral Disease',
        DiseaseCategory.pest => 'Pest Damage',
        DiseaseCategory.nutrientDeficiency => 'Nutrient Deficiency',
        DiseaseCategory.healthy => 'Healthy',
      };
}

enum DiseaseSeverity { low, moderate, high, critical }

extension DiseaseSeverityX on DiseaseSeverity {
  String get label => switch (this) {
        DiseaseSeverity.low => 'Low',
        DiseaseSeverity.moderate => 'Moderate',
        DiseaseSeverity.high => 'High',
        DiseaseSeverity.critical => 'Critical',
      };
}

enum TreatmentType { chemical, biological, cultural }

extension TreatmentTypeX on TreatmentType {
  String get label => switch (this) {
        TreatmentType.chemical => 'Chemical',
        TreatmentType.biological => 'Biological',
        TreatmentType.cultural => 'Cultural Practice',
      };
}

class TreatmentOption {
  const TreatmentOption({
    required this.name,
    required this.type,
    required this.description,
    required this.applicationMethod,
    required this.timing,
    this.saProducts,
    this.waitingDays = 0,
  });

  final String name;
  final TreatmentType type;
  final String description;
  final String applicationMethod;

  /// When to apply — e.g. "At first sign of symptoms", "Preventatively".
  final String timing;

  /// South African registered product trade names.
  final List<String>? saProducts;

  /// Pre-harvest interval in days.
  final int waitingDays;
}

class DiseaseInfo {
  const DiseaseInfo({
    required this.id,
    required this.name,
    this.scientificName,
    required this.cropTypes,
    required this.category,
    required this.severity,
    required this.description,
    required this.visualSymptoms,
    required this.spread,
    required this.treatments,
    required this.preventionTips,
    required this.requiresImmediateAction,
  });

  final String id;
  final String name;
  final String? scientificName;

  /// Which crop types are affected — 'any' means all crops.
  final List<String> cropTypes;

  final DiseaseCategory category;
  final DiseaseSeverity severity;
  final String description;

  /// Visual symptoms the farmer will observe on the leaf/plant.
  final String visualSymptoms;

  /// How the disease/pest spreads between plants or fields.
  final String spread;

  final List<TreatmentOption> treatments;
  final List<String> preventionTips;
  final bool requiresImmediateAction;
}

// ── Detection output ─────────────────────────────────────────────────────────

class DiseaseMatch {
  const DiseaseMatch({
    required this.disease,
    required this.confidence,
  });

  final DiseaseInfo disease;

  /// Confidence score 0.0–1.0 (mock uses seeded values).
  final double confidence;

  String get confidenceLabel {
    if (confidence >= 0.85) return 'Very High';
    if (confidence >= 0.70) return 'High';
    if (confidence >= 0.50) return 'Moderate';
    if (confidence >= 0.30) return 'Low';
    return 'Very Low';
  }
}

class DiseaseDetectionResult {
  const DiseaseDetectionResult({
    required this.id,
    required this.detectedAt,
    required this.imagePath,
    required this.matches,
    this.cropHint,
  });

  final String id;
  final DateTime detectedAt;

  /// Local filesystem path to the captured image.
  final String imagePath;

  /// Results sorted descending by confidence.
  final List<DiseaseMatch> matches;

  /// Optional crop type hint provided by the farmer.
  final String? cropHint;

  DiseaseMatch get topMatch => matches.first;
  bool get isHealthy => topMatch.disease.category == DiseaseCategory.healthy;
}
