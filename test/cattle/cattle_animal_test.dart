import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/cattle/models/cattle_animal.dart';

void main() {
  group('CattleAnimal', () {
    const animal = CattleAnimal(
      id: 'CA001',
      farmId: 'farm-001',
      tagNumber: 'CA001',
      name: 'Thandi',
      breed: 'Nguni',
      productionType: 'beef',
      sex: 'cow',
      status: 'active',
      herdId: 'herd-nguni',
      dateOfBirth: '2020-03-14',
      isPregnant: true,
      isLactating: false,
    );

    test('stores required fields', () {
      expect(animal.id, 'CA001');
      expect(animal.farmId, 'farm-001');
      expect(animal.tagNumber, 'CA001');
      expect(animal.breed, 'Nguni');
      expect(animal.productionType, 'beef');
      expect(animal.sex, 'cow');
      expect(animal.status, 'active');
      expect(animal.herdId, 'herd-nguni');
      expect(animal.dateOfBirth, '2020-03-14');
      expect(animal.isPregnant, true);
      expect(animal.isLactating, false);
    });

    test('optional fields default to null', () {
      expect(animal.damId, isNull);
      expect(animal.sireId, isNull);
      expect(animal.purchaseDate, isNull);
      expect(animal.purchasePrice, isNull);
      expect(animal.currentWeightKg, isNull);
      expect(animal.notes, isNull);
      expect(animal.beefSpecific, isNull);
      expect(animal.dairySpecific, isNull);
    });

    test('brucellaTested defaults to false', () {
      expect(animal.brucellaTested, false);
    });

    test('stores beefSpecific when provided', () {
      const beef = CattleAnimal(
        id: 'CA002',
        farmId: 'farm-001',
        tagNumber: 'CA002',
        breed: 'Bonsmara',
        productionType: 'beef',
        sex: 'bull',
        status: 'active',
        herdId: 'herd-beef',
        dateOfBirth: '2019-06-01',
        isPregnant: false,
        isLactating: false,
        beefSpecific: BeefSpecific(averageDailyGainKg: 0.95),
      );
      expect(beef.beefSpecific, isNotNull);
      expect(beef.beefSpecific!.averageDailyGainKg, 0.95);
    });

    test('stores dairySpecific when provided', () {
      const dairy = CattleAnimal(
        id: 'CA003',
        farmId: 'farm-001',
        tagNumber: 'CA003',
        breed: 'Holstein',
        productionType: 'dairy',
        sex: 'cow',
        status: 'active',
        herdId: 'herd-dairy',
        dateOfBirth: '2021-02-10',
        isPregnant: false,
        isLactating: true,
        dairySpecific: DairySpecific(
          totalMilkThisLactation: 8400,
          peakMilkLitrePd: 28.0,
        ),
      );
      expect(dairy.dairySpecific, isNotNull);
      expect(dairy.dairySpecific!.peakMilkLitrePd, 28.0);
    });
  });

  group('BeefSpecific', () {
    test('stores adg', () {
      const b = BeefSpecific(averageDailyGainKg: 1.1);
      expect(b.averageDailyGainKg, 1.1);
    });
  });

  group('DairySpecific', () {
    test('stores milk yield fields', () {
      const d = DairySpecific(
        totalMilkThisLactation: 9000,
        peakMilkLitrePd: 30.0,
      );
      expect(d.peakMilkLitrePd, 30.0);
      expect(d.totalMilkThisLactation, 9000);
    });
  });
}
