import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/cattle/models/cattle_records.dart';

void main() {
  // ── WeightRecord ──────────────────────────────────────────────────────────

  group('WeightRecord', () {
    test('fromJson / toJson round-trip', () {
      final json = {
        'id': 'wr1',
        'animalId': 'a1',
        'date': '2024-01-15',
        'weightKg': 350.5,
        'bodyConditionScore': 3.0,
        'notes': 'Monthly weigh-in',
      };
      final record = WeightRecord.fromJson(json);
      expect(record.id, 'wr1');
      expect(record.animalId, 'a1');
      expect(record.date, '2024-01-15');
      expect(record.weightKg, 350.5);
      expect(record.bodyConditionScore, 3.0);
      expect(record.notes, 'Monthly weigh-in');

      final back = record.toJson();
      expect(back['id'], 'wr1');
      expect(back['weightKg'], 350.5);
    });

    test('optional fields are null when absent', () {
      final record = WeightRecord.fromJson({
        'id': 'wr2',
        'animalId': 'a1',
        'date': '2024-01-15',
        'weightKg': 300.0,
      });
      expect(record.bodyConditionScore, isNull);
      expect(record.notes, isNull);
    });
  });

  // ── BreedingRecord ────────────────────────────────────────────────────────

  group('BreedingRecord', () {
    test('fromJson / toJson round-trip', () {
      final json = {
        'id': 'br1',
        'cowId': 'cow1',
        'bullId': 'bull1',
        'serviceDate': '2024-03-10',
        'serviceMethod': 'natural',
        'semenSource': 'Bull A',
        'technician': 'John',
        'expectedCalvingDate': '2024-12-10',
        'outcome': 'confirmed',
        'notes': 'First service',
      };
      final record = BreedingRecord.fromJson(json);
      expect(record.id, 'br1');
      expect(record.cowId, 'cow1');
      expect(record.bullId, 'bull1');
      expect(record.serviceDate, '2024-03-10');
      expect(record.serviceMethod, 'natural');
      expect(record.expectedCalvingDate, '2024-12-10');
      expect(record.outcome, 'confirmed');

      final back = record.toJson();
      expect(back['cowId'], 'cow1');
      expect(back['serviceMethod'], 'natural');
    });

    test('optional fields are null when absent', () {
      final record = BreedingRecord.fromJson({
        'id': 'br2',
        'cowId': 'cow1',
        'bullId': 'bull1',
        'serviceDate': '2024-03-10',
        'serviceMethod': 'AI',
      });
      expect(record.semenSource, isNull);
      expect(record.technician, isNull);
      expect(record.expectedCalvingDate, isNull);
      expect(record.outcome, isNull);
    });
  });

  // ── PregnancyCheck ────────────────────────────────────────────────────────

  group('PregnancyCheck', () {
    test('fromJson / toJson round-trip', () {
      final json = {
        'id': 'pc1',
        'animalId': 'a1',
        'date': '2024-04-01',
        'method': 'rectal palpation',
        'result': 'positive',
        'expectedCalvingDate': '2025-01-10',
        'daysPregnant': 60,
        'checkedBy': 'Dr Smith',
        'notes': 'No issues',
      };
      final check = PregnancyCheck.fromJson(json);
      expect(check.id, 'pc1');
      expect(check.method, 'rectal palpation');
      expect(check.result, 'positive');
      expect(check.daysPregnant, 60);
      expect(check.checkedBy, 'Dr Smith');

      final back = check.toJson();
      expect(back['result'], 'positive');
    });

    test('optional fields are null when absent', () {
      final check = PregnancyCheck.fromJson({
        'id': 'pc2',
        'animalId': 'a1',
        'date': '2024-04-01',
        'method': 'ultrasound',
        'result': 'negative',
      });
      expect(check.expectedCalvingDate, isNull);
      expect(check.daysPregnant, isNull);
      expect(check.checkedBy, isNull);
    });
  });

  // ── CalvingEvent ──────────────────────────────────────────────────────────

  group('CalvingEvent', () {
    test('fromJson / toJson round-trip', () {
      final json = {
        'id': 'ce1',
        'damId': 'cow1',
        'calvingDate': '2024-11-20',
        'calvingEase': 'normal',
        'calfAlive': true,
        'calfId': 'calf1',
        'calfSex': 'heifer',
        'calfWeightKg': 32.0,
        'complications': null,
        'notes': 'Smooth delivery',
      };
      final event = CalvingEvent.fromJson(json);
      expect(event.id, 'ce1');
      expect(event.damId, 'cow1');
      expect(event.calvingEase, 'normal');
      expect(event.calfAlive, isTrue);
      expect(event.calfSex, 'heifer');
      expect(event.calfWeightKg, 32.0);

      final back = event.toJson();
      expect(back['calfAlive'], isTrue);
    });

    test('calfAlive defaults to true when key is absent', () {
      final event = CalvingEvent.fromJson({
        'id': 'ce2',
        'damId': 'cow1',
        'calvingDate': '2024-11-20',
        'calvingEase': 'assisted',
        // calfAlive is intentionally absent
      });
      expect(event.calfAlive, isTrue);
    });

    test('calfAlive is false when explicitly false', () {
      final event = CalvingEvent.fromJson({
        'id': 'ce3',
        'damId': 'cow1',
        'calvingDate': '2024-11-20',
        'calvingEase': 'difficult',
        'calfAlive': false,
      });
      expect(event.calfAlive, isFalse);
    });
  });

  // ── DailyMilkRecord ───────────────────────────────────────────────────────

  group('DailyMilkRecord', () {
    test('fromJson / toJson round-trip', () {
      final json = {
        'id': 'dm1',
        'animalId': 'cow1',
        'date': '2024-06-01',
        'morningLitres': 8.5,
        'eveningLitres': 7.0,
        'lactationDay': 45,
        'qualityFlag': null,
        'notes': null,
      };
      final record = DailyMilkRecord.fromJson(json);
      expect(record.morningLitres, 8.5);
      expect(record.eveningLitres, 7.0);
      expect(record.lactationDay, 45);

      final back = record.toJson();
      expect(back['morningLitres'], 8.5);
    });

    test('totalLitres = morningLitres + eveningLitres', () {
      final record = DailyMilkRecord.fromJson({
        'id': 'dm2',
        'animalId': 'cow1',
        'date': '2024-06-01',
        'morningLitres': 8.5,
        'eveningLitres': 7.0,
        'lactationDay': 45,
      });
      expect(record.totalLitres, closeTo(15.5, 0.001));
    });

    test('totalLitres = morningLitres when eveningLitres is absent', () {
      final record = DailyMilkRecord.fromJson({
        'id': 'dm3',
        'animalId': 'cow1',
        'date': '2024-06-01',
        'morningLitres': 10.0,
        'lactationDay': 10,
      });
      expect(record.eveningLitres, isNull);
      expect(record.totalLitres, closeTo(10.0, 0.001));
    });
  });

  // ── CattleHealthEvent ─────────────────────────────────────────────────────

  group('CattleHealthEvent', () {
    test('fromJson / toJson round-trip', () {
      final json = {
        'id': 'he1',
        'animalId': 'a1',
        'date': '2024-05-10',
        'eventType': 'illness',
        'diagnosis': 'Foot and Mouth Disease',
        'severity': 'critical',
        'treatedBy': 'Dr Jones',
        'isNotifiable': true,
        'outcome': 'recovered',
        'notes': 'Reported to state vet',
      };
      final event = CattleHealthEvent.fromJson(json);
      expect(event.diagnosis, 'Foot and Mouth Disease');
      expect(event.severity, 'critical');
      expect(event.isNotifiable, isTrue);
      expect(event.outcome, 'recovered');

      final back = event.toJson();
      expect(back['isNotifiable'], isTrue);
    });

    test('isNotifiable defaults to false when absent', () {
      final event = CattleHealthEvent.fromJson({
        'id': 'he2',
        'animalId': 'a1',
        'date': '2024-05-10',
        'eventType': 'routine',
        'diagnosis': 'Mild lameness',
        'severity': 'low',
      });
      expect(event.isNotifiable, isFalse);
    });
  });

  // ── CattleMedicationLog ───────────────────────────────────────────────────

  group('CattleMedicationLog', () {
    test('fromJson / toJson round-trip', () {
      final json = {
        'id': 'ml1',
        'animalId': 'a1',
        'date': '2024-01-01',
        'medicationName': 'Terramycin LA',
        'route': 'injection',
        'doseMg': 200.0,
        'withdrawalDaysMeat': 14,
        'withdrawalDaysMilk': 7,
        'veterinarianApproved': true,
        'administeredBy': 'Farmer Joe',
        'notes': null,
      };
      final log = CattleMedicationLog.fromJson(json);
      expect(log.medicationName, 'Terramycin LA');
      expect(log.doseMg, 200.0);
      expect(log.withdrawalDaysMeat, 14);
      expect(log.withdrawalDaysMilk, 7);
      expect(log.veterinarianApproved, isTrue);

      final back = log.toJson();
      expect(back['medicationName'], 'Terramycin LA');
    });

    test('withdrawalExpiryDateMeat is date + withdrawalDaysMeat', () {
      final log = CattleMedicationLog.fromJson({
        'id': 'ml2',
        'animalId': 'a1',
        'date': '2024-01-01',
        'medicationName': 'Drug X',
        'route': 'oral',
        'doseMg': 50.0,
        'withdrawalDaysMeat': 14,
      });
      // 2024-01-01 + 14 days = 2024-01-15
      expect(log.withdrawalExpiryDateMeat, '2024-01-15');
    });

    test('withdrawalExpiryDateMilk is date + withdrawalDaysMilk', () {
      final log = CattleMedicationLog.fromJson({
        'id': 'ml3',
        'animalId': 'a1',
        'date': '2024-01-01',
        'medicationName': 'Drug Y',
        'route': 'injection',
        'doseMg': 100.0,
        'withdrawalDaysMilk': 5,
      });
      // 2024-01-01 + 5 days = 2024-01-06
      expect(log.withdrawalExpiryDateMilk, '2024-01-06');
    });

    test('withdrawal expiry is null when withdrawal days absent', () {
      final log = CattleMedicationLog.fromJson({
        'id': 'ml4',
        'animalId': 'a1',
        'date': '2024-01-01',
        'medicationName': 'Vitamin B',
        'route': 'oral',
        'doseMg': 10.0,
      });
      expect(log.withdrawalExpiryDateMeat, isNull);
      expect(log.withdrawalExpiryDateMilk, isNull);
    });
  });

  // ── CattleVaccination ─────────────────────────────────────────────────────

  group('CattleVaccination', () {
    test('fromJson / toJson round-trip', () {
      final json = {
        'id': 'vac1',
        'animalId': 'a1',
        'vaccineName': 'Lumpy Skin',
        'dueDate': '2024-06-01',
        'givenDate': '2024-06-01',
        'batchNumber': 'B001',
        'nextDueDate': '2025-06-01',
        'route': 'subcutaneous',
        'siteOnBody': 'neck',
        'administeredBy': 'Vet',
      };
      final vac = CattleVaccination.fromJson(json);
      expect(vac.vaccineName, 'Lumpy Skin');
      expect(vac.givenDate, '2024-06-01');
      expect(vac.batchNumber, 'B001');

      final back = vac.toJson();
      expect(back['vaccineName'], 'Lumpy Skin');
    });

    test('isGiven is true when givenDate is not null', () {
      final vac = CattleVaccination.fromJson({
        'id': 'vac2',
        'animalId': 'a1',
        'vaccineName': 'Anthrax',
        'dueDate': '2024-05-01',
        'givenDate': '2024-05-02',
      });
      expect(vac.isGiven, isTrue);
    });

    test('isGiven is false when givenDate is null', () {
      final vac = CattleVaccination.fromJson({
        'id': 'vac3',
        'animalId': 'a1',
        'vaccineName': 'Anthrax',
        'dueDate': '2024-05-01',
      });
      expect(vac.isGiven, isFalse);
    });

    test('isOverdue is true when dueDate is past and not given', () {
      // Use a date well in the past
      final vac = CattleVaccination.fromJson({
        'id': 'vac4',
        'animalId': 'a1',
        'vaccineName': 'Brucella',
        'dueDate': '2020-01-01',
      });
      expect(vac.isOverdue, isTrue);
    });

    test('isOverdue is false when vaccine has been given', () {
      final vac = CattleVaccination.fromJson({
        'id': 'vac5',
        'animalId': 'a1',
        'vaccineName': 'Brucella',
        'dueDate': '2020-01-01',
        'givenDate': '2020-01-03',
      });
      expect(vac.isOverdue, isFalse);
    });
  });

  // ── CattleSaleRecord ──────────────────────────────────────────────────────

  group('CattleSaleRecord', () {
    test('fromJson / toJson round-trip', () {
      final json = {
        'id': 'sr1',
        'animalId': 'a1',
        'saleDate': '2024-08-15',
        'buyerName': 'Farmer Brown',
        'saleWeightKg': 480.0,
        'pricePerKg': 35.0,
        'totalAmount': 16800.0,
        'transportCost': 500.0,
        'permitNumber': 'P-123',
        'invoiceRef': 'INV-001',
        'notes': 'Good price',
      };
      final sale = CattleSaleRecord.fromJson(json);
      expect(sale.buyerName, 'Farmer Brown');
      expect(sale.totalAmount, 16800.0);
      expect(sale.transportCost, 500.0);

      final back = sale.toJson();
      expect(back['buyerName'], 'Farmer Brown');
    });

    test('netRevenue = totalAmount - transportCost', () {
      final sale = CattleSaleRecord.fromJson({
        'id': 'sr2',
        'animalId': 'a1',
        'saleDate': '2024-08-15',
        'buyerName': 'Buyer X',
        'totalAmount': 16800.0,
        'transportCost': 500.0,
      });
      expect(sale.netRevenue, closeTo(16300.0, 0.001));
    });

    test('netRevenue equals totalAmount when no transportCost', () {
      final sale = CattleSaleRecord.fromJson({
        'id': 'sr3',
        'animalId': 'a1',
        'saleDate': '2024-08-15',
        'buyerName': 'Buyer Y',
        'totalAmount': 12000.0,
      });
      expect(sale.netRevenue, closeTo(12000.0, 0.001));
    });
  });

  // ── CattleFeedRecord ──────────────────────────────────────────────────────

  group('CattleFeedRecord', () {
    test('fromJson / toJson round-trip', () {
      final json = {
        'id': 'fr1',
        'animalId': 'a1',
        'date': '2024-07-01',
        'feedType': 'maize',
        'quantityKg': 5.0,
        'costPerKg': 3.50,
        'feedlotPenId': 'pen1',
        'rationName': 'Ration A',
        'notes': null,
      };
      final record = CattleFeedRecord.fromJson(json);
      expect(record.feedType, 'maize');
      expect(record.quantityKg, 5.0);
      expect(record.costPerKg, 3.5);

      final back = record.toJson();
      expect(back['feedType'], 'maize');
    });

    test('totalCost = quantityKg * costPerKg', () {
      final record = CattleFeedRecord.fromJson({
        'id': 'fr2',
        'animalId': 'a1',
        'date': '2024-07-01',
        'feedType': 'hay',
        'quantityKg': 10.0,
        'costPerKg': 2.0,
      });
      expect(record.totalCost, closeTo(20.0, 0.001));
    });

    test('totalCost is null when costPerKg is absent', () {
      final record = CattleFeedRecord.fromJson({
        'id': 'fr3',
        'animalId': 'a1',
        'date': '2024-07-01',
        'feedType': 'grass',
        'quantityKg': 20.0,
      });
      expect(record.costPerKg, isNull);
      expect(record.totalCost, isNull);
    });
  });

  // ── PastureRecord ─────────────────────────────────────────────────────────

  group('PastureRecord', () {
    test('fromJson / toJson round-trip', () {
      final json = {
        'id': 'pr1',
        'herdId': 'herd1',
        'campId': 'camp1',
        'entryDate': '2024-09-01',
        'exitDate': '2024-09-14',
        'estimatedHa': 50.0,
        'veldCondition': 'good',
        'notes': 'Rotated on schedule',
      };
      final record = PastureRecord.fromJson(json);
      expect(record.herdId, 'herd1');
      expect(record.campId, 'camp1');
      expect(record.entryDate, '2024-09-01');
      expect(record.exitDate, '2024-09-14');
      expect(record.estimatedHa, 50.0);
      expect(record.veldCondition, 'good');

      final back = record.toJson();
      expect(back['campId'], 'camp1');
    });

    test('optional fields are null when absent', () {
      final record = PastureRecord.fromJson({
        'id': 'pr2',
        'herdId': 'herd1',
        'campId': 'camp2',
        'entryDate': '2024-09-01',
      });
      expect(record.exitDate, isNull);
      expect(record.estimatedHa, isNull);
      expect(record.veldCondition, isNull);
    });
  });

  // ── BodyConditionRecord ───────────────────────────────────────────────────

  group('BodyConditionRecord', () {
    test('fromJson / toJson round-trip', () {
      final json = {
        'id': 'bcs1',
        'animalId': 'a1',
        'date': '2024-04-15',
        'score': 3.5,
        'assessedBy': 'Farmer Joe',
        'notes': 'Good condition',
      };
      final record = BodyConditionRecord.fromJson(json);
      expect(record.score, 3.5);
      expect(record.assessedBy, 'Farmer Joe');

      final back = record.toJson();
      expect(back['score'], 3.5);
    });

    test('score stored correctly across range', () {
      for (final score in [1.0, 2.5, 3.0, 4.0, 5.0]) {
        final record = BodyConditionRecord.fromJson({
          'id': 'bcs',
          'animalId': 'a1',
          'date': '2024-01-01',
          'score': score,
        });
        expect(record.score, closeTo(score, 0.001));
      }
    });
  });

  // ── DippingRecord ─────────────────────────────────────────────────────────

  group('DippingRecord', () {
    test('fromJson / toJson round-trip', () {
      final json = {
        'id': 'dip1',
        'animalId': 'a1',
        'dippingDate': '2024-01-01',
        'productUsed': 'Triatix',
        'concentration': '0.05%',
        'method': 'spray',
        'nextDueDays': 14,
        'veterinarianApproved': true,
        'notes': 'Full herd',
      };
      final record = DippingRecord.fromJson(json);
      expect(record.productUsed, 'Triatix');
      expect(record.concentration, '0.05%');
      expect(record.method, 'spray');
      expect(record.nextDueDays, 14);
      expect(record.veterinarianApproved, isTrue);

      final back = record.toJson();
      expect(back['productUsed'], 'Triatix');
    });

    test('nextDueDate = dippingDate + nextDueDays', () {
      final record = DippingRecord.fromJson({
        'id': 'dip2',
        'animalId': 'a1',
        'dippingDate': '2024-01-01',
        'productUsed': 'Triatix',
        'concentration': '0.05%',
        'method': 'dip tank',
        'nextDueDays': 14,
      });
      // 2024-01-01 + 14 days = 2024-01-15
      expect(record.nextDueDate, '2024-01-15');
    });

    test('nextDueDate with 30-day interval', () {
      final record = DippingRecord.fromJson({
        'id': 'dip3',
        'animalId': 'a1',
        'dippingDate': '2024-03-01',
        'productUsed': 'Amitraz',
        'concentration': '0.04%',
        'method': 'spray',
        'nextDueDays': 30,
      });
      // 2024-03-01 + 30 days = 2024-03-31
      expect(record.nextDueDate, '2024-03-31');
    });
  });
}
