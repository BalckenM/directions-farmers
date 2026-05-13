// Tests for PoultryFlock model — covers all 4 poultry farming types:
//   1. Broiler farming   (raising chickens for meat)
//   2. Layer farming     (raising hens for egg production)
//   3. Breeder / Hatchery (parent stock producing fertile eggs → DOC chicks)
//   4. Other species     (duck, turkey, quail)

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/poultry/models/poultry_flock.dart';

// ---------------------------------------------------------------------------
// Minimal JSON fixtures — one per farming type
// ---------------------------------------------------------------------------

Map<String, dynamic> _broilerJson() => {
      'id': 'flock-broiler-01',
      'farm_id': 'farm-001',
      'batch_name': 'Broiler Batch A',
      'species': 'chicken',
      'production_type': 'broiler',
      'strain': 'Ross 308',
      'house_id': 'house-A1',
      'status': 'active',
      'placement_date': '2024-01-01',
      'placement_count': 20000,
      'current_count': 19800,
      'mortality_total': 200,
      'mortality_pct': 1.0,
      'day_of_age': 21,
      'livability_pct': 99.0,
      'current_avg_weight_g': 650.0,
      'feed_consumed_total_kg': 1400.0,
      'fcr_to_date': 1.71,
      'projected_slaughter_date': '2024-02-12',
      'target_slaughter_weight_g': 2400,
      'unit_cost_per_chick': 7.50,
      'broiler_specific': {
        'target_7d_weight_g': 170,
        'target_14d_weight_g': 420,
        'target_21d_weight_g': 850,
        'target_42d_weight_g': 2400,
        'actual_7d_weight_g': 175,
        'actual_21d_weight_g': 660,
        'uniformity_pct': 87.5,
        'target_fcr_42d': 1.75,
        'epef_current': 312,
        'lighting_program': '23L_1D',
        'ventilation_mode': 'tunnel',
      },
    };

Map<String, dynamic> _layerJson() => {
      'id': 'flock-layer-01',
      'farm_id': 'farm-002',
      'batch_name': 'Layer Flock B',
      'species': 'chicken',
      'production_type': 'layer',
      'strain': 'Lohmann Brown Classic',
      'house_id': 'house-B2',
      'status': 'active',
      'placement_date': '2023-07-01',
      'placement_count': 8000,
      'current_count': 7850,
      'mortality_total': 150,
      'mortality_pct': 1.875,
      'day_of_age': 210,
      'week_of_age': 30,
      'current_stage': 'Production',
      'livability_pct': 98.125,
      'layer_specific': {
        'point_of_lay_date': '2023-11-15',
        'peak_production_date': '2024-01-10',
        'peak_hdp_pct': 93.5,
        'current_hdp_pct': 88.2,
        'total_eggs_produced': 1470000,
        'avg_egg_weight_g': 62.3,
        'feed_per_dozen_kg': 1.85,
        'projected_molt_date': '2024-09-01',
        'lighting_program': '16L_8D',
        'hen_housed_avg_pct': 87.0,
        'egg_mass_g_per_hen_per_day': 54.9,
      },
    };

Map<String, dynamic> _breederJson() => {
      'id': 'flock-breeder-01',
      'farm_id': 'farm-003',
      'batch_name': 'Breeder Parent Stock C',
      'species': 'chicken',
      'production_type': 'breeder',
      'strain': 'Ross 308 PS',
      'house_id': 'house-C1',
      'status': 'active',
      'placement_date': '2023-06-01',
      'placement_count': 5000,
      'current_count': 4850,
      'mortality_total': 150,
      'mortality_pct': 3.0,
      'day_of_age': 250,
      'unit_cost_per_chick': 28.00,
      'breeder_specific': {
        'hen_count': 4400,
        'rooster_count': 450,
        'male_female_ratio': '1:9.8',
        'point_of_lay_date': '2023-10-20',
        'peak_production_date': '2023-12-01',
        'peak_hdp_pct': 86.0,
        'current_hdp_pct': 78.5,
        'fertility_pct': 94.2,
        'hatchability_pct': 82.7,
        'total_hatching_eggs': 385000,
        'total_chicks_produced': 318495,
        'total_chicks_sold': 310000,
        'avg_chick_weight_g': 41.5,
        'lighting_program': '14L_10D',
        'projected_depletion_date': '2024-08-01',
      },
    };

Map<String, dynamic> _duckJson() => {
      'id': 'flock-duck-01',
      'farm_id': 'farm-004',
      'batch_name': 'Duck Batch D',
      'species': 'duck',
      'production_type': 'duck_meat',
      'strain': 'Pekin',
      'house_id': 'house-D1',
      'status': 'active',
      'placement_date': '2024-03-01',
      'placement_count': 5000,
      'current_count': 4950,
      'mortality_total': 50,
      'mortality_pct': 1.0,
      'day_of_age': 28,
      'duck_specific': {
        'water_access': true,
        'target_42d_weight_g': 3200,
        'target_fcr_42d': 2.0,
      },
    };

Map<String, dynamic> _turkeyJson() => {
      'id': 'flock-turkey-01',
      'farm_id': 'farm-005',
      'batch_name': 'Turkey Batch T',
      'species': 'turkey',
      'production_type': 'turkey_meat',
      'strain': 'Nicholas 700',
      'house_id': 'house-T1',
      'status': 'active',
      'placement_date': '2024-02-01',
      'placement_count': 2000,
      'current_count': 1980,
      'mortality_total': 20,
      'mortality_pct': 1.0,
      'day_of_age': 42,
      'turkey_specific': {
        'target_market_weight_g': 14000,
        'target_fcr': 2.8,
        'lighting_program': '18L_6D',
      },
    };

Map<String, dynamic> _quailJson() => {
      'id': 'flock-quail-01',
      'farm_id': 'farm-006',
      'batch_name': 'Quail Batch Q',
      'species': 'quail',
      'production_type': 'quail',
      'strain': 'Coturnix',
      'house_id': 'house-Q1',
      'status': 'active',
      'placement_date': '2024-04-01',
      'placement_count': 3000,
      'current_count': 2980,
      'mortality_total': 20,
      'mortality_pct': 0.67,
      'day_of_age': 42,
      'quail_specific': {
        'target_egg_production_pct': 80.0,
        'avg_egg_weight_g': 12.5,
      },
    };

Map<String, dynamic> _harvestedBroilerJson() => {
      ..._broilerJson(),
      'id': 'flock-broiler-done',
      'status': 'harvested',
      'day_of_age': 42,
      'projected_slaughter_date': '2024-02-12',
    };

Map<String, dynamic> _depletedLayerJson() => {
      ..._layerJson(),
      'id': 'flock-layer-done',
      'status': 'depleted',
    };

// ===========================================================================
// 1. BROILER FARMING TESTS
// ===========================================================================

void main() {
  group('PoultryFlock — Broiler Farming (meat production)', () {
    late PoultryFlock flock;

    setUp(() => flock = PoultryFlock.fromJson(_broilerJson()));

    test('fromJson parses core fields correctly', () {
      expect(flock.id, 'flock-broiler-01');
      expect(flock.batchName, 'Broiler Batch A');
      expect(flock.species, 'chicken');
      expect(flock.productionType, 'broiler');
      expect(flock.strain, 'Ross 308');
      expect(flock.placementCount, 20000);
      expect(flock.currentCount, 19800);
      expect(flock.mortalityTotal, 200);
      expect(flock.mortalityPct, 1.0);
      expect(flock.dayOfAge, 21);
      expect(flock.fcrToDate, closeTo(1.71, 0.001));
      expect(flock.currentAvgWeightG, closeTo(650.0, 0.01));
      expect(flock.targetSlaughterWeightG, 2400);
      expect(flock.unitCostPerChick, closeTo(7.50, 0.001));
    });

    test('isBroiler returns true, other type flags false', () {
      expect(flock.isBroiler, isTrue);
      expect(flock.isLayer, isFalse);
      expect(flock.isBreeder, isFalse);
      expect(flock.isDuck, isFalse);
      expect(flock.isTurkey, isFalse);
      expect(flock.isQuail, isFalse);
    });

    test('isActive returns true for active status', () {
      expect(flock.isActive, isTrue);
    });

    test('BroilerSpecific data is parsed correctly', () {
      expect(flock.broilerSpecific, isNotNull);
      final b = flock.broilerSpecific!;
      expect(b.target7dWeightG, 170);
      expect(b.target14dWeightG, 420);
      expect(b.target21dWeightG, 850);
      expect(b.target42dWeightG, 2400);
      expect(b.actual7dWeightG, 175);
      expect(b.actual21dWeightG, 660);
      expect(b.uniformityPct, closeTo(87.5, 0.01));
      expect(b.targetFcr42d, closeTo(1.75, 0.001));
      expect(b.epefCurrent, 312);
      expect(b.lightingProgram, '23L_1D');
      expect(b.ventilationMode, 'tunnel');
    });

    test('broilerSpecific — null fields are null (not asserted data)', () {
      final b = flock.broilerSpecific!;
      // Fields not in fixture are null
      expect(b.target28dWeightG, isNull);
      expect(b.target35dWeightG, isNull);
      expect(b.actual14dWeightG, isNull);
    });

    test('layerSpecific and breederSpecific are null for broiler', () {
      expect(flock.layerSpecific, isNull);
      expect(flock.breederSpecific, isNull);
      expect(flock.duckSpecific, isNull);
      expect(flock.turkeySpecific, isNull);
      expect(flock.quailSpecific, isNull);
    });

    test('growOutProgress calculates correctly mid-cycle', () {
      // placement: 2024-01-01, slaughter: 2024-02-12, dayOfAge: 21
      // total days = 42, progress = 21/42 = 0.5
      expect(flock.growOutProgress, closeTo(0.5, 0.01));
    });

    test('growOutProgress clamps to [0.0, 1.0]', () {
      final overdue = PoultryFlock.fromJson({
        ..._broilerJson(),
        'day_of_age': 100,
        'projected_slaughter_date': '2024-02-12',
      });
      expect(overdue.growOutProgress, closeTo(1.0, 0.001));
    });

    test('growOutProgress returns null when no projected slaughter date', () {
      final noDate = PoultryFlock.fromJson({
        ..._broilerJson(),
        'projected_slaughter_date': null,
      });
      expect(noDate.growOutProgress, isNull);
    });

    test('isActive false when status is harvested', () {
      final done = PoultryFlock.fromJson(_harvestedBroilerJson());
      expect(done.isActive, isFalse);
      expect(done.status, 'harvested');
    });

    test('livabilityPct parsed correctly', () {
      expect(flock.livabilityPct, closeTo(99.0, 0.01));
    });

    test('feedConsumedTotalKg parsed correctly', () {
      expect(flock.feedConsumedTotalKg, closeTo(1400.0, 0.01));
    });
  });

  // =========================================================================
  // 2. LAYER FARMING TESTS
  // =========================================================================

  group('PoultryFlock — Layer Farming (egg production)', () {
    late PoultryFlock flock;

    setUp(() => flock = PoultryFlock.fromJson(_layerJson()));

    test('fromJson parses layer core fields', () {
      expect(flock.id, 'flock-layer-01');
      expect(flock.productionType, 'layer');
      expect(flock.species, 'chicken');
      expect(flock.strain, 'Lohmann Brown Classic');
      expect(flock.dayOfAge, 210);
      expect(flock.weekOfAge, 30);
      expect(flock.currentStage, 'Production');
      expect(flock.placementCount, 8000);
      expect(flock.mortalityPct, closeTo(1.875, 0.001));
    });

    test('isLayer returns true, other type flags false', () {
      expect(flock.isLayer, isTrue);
      expect(flock.isBroiler, isFalse);
      expect(flock.isBreeder, isFalse);
      expect(flock.isDuck, isFalse);
      expect(flock.isTurkey, isFalse);
      expect(flock.isQuail, isFalse);
    });

    test('LayerSpecific data is parsed correctly', () {
      expect(flock.layerSpecific, isNotNull);
      final ls = flock.layerSpecific!;
      expect(ls.pointOfLayDate, '2023-11-15');
      expect(ls.peakProductionDate, '2024-01-10');
      expect(ls.peakHdpPct, closeTo(93.5, 0.01));
      expect(ls.currentHdpPct, closeTo(88.2, 0.01));
      expect(ls.totalEggsProduced, 1470000);
      expect(ls.avgEggWeightG, closeTo(62.3, 0.01));
      expect(ls.feedPerDozenKg, closeTo(1.85, 0.001));
      expect(ls.projectedMoltDate, '2024-09-01');
      expect(ls.lightingProgram, '16L_8D');
      expect(ls.henHousedAvgPct, closeTo(87.0, 0.01));
      expect(ls.eggMassGPerHenPerDay, closeTo(54.9, 0.01));
    });

    test('broilerSpecific and breederSpecific are null for layer', () {
      expect(flock.broilerSpecific, isNull);
      expect(flock.breederSpecific, isNull);
      expect(flock.duckSpecific, isNull);
      expect(flock.turkeySpecific, isNull);
      expect(flock.quailSpecific, isNull);
    });

    test('growOutProgress is null for layer (no slaughter date)', () {
      expect(flock.growOutProgress, isNull);
    });

    test('isActive returns true for active layer flock', () {
      expect(flock.isActive, isTrue);
    });

    test('isActive returns false for depleted layer flock', () {
      final done = PoultryFlock.fromJson(_depletedLayerJson());
      expect(done.isActive, isFalse);
      expect(done.status, 'depleted');
    });
  });

  // =========================================================================
  // 3. BREEDER / HATCHERY TESTS
  //    Parent stock that produce fertile eggs → day-old chicks (DOC)
  // =========================================================================

  group('PoultryFlock — Breeder / Hatchery (parent stock, DOC production)', () {
    late PoultryFlock flock;

    setUp(() => flock = PoultryFlock.fromJson(_breederJson()));

    test('fromJson parses breeder core fields', () {
      expect(flock.id, 'flock-breeder-01');
      expect(flock.productionType, 'breeder');
      expect(flock.species, 'chicken');
      expect(flock.strain, 'Ross 308 PS');
      expect(flock.placementCount, 5000);
      expect(flock.dayOfAge, 250);
      expect(flock.unitCostPerChick, closeTo(28.0, 0.001));
    });

    test('isBreeder returns true, other type flags false', () {
      expect(flock.isBreeder, isTrue);
      expect(flock.isBroiler, isFalse);
      expect(flock.isLayer, isFalse);
      expect(flock.isDuck, isFalse);
      expect(flock.isTurkey, isFalse);
      expect(flock.isQuail, isFalse);
    });

    test('BreederSpecific data is parsed correctly', () {
      expect(flock.breederSpecific, isNotNull);
      final bs = flock.breederSpecific!;
      expect(bs.henCount, 4400);
      expect(bs.roosterCount, 450);
      expect(bs.maleFemaleRatio, '1:9.8');
      expect(bs.pointOfLayDate, '2023-10-20');
      expect(bs.peakProductionDate, '2023-12-01');
      expect(bs.peakHdpPct, closeTo(86.0, 0.01));
      expect(bs.currentHdpPct, closeTo(78.5, 0.01));
      expect(bs.fertilityPct, closeTo(94.2, 0.01));
      expect(bs.hatchabilityPct, closeTo(82.7, 0.01));
      expect(bs.totalHatchingEggs, 385000);
      expect(bs.totalChicksProduced, 318495);
      expect(bs.totalChicksSold, 310000);
      expect(bs.avgChickWeightG, closeTo(41.5, 0.01));
      expect(bs.lightingProgram, '14L_10D');
      expect(bs.projectedDepletionDate, '2024-08-01');
    });

    test('BreederSpecific — chick production KPIs are non-zero', () {
      final bs = flock.breederSpecific!;
      expect(bs.totalChicksProduced, greaterThan(0));
      expect(bs.totalChicksSold, greaterThan(0));
      expect(bs.fertilityPct, greaterThan(0));
      expect(bs.hatchabilityPct, greaterThan(0));
    });

    test('BreederSpecific — hatchability is less than fertility (expected)', () {
      final bs = flock.breederSpecific!;
      expect(bs.hatchabilityPct!, lessThan(bs.fertilityPct!));
    });

    test('other type-specific fields are null for breeder', () {
      expect(flock.broilerSpecific, isNull);
      expect(flock.layerSpecific, isNull);
      expect(flock.duckSpecific, isNull);
      expect(flock.turkeySpecific, isNull);
      expect(flock.quailSpecific, isNull);
    });

    test('isActive true for active breeder flock', () {
      expect(flock.isActive, isTrue);
    });
  });

  // =========================================================================
  // 4. OTHER SPECIES — Duck
  // =========================================================================

  group('PoultryFlock — Duck Meat Farming', () {
    late PoultryFlock flock;

    setUp(() => flock = PoultryFlock.fromJson(_duckJson()));

    test('fromJson parses duck fields', () {
      expect(flock.productionType, 'duck_meat');
      expect(flock.species, 'duck');
      expect(flock.strain, 'Pekin');
    });

    test('isDuck returns true', () {
      expect(flock.isDuck, isTrue);
      expect(flock.isBroiler, isFalse);
      expect(flock.isLayer, isFalse);
      expect(flock.isBreeder, isFalse);
    });

    test('DuckSpecific data parsed correctly', () {
      expect(flock.duckSpecific, isNotNull);
      final ds = flock.duckSpecific!;
      expect(ds.waterAccess, isTrue);
      expect(ds.target42dWeightG, 3200);
      expect(ds.targetFcr42d, closeTo(2.0, 0.001));
    });
  });

  // =========================================================================
  // 5. OTHER SPECIES — Turkey
  // =========================================================================

  group('PoultryFlock — Turkey Meat Farming', () {
    late PoultryFlock flock;

    setUp(() => flock = PoultryFlock.fromJson(_turkeyJson()));

    test('fromJson parses turkey fields', () {
      expect(flock.productionType, 'turkey_meat');
      expect(flock.species, 'turkey');
      expect(flock.strain, 'Nicholas 700');
    });

    test('isTurkey returns true', () {
      expect(flock.isTurkey, isTrue);
      expect(flock.isBroiler, isFalse);
      expect(flock.isLayer, isFalse);
    });

    test('TurkeySpecific data parsed correctly', () {
      expect(flock.turkeySpecific, isNotNull);
      final ts = flock.turkeySpecific!;
      expect(ts.targetMarketWeightG, 14000);
      expect(ts.targetFcr, closeTo(2.8, 0.001));
      expect(ts.lightingProgram, '18L_6D');
    });
  });

  // =========================================================================
  // 6. OTHER SPECIES — Quail
  // =========================================================================

  group('PoultryFlock — Quail Farming', () {
    late PoultryFlock flock;

    setUp(() => flock = PoultryFlock.fromJson(_quailJson()));

    test('fromJson parses quail fields', () {
      expect(flock.productionType, 'quail');
      expect(flock.species, 'quail');
    });

    test('isQuail returns true', () {
      expect(flock.isQuail, isTrue);
      expect(flock.isBroiler, isFalse);
      expect(flock.isLayer, isFalse);
    });

    test('QuailSpecific data parsed correctly', () {
      expect(flock.quailSpecific, isNotNull);
      final qs = flock.quailSpecific!;
      expect(qs.targetEggProductionPct, closeTo(80.0, 0.01));
      expect(qs.avgEggWeightG, closeTo(12.5, 0.01));
    });
  });

  // =========================================================================
  // 7. NULL SAFETY & DEFAULTS
  // =========================================================================

  group('PoultryFlock — null safety and default values', () {
    test('fromJson handles minimal JSON without optional fields', () {
      final minimal = PoultryFlock.fromJson({
        'id': 'f-min',
        'farm_id': 'farm-0',
        'batch_name': 'Min Flock',
        'species': 'chicken',
        'production_type': 'broiler',
        'strain': 'Unknown',
        'house_id': 'house-0',
        'status': 'active',
        'placement_date': '2024-01-01',
        'placement_count': 1000,
        'current_count': 1000,
        'mortality_total': 0,
        'mortality_pct': 0.0,
        'day_of_age': 1,
      });
      expect(minimal.livabilityPct, isNull);
      expect(minimal.currentAvgWeightG, isNull);
      expect(minimal.feedConsumedTotalKg, isNull);
      expect(minimal.fcrToDate, isNull);
      expect(minimal.projectedSlaughterDate, isNull);
      expect(minimal.targetSlaughterWeightG, isNull);
      expect(minimal.weekOfAge, isNull);
      expect(minimal.currentStage, isNull);
      expect(minimal.unitCostPerChick, isNull);
      expect(minimal.broilerSpecific, isNull);
      expect(minimal.layerSpecific, isNull);
      expect(minimal.breederSpecific, isNull);
      expect(minimal.duckSpecific, isNull);
      expect(minimal.turkeySpecific, isNull);
      expect(minimal.quailSpecific, isNull);
      expect(minimal.createdAt, isNull);
      expect(minimal.updatedAt, isNull);
      expect(minimal.growOutProgress, isNull);
    });

    test('fromJson defaults missing required fields gracefully', () {
      final empty = PoultryFlock.fromJson({});
      expect(empty.id, '');
      expect(empty.placementCount, 0);
      expect(empty.mortalityTotal, 0);
      expect(empty.mortalityPct, 0.0);
      expect(empty.dayOfAge, 0);
    });

    test('each farming type has mutually exclusive type flags', () {
      final broiler = PoultryFlock.fromJson(_broilerJson());
      final layer = PoultryFlock.fromJson(_layerJson());
      final breeder = PoultryFlock.fromJson(_breederJson());
      final duck = PoultryFlock.fromJson(_duckJson());

      // Count how many type flags are true for each flock
      int countTrue(PoultryFlock f) => [
            f.isBroiler,
            f.isLayer,
            f.isBreeder,
            f.isDuck,
            f.isTurkey,
            f.isQuail,
          ].where((v) => v).length;

      // Each flock should have exactly one farming-type flag set
      expect(countTrue(broiler), 1);
      expect(countTrue(layer), 1);
      expect(countTrue(breeder), 1);
      expect(countTrue(duck), 1);
    });
  });

  // =========================================================================
  // 8. STATUS LIFECYCLE
  // =========================================================================

  group('PoultryFlock — status lifecycle', () {
    test('active flock: isActive is true', () {
      final f = PoultryFlock.fromJson(_broilerJson());
      expect(f.isActive, isTrue);
    });

    test('harvested broiler: isActive is false', () {
      final f = PoultryFlock.fromJson({..._broilerJson(), 'status': 'harvested'});
      expect(f.isActive, isFalse);
    });

    test('depleted layer: isActive is false', () {
      final f = PoultryFlock.fromJson({..._layerJson(), 'status': 'depleted'});
      expect(f.isActive, isFalse);
    });

    test('sold flock: isActive is false', () {
      final f = PoultryFlock.fromJson({..._broilerJson(), 'status': 'sold'});
      expect(f.isActive, isFalse);
    });

    test('completed flock: isActive is false', () {
      final f = PoultryFlock.fromJson({..._layerJson(), 'status': 'completed'});
      expect(f.isActive, isFalse);
    });
  });
}
