// Unit tests for events models — BreedingEvent, WeightRecord, HealthEvent.
// Covers fromJson, copyWith, and computed getters.

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/events/models/breeding_event.dart';
import 'package:mobile_app/features/events/models/health_event.dart';
import 'package:mobile_app/features/events/models/weight_record.dart';

void main() {
  // ── BreedingEvent ─────────────────────────────────────────────────────────

  group('BreedingEvent', () {
    final base = BreedingEvent(
      id: 'be1',
      animalId: 'a1',
      animalType: 'cattle',
      eventType: 'natural_mating',
      serviceDate: '2024-03-01',
      sireName: 'Bull A',
      sireBreed: 'Angus',
      expectedBirthDate: '2024-12-01',
      pregnancyResult: 'confirmed',
      notes: 'Healthy',
    );

    test('fromJson parses all fields', () {
      final json = {
        'id': 'be1',
        'animal_id': 'a1',
        'animal_type': 'cattle',
        'event_type': 'natural_mating',
        'service_date': '2024-03-01',
        'sire_name': 'Bull A',
        'sire_breed': 'Angus',
        'expected_birth_date': '2024-12-01',
        'pregnancy_result': 'confirmed',
        'notes': 'Healthy',
      };
      final event = BreedingEvent.fromJson(json);
      expect(event.id, 'be1');
      expect(event.animalId, 'a1');
      expect(event.animalType, 'cattle');
      expect(event.eventType, 'natural_mating');
      expect(event.sireName, 'Bull A');
      expect(event.sireBreed, 'Angus');
      expect(event.expectedBirthDate, '2024-12-01');
      expect(event.pregnancyResult, 'confirmed');
      expect(event.notes, 'Healthy');
    });

    test('fromJson handles missing optional fields', () {
      final event = BreedingEvent.fromJson({
        'id': 'be2',
        'animal_id': 'a2',
        'animal_type': 'sheep',
        'event_type': 'ai',
        'service_date': '2024-04-01',
      });
      expect(event.sireName, isNull);
      expect(event.sireBreed, isNull);
      expect(event.pregnancyResult, isNull);
      expect(event.notes, isNull);
    });

    test('displayType formats event type', () {
      expect(base.displayType, 'NATURAL MATING');
    });

    test('copyWith returns same values when no override', () {
      final copy = base.copyWith();
      expect(copy.id, base.id);
      expect(copy.animalId, base.animalId);
      expect(copy.eventType, base.eventType);
      expect(copy.sireName, base.sireName);
    });

    test('copyWith overrides specific fields', () {
      final copy = base.copyWith(
        pregnancyResult: 'negative',
        notes: 'Re-check needed',
      );
      expect(copy.pregnancyResult, 'negative');
      expect(copy.notes, 'Re-check needed');
      expect(copy.id, base.id);
      expect(copy.sireName, base.sireName);
    });
  });

  // ── WeightRecord ──────────────────────────────────────────────────────────

  group('WeightRecord', () {
    final base = WeightRecord(
      id: 'wr1',
      animalId: 'a1',
      animalType: 'cattle',
      weighDate: '2024-01-15',
      weightKg: 350.5,
      bodyConditionScore: 3,
      adgSinceLastKg: 0.8,
      method: 'scale',
      notes: 'Healthy',
    );

    test('fromJson parses numeric fields correctly', () {
      final json = {
        'id': 'wr1',
        'animal_id': 'a1',
        'animal_type': 'cattle',
        'weigh_date': '2024-01-15',
        'weight_kg': 350,
        'body_condition_score': 3,
        'adg_since_last_kg': 0.8,
        'method': 'scale',
        'notes': 'Healthy',
      };
      final r = WeightRecord.fromJson(json);
      expect(r.weightKg, 350.0);
      expect(r.bodyConditionScore, 3);
      expect(r.adgSinceLastKg, 0.8);
    });

    test('fromJson handles missing optional fields', () {
      final r = WeightRecord.fromJson({
        'id': 'wr2',
        'animal_id': 'a2',
        'animal_type': 'sheep',
        'weigh_date': '2024-02-01',
        'weight_kg': 45.0,
      });
      expect(r.bodyConditionScore, isNull);
      expect(r.adgSinceLastKg, isNull);
      expect(r.method, isNull);
      expect(r.notes, isNull);
    });

    test('copyWith returns same values when no override', () {
      final copy = base.copyWith();
      expect(copy.id, base.id);
      expect(copy.weightKg, base.weightKg);
      expect(copy.bodyConditionScore, base.bodyConditionScore);
    });

    test('copyWith overrides specific fields', () {
      final copy = base.copyWith(weightKg: 360.0, notes: 'Updated');
      expect(copy.weightKg, 360.0);
      expect(copy.notes, 'Updated');
      expect(copy.id, base.id);
      expect(copy.animalId, base.animalId);
    });
  });

  // ── HealthEvent ───────────────────────────────────────────────────────────

  group('HealthEvent', () {
    const base = HealthEvent(
      id: 'he1',
      animalId: 'a1',
      animalType: 'cattle',
      eventType: 'vaccination',
      eventDate: '2024-02-10',
      productName: 'Multivax',
      withdrawalDays: 21,
      withdrawalEndDate: '2099-12-31',
      famachaScore: 2,
      isNotifiable: false,
    );

    test('displayType formats correctly', () {
      expect(base.displayType, 'VACCINATION');
    });

    test('isWithdrawalActive is true for future end date', () {
      expect(base.isWithdrawalActive, isTrue);
    });

    test('isWithdrawalActive is false when withdrawalEndDate is null', () {
      const event = HealthEvent(
        id: 'he2',
        animalId: 'a2',
        animalType: 'cattle',
        eventType: 'treatment',
        eventDate: '2024-01-01',
      );
      expect(event.isWithdrawalActive, isFalse);
    });

    test('displayFamachaScore returns correct label', () {
      const event2 = HealthEvent(
        id: 'he3',
        animalId: 'a3',
        animalType: 'sheep',
        eventType: 'famacha',
        eventDate: '2024-03-01',
        famachaScore: 4,
      );
      expect(event2.displayFamachaScore, contains('Treat'));
    });

    test('copyWith returns same values when no override', () {
      final copy = base.copyWith();
      expect(copy.id, base.id);
      expect(copy.productName, base.productName);
      expect(copy.famachaScore, base.famachaScore);
    });

    test('copyWith overrides specific fields', () {
      final copy = base.copyWith(
        isNotifiable: true,
        notifiableDisease: NotifiableDisease.footAndMouth,
        daffReportRef: 'DAFF-2024-001',
      );
      expect(copy.isNotifiable, isTrue);
      expect(copy.notifiableDisease, NotifiableDisease.footAndMouth);
      expect(copy.daffReportRef, 'DAFF-2024-001');
      expect(copy.id, base.id);
      expect(copy.famachaScore, base.famachaScore);
    });
  });
}
