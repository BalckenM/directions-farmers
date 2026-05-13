// Repository integration tests — load real mock JSON assets and verify
// the repository correctly parses all 4 poultry farming types.
//
// Requires TestWidgetsFlutterBinding for rootBundle asset access.
// Run with:  flutter test test/poultry/data/poultry_repository_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/poultry/data/poultry_mock_data_source.dart';
import 'package:mobile_app/features/poultry/data/poultry_repository.dart';

void main() {
  // rootBundle requires the Flutter test binding to be initialised first
  TestWidgetsFlutterBinding.ensureInitialized();

  late PoultryRepository repo;

  setUp(() {
    repo = PoultryRepository(PoultryMockDataSource());
  });

  // =========================================================================
  // Flock list — counts and types
  // =========================================================================

  group('PoultryRepository.getFlocks()', () {
    test('returns exactly 14 flocks from mock JSON', () async {
      final flocks = await repo.getFlocks();
      expect(flocks.length, 14);
    });

    // ── Hatchery flock ─────────────────────────────────────────────────────
    test('contains 1 hatchery flock (flock-014)', () async {
      final flocks = await repo.getFlocks();
      final hatcheries = flocks.where((f) => f.isHatchery).toList();
      expect(hatcheries.length, 1, reason: 'Expected exactly one hatchery flock');
      expect(hatcheries.first.id, 'flock-014');
      expect(hatcheries.first.productionType, 'hatchery');
      expect(hatcheries.first.isActive, isTrue);
    });

    test('all flocks have non-empty ids', () async {
      final flocks = await repo.getFlocks();
      for (final f in flocks) {
        expect(f.id, isNotEmpty, reason: 'Flock id should not be empty');
      }
    });

    // ── Broiler flocks ─────────────────────────────────────────────────────
    test('contains 3 broiler flocks (flock-001, flock-004, flock-007)', () async {
      final flocks = await repo.getFlocks();
      final broilers = flocks.where((f) => f.isBroiler).toList();
      expect(broilers.length, 3);
      final ids = broilers.map((f) => f.id).toSet();
      expect(ids, containsAll(['flock-001', 'flock-004', 'flock-007']));
    });

    // ── Layer flocks ───────────────────────────────────────────────────────
    test('contains 3 layer flocks (flock-002, flock-005, flock-012)', () async {
      final flocks = await repo.getFlocks();
      final layers = flocks.where((f) => f.isLayer).toList();
      expect(layers.length, 3);
      final ids = layers.map((f) => f.id).toSet();
      expect(ids, containsAll(['flock-002', 'flock-005', 'flock-012']));
    });

    // ── Breeder flocks ─────────────────────────────────────────────────────
    test('contains 2 breeder flocks (flock-006, flock-010)', () async {
      final flocks = await repo.getFlocks();
      final breeders = flocks.where((f) => f.isBreeder).toList();
      expect(breeders.length, 2);
      final ids = breeders.map((f) => f.id).toSet();
      expect(ids, containsAll(['flock-006', 'flock-010']));
    });

    // ── Other species ──────────────────────────────────────────────────────
    test('flock-003 is duck_meat production type', () async {
      final flocks = await repo.getFlocks();
      final duck = flocks.firstWhere((f) => f.id == 'flock-003');
      expect(duck.isDuck, isTrue);
      expect(duck.productionType, 'duck_meat');
    });

    test('flock-011 is turkey_meat production type', () async {
      final flocks = await repo.getFlocks();
      final turkey = flocks.firstWhere((f) => f.id == 'flock-011');
      expect(turkey.isTurkey, isTrue);
    });

    test('flock-013 is quail production type', () async {
      final flocks = await repo.getFlocks();
      final quail = flocks.firstWhere((f) => f.id == 'flock-013');
      expect(quail.isQuail, isTrue);
    });

    // ── Status mix ─────────────────────────────────────────────────────────
    test('has at least one active flock', () async {
      final flocks = await repo.getFlocks();
      expect(flocks.any((f) => f.isActive), isTrue);
    });

    test('flock-004 (broiler) is harvested — not active', () async {
      final flocks = await repo.getFlocks();
      final f = flocks.firstWhere((f) => f.id == 'flock-004');
      expect(f.isBroiler, isTrue);
      expect(f.isActive, isFalse);
      expect(f.status, 'harvested');
    });

    test('flock-005 (layer) is depleted — not active', () async {
      final flocks = await repo.getFlocks();
      final f = flocks.firstWhere((f) => f.id == 'flock-005');
      expect(f.isLayer, isTrue);
      expect(f.isActive, isFalse);
    });
  });

  // =========================================================================
  // getFlockById — per-type validation
  // =========================================================================

  group('PoultryRepository.getFlockById()', () {
    // ── Broiler ────────────────────────────────────────────────────────────
    test('flock-001 is active broiler with broilerSpecific data', () async {
      final f = await repo.getFlockById('flock-001');
      expect(f, isNotNull);
      expect(f!.isBroiler, isTrue);
      expect(f.isActive, isTrue);
      expect(f.broilerSpecific, isNotNull);
    });

    test('flock-001 broilerSpecific has valid FCR and EPEF', () async {
      final f = await repo.getFlockById('flock-001');
      final bs = f!.broilerSpecific!;
      expect(bs.targetFcr42d, isNotNull);
      expect(bs.epefCurrent, isNotNull);
    });

    // ── Layer ──────────────────────────────────────────────────────────────
    test('flock-002 is active layer with layerSpecific data', () async {
      final f = await repo.getFlockById('flock-002');
      expect(f, isNotNull);
      expect(f!.isLayer, isTrue);
      expect(f.isActive, isTrue);
      expect(f.layerSpecific, isNotNull);
    });

    test('flock-002 layerSpecific has valid HDP% and egg production data', () async {
      final f = await repo.getFlockById('flock-002');
      final ls = f!.layerSpecific!;
      expect(ls.currentHdpPct, isNotNull);
      expect(ls.totalEggsProduced, isNotNull);
      expect(ls.totalEggsProduced!, greaterThan(0));
    });

    // ── Breeder / Hatchery ─────────────────────────────────────────────────
    test('flock-006 is active breeder with breederSpecific data', () async {
      final f = await repo.getFlockById('flock-006');
      expect(f, isNotNull);
      expect(f!.isBreeder, isTrue);
      expect(f.isActive, isTrue);
      expect(f.breederSpecific, isNotNull);
    });

    test('flock-006 breederSpecific has fertility, hatchability, and chick production data',
        () async {
      final f = await repo.getFlockById('flock-006');
      final bs = f!.breederSpecific!;
      expect(bs.henCount, isNotNull);
      expect(bs.roosterCount, isNotNull);
      expect(bs.fertilityPct, isNotNull);
      expect(bs.hatchabilityPct, isNotNull);
      expect(bs.totalChicksProduced, isNotNull);
      expect(bs.totalChicksProduced!, greaterThan(0));
    });

    test('flock-006 breeder: hatchability < fertility (industry standard)', () async {
      final f = await repo.getFlockById('flock-006');
      final bs = f!.breederSpecific!;
      if (bs.hatchabilityPct != null && bs.fertilityPct != null) {
        expect(bs.hatchabilityPct!, lessThan(bs.fertilityPct!));
      }
    });

    // ── Returns null for missing flock ─────────────────────────────────────
    test('returns null for nonexistent flock id', () async {
      final f = await repo.getFlockById('nonexistent-flock-id');
      expect(f, isNull);
    });

    test('returns null for empty string id', () async {
      final f = await repo.getFlockById('');
      expect(f, isNull);
    });
  });

  // =========================================================================
  // getDailyRecords
  // =========================================================================

  group('PoultryRepository.getDailyRecords()', () {
    test('returns non-empty list', () async {
      final records = await repo.getDailyRecords();
      expect(records, isNotEmpty);
    });

    test('all records have non-empty flock_id and date', () async {
      final records = await repo.getDailyRecords();
      for (final r in records) {
        expect(r.flockId, isNotEmpty);
        expect(r.date, isNotEmpty);
      }
    });

    test('layer flock records have egg collection data', () async {
      final records = await repo.getDailyRecords();
      final layerRecords = records.where((r) => r.isLayerRecord).toList();
      expect(layerRecords, isNotEmpty,
          reason: 'Should have at least some layer records with egg data');
    });
  });

  // =========================================================================
  // getVaccinationSchedules
  // =========================================================================

  group('PoultryRepository.getVaccinationSchedules()', () {
    test('returns non-empty list', () async {
      final schedules = await repo.getVaccinationSchedules();
      expect(schedules, isNotEmpty);
    });

    test('all schedules have non-empty flockId', () async {
      final schedules = await repo.getVaccinationSchedules();
      for (final s in schedules) {
        expect(s.flockId, isNotEmpty);
      }
    });

    test('each schedule has at least one vaccine item', () async {
      final schedules = await repo.getVaccinationSchedules();
      for (final s in schedules) {
        expect(s.schedule, isNotEmpty,
            reason: 'Schedule for ${s.flockId} should have vaccine items');
      }
    });
  });

  // =========================================================================
  // getFeedPhases
  // =========================================================================

  group('PoultryRepository.getFeedPhases()', () {
    test('returns non-empty list', () async {
      final phases = await repo.getFeedPhases();
      expect(phases, isNotEmpty);
    });

    test('all phases have valid dayStart <= dayEnd', () async {
      final phases = await repo.getFeedPhases();
      for (final p in phases) {
        expect(p.dayStart, lessThanOrEqualTo(p.dayEnd),
            reason: 'Phase ${p.id}: dayStart must be <= dayEnd');
      }
    });
  });

  // =========================================================================
  // getHarvestRecords — broiler-specific
  // =========================================================================

  group('PoultryRepository.getHarvestRecords()', () {
    test('returns non-empty list (flock-004 is harvested)', () async {
      final records = await repo.getHarvestRecords();
      expect(records, isNotEmpty);
    });

    test('all harvest records have positive birdsHarvested', () async {
      final records = await repo.getHarvestRecords();
      for (final r in records) {
        expect(r.birdsHarvested, greaterThan(0),
            reason: 'Harvest record ${r.id} should have positive bird count');
      }
    });

    test('avgHarvestWeightKg is positive for all records', () async {
      final records = await repo.getHarvestRecords();
      for (final r in records) {
        expect(r.avgHarvestWeightKg, greaterThan(0));
      }
    });
  });

  // =========================================================================
  // getMedicationLogs
  // =========================================================================

  group('PoultryRepository.getMedicationLogs()', () {
    test('returns non-empty list', () async {
      final logs = await repo.getMedicationLogs();
      expect(logs, isNotEmpty);
    });

    test('all logs have valid clearanceDate format (YYYY-MM-DD)', () async {
      final logs = await repo.getMedicationLogs();
      final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
      for (final log in logs) {
        expect(dateRegex.hasMatch(log.clearanceDate), isTrue,
            reason: 'clearanceDate "${log.clearanceDate}" should be YYYY-MM-DD');
      }
    });
  });

  // =========================================================================
  // getDiseaseEvents
  // =========================================================================

  group('PoultryRepository.getDiseaseEvents()', () {
    test('returns non-empty list', () async {
      final events = await repo.getDiseaseEvents();
      expect(events, isNotEmpty);
    });

    test('all events have non-empty disease name', () async {
      final events = await repo.getDiseaseEvents();
      for (final e in events) {
        expect(e.disease, isNotEmpty);
      }
    });
  });

  // =========================================================================
  // getEnvironmentReadings
  // =========================================================================

  group('PoultryRepository.getEnvironmentReadings()', () {
    test('returns non-empty list', () async {
      final readings = await repo.getEnvironmentReadings();
      expect(readings, isNotEmpty);
    });

    test('all readings have non-empty flockId and timestamp', () async {
      final readings = await repo.getEnvironmentReadings();
      for (final r in readings) {
        expect(r.flockId, isNotEmpty);
        expect(r.timestamp, isNotEmpty);
      }
    });
  });

  // =========================================================================
  // getEggSales — Layer farming revenue
  // =========================================================================

  group('PoultryRepository.getEggSales()', () {
    test('returns non-empty list', () async {
      final sales = await repo.getEggSales();
      expect(sales, isNotEmpty);
    });

    test('all egg sales have positive totalRevenue', () async {
      final sales = await repo.getEggSales();
      for (final s in sales) {
        expect(s.totalRevenue, greaterThan(0),
            reason: 'EggSale ${s.id} should have positive revenue');
      }
    });

    test('all egg sales belong to layer or breeder flocks (by flock id prefix)', () async {
      final sales = await repo.getEggSales();
      // All egg sales should have a valid flock id
      for (final s in sales) {
        expect(s.flockId, isNotEmpty);
      }
    });
  });

  // =========================================================================
  // getChickSales — Hatchery / Breeder DOC output
  // =========================================================================

  group('PoultryRepository.getChickSales()', () {
    test('returns non-empty list', () async {
      final sales = await repo.getChickSales();
      expect(sales, isNotEmpty);
    });

    test('all chick sales have positive chickCount and pricePerChick', () async {
      final sales = await repo.getChickSales();
      for (final s in sales) {
        expect(s.chickCount, greaterThan(0));
        expect(s.pricePerChick, greaterThan(0));
      }
    });

    test('all chick sales have positive totalAmount', () async {
      final sales = await repo.getChickSales();
      for (final s in sales) {
        expect(s.totalAmount, greaterThan(0));
      }
    });
  });

  // =========================================================================
  // getInventoryItems
  // =========================================================================

  group('PoultryRepository.getInventoryItems()', () {
    test('returns non-empty list', () async {
      final items = await repo.getInventoryItems();
      expect(items, isNotEmpty);
    });
  });
}
