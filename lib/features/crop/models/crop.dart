class Crop {
  const Crop({
    required this.id,
    required this.categoryId,
    required this.name,
    this.scientificName,
    required this.localNames,
    required this.maturityDaysMin,
    required this.maturityDaysMax,
    required this.plantingMonths,
    required this.harvestMonths,
    required this.waterRequirement,
    required this.rainfallMmMin,
    required this.rainfallMmMax,
    required this.suitableProvinces,
    required this.soilTypes,
    required this.farmType,
    required this.temperatureMinC,
    required this.temperatureMaxC,
    this.expectedYieldDrylandTHa,
    this.expectedYieldIrrigatedTHa,
    required this.marketUse,
    required this.commonPests,
    required this.commonDiseases,
    this.fertilizerNKgHa,
    this.fertilizerPKgHa,
    this.fertilizerKKgHa,
  });

  final String id;
  final String categoryId;
  final String name;
  final String? scientificName;
  final Map<String, String> localNames;
  final int maturityDaysMin;
  final int maturityDaysMax;
  final List<int> plantingMonths;
  final List<int> harvestMonths;
  final String waterRequirement;
  final int rainfallMmMin;
  final int rainfallMmMax;
  final List<String> suitableProvinces;
  final List<String> soilTypes;
  final List<String> farmType;
  final double temperatureMinC;
  final double temperatureMaxC;
  final double? expectedYieldDrylandTHa;
  final double? expectedYieldIrrigatedTHa;
  final List<String> marketUse;
  final List<String> commonPests;
  final List<String> commonDiseases;
  final double? fertilizerNKgHa;
  final double? fertilizerPKgHa;
  final double? fertilizerKKgHa;

  factory Crop.fromJson(Map<String, dynamic> json) => Crop(
        id: json['id'] as String,
        categoryId: json['category_id'] as String,
        name: json['name'] as String,
        scientificName: json['scientific_name'] as String?,
        localNames: (json['local_names'] as Map<String, dynamic>?)
                ?.cast<String, String>() ??
            {},
        maturityDaysMin: (json['maturity_days_min'] as num).toInt(),
        maturityDaysMax: (json['maturity_days_max'] as num).toInt(),
        plantingMonths: (json['planting_months'] as List<dynamic>)
            .map((e) => (e as num).toInt())
            .toList(),
        harvestMonths: (json['harvest_months'] as List<dynamic>)
            .map((e) => (e as num).toInt())
            .toList(),
        waterRequirement: json['water_requirement'] as String,
        rainfallMmMin: (json['rainfall_mm_min'] as num).toInt(),
        rainfallMmMax: (json['rainfall_mm_max'] as num).toInt(),
        suitableProvinces: (json['suitable_provinces'] as List<dynamic>)
            .cast<String>(),
        soilTypes:
            (json['soil_types'] as List<dynamic>).cast<String>(),
        farmType: (json['farm_type'] as List<dynamic>).cast<String>(),
        temperatureMinC: (json['temperature_min_c'] as num).toDouble(),
        temperatureMaxC: (json['temperature_max_c'] as num).toDouble(),
        expectedYieldDrylandTHa:
            (json['expected_yield_dryland_t_ha'] as num?)?.toDouble(),
        expectedYieldIrrigatedTHa:
            (json['expected_yield_irrigated_t_ha'] as num?)?.toDouble(),
        marketUse: (json['market_use'] as List<dynamic>).cast<String>(),
        commonPests: (json['common_pests'] as List<dynamic>).cast<String>(),
        commonDiseases:
            (json['common_diseases'] as List<dynamic>).cast<String>(),
        fertilizerNKgHa: (json['fertilizer_n_kg_ha'] as num?)?.toDouble(),
        fertilizerPKgHa: (json['fertilizer_p_kg_ha'] as num?)?.toDouble(),
        fertilizerKKgHa: (json['fertilizer_k_kg_ha'] as num?)?.toDouble(),
      );

  String get maturityRange => '$maturityDaysMin–$maturityDaysMax days';

  double? get bestYieldTHa =>
      expectedYieldIrrigatedTHa ?? expectedYieldDrylandTHa;
}
