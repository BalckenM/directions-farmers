class SprayRecord {
  const SprayRecord({
    required this.id,
    this.pestObservationId,
    required this.fieldId,
    required this.sprayDate,
    required this.productName,
    required this.dosagePerHa,
    required this.areaSprayedHa,
    this.applicatorName,
    required this.withholdingDays,
    required this.reEntryDate,
    this.outcome,
  });

  final String id;
  final String? pestObservationId;
  final String fieldId;
  final DateTime sprayDate;
  final String productName;
  final double dosagePerHa;
  final double areaSprayedHa;
  final String? applicatorName;
  final int withholdingDays;
  final DateTime reEntryDate;
  final String? outcome;

  factory SprayRecord.fromJson(Map<String, dynamic> json) => SprayRecord(
        id: json['id'] as String,
        pestObservationId: json['pest_observation_id'] as String?,
        fieldId: json['field_id'] as String,
        sprayDate: DateTime.parse(json['spray_date'] as String),
        productName: json['product_name'] as String,
        dosagePerHa: (json['dosage_per_ha'] as num).toDouble(),
        areaSprayedHa: (json['area_sprayed_ha'] as num).toDouble(),
        applicatorName: json['applicator_name'] as String?,
        withholdingDays: (json['withholding_days'] as num).toInt(),
        reEntryDate: DateTime.parse(json['re_entry_date'] as String),
        outcome: json['outcome'] as String?,
      );
}
