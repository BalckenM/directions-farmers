import 'insights_data_source.dart';

class InsightsMockDataSource implements InsightsDataSource {
  @override
  Future<Map<String, dynamic>> getMarketPrices() async => _marketPrices;

  static const Map<String, dynamic> _marketPrices = {
    'updated_at': '2024-04-01',
    'source_note':
        'Indicative prices — SA livestock auctions & SAMIC. Verify before trading.',

    // ── Cattle ───────────────────────────────────────────────────────────────
    'cattle': {
      'beef_on_hoof': {
        'grade_a_bulls': 30.50,
        'grade_a_heifers': 28.00,
        'grade_ab_steers': 29.50,
        'weaners_male': 36.00,
        'weaners_female': 32.00,
        'cull_cows': 20.00,
      },
      'milk_farm_gate': {
        'base_price_raw': 5.85,
        'effective_with_premium': 6.60,
      },
      'auction_highlights': [
        {
          'market': 'Midlands Livestock Auction',
          'date': '2024-03-28',
          'top_price_per_kg': 32.50,
          'note': 'Nguni weaner bulls — strong demand from commercial buyers',
        },
        {
          'market': 'Standerton Veemark',
          'date': '2024-03-25',
          'top_price_per_kg': 31.20,
          'note': 'Bonsmara heifers — breed society certified',
        },
      ],
    },

    // ── Sheep ────────────────────────────────────────────────────────────────
    'sheep': {
      'mutton': {
        'dorper_slaughter': 38.00,
        'merino_slaughter': 34.00,
        'corriedale_slaughter': 31.00,
      },
      'wool': {
        'fine_merino_19_micron': 98.00,
        'medium_merino_20_22_micron': 84.00,
        'broad_crossbred': 68.00,
      },
      'auction_highlights': [
        {
          'market': 'Karoo Agri Veilings',
          'date': '2024-03-30',
          'top_price_per_kg': 42.00,
          'note': 'Prime Dorper lambs (A1 grade) — festive season demand',
        },
      ],
    },

    // ── Goats ────────────────────────────────────────────────────────────────
    'goats': {
      'meat': {
        'boer_A2': 30.00,
        'boer_A3': 27.50,
        'kalahari_red': 29.00,
        'kid_A1': 45.00,
        'cull_does': 22.00,
      },
      'auction_highlights': [
        {
          'market': 'Vryburg Boerbok Veiling',
          'date': '2024-03-26',
          'top_price_per_kg': 48.00,
          'note': 'Registered Boer goat kids — stud quality',
        },
      ],
    },

    // ── Poultry ──────────────────────────────────────────────────────────────
    'poultry': {
      'broilers_live': {'grade_a_per_kg': 20.50, 'spent_hens_per_kg': 11.00},
      'eggs': {
        'extra_large_6_pack': 38.00,
        'large_12_pack': 62.00,
        'free_range_premium_percent': 20,
      },
    },

    // ── Feed inputs ──────────────────────────────────────────────────────────
    'feed_inputs': {
      'maize': {
        'unit': 'ZAR/tonne',
        'yellow_maize_spot': 3850.0,
        'white_maize_spot': 4050.0,
        'maize_silage': 1200.0,
      },
      'protein_meals': {
        'unit': 'ZAR/tonne',
        'soya_oilcake_48pct': 9800.0,
        'sunflower_oilcake_36pct': 5200.0,
        'fish_meal_65pct': 22000.0,
      },
      'roughage': {
        'unit': 'ZAR/tonne',
        'lucerne_hay_grade1': 5400.0,
        'teff_hay': 3800.0,
        'wheat_bran': 3200.0,
        'molasses': 4100.0,
      },
    },
  };
}
