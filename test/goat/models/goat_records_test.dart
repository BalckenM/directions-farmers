// Unit tests for all goat record models.
//
// Tests fromJson, toJson, and computed getters for all 14 record types.
// Pure Dart — no Flutter binding required.

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/goat/models/goat_records.dart';

void main() {
  // =========================================================================
  // WeightRecord
  // =========================================================================

  group('WeightRecord', () {
    test('fromJson parses all fields', () {
      final r = WeightRecord.fromJson({
        'id': 'wr-001',
        'animalId': 'goat-001',
        'date': '2024-05-10',
        'weightKg': 42.5,
        'bodyConditionScore': 3.0,
        'notes': 'Pre-breeding check',
      });
      expect(r.id, 'wr-001');
      expect(r.animalId, 'goat-001');
      expect(r.date, '2024-05-10');
      expect(r.weightKg, closeTo(42.5, 0.01));
      expect(r.bodyConditionScore, closeTo(3.0, 0.01));
      expect(r.notes, 'Pre-breeding check');
    });

    test('toJson round-trips', () {
      const r = WeightRecord(
        id: 'wr-2',
        animalId: 'g1',
        date: '2024-06-01',
        weightKg: 38.0,
      );
      final j = r.toJson();
      expect(j['weightKg'], closeTo(38.0, 0.01));
      expect(j.containsKey('bodyConditionScore'), isFalse);
    });
  });

  // =========================================================================
  // MatingRecord
  // =========================================================================

  group('MatingRecord', () {
    test('fromJson parses all fields', () {
      final r = MatingRecord.fromJson({
        'id': 'mat-001',
        'doeId': 'goat-002',
        'buckId': 'goat-005',
        'serviceDate': '2024-03-01',
        'serviceMethod': 'natural',
        'expectedKiddingDate': '2024-08-01',
        'outcome': 'confirmed',
        'notes': 'First service',
      });
      expect(r.id, 'mat-001');
      expect(r.doeId, 'goat-002');
      expect(r.buckId, 'goat-005');
      expect(r.serviceDate, '2024-03-01');
      expect(r.serviceMethod, 'natural');
      expect(r.expectedKiddingDate, '2024-08-01');
      expect(r.outcome, 'confirmed');
      expect(r.notes, 'First service');
    });

    test('expectedKiddingDate nullable', () {
      final r = MatingRecord.fromJson({
        'id': 'm2',
        'doeId': 'd1',
        'buckId': 'b1',
        'serviceDate': '2024-04-01',
        'serviceMethod': 'AI',
        'outcome': 'pending',
      });
      expect(r.expectedKiddingDate, isNull);
    });
  });

  // =========================================================================
  // PregnancyCheck
  // =========================================================================

  group('PregnancyCheck', () {
    test('fromJson parses all fields', () {
      final r = PregnancyCheck.fromJson({
        'id': 'pc-001',
        'animalId': 'goat-003',
        'date': '2024-04-10',
        'method': 'ultrasound',
        'result': 'positive',
        'expectedKiddingDate': '2024-09-10',
        'daysPregnant': 60,
        'notes': 'Twins suspected',
      });
      expect(r.result, 'positive');
      expect(r.daysPregnant, 60);
      expect(r.expectedKiddingDate, '2024-09-10');
    });
  });

  // =========================================================================
  // KiddingEvent
  // =========================================================================

  group('KiddingEvent', () {
    test('fromJson parses all fields', () {
      final r = KiddingEvent.fromJson({
        'id': 'kid-001',
        'damId': 'goat-002',
        'kiddingDate': '2024-08-15',
        'totalKidsBorn': 2,
        'kidsAliveBorn': 2,
        'kidsStillborn': 0,
        'birthWeights': [3.2, 3.0],
        'kidIds': ['goat-k1', 'goat-k2'],
        'assisted': true,
        'complications': 'Mild dystocia',
        'notes': 'Both kids healthy',
      });
      expect(r.totalKidsBorn, 2);
      expect(r.kidsAliveBorn, 2);
      expect(r.kidsStillborn, 0);
      expect(r.birthWeights.length, 2);
      expect(r.birthWeights[0], closeTo(3.2, 0.01));
      expect(r.kidIds, containsAll(['goat-k1', 'goat-k2']));
      expect(r.assisted, isTrue);
      expect(r.complications, 'Mild dystocia');
    });

    test('assisted defaults to false', () {
      final r = KiddingEvent.fromJson({
        'id': 'k2',
        'damId': 'd1',
        'kiddingDate': '2024-08-20',
        'totalKidsBorn': 1,
        'kidsAliveBorn': 1,
        'kidsStillborn': 0,
        'birthWeights': [],
        'kidIds': [],
      });
      expect(r.assisted, isFalse);
    });
  });

  // =========================================================================
  // DailyMilkRecord — totalLitres getter
  // =========================================================================

  group('DailyMilkRecord', () {
    test('fromJson parses all fields', () {
      final r = DailyMilkRecord.fromJson({
        'id': 'mlk-001',
        'animalId': 'goat-003',
        'date': '2024-06-01',
        'morningLitres': 1.8,
        'eveningLitres': 1.5,
        'lactationDay': 45,
        'notes': 'Normal production',
      });
      expect(r.morningLitres, closeTo(1.8, 0.01));
      expect(r.eveningLitres, closeTo(1.5, 0.01));
      expect(r.lactationDay, 45);
    });

    group('totalLitres', () {
      test('is sum of morning + evening', () {
        const r = DailyMilkRecord(
          id: 'm1',
          animalId: 'g1',
          date: '2024-01-01',
          morningLitres: 2.0,
          eveningLitres: 1.5,
          lactationDay: 10,
        );
        expect(r.totalLitres, closeTo(3.5, 0.01));
      });

      test('is 0 when both sessions are 0', () {
        const r = DailyMilkRecord(
          id: 'm2',
          animalId: 'g1',
          date: '2024-01-02',
          morningLitres: 0.0,
          eveningLitres: 0.0,
          lactationDay: 11,
        );
        expect(r.totalLitres, closeTo(0.0, 0.01));
      });
    });
  });

  // =========================================================================
  // ShearingRecord — totalRevenue getter
  // =========================================================================

  group('ShearingRecord', () {
    test('fromJson parses all fields', () {
      final r = ShearingRecord.fromJson({
        'id': 'sh-001',
        'animalId': 'goat-006',
        'shearingDate': '2024-05-15',
        'fleeceWeightKg': 2.8,
        'stapleLength': 95.0,
        'micron': 23.5,
        'colorGrade': 'white',
        'pricePerKg': 90.0,
        'notes': 'Good clip',
      });
      expect(r.fleeceWeightKg, closeTo(2.8, 0.01));
      expect(r.pricePerKg, closeTo(90.0, 0.01));
      expect(r.colorGrade, 'white');
    });

    group('totalRevenue', () {
      test('is fleeceWeightKg * pricePerKg when both present', () {
        const r = ShearingRecord(
          id: 'sh-2',
          animalId: 'g1',
          shearingDate: '2024-05-01',
          fleeceWeightKg: 3.0,
          pricePerKg: 80.0,
        );
        expect(r.totalRevenue, closeTo(240.0, 0.01));
      });

      test('is null when pricePerKg is null', () {
        const r = ShearingRecord(
          id: 'sh-3',
          animalId: 'g1',
          shearingDate: '2024-05-01',
          fleeceWeightKg: 3.0,
        );
        expect(r.totalRevenue, isNull);
      });
    });
  });

  // =========================================================================
  // GoatHealthEvent
  // =========================================================================

  group('GoatHealthEvent', () {
    test('fromJson parses all fields', () {
      final r = GoatHealthEvent.fromJson({
        'id': 'he-001',
        'animalId': 'goat-002',
        'date': '2024-06-10',
        'condition': 'Pasteurellosis',
        'severity': 'moderate',
        'treatment': 'Oxytetracycline 20mg/kg',
        'vet': 'Dr Smith',
        'outcome': 'resolved',
        'notes': 'Responded well',
      });
      expect(r.condition, 'Pasteurellosis');
      expect(r.severity, 'moderate');
      expect(r.treatment, 'Oxytetracycline 20mg/kg');
      expect(r.vet, 'Dr Smith');
      expect(r.outcome, 'resolved');
    });

    test('optional fields default to null', () {
      final r = GoatHealthEvent.fromJson({
        'id': 'he-2',
        'animalId': 'g1',
        'date': '2024-07-01',
        'condition': 'PPR',
        'severity': 'severe',
      });
      expect(r.treatment, isNull);
      expect(r.vet, isNull);
      expect(r.outcome, isNull);
    });
  });

  // =========================================================================
  // GoatMedicationLog — withdrawalExpiryDate getter
  // =========================================================================

  group('GoatMedicationLog', () {
    test('fromJson parses all fields', () {
      final r = GoatMedicationLog.fromJson({
        'id': 'med-001',
        'animalId': 'goat-001',
        'date': '2024-07-01',
        'drug': 'Penicillin',
        'dose': '10mg/kg',
        'route': 'injection',
        'reason': 'Respiratory infection',
        'withdrawalDays': 7,
        'administeredBy': 'user-001',
        'notes': 'Follow up in 3 days',
      });
      expect(r.drug, 'Penicillin');
      expect(r.withdrawalDays, 7);
      expect(r.route, 'injection');
    });

    group('withdrawalExpiryDate', () {
      test('adds withdrawalDays to date', () {
        const r = GoatMedicationLog(
          id: 'm1',
          animalId: 'g1',
          date: '2024-07-01',
          drug: 'Oxytet',
          dose: '20mg/kg',
          route: 'injection',
          withdrawalDays: 7,
        );
        expect(r.withdrawalExpiryDate, '2024-07-08');
      });

      test('returns null when withdrawalDays is null', () {
        const r = GoatMedicationLog(
          id: 'm2',
          animalId: 'g1',
          date: '2024-07-01',
          drug: 'Vitamin B',
          dose: '5ml',
          route: 'injection',
        );
        expect(r.withdrawalExpiryDate, isNull);
      });

      test('returns null when withdrawalDays is 0', () {
        const r = GoatMedicationLog(
          id: 'm3',
          animalId: 'g1',
          date: '2024-07-01',
          drug: 'Probiotics',
          dose: '10ml',
          route: 'oral',
          withdrawalDays: 0,
        );
        expect(r.withdrawalExpiryDate, isNull);
      });
    });
  });

  // =========================================================================
  // GoatVaccination
  // =========================================================================

  group('GoatVaccination', () {
    test('fromJson parses all fields', () {
      final r = GoatVaccination.fromJson({
        'id': 'vac-001',
        'animalId': 'goat-004',
        'vaccineName': 'Pasteurella vaccine',
        'dueDate': '2024-01-01',
        'givenDate': '2024-01-03',
        'batchNumber': 'BN2024-01',
        'nextDueDate': '2024-07-03',
        'administeredBy': 'farm-worker',
      });
      expect(r.vaccineName, 'Pasteurella vaccine');
      expect(r.givenDate, '2024-01-03');
      expect(r.batchNumber, 'BN2024-01');
    });

    group('isOverdue', () {
      test('false when givenDate is set', () {
        final r = GoatVaccination.fromJson({
          'id': 'v1',
          'animalId': 'g1',
          'vaccineName': 'Test',
          'dueDate': '2020-01-01',
          'givenDate': '2020-01-02',
        });
        expect(r.isOverdue, isFalse);
      });

      test('true when past due and not given', () {
        final r = GoatVaccination.fromJson({
          'id': 'v2',
          'animalId': 'g1',
          'vaccineName': 'Pasteurella',
          'dueDate': '2020-01-01',
        });
        expect(r.isOverdue, isTrue);
      });

      test('false when due in future and not given', () {
        final r = GoatVaccination.fromJson({
          'id': 'v3',
          'animalId': 'g1',
          'vaccineName': 'CDT',
          'dueDate': '2099-01-01',
        });
        expect(r.isOverdue, isFalse);
      });
    });

    group('isGiven', () {
      test('true when givenDate is set', () {
        final r = GoatVaccination.fromJson({
          'id': 'v4',
          'animalId': 'g1',
          'vaccineName': 'T',
          'dueDate': '2024-01-01',
          'givenDate': '2024-01-02',
        });
        expect(r.isGiven, isTrue);
      });

      test('false when givenDate is null', () {
        final r = GoatVaccination.fromJson({
          'id': 'v5',
          'animalId': 'g1',
          'vaccineName': 'T',
          'dueDate': '2024-01-01',
        });
        expect(r.isGiven, isFalse);
      });
    });
  });

  // =========================================================================
  // BodyConditionRecord
  // =========================================================================

  group('BodyConditionRecord', () {
    test('fromJson parses all fields', () {
      final r = BodyConditionRecord.fromJson({
        'id': 'bcs-001',
        'animalId': 'goat-001',
        'date': '2024-05-01',
        'score': 2.5,
        'notes': 'Thin — increase feed',
      });
      expect(r.score, closeTo(2.5, 0.01));
      expect(r.notes, 'Thin — increase feed');
    });
  });

  // =========================================================================
  // GoatSaleRecord
  // =========================================================================

  group('GoatSaleRecord', () {
    test('fromJson parses all fields', () {
      final r = GoatSaleRecord.fromJson({
        'id': 'sale-001',
        'animalId': 'goat-007',
        'saleDate': '2024-07-01',
        'buyerName': 'J. Theron',
        'saleWeightKg': 40.0,
        'pricePerKg': 55.0,
        'totalRevenue': 2200.0,
        'invoiceRef': 'INV-001',
        'notes': 'Abattoir sale',
      });
      expect(r.buyerName, 'J. Theron');
      expect(r.totalRevenue, closeTo(2200.0, 0.01));
      expect(r.invoiceRef, 'INV-001');
    });
  });

  // =========================================================================
  // GoatFeedRecord — totalCost getter
  // =========================================================================

  group('GoatFeedRecord', () {
    test('fromJson parses all fields', () {
      final r = GoatFeedRecord.fromJson({
        'id': 'feed-001',
        'herdId': 'herd-a',
        'date': '2024-05-01',
        'feedType': 'lucerne hay',
        'quantityKg': 50.0,
        'costPerKg': 4.5,
        'notes': 'Supplement during drought',
      });
      expect(r.feedType, 'lucerne hay');
      expect(r.quantityKg, closeTo(50.0, 0.01));
      expect(r.costPerKg, closeTo(4.5, 0.01));
    });

    group('totalCost', () {
      test('is quantityKg * costPerKg when both present', () {
        const r = GoatFeedRecord(
          id: 'f1',
          herdId: 'h1',
          date: '2024-01-01',
          feedType: 'maize',
          quantityKg: 20.0,
          costPerKg: 6.0,
        );
        expect(r.totalCost, closeTo(120.0, 0.01));
      });

      test('is null when costPerKg is null', () {
        const r = GoatFeedRecord(
          id: 'f2',
          herdId: 'h1',
          date: '2024-01-01',
          feedType: 'veld grass',
          quantityKg: 30.0,
        );
        expect(r.totalCost, isNull);
      });
    });
  });

  // =========================================================================
  // PastureRecord
  // =========================================================================

  group('PastureRecord', () {
    test('fromJson parses all fields', () {
      final r = PastureRecord.fromJson({
        'id': 'pas-001',
        'herdId': 'herd-a',
        'campId': 'camp-1',
        'entryDate': '2024-05-01',
        'exitDate': '2024-05-14',
        'estimatedHa': 12.5,
        'veldCondition': 'good',
        'notes': 'Resting after previous rotation',
      });
      expect(r.campId, 'camp-1');
      expect(r.estimatedHa, closeTo(12.5, 0.01));
      expect(r.veldCondition, 'good');
      expect(r.exitDate, '2024-05-14');
    });

    test('exitDate nullable', () {
      final r = PastureRecord.fromJson({
        'id': 'p2',
        'herdId': 'h1',
        'campId': 'c1',
        'entryDate': '2024-06-01',
      });
      expect(r.exitDate, isNull);
    });
  });

  // =========================================================================
  // FamachaRecord
  // =========================================================================

  group('FamachaRecord', () {
    test('fromJson parses all fields', () {
      final r = FamachaRecord.fromJson({
        'id': 'fam-001',
        'animalId': 'goat-008',
        'date': '2024-06-15',
        'score': 4,
        'actionTaken': 'Deworm with Closantel',
        'notes': 'Severe anaemia suspected',
      });
      expect(r.score, 4);
      expect(r.actionTaken, 'Deworm with Closantel');
    });

    test('scores 1-5 are valid integers', () {
      for (var score = 1; score <= 5; score++) {
        final r = FamachaRecord.fromJson({
          'id': 'fam-s$score',
          'animalId': 'g1',
          'date': '2024-01-01',
          'score': score,
        });
        expect(r.score, score);
      }
    });
  });
}
