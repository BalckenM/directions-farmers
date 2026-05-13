import 'insights_data_source.dart';

class InsightsMockDataSource implements InsightsDataSource {
  @override
  Future<Map<String, dynamic>> getMarketPrices() async => _marketPrices;

  static const Map<String, dynamic> _marketPrices = {
    'updated_at': '2024-04-01',
    'source_note': 'Indicative prices — SA livestock auctions & SAMIC. Verify before trading.',
    'cattle': {
      'unit': 'c/kg live mass',
      'A2_cow': 2400,
      'A2_heifer': 2550,
      'ox_feedlot': 2850,
      'weaner_calf_per_head': 4200,
      'bull_breeding': 18000,
    },
    'sheep': {
      'unit': 'c/kg live mass',
      'A2_mutton': 3100,
      'A3_mutton': 2900,
      'lamb_A1': 4200,
      'merino_ewe_per_head': 2800,
    },
    'goats': {
      'unit': 'c/kg live mass',
      'boer_goat_A2': 2800,
      'milk_goat_per_head': 3500,
      'kid_per_head': 1200,
    },
    'pigs': {
      'unit': 'c/kg dead mass',
      'baconer_P1': 2950,
      'porker_P1': 2800,
      'sow_cull': 1800,
    },
    'poultry': {
      'unit': 'R/kg live mass',
      'broiler_live': 18.5,
      'layer_hen_cull': 12.0,
    },
    'wool': {
      'unit': 'R/kg clean mass',
      'merino_19_micron': 95.0,
      'merino_21_micron': 82.0,
      'mohair_kid': 230.0,
      'mohair_adult': 185.0,
    },
  };
}
