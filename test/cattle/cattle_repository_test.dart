import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/cattle/data/cattle_mock_data_source.dart';
import 'package:mobile_app/features/cattle/data/cattle_repository.dart';
import 'package:mobile_app/features/cattle/models/cattle_animal.dart';
import 'package:mobile_app/features/cattle/models/cattle_records.dart';

void main() {
  late CattleRepository repo;

  setUp(() {
    repo = CattleRepository(CattleMockDataSource());
  });

  group('CattleRepository.getAnimals', () {
    test('returns animals from data source', () async {
      final animals = await repo.getAnimals();
      expect(animals, isA<List<CattleAnimal>>());
      expect(animals, isNotEmpty);
    });
  });

  group('CattleRepository.getWeightRecords', () {
    test('returns weight records', () async {
      final records = await repo.getWeightRecords();
      expect(records, isA<List<WeightRecord>>());
    });
  });

  group('CattleRepository.getBreedingRecords', () {
    test('returns breeding records', () async {
      final records = await repo.getBreedingRecords();
      expect(records, isA<List<BreedingRecord>>());
    });
  });

  group('CattleRepository.getSaleRecords', () {
    test('returns sale records', () async {
      final records = await repo.getSaleRecords();
      expect(records, isA<List<CattleSaleRecord>>());
    });
  });

  group('CattleRepository.createAnimal', () {
    test('adds animal and returns it', () async {
      const newAnimal = CattleAnimal(
        id: 'REPO-TEST',
        farmId: 'farm-001',
        tagNumber: 'REPO-TEST',
        breed: 'Nguni',
        productionType: 'beef',
        sex: 'cow',
        status: 'active',
        herdId: 'herd-test',
        dateOfBirth: '2023-01-01',
        isPregnant: false,
        isLactating: false,
      );
      final result = await repo.createAnimal(newAnimal);
      expect(result.id, 'REPO-TEST');
      expect(result.breed, 'Nguni');
    });
  });

  group('CattleRepository.createWeightRecord', () {
    test('adds record and returns it', () async {
      final record = WeightRecord(
        id: 'WT-REPO',
        animalId: 'CA001',
        date: '2025-09-01',
        weightKg: 520,
      );
      final result = await repo.createWeightRecord(record);
      expect(result.id, 'WT-REPO');
      expect(result.weightKg, 520);
    });
  });
}
