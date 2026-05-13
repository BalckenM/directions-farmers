import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/cattle/data/cattle_mock_data_source.dart';
import 'package:mobile_app/features/cattle/models/cattle_animal.dart';
import 'package:mobile_app/features/cattle/models/cattle_records.dart';

void main() {
  late CattleMockDataSource ds;

  setUp(() {
    ds = CattleMockDataSource();
  });

  group('CattleMockDataSource.getAnimals', () {
    test('returns non-empty list', () async {
      final animals = await ds.getAnimals();
      expect(animals, isNotEmpty);
    });

    test('all animals have required fields populated', () async {
      final animals = await ds.getAnimals();
      for (final a in animals) {
        expect(a.id, isNotEmpty);
        expect(a.tagNumber, isNotEmpty);
        expect(a.breed, isNotEmpty);
        expect(a.sex, isNotEmpty);
        expect(['beef', 'dairy'].contains(a.productionType), isTrue);
      }
    });

    test('contains expected breeds', () async {
      final animals = await ds.getAnimals();
      final breeds = animals.map((a) => a.breed).toSet();
      expect(breeds, containsAll(['Nguni', 'Bonsmara']));
    });
  });

  group('CattleMockDataSource CRUD – Animals', () {
    test('createAnimal adds animal', () async {
      final before = (await ds.getAnimals()).length;
      const newAnimal = CattleAnimal(
        id: 'CATEST',
        farmId: 'farm-001',
        tagNumber: 'CATEST',
        breed: 'Nguni',
        productionType: 'beef',
        sex: 'cow',
        status: 'active',
        herdId: 'herd-test',
        dateOfBirth: '2022-01-01',
        isPregnant: false,
        isLactating: false,
      );
      await ds.createAnimal(newAnimal);
      final after = (await ds.getAnimals()).length;
      expect(after, before + 1);
    });

    test('updateAnimal changes fields', () async {
      final animals = await ds.getAnimals();
      final original = animals.first;
      final updated = CattleAnimal(
        id: original.id,
        farmId: original.farmId,
        tagNumber: original.tagNumber,
        breed: original.breed,
        productionType: original.productionType,
        sex: original.sex,
        status: 'sold',
        herdId: original.herdId,
        dateOfBirth: original.dateOfBirth,
        isPregnant: false,
        isLactating: false,
      );
      final result = await ds.updateAnimal(updated);
      expect(result.status, 'sold');
    });

    test('deleteAnimal removes animal', () async {
      final animals = await ds.getAnimals();
      final before = animals.length;
      await ds.deleteAnimal(animals.last.id);
      final after = (await ds.getAnimals()).length;
      expect(after, before - 1);
    });
  });

  group('CattleMockDataSource – Records', () {
    test('getWeightRecords returns list', () async {
      final records = await ds.getWeightRecords();
      expect(records, isA<List<WeightRecord>>());
    });

    test('getBreedingRecords returns list', () async {
      final records = await ds.getBreedingRecords();
      expect(records, isA<List<BreedingRecord>>());
    });

    test('getSaleRecords returns list', () async {
      final records = await ds.getSaleRecords();
      expect(records, isA<List<CattleSaleRecord>>());
    });

    test('getPastureRecords returns list', () async {
      final records = await ds.getPastureRecords();
      expect(records, isA<List<PastureRecord>>());
    });

    test('getFeedRecords returns list', () async {
      final records = await ds.getFeedRecords();
      expect(records, isA<List<CattleFeedRecord>>());
    });

    test('createWeightRecord adds a record', () async {
      final before = (await ds.getWeightRecords()).length;
      final record = WeightRecord(
        id: 'WT-TEST',
        animalId: 'CA001',
        date: '2025-08-01',
        weightKg: 450,
      );
      await ds.createWeightRecord(record);
      final after = (await ds.getWeightRecords()).length;
      expect(after, before + 1);
    });
  });
}
