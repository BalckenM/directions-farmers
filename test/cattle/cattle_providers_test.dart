import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/cattle/models/cattle_animal.dart';
import 'package:mobile_app/features/cattle/models/cattle_records.dart';
import 'package:mobile_app/features/cattle/providers/cattle_providers.dart';

void main() {
  group('addedCattleProvider', () {
    test('starts empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(addedCattleProvider), isEmpty);
    });

    test('addAnimal appends to list', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      const animal = CattleAnimal(
        id: 'PROV-01',
        farmId: 'farm-001',
        tagNumber: 'PROV-01',
        breed: 'Nguni',
        productionType: 'beef',
        sex: 'cow',
        status: 'active',
        herdId: 'herd-001',
        dateOfBirth: '2022-01-01',
        isPregnant: false,
        isLactating: false,
      );
      container.read(addedCattleProvider.notifier).addAnimal(animal);
      expect(container.read(addedCattleProvider).length, 1);
      expect(container.read(addedCattleProvider).first.id, 'PROV-01');
    });

    test('addAnimal prepends (newest first)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final a1 = CattleAnimal(
        id: 'A1', farmId: 'f', tagNumber: 'A1', breed: 'Nguni',
        productionType: 'beef', sex: 'cow', status: 'active',
        herdId: 'h', dateOfBirth: '2022-01-01',
        isPregnant: false, isLactating: false,
      );
      final a2 = CattleAnimal(
        id: 'A2', farmId: 'f', tagNumber: 'A2', breed: 'Bonsmara',
        productionType: 'beef', sex: 'bull', status: 'active',
        herdId: 'h', dateOfBirth: '2021-05-01',
        isPregnant: false, isLactating: false,
      );
      container.read(addedCattleProvider.notifier).addAnimal(a1);
      container.read(addedCattleProvider.notifier).addAnimal(a2);
      expect(container.read(addedCattleProvider).first.id, 'A2');
    });
  });

  group('cattleStatusOverrideProvider', () {
    test('starts empty map', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(cattleStatusOverrideProvider), isEmpty);
    });

    test('setStatus stores status for animalId', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container
          .read(cattleStatusOverrideProvider.notifier)
          .setStatus('CA001', 'sold');
      expect(container.read(cattleStatusOverrideProvider)['CA001'], 'sold');
    });

    test('setStatus overwrites existing status', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container
          .read(cattleStatusOverrideProvider.notifier)
          .setStatus('CA001', 'sold');
      container
          .read(cattleStatusOverrideProvider.notifier)
          .setStatus('CA001', 'deceased');
      expect(
          container.read(cattleStatusOverrideProvider)['CA001'], 'deceased');
    });
  });

  group('cattleEditProvider', () {
    test('starts empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(cattleEditProvider), isEmpty);
    });

    test('applyEdit stores edits for animalId', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container
          .read(cattleEditProvider.notifier)
          .applyEdit('CA001', {'breed': 'Simmental'});
      expect(
          container.read(cattleEditProvider)['CA001']?['breed'], 'Simmental');
    });

    test('applyEdit merges with existing edits', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container
          .read(cattleEditProvider.notifier)
          .applyEdit('CA001', {'breed': 'Simmental'});
      container
          .read(cattleEditProvider.notifier)
          .applyEdit('CA001', {'notes': 'test note'});
      final edits = container.read(cattleEditProvider)['CA001']!;
      expect(edits['breed'], 'Simmental');
      expect(edits['notes'], 'test note');
    });
  });

  group('newCattleWeightRecordProvider', () {
    test('starts empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(newCattleWeightRecordProvider), isEmpty);
    });

    test('addRecord stores record under animalId', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final record = WeightRecord(
        id: 'WT-001',
        animalId: 'CA001',
        date: '2025-08-01',
        weightKg: 480,
      );
      container
          .read(newCattleWeightRecordProvider.notifier)
          .addRecord('CA001', record);
      final records = container.read(newCattleWeightRecordProvider)['CA001']!;
      expect(records.length, 1);
      expect(records.first.weightKg, 480);
    });
  });

  group('newCattlePastureRecordProvider', () {
    test('addRecord stores under herdId', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final record = PastureRecord(
        id: 'PR-001',
        herdId: 'herd-001',
        campId: 'PAS-01',
        entryDate: '2025-08-01',
      );
      container
          .read(newCattlePastureRecordProvider.notifier)
          .addRecord('herd-001', record);
      final records =
          container.read(newCattlePastureRecordProvider)['herd-001']!;
      expect(records.length, 1);
      expect(records.first.campId, 'PAS-01');
    });
  });

  group('newCattleFeedRecordProvider', () {
    test('addRecord stores under herdId', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final record = CattleFeedRecord(
        id: 'FEED-001',
        animalId: 'herd-001',
        date: '2025-08-01',
        feedType: 'lucerne',
        quantityKg: 50,
      );
      container
          .read(newCattleFeedRecordProvider.notifier)
          .addRecord('herd-001', record);
      final records =
          container.read(newCattleFeedRecordProvider)['herd-001']!;
      expect(records.length, 1);
      expect(records.first.feedType, 'lucerne');
    });
  });
}
