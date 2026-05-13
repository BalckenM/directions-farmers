// Integration tests for GoatRepository backed by GoatMockDataSource.
//
// No Flutter binding needed — the mock data source is entirely in-memory.

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/goat/data/goat_mock_data_source.dart';
import 'package:mobile_app/features/goat/data/goat_repository.dart';

void main() {
  late GoatRepository repo;

  setUp(() {
    repo = GoatRepository(GoatMockDataSource());
  });

  // =========================================================================
  // Animals
  // =========================================================================

  group('GoatRepository.getAnimals()', () {
    test('returns 14 mock animals', () async {
      final animals = await repo.getAnimals();
      expect(animals.length, 14);
    });

    test('all animals have non-empty ids and tagNumbers', () async {
      final animals = await repo.getAnimals();
      for (final a in animals) {
        expect(a.id, isNotEmpty);
        expect(a.tagNumber, isNotEmpty);
      }
    });

    test('animals span 6 herds (herd-a through herd-f)', () async {
      final animals = await repo.getAnimals();
      final herds = animals.map((a) => a.herdId).toSet();
      expect(herds, containsAll(['herd-a', 'herd-b', 'herd-c', 'herd-d', 'herd-e', 'herd-f']));
    });

    test('goat-001 (Bella) has expected fields', () async {
      final animals = await repo.getAnimals();
      final bella = animals.firstWhere((a) => a.id == 'goat-001');
      expect(bella.name, 'Bella');
      expect(bella.breed, 'Boer');
      expect(bella.productionType, 'meat');
      expect(bella.sex, 'doe');
      expect(bella.isPregnant, isTrue);
    });

    test('at least one animal has FAMACHA score >= 4', () async {
      final animals = await repo.getAnimals();
      final highFamacha =
          animals.where((a) => a.famachaScore != null && a.famachaScore! >= 4);
      expect(highFamacha, isNotEmpty);
    });

    test('isAlive is false for sold/slaughtered animals', () async {
      final animals = await repo.getAnimals();
      final inactive = animals.where((a) => !a.isAlive);
      // Some animals may have been culled/sold in mock data
      for (final a in inactive) {
        expect(
          ['sold', 'slaughtered', 'deceased', 'culled'].contains(a.status),
          isTrue,
          reason: 'Expected inactive status, got ${a.status} for ${a.id}',
        );
      }
    });
  });

  // =========================================================================
  // Weight records
  // =========================================================================

  group('GoatRepository.getWeightRecords()', () {
    test('returns non-empty list', () async {
      final records = await repo.getWeightRecords();
      expect(records, isNotEmpty);
    });

    test('all records have valid animalId and weight', () async {
      final records = await repo.getWeightRecords();
      for (final r in records) {
        expect(r.animalId, isNotEmpty);
        expect(r.weightKg, greaterThan(0));
      }
    });
  });

  // =========================================================================
  // Mating records
  // =========================================================================

  group('GoatRepository.getMatingRecords()', () {
    test('returns list (may be empty for mock)', () async {
      final records = await repo.getMatingRecords();
      expect(records, isA<List>());
    });
  });

  // =========================================================================
  // Pregnancy checks
  // =========================================================================

  group('GoatRepository.getPregnancyChecks()', () {
    test('returns list', () async {
      final records = await repo.getPregnancyChecks();
      expect(records, isA<List>());
    });
  });

  // =========================================================================
  // Kidding events
  // =========================================================================

  group('GoatRepository.getKiddingEvents()', () {
    test('returns non-empty list', () async {
      final events = await repo.getKiddingEvents();
      expect(events, isNotEmpty);
    });

    test('all events have non-empty damId and kiddingDate', () async {
      final events = await repo.getKiddingEvents();
      for (final e in events) {
        expect(e.damId, isNotEmpty);
        expect(e.kiddingDate, isNotEmpty);
      }
    });
  });

  // =========================================================================
  // Milk records
  // =========================================================================

  group('GoatRepository.getMilkRecords()', () {
    test('returns non-empty list', () async {
      final records = await repo.getMilkRecords();
      expect(records, isNotEmpty);
    });

    test('totalLitres is always >= 0', () async {
      final records = await repo.getMilkRecords();
      for (final r in records) {
        expect(r.totalLitres, greaterThanOrEqualTo(0));
      }
    });
  });

  // =========================================================================
  // Shearing records
  // =========================================================================

  group('GoatRepository.getShearingRecords()', () {
    test('returns list', () async {
      final records = await repo.getShearingRecords();
      expect(records, isA<List>());
    });
  });

  // =========================================================================
  // Health events
  // =========================================================================

  group('GoatRepository.getHealthEvents()', () {
    test('returns non-empty list', () async {
      final events = await repo.getHealthEvents();
      expect(events, isNotEmpty);
    });

    test('severity is one of mild/moderate/severe', () async {
      final events = await repo.getHealthEvents();
      const validSeverities = {'mild', 'moderate', 'severe'};
      for (final e in events) {
        expect(validSeverities, contains(e.severity),
            reason: 'Unexpected severity "${e.severity}" on ${e.id}');
      }
    });
  });

  // =========================================================================
  // Medication logs
  // =========================================================================

  group('GoatRepository.getMedicationLogs()', () {
    test('returns non-empty list', () async {
      final logs = await repo.getMedicationLogs();
      expect(logs, isNotEmpty);
    });
  });

  // =========================================================================
  // Vaccinations
  // =========================================================================

  group('GoatRepository.getVaccinations()', () {
    test('returns non-empty list', () async {
      final vaccinations = await repo.getVaccinations();
      expect(vaccinations, isNotEmpty);
    });

    test('at least one vaccination is overdue', () async {
      final vaccinations = await repo.getVaccinations();
      final overdue = vaccinations.where((v) => v.isOverdue);
      expect(overdue, isNotEmpty,
          reason: 'Mock data should include at least one overdue vaccination');
    });
  });

  // =========================================================================
  // Sale records
  // =========================================================================

  group('GoatRepository.getSaleRecords()', () {
    test('returns list', () async {
      final records = await repo.getSaleRecords();
      expect(records, isA<List>());
    });
  });

  // =========================================================================
  // Feed records
  // =========================================================================

  group('GoatRepository.getFeedRecords()', () {
    test('returns non-empty list', () async {
      final records = await repo.getFeedRecords();
      expect(records, isNotEmpty);
    });

    test('totalCost is non-null when costPerKg is set', () async {
      final records = await repo.getFeedRecords();
      for (final r in records) {
        if (r.costPerKg != null) {
          expect(r.totalCost, isNotNull);
          expect(r.totalCost, closeTo(r.quantityKg * r.costPerKg!, 0.01));
        }
      }
    });
  });

  // =========================================================================
  // Pasture records
  // =========================================================================

  group('GoatRepository.getPastureRecords()', () {
    test('returns non-empty list', () async {
      final records = await repo.getPastureRecords();
      expect(records, isNotEmpty);
    });
  });

  // =========================================================================
  // FAMACHA records
  // =========================================================================

  group('GoatRepository.getFamachaRecords()', () {
    test('returns non-empty list', () async {
      final records = await repo.getFamachaRecords();
      expect(records, isNotEmpty);
    });

    test('all scores are between 1 and 5', () async {
      final records = await repo.getFamachaRecords();
      for (final r in records) {
        expect(r.score, inInclusiveRange(1, 5));
      }
    });
  });

  // =========================================================================
  // Body condition records
  // =========================================================================

  group('GoatRepository.getBodyConditionRecords()', () {
    test('returns non-empty list', () async {
      final records = await repo.getBodyConditionRecords();
      expect(records, isNotEmpty);
    });

    test('all scores are between 1.0 and 5.0', () async {
      final records = await repo.getBodyConditionRecords();
      for (final r in records) {
        expect(r.score, inInclusiveRange(1.0, 5.0));
      }
    });
  });
}
