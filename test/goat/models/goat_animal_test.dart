// Unit tests for GoatAnimal and its nested type-specific classes.
//
// Pure Dart tests — no Flutter binding required.

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/goat/models/goat_animal.dart';

void main() {
  // =========================================================================
  // GoatAnimal — fromJson / toJson round-trip
  // =========================================================================

  group('GoatAnimal', () {
    const baseJson = {
      'id': 'goat-001',
      'farmId': 'farm-001',
      'tagNumber': 'T001',
      'name': 'Bella',
      'breed': 'Boer',
      'productionType': 'meat',
      'sex': 'doe',
      'status': 'active',
      'herdId': 'herd-a',
      'dateOfBirth': '2022-03-15',
      'isPregnant': true,
      'isLactating': false,
      'expectedKiddingDate': '2024-08-20',
      'bodyConditionScore': 3.5,
      'famachaScore': 2,
      'currentWeightKg': 45.5,
      'targetWeightKg': 55.0,
      'purchasePrice': 2000.0,
      'registrationNumber': 'REG-001',
      'notes': 'Test animal',
    };

    test('fromJson parses all required fields', () {
      final a = GoatAnimal.fromJson(baseJson);
      expect(a.id, 'goat-001');
      expect(a.farmId, 'farm-001');
      expect(a.tagNumber, 'T001');
      expect(a.name, 'Bella');
      expect(a.breed, 'Boer');
      expect(a.productionType, 'meat');
      expect(a.sex, 'doe');
      expect(a.status, 'active');
      expect(a.herdId, 'herd-a');
      expect(a.dateOfBirth, '2022-03-15');
      expect(a.isPregnant, isTrue);
      expect(a.isLactating, isFalse);
      expect(a.expectedKiddingDate, '2024-08-20');
      expect(a.bodyConditionScore, closeTo(3.5, 0.01));
      expect(a.famachaScore, 2);
      expect(a.currentWeightKg, closeTo(45.5, 0.01));
      expect(a.targetWeightKg, closeTo(55.0, 0.01));
      expect(a.purchasePrice, closeTo(2000.0, 0.01));
      expect(a.registrationNumber, 'REG-001');
      expect(a.notes, 'Test animal');
    });

    test('fromJson defaults isPregnant and isLactating to false when missing', () {
      final a = GoatAnimal.fromJson({
        'id': 'g2',
        'farmId': 'f1',
        'tagNumber': 'T2',
        'breed': 'Saanen',
        'productionType': 'dairy',
        'sex': 'doe',
        'status': 'active',
        'herdId': 'herd-b',
        'dateOfBirth': '2021-01-01',
      });
      expect(a.isPregnant, isFalse);
      expect(a.isLactating, isFalse);
    });

    test('toJson round-trips correctly', () {
      final a = GoatAnimal.fromJson(baseJson);
      final j = a.toJson();
      expect(j['id'], 'goat-001');
      expect(j['tagNumber'], 'T001');
      expect(j['isPregnant'], isTrue);
      expect(j['bodyConditionScore'], closeTo(3.5, 0.01));
      expect(j['registrationNumber'], 'REG-001');
    });

    // ── SA compliance fields ─────────────────────────────────────────────────

    test('fromJson parses SA compliance fields', () {
      final j = {
        ...baseJson,
        'brandNumber': 'BRN-999',
        'brandPosition': 'Left rib T7',
        'earmarkDesc': 'Double notch right',
        'brucellaTested': true,
        'brucellaTestDate': '2024-01-15',
        'fmdZone': 'FMD-C3',
        'rmisAnimalId': 'RMIS-001234',
        'importPermitNo': null,
      };
      final a = GoatAnimal.fromJson(j);
      expect(a.brandNumber, 'BRN-999');
      expect(a.brandPosition, 'Left rib T7');
      expect(a.earmarkDesc, 'Double notch right');
      expect(a.brucellaTested, isTrue);
      expect(a.brucellaTestDate, '2024-01-15');
      expect(a.fmdZone, 'FMD-C3');
      expect(a.rmisAnimalId, 'RMIS-001234');
      expect(a.importPermitNo, isNull);
    });

    test('brucellaTested defaults to false when absent', () {
      final a = GoatAnimal.fromJson({
        'id': 'g3',
        'farmId': 'f1',
        'tagNumber': 'T3',
        'breed': 'Boer',
        'productionType': 'meat',
        'sex': 'buck',
        'status': 'active',
        'herdId': 'herd-a',
        'dateOfBirth': '2020-06-01',
      });
      expect(a.brucellaTested, isFalse);
    });

    // ── Computed helpers ─────────────────────────────────────────────────────

    group('displayName', () {
      test('returns name when non-empty', () {
        final a = GoatAnimal.fromJson(baseJson);
        expect(a.displayName, 'Bella');
      });

      test('falls back to tagNumber when name is null', () {
        final a = GoatAnimal.fromJson({
          ...baseJson,
          'name': null,
        });
        expect(a.displayName, 'T001');
      });

      test('falls back to tagNumber when name is empty string', () {
        final a = GoatAnimal.fromJson({
          ...baseJson,
          'name': '',
        });
        expect(a.displayName, 'T001');
      });
    });

    group('ageMonths', () {
      test('returns 0 for invalid date', () {
        final a = GoatAnimal.fromJson({
          ...baseJson,
          'dateOfBirth': 'not-a-date',
        });
        expect(a.ageMonths, 0);
      });

      test('is positive for past date', () {
        final a = GoatAnimal.fromJson({
          ...baseJson,
          'dateOfBirth': '2020-01-01',
        });
        expect(a.ageMonths, greaterThan(0));
      });
    });

    group('isKid', () {
      test('true when age < 12 months', () {
        final dob = DateTime.now().subtract(const Duration(days: 60));
        final dobStr =
            '${dob.year}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}';
        final a = GoatAnimal.fromJson({...baseJson, 'dateOfBirth': dobStr});
        expect(a.isKid, isTrue);
      });

      test('false when age >= 12 months', () {
        final a = GoatAnimal.fromJson({
          ...baseJson,
          'dateOfBirth': '2020-01-01',
        });
        expect(a.isKid, isFalse);
      });
    });

    group('isFemale / isMale', () {
      test('doe is female', () {
        final a = GoatAnimal.fromJson({...baseJson, 'sex': 'doe'});
        expect(a.isFemale, isTrue);
        expect(a.isMale, isFalse);
      });

      test('kid_female is female', () {
        final a = GoatAnimal.fromJson({...baseJson, 'sex': 'kid_female'});
        expect(a.isFemale, isTrue);
        expect(a.isMale, isFalse);
      });

      test('buck is male', () {
        final a = GoatAnimal.fromJson({...baseJson, 'sex': 'buck'});
        expect(a.isFemale, isFalse);
        expect(a.isMale, isTrue);
      });

      test('wether is male', () {
        final a = GoatAnimal.fromJson({...baseJson, 'sex': 'wether'});
        expect(a.isMale, isTrue);
      });

      test('kid_male is male', () {
        final a = GoatAnimal.fromJson({...baseJson, 'sex': 'kid_male'});
        expect(a.isMale, isTrue);
      });
    });

    group('isAlive', () {
      for (final aliveStatus in ['active', 'dry']) {
        test('$aliveStatus is alive', () {
          final a = GoatAnimal.fromJson({...baseJson, 'status': aliveStatus});
          expect(a.isAlive, isTrue);
        });
      }

      for (final deadStatus in ['sold', 'slaughtered', 'deceased', 'culled']) {
        test('$deadStatus is not alive', () {
          final a = GoatAnimal.fromJson({...baseJson, 'status': deadStatus});
          expect(a.isAlive, isFalse);
        });
      }
    });

    // ── copyWith ──────────────────────────────────────────────────────────────

    group('copyWith', () {
      test('overrides specified fields and preserves others', () {
        final a = GoatAnimal.fromJson(baseJson);
        final b = a.copyWith(name: 'Daisy', bodyConditionScore: 4.0);
        expect(b.name, 'Daisy');
        expect(b.bodyConditionScore, closeTo(4.0, 0.01));
        expect(b.id, a.id);
        expect(b.breed, a.breed);
        expect(b.isPregnant, a.isPregnant);
      });

      test('copyWith preserves SA compliance fields', () {
        final a = GoatAnimal.fromJson({
          ...baseJson,
          'brandNumber': 'B1',
          'fmdZone': 'Z1',
          'brucellaTested': true,
        });
        final b = a.copyWith(notes: 'changed');
        expect(b.brandNumber, 'B1');
        expect(b.fmdZone, 'Z1');
        expect(b.brucellaTested, isTrue);
      });
    });
  });

  // =========================================================================
  // MeatSpecific
  // =========================================================================

  group('MeatSpecific', () {
    test('fromJson parses all fields', () {
      final m = MeatSpecific.fromJson({
        'adgGPerDay': 180.5,
        'targetSlaughterAgeMonths': 8,
        'dressingPct': 52.0,
      });
      expect(m.adgGPerDay, closeTo(180.5, 0.01));
      expect(m.targetSlaughterAgeMonths, 8);
      expect(m.dressingPct, closeTo(52.0, 0.01));
    });

    test('fromJson with all nulls', () {
      final m = MeatSpecific.fromJson({});
      expect(m.adgGPerDay, isNull);
      expect(m.targetSlaughterAgeMonths, isNull);
      expect(m.dressingPct, isNull);
    });

    test('toJson omits null fields', () {
      const m = MeatSpecific(targetSlaughterAgeMonths: 9);
      final j = m.toJson();
      expect(j.containsKey('targetSlaughterAgeMonths'), isTrue);
      expect(j.containsKey('adgGPerDay'), isFalse);
      expect(j.containsKey('dressingPct'), isFalse);
    });
  });

  // =========================================================================
  // DairySpecific
  // =========================================================================

  group('DairySpecific', () {
    test('fromJson parses all fields', () {
      final d = DairySpecific.fromJson({
        'peakMilkLitrePd': 3.2,
        'totalMilkThisLactation': 450.0,
        'dryMatterIntakeKgPd': 1.8,
        'milkFatPct': 3.8,
        'milkProteinPct': 3.1,
        'projectedDryOffDate': '2024-09-01',
      });
      expect(d.peakMilkLitrePd, closeTo(3.2, 0.01));
      expect(d.totalMilkThisLactation, closeTo(450.0, 0.01));
      expect(d.dryMatterIntakeKgPd, closeTo(1.8, 0.01));
      expect(d.milkFatPct, closeTo(3.8, 0.01));
      expect(d.milkProteinPct, closeTo(3.1, 0.01));
      expect(d.projectedDryOffDate, '2024-09-01');
    });

    test('fromJson with all nulls returns nulls', () {
      final d = DairySpecific.fromJson({});
      expect(d.peakMilkLitrePd, isNull);
      expect(d.projectedDryOffDate, isNull);
    });
  });

  // =========================================================================
  // FiberSpecific
  // =========================================================================

  group('FiberSpecific', () {
    test('fromJson parses all fields', () {
      final f = FiberSpecific.fromJson({
        'avgFleeceMassKg': 2.5,
        'stapleLength': 90.0,
        'micronRating': 24.5,
        'colorGrade': 'white',
        'lastMohairPricePerKg': 85.0,
      });
      expect(f.avgFleeceMassKg, closeTo(2.5, 0.01));
      expect(f.stapleLength, closeTo(90.0, 0.01));
      expect(f.micronRating, closeTo(24.5, 0.01));
      expect(f.colorGrade, 'white');
      expect(f.lastMohairPricePerKg, closeTo(85.0, 0.01));
    });

    test('toJson round-trips', () {
      const f = FiberSpecific(micronRating: 26.0, colorGrade: 'black');
      final j = f.toJson();
      expect(j['micronRating'], closeTo(26.0, 0.01));
      expect(j['colorGrade'], 'black');
      expect(j.containsKey('avgFleeceMassKg'), isFalse);
    });
  });

  // =========================================================================
  // BreederSpecific
  // =========================================================================

  group('BreederSpecific', () {
    test('fromJson parses all fields', () {
      final b = BreederSpecific.fromJson({
        'studBookNumber': 'SB-100',
        'registeredBreeder': true,
        'breedingFee': 500.0,
        'doesServedCount': 12,
        'kidRatio': 1.8,
      });
      expect(b.studBookNumber, 'SB-100');
      expect(b.registeredBreeder, isTrue);
      expect(b.breedingFee, closeTo(500.0, 0.01));
      expect(b.doesServedCount, 12);
      expect(b.kidRatio, closeTo(1.8, 0.01));
    });

    test('registeredBreeder defaults to false', () {
      final b = BreederSpecific.fromJson({'studBookNumber': 'SB-001'});
      expect(b.registeredBreeder, isFalse);
    });

    test('toJson includes registeredBreeder bool', () {
      const b = BreederSpecific(registeredBreeder: true, breedingFee: 300.0);
      final j = b.toJson();
      expect(j['registeredBreeder'], isTrue);
      expect(j['breedingFee'], closeTo(300.0, 0.01));
      expect(j.containsKey('studBookNumber'), isFalse);
    });
  });

  // =========================================================================
  // GoatAnimal with nested type-specific data
  // =========================================================================

  group('GoatAnimal — nested type data round-trip', () {
    test('parses meatSpecific', () {
      final a = GoatAnimal.fromJson({
        'id': 'gm1',
        'farmId': 'f1',
        'tagNumber': 'TM1',
        'breed': 'Boer',
        'productionType': 'meat',
        'sex': 'buck',
        'status': 'active',
        'herdId': 'h1',
        'dateOfBirth': '2022-06-01',
        'isPregnant': false,
        'isLactating': false,
        'meatSpecific': {
          'adgGPerDay': 150.0,
          'targetSlaughterAgeMonths': 9,
          'dressingPct': 50.0,
        },
      });
      expect(a.meatSpecific, isNotNull);
      expect(a.meatSpecific!.adgGPerDay, closeTo(150.0, 0.01));
      expect(a.dairySpecific, isNull);
    });

    test('parses dairySpecific', () {
      final a = GoatAnimal.fromJson({
        'id': 'gd1',
        'farmId': 'f1',
        'tagNumber': 'TD1',
        'breed': 'Saanen',
        'productionType': 'dairy',
        'sex': 'doe',
        'status': 'active',
        'herdId': 'h1',
        'dateOfBirth': '2021-03-01',
        'isPregnant': false,
        'isLactating': true,
        'dairySpecific': {
          'peakMilkLitrePd': 3.5,
          'projectedDryOffDate': '2024-10-01',
        },
      });
      expect(a.dairySpecific, isNotNull);
      expect(a.dairySpecific!.peakMilkLitrePd, closeTo(3.5, 0.01));
      expect(a.dairySpecific!.projectedDryOffDate, '2024-10-01');
    });
  });
}
