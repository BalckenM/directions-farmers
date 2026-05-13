// Unit tests for all supporting models used by the poultry module:
//   DailyRecord, FeedPhase, FeedPhaseType, HarvestRecord, VaccineItem,
//   VaccinationSchedule, MedicationLog, DiseaseEvent, EnvironmentReading,
//   EggSale, ChickSale, MortalityCause
//
// These are pure Dart unit tests — no Flutter binding or rootBundle required.

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/poultry/models/flock.dart';

void main() {
  // =========================================================================
  // DailyRecord
  // =========================================================================

  group('DailyRecord', () {
    test('fromJson parses all fields correctly', () {
      final r = DailyRecord.fromJson({
        'id': 'dr-001',
        'flock_id': 'flock-001',
        'date': '2024-03-15',
        'day_of_age': 14,
        'mortality_count': 5,
        'mortality_cause': 'sds',
        'culls': 2,
        'feed_consumed_kg': 850.5,
        'water_consumed_litres': 1600.0,
        'feed_type': 'starter',
        'avg_house_temp_c': 28.0,
        'avg_body_weight_g': 320,
        'eggs_collected_am': 3200,
        'eggs_collected_pm': 3100,
        'broken_eggs': 20,
        'floor_eggs': 15,
        'avg_egg_weight_g': 58.5,
        'hdp_pct': 82.5,
        'eggs_jumbo': 100,
        'eggs_extra_large': 500,
        'eggs_large': 2000,
        'eggs_medium': 3500,
        'eggs_small': 200,
        'eggs_peewee': 0,
        'notes': 'Normal day',
        'recorded_by': 'user-001',
      });

      expect(r.id, 'dr-001');
      expect(r.flockId, 'flock-001');
      expect(r.date, '2024-03-15');
      expect(r.dayOfAge, 14);
      expect(r.mortalityCount, 5);
      expect(r.mortalityCause, 'sds');
      expect(r.culls, 2);
      expect(r.feedConsumedKg, closeTo(850.5, 0.01));
      expect(r.waterConsumedLitres, closeTo(1600.0, 0.01));
      expect(r.feedType, 'starter');
      expect(r.avgHouseTempC, closeTo(28.0, 0.01));
      expect(r.avgBodyWeightG, 320);
      expect(r.eggsCollectedAm, 3200);
      expect(r.eggsCollectedPm, 3100);
      expect(r.brokenEggs, 20);
      expect(r.floorEggs, 15);
      expect(r.avgEggWeightG, closeTo(58.5, 0.01));
      expect(r.hdpPct, closeTo(82.5, 0.01));
      expect(r.eggsJumbo, 100);
      expect(r.eggsExtraLarge, 500);
      expect(r.eggsLarge, 2000);
      expect(r.eggsMedium, 3500);
      expect(r.eggsSmall, 200);
      expect(r.eggsPeewee, 0);
      expect(r.notes, 'Normal day');
      expect(r.recordedBy, 'user-001');
    });

    group('totalEggs', () {
      test('is sum of am + pm eggs', () {
        const r = DailyRecord(
          id: 'r1',
          flockId: 'f1',
          date: '2024-01-01',
          eggsCollectedAm: 3000,
          eggsCollectedPm: 2800,
        );
        expect(r.totalEggs, 5800);
      });

      test('is 0 when both null (broiler record)', () {
        const r = DailyRecord(id: 'r2', flockId: 'f1', date: '2024-01-01');
        expect(r.totalEggs, 0);
      });

      test('handles null am, non-null pm', () {
        const r = DailyRecord(
          id: 'r3',
          flockId: 'f1',
          date: '2024-01-01',
          eggsCollectedPm: 1500,
        );
        expect(r.totalEggs, 1500);
      });

      test('handles non-null am, null pm', () {
        const r = DailyRecord(
          id: 'r4',
          flockId: 'f1',
          date: '2024-01-01',
          eggsCollectedAm: 2200,
        );
        expect(r.totalEggs, 2200);
      });
    });

    group('isLayerRecord', () {
      test('true when eggsCollectedAm is set', () {
        const r = DailyRecord(
          id: 'r1',
          flockId: 'f1',
          date: '2024-01-01',
          eggsCollectedAm: 3000,
        );
        expect(r.isLayerRecord, isTrue);
      });

      test('true when eggsCollectedPm is set', () {
        const r = DailyRecord(
          id: 'r2',
          flockId: 'f1',
          date: '2024-01-01',
          eggsCollectedPm: 2000,
        );
        expect(r.isLayerRecord, isTrue);
      });

      test('false when neither am nor pm eggs are set (broiler)', () {
        const r = DailyRecord(id: 'r3', flockId: 'f1', date: '2024-01-01');
        expect(r.isLayerRecord, isFalse);
      });
    });

    group('gradedEggs & hasGrading', () {
      test('gradedEggs is sum of all grade counts', () {
        const r = DailyRecord(
          id: 'r1',
          flockId: 'f1',
          date: '2024-01-01',
          eggsJumbo: 100,
          eggsExtraLarge: 200,
          eggsLarge: 500,
          eggsMedium: 800,
          eggsSmall: 50,
          eggsPeewee: 10,
        );
        expect(r.gradedEggs, 1660);
      });

      test('hasGrading true when grade counts are non-zero', () {
        const r = DailyRecord(
          id: 'r2',
          flockId: 'f1',
          date: '2024-01-01',
          eggsLarge: 400,
        );
        expect(r.hasGrading, isTrue);
      });

      test('hasGrading false when all grade counts are null/zero', () {
        const r = DailyRecord(id: 'r3', flockId: 'f1', date: '2024-01-01');
        expect(r.hasGrading, isFalse);
      });

      test('hasGrading false when all grades explicitly zero', () {
        const r = DailyRecord(
          id: 'r4',
          flockId: 'f1',
          date: '2024-01-01',
          eggsJumbo: 0,
          eggsExtraLarge: 0,
          eggsLarge: 0,
          eggsMedium: 0,
          eggsSmall: 0,
          eggsPeewee: 0,
        );
        expect(r.hasGrading, isFalse);
      });
    });
  });

  // =========================================================================
  // FeedPhaseType
  // =========================================================================

  group('FeedPhaseType', () {
    test('forProductionType returns layer/breeder phases for "layer"', () {
      final phases = FeedPhaseType.forProductionType('layer');
      expect(phases, containsAll([
        FeedPhaseType.starter,
        FeedPhaseType.pulletRearer,
        FeedPhaseType.layingMash,
      ]));
      expect(phases, isNot(contains(FeedPhaseType.grower)));
      expect(phases, isNot(contains(FeedPhaseType.finisher)));
    });

    test('forProductionType returns layer/breeder phases for "breeder"', () {
      final phases = FeedPhaseType.forProductionType('breeder');
      expect(phases, containsAll([
        FeedPhaseType.starter,
        FeedPhaseType.pulletRearer,
        FeedPhaseType.layingMash,
      ]));
      expect(phases, isNot(contains(FeedPhaseType.grower)));
      expect(phases, isNot(contains(FeedPhaseType.finisher)));
    });

    test('forProductionType returns grow-out phases for "broiler"', () {
      final phases = FeedPhaseType.forProductionType('broiler');
      expect(phases, containsAll([
        FeedPhaseType.starter,
        FeedPhaseType.grower,
        FeedPhaseType.finisher,
      ]));
      expect(phases, isNot(contains(FeedPhaseType.pulletRearer)));
      expect(phases, isNot(contains(FeedPhaseType.layingMash)));
    });

    test('forProductionType returns grow-out phases for "duck_meat"', () {
      final phases = FeedPhaseType.forProductionType('duck_meat');
      expect(phases, containsAll([
        FeedPhaseType.starter,
        FeedPhaseType.grower,
        FeedPhaseType.finisher,
      ]));
    });

    test('forProductionType returns grow-out phases for "turkey_meat"', () {
      final phases = FeedPhaseType.forProductionType('turkey_meat');
      expect(phases, containsAll([
        FeedPhaseType.starter,
        FeedPhaseType.grower,
        FeedPhaseType.finisher,
      ]));
    });

    test('label returns human-readable strings', () {
      expect(FeedPhaseType.label(FeedPhaseType.starter), 'Starter');
      expect(FeedPhaseType.label(FeedPhaseType.grower), 'Grower');
      expect(FeedPhaseType.label(FeedPhaseType.finisher), 'Finisher');
      expect(FeedPhaseType.label(FeedPhaseType.pulletRearer), 'Pullet Rearer');
      expect(FeedPhaseType.label(FeedPhaseType.layingMash), 'Laying Mash');
    });

    test('allValues contains exactly 5 entries', () {
      expect(FeedPhaseType.allValues.length, 5);
    });
  });

  // =========================================================================
  // FeedPhase — isActiveOnDay
  // =========================================================================

  group('FeedPhase — isActiveOnDay', () {
    const phase = FeedPhase(
      id: 'fp-1',
      flockId: 'f-1',
      phaseName: 'Starter',
      feedType: FeedPhaseType.starter,
      dayStart: 1,
      dayEnd: 14,
    );

    test('returns true on exact dayStart boundary', () {
      expect(phase.isActiveOnDay(1), isTrue);
    });

    test('returns true on exact dayEnd boundary', () {
      expect(phase.isActiveOnDay(14), isTrue);
    });

    test('returns true on a day within range', () {
      expect(phase.isActiveOnDay(7), isTrue);
    });

    test('returns false for day before dayStart', () {
      expect(phase.isActiveOnDay(0), isFalse);
    });

    test('returns false for day after dayEnd', () {
      expect(phase.isActiveOnDay(15), isFalse);
    });

    test('single-day phase (dayStart == dayEnd)', () {
      const single = FeedPhase(
        id: 'fp-s',
        flockId: 'f-1',
        phaseName: 'Single Day',
        feedType: FeedPhaseType.grower,
        dayStart: 15,
        dayEnd: 15,
      );
      expect(single.isActiveOnDay(15), isTrue);
      expect(single.isActiveOnDay(14), isFalse);
      expect(single.isActiveOnDay(16), isFalse);
    });
  });

  // =========================================================================
  // HarvestRecord
  // =========================================================================

  group('HarvestRecord', () {
    test('avgHarvestWeightKg = totalLiveWeightKg / birdsHarvested', () {
      const h = HarvestRecord(
        id: 'h1',
        flockId: 'f1',
        harvestDate: '2024-02-12',
        birdsHarvested: 19500,
        totalLiveWeightKg: 46800.0,
      );
      expect(h.avgHarvestWeightKg, closeTo(2.4, 0.001));
    });

    test('avgHarvestWeightKg returns 0 when birdsHarvested is 0', () {
      const h = HarvestRecord(
        id: 'h2',
        flockId: 'f1',
        harvestDate: '2024-02-12',
        birdsHarvested: 0,
        totalLiveWeightKg: 0.0,
      );
      expect(h.avgHarvestWeightKg, 0.0);
    });

    test('totalRevenueZar = totalLiveWeightKg × pricePerKgZar', () {
      const h = HarvestRecord(
        id: 'h3',
        flockId: 'f1',
        harvestDate: '2024-02-12',
        birdsHarvested: 19500,
        totalLiveWeightKg: 46800.0,
        pricePerKgZar: 22.50,
      );
      expect(h.totalRevenueZar, closeTo(1053000.0, 0.01));
    });

    test('totalRevenueZar returns 0 when pricePerKgZar is null', () {
      const h = HarvestRecord(
        id: 'h4',
        flockId: 'f1',
        harvestDate: '2024-02-12',
        birdsHarvested: 19500,
        totalLiveWeightKg: 46800.0,
      );
      expect(h.totalRevenueZar, 0.0);
    });

    test('fromJson parses all fields', () {
      final h = HarvestRecord.fromJson({
        'id': 'h5',
        'flock_id': 'flock-004',
        'harvest_date': '2024-02-12',
        'birds_harvested': 19500,
        'total_live_weight_kg': 46800.0,
        'processor_name': 'Rainbow Farms',
        'carcass_grade_a_pct': 92.5,
        'condemnation_rate_pct': 1.2,
        'price_per_kg_zar': 22.50,
        'notes': 'Good batch',
        'recorded_by': 'user-001',
      });
      expect(h.birdsHarvested, 19500);
      expect(h.totalLiveWeightKg, closeTo(46800.0, 0.01));
      expect(h.processorName, 'Rainbow Farms');
      expect(h.carcassGradeAPct, closeTo(92.5, 0.01));
      expect(h.condemnationRatePct, closeTo(1.2, 0.001));
      expect(h.pricePerKgZar, closeTo(22.50, 0.001));
    });
  });

  // =========================================================================
  // VaccineItem
  // =========================================================================

  group('VaccineItem — status helpers', () {
    test('isCompleted true when status is "completed"', () {
      final v = VaccineItem.fromJson({
        'vaccine': 'Newcastle',
        'target_day': 7,
        'method': 'eye_drop',
        'status': 'completed',
        'completed_date': '2024-01-08',
      });
      expect(v.isCompleted, isTrue);
      expect(v.isPending, isFalse);
      expect(v.isOverdue, isFalse);
    });

    test('isPending true when status is "pending"', () {
      final v = VaccineItem.fromJson({
        'vaccine': 'IB',
        'target_day': 14,
        'method': 'drinking_water',
        'status': 'pending',
        'due_date': '2024-01-15',
      });
      expect(v.isPending, isTrue);
      expect(v.isCompleted, isFalse);
      expect(v.isOverdue, isFalse);
    });

    test('isOverdue true when status is "overdue"', () {
      final v = VaccineItem.fromJson({
        'vaccine': 'Gumboro',
        'target_day': 21,
        'method': 'drinking_water',
        'status': 'overdue',
      });
      expect(v.isOverdue, isTrue);
      expect(v.isCompleted, isFalse);
      expect(v.isPending, isFalse);
    });
  });

  // =========================================================================
  // VaccinationSchedule — computed counts
  // =========================================================================

  group('VaccinationSchedule — computed counts', () {
    late VaccinationSchedule schedule;

    setUp(() {
      schedule = VaccinationSchedule.fromJson({
        'id': 'vs-001',
        'flock_id': 'flock-001',
        'production_type': 'broiler',
        'strain': 'Ross 308',
        'placement_date': '2024-01-01',
        'schedule': [
          {
            'vaccine': 'NDV',
            'target_day': 7,
            'method': 'eye_drop',
            'status': 'completed',
          },
          {
            'vaccine': 'IBD',
            'target_day': 14,
            'method': 'drinking_water',
            'status': 'completed',
          },
          {
            'vaccine': 'IB',
            'target_day': 21,
            'method': 'drinking_water',
            'status': 'pending',
          },
          {
            'vaccine': 'ND Booster',
            'target_day': 28,
            'method': 'drinking_water',
            'status': 'overdue',
          },
        ],
      });
    });

    test('completedCount is correct', () => expect(schedule.completedCount, 2));
    test('pendingCount is correct', () => expect(schedule.pendingCount, 1));
    test('overdueCount is correct', () => expect(schedule.overdueCount, 1));
    test('total schedule length is 4', () => expect(schedule.schedule.length, 4));

    test('empty schedule yields all zeros', () {
      final empty = VaccinationSchedule.fromJson({
        'id': 'vs-empty',
        'flock_id': 'f1',
        'production_type': 'layer',
        'strain': 'LB',
        'placement_date': '2024-01-01',
        'schedule': [],
      });
      expect(empty.completedCount, 0);
      expect(empty.pendingCount, 0);
      expect(empty.overdueCount, 0);
    });
  });

  // =========================================================================
  // MedicationLog — clearanceDate
  // =========================================================================

  group('MedicationLog — clearanceDate', () {
    test('adds withdrawalDays to date correctly', () {
      final log = MedicationLog.fromJson({
        'id': 'ml-001',
        'flock_id': 'flock-001',
        'date': '2024-03-01',
        'drug_name': 'Enrofloxacin',
        'dosage': '10 mg/kg',
        'route': 'drinking_water',
        'withdrawal_days': 7,
      });
      expect(log.clearanceDate, '2024-03-08');
    });

    test('handles month boundary correctly', () {
      final log = MedicationLog.fromJson({
        'id': 'ml-002',
        'flock_id': 'flock-001',
        'date': '2024-01-28',
        'drug_name': 'Amoxicillin',
        'dosage': '15 mg/kg',
        'route': 'drinking_water',
        'withdrawal_days': 7,
      });
      expect(log.clearanceDate, '2024-02-04');
    });

    test('handles year boundary correctly', () {
      final log = MedicationLog.fromJson({
        'id': 'ml-003',
        'flock_id': 'flock-001',
        'date': '2023-12-28',
        'drug_name': 'Tylosin',
        'dosage': '12 mg/kg',
        'route': 'drinking_water',
        'withdrawal_days': 7,
      });
      expect(log.clearanceDate, '2024-01-04');
    });

    test('zero withdrawal days returns same date', () {
      final log = MedicationLog.fromJson({
        'id': 'ml-004',
        'flock_id': 'flock-001',
        'date': '2024-03-15',
        'drug_name': 'Vitamin supplement',
        'dosage': '5 ml/L',
        'route': 'drinking_water',
        'withdrawal_days': 0,
      });
      expect(log.clearanceDate, '2024-03-15');
    });
  });

  // =========================================================================
  // DiseaseEvent
  // =========================================================================

  group('DiseaseEvent — isHpai', () {
    test('true for "Avian Influenza" (mixed case)', () {
      final e = DiseaseEvent.fromJson({
        'id': 'de-1',
        'flock_id': 'f1',
        'date': '2024-03-01',
        'disease': 'Avian Influenza',
        'severity': 'emergency',
        'affected_count': 200,
      });
      expect(e.isHpai, isTrue);
    });

    test('true for "hpai" (lowercase)', () {
      final e = DiseaseEvent.fromJson({
        'id': 'de-2',
        'flock_id': 'f1',
        'date': '2024-03-01',
        'disease': 'hpai H5N1',
        'severity': 'emergency',
        'affected_count': 500,
      });
      expect(e.isHpai, isTrue);
    });

    test('true for "bird flu"', () {
      final e = DiseaseEvent.fromJson({
        'id': 'de-3',
        'flock_id': 'f1',
        'date': '2024-03-01',
        'disease': 'Bird Flu outbreak',
        'severity': 'high',
        'affected_count': 100,
      });
      expect(e.isHpai, isTrue);
    });

    test('false for unrelated disease', () {
      final e = DiseaseEvent.fromJson({
        'id': 'de-4',
        'flock_id': 'f1',
        'date': '2024-03-01',
        'disease': 'Infectious Bronchitis',
        'severity': 'medium',
        'affected_count': 50,
      });
      expect(e.isHpai, isFalse);
    });
  });

  group('DiseaseEvent — isEmergency', () {
    test('true when severity is "emergency"', () {
      final e = DiseaseEvent.fromJson({
        'id': 'de-5',
        'flock_id': 'f1',
        'date': '2024-03-01',
        'disease': 'Newcastle Disease',
        'severity': 'emergency',
        'affected_count': 300,
      });
      expect(e.isEmergency, isTrue);
    });

    test('false when severity is "high"', () {
      final e = DiseaseEvent.fromJson({
        'id': 'de-6',
        'flock_id': 'f1',
        'date': '2024-03-01',
        'disease': 'Newcastle Disease',
        'severity': 'high',
        'affected_count': 100,
      });
      expect(e.isEmergency, isFalse);
    });

    test('false when severity is "medium"', () {
      final e = DiseaseEvent.fromJson({
        'id': 'de-7',
        'flock_id': 'f1',
        'date': '2024-03-01',
        'disease': 'CRD',
        'severity': 'medium',
        'affected_count': 30,
      });
      expect(e.isEmergency, isFalse);
    });
  });

  // =========================================================================
  // EnvironmentReading
  // =========================================================================

  group('EnvironmentReading — alert flags', () {
    group('tempAlert', () {
      test('true when tempC > 32 (heat stress)', () {
        const r = EnvironmentReading(
          id: 'er-1',
          flockId: 'f1',
          timestamp: '2024-03-15T14:00:00',
          sensorZone: 'north',
          tempC: 33.5,
        );
        expect(r.tempAlert, isTrue);
      });

      test('true when tempC < 16 (cold stress)', () {
        const r = EnvironmentReading(
          id: 'er-2',
          flockId: 'f1',
          timestamp: '2024-03-15T06:00:00',
          sensorZone: 'north',
          tempC: 14.0,
        );
        expect(r.tempAlert, isTrue);
      });

      test('false when tempC is in normal range (20°C)', () {
        const r = EnvironmentReading(
          id: 'er-3',
          flockId: 'f1',
          timestamp: '2024-03-15T10:00:00',
          sensorZone: 'north',
          tempC: 20.0,
        );
        expect(r.tempAlert, isFalse);
      });

      test('false at exact boundary 32°C', () {
        const r = EnvironmentReading(
          id: 'er-4',
          flockId: 'f1',
          timestamp: '2024-03-15T10:00:00',
          sensorZone: 'north',
          tempC: 32.0,
        );
        expect(r.tempAlert, isFalse);
      });

      test('false at exact boundary 16°C', () {
        const r = EnvironmentReading(
          id: 'er-5',
          flockId: 'f1',
          timestamp: '2024-03-15T10:00:00',
          sensorZone: 'north',
          tempC: 16.0,
        );
        expect(r.tempAlert, isFalse);
      });

      test('false when tempC is null', () {
        const r = EnvironmentReading(
          id: 'er-6',
          flockId: 'f1',
          timestamp: '2024-03-15T10:00:00',
          sensorZone: 'north',
        );
        expect(r.tempAlert, isFalse);
      });
    });

    group('ammoniaAlert', () {
      test('true when ammoniaPpm > 20', () {
        const r = EnvironmentReading(
          id: 'er-7',
          flockId: 'f1',
          timestamp: '2024-03-15T10:00:00',
          sensorZone: 'south',
          ammoniaPpm: 25.0,
        );
        expect(r.ammoniaAlert, isTrue);
      });

      test('false when ammoniaPpm is exactly 20', () {
        const r = EnvironmentReading(
          id: 'er-8',
          flockId: 'f1',
          timestamp: '2024-03-15T10:00:00',
          sensorZone: 'south',
          ammoniaPpm: 20.0,
        );
        expect(r.ammoniaAlert, isFalse);
      });

      test('false when ammoniaPpm is below 20', () {
        const r = EnvironmentReading(
          id: 'er-9',
          flockId: 'f1',
          timestamp: '2024-03-15T10:00:00',
          sensorZone: 'south',
          ammoniaPpm: 12.0,
        );
        expect(r.ammoniaAlert, isFalse);
      });

      test('false when ammoniaPpm is null', () {
        const r = EnvironmentReading(
          id: 'er-10',
          flockId: 'f1',
          timestamp: '2024-03-15T10:00:00',
          sensorZone: 'south',
        );
        expect(r.ammoniaAlert, isFalse);
      });
    });

    group('humidityAlert', () {
      test('true when humidityPct > 80 (too humid)', () {
        const r = EnvironmentReading(
          id: 'er-11',
          flockId: 'f1',
          timestamp: '2024-03-15T10:00:00',
          sensorZone: 'inlet',
          humidityPct: 85.0,
        );
        expect(r.humidityAlert, isTrue);
      });

      test('true when humidityPct < 40 (too dry)', () {
        const r = EnvironmentReading(
          id: 'er-12',
          flockId: 'f1',
          timestamp: '2024-03-15T10:00:00',
          sensorZone: 'inlet',
          humidityPct: 35.0,
        );
        expect(r.humidityAlert, isTrue);
      });

      test('false when humidityPct is in normal range (60%)', () {
        const r = EnvironmentReading(
          id: 'er-13',
          flockId: 'f1',
          timestamp: '2024-03-15T10:00:00',
          sensorZone: 'inlet',
          humidityPct: 60.0,
        );
        expect(r.humidityAlert, isFalse);
      });

      test('false at exact boundary 80%', () {
        const r = EnvironmentReading(
          id: 'er-14',
          flockId: 'f1',
          timestamp: '2024-03-15T10:00:00',
          sensorZone: 'inlet',
          humidityPct: 80.0,
        );
        expect(r.humidityAlert, isFalse);
      });

      test('false at exact boundary 40%', () {
        const r = EnvironmentReading(
          id: 'er-15',
          flockId: 'f1',
          timestamp: '2024-03-15T10:00:00',
          sensorZone: 'inlet',
          humidityPct: 40.0,
        );
        expect(r.humidityAlert, isFalse);
      });
    });
  });

  // =========================================================================
  // EggSale — Layer farming revenue
  // =========================================================================

  group('EggSale — Layer farming revenue', () {
    test('totalRevenue = dozensTotal × pricePerDozen', () {
      final sale = EggSale.fromJson({
        'id': 'es-1',
        'flock_id': 'flock-002',
        'date': '2024-03-15',
        'buyer_name': 'Freshpack Markets',
        'dozens_total': 5000.0,
        'price_per_dozen': 38.50,
        'grade_breakdown': {
          'large': 3600,
          'extra_large': 1200,
          'jumbo': 200,
        },
        'invoice_ref': 'INV-001',
      });
      expect(sale.totalRevenue, closeTo(192500.0, 0.01));
    });

    test('totalEggs is sum of gradeBreakdown values', () {
      final sale = EggSale.fromJson({
        'id': 'es-2',
        'flock_id': 'flock-002',
        'date': '2024-03-15',
        'buyer_name': 'Buyer',
        'dozens_total': 500.0,
        'price_per_dozen': 35.0,
        'grade_breakdown': {
          'jumbo': 100,
          'extra_large': 500,
          'large': 2000,
          'medium': 3400,
        },
      });
      expect(sale.totalEggs, 6000);
    });

    test('totalEggs is 0 when gradeBreakdown is empty', () {
      final sale = EggSale.fromJson({
        'id': 'es-3',
        'flock_id': 'flock-002',
        'date': '2024-03-15',
        'buyer_name': 'Buyer',
        'dozens_total': 100.0,
        'price_per_dozen': 30.0,
      });
      expect(sale.totalEggs, 0);
    });

    test('toJson round-trips correctly', () {
      final sale = EggSale.fromJson({
        'id': 'es-4',
        'flock_id': 'flock-002',
        'date': '2024-03-20',
        'buyer_name': 'Test Buyer',
        'dozens_total': 200.0,
        'price_per_dozen': 40.0,
        'grade_breakdown': {'large': 2400},
        'invoice_ref': 'INV-999',
        'notes': 'Rush order',
      });
      final json = sale.toJson();
      expect(json['id'], 'es-4');
      expect(json['flock_id'], 'flock-002');
      expect(json['buyer_name'], 'Test Buyer');
      expect(json['dozens_total'], 200.0);
      expect(json['price_per_dozen'], 40.0);
      expect((json['grade_breakdown'] as Map)['large'], 2400);
      expect(json['invoice_ref'], 'INV-999');
      expect(json['notes'], 'Rush order');
    });
  });

  // =========================================================================
  // ChickSale — Hatchery / Breeder sales
  // =========================================================================

  group('ChickSale — Hatchery/Breeder DOC sales', () {
    test('fromJson parses all fields correctly', () {
      final sale = ChickSale.fromJson({
        'id': 'cs-1',
        'flock_id': 'flock-006',
        'batch_no': 'BATCH-2024-03-A',
        'hatch_date': '2024-03-14',
        'sale_date': '2024-03-15',
        'buyer_name': 'Sunrise Farms',
        'chick_count': 5000,
        'price_per_chick': 8.50,
        'total_amount': 42500.0,
        'chick_sex': 'straight_run',
        'eggs_set': 6000,
        'eggs_hatched': 5200,
        'fertility_pct': 94.2,
        'hatchability_pct': 86.7,
        'avg_chick_weight_g': 41.5,
        'invoice_ref': 'CS-INV-001',
        'notes': 'Healthy batch',
      });

      expect(sale.id, 'cs-1');
      expect(sale.flockId, 'flock-006');
      expect(sale.batchNo, 'BATCH-2024-03-A');
      expect(sale.hatchDate, '2024-03-14');
      expect(sale.saleDate, '2024-03-15');
      expect(sale.buyerName, 'Sunrise Farms');
      expect(sale.chickCount, 5000);
      expect(sale.pricePerChick, closeTo(8.50, 0.001));
      expect(sale.totalAmount, closeTo(42500.0, 0.01));
      expect(sale.chickSex, 'straight_run');
      expect(sale.eggsSet, 6000);
      expect(sale.eggsHatched, 5200);
      expect(sale.fertilityPct, closeTo(94.2, 0.01));
      expect(sale.hatchabilityPct, closeTo(86.7, 0.01));
      expect(sale.avgChickWeightG, closeTo(41.5, 0.01));
      expect(sale.invoiceRef, 'CS-INV-001');
      expect(sale.notes, 'Healthy batch');
    });

    test('totalAmount matches chickCount × pricePerChick', () {
      final sale = ChickSale.fromJson({
        'id': 'cs-2',
        'flock_id': 'flock-006',
        'hatch_date': '2024-03-14',
        'sale_date': '2024-03-15',
        'buyer_name': 'Farm B',
        'chick_count': 2000,
        'price_per_chick': 9.00,
        'total_amount': 18000.0,
        'chick_sex': 'female',
      });
      // total_amount stored in JSON = chickCount * pricePerChick
      expect(sale.totalAmount, closeTo(sale.chickCount * sale.pricePerChick, 0.01));
    });

    test('toJson round-trips correctly', () {
      final sale = ChickSale.fromJson({
        'id': 'cs-3',
        'flock_id': 'flock-006',
        'hatch_date': '2024-04-01',
        'sale_date': '2024-04-02',
        'buyer_name': 'Valley Poultry',
        'chick_count': 3000,
        'price_per_chick': 7.50,
        'total_amount': 22500.0,
        'chick_sex': 'male',
        'invoice_ref': 'CS-INV-100',
      });
      final json = sale.toJson();
      expect(json['id'], 'cs-3');
      expect(json['flock_id'], 'flock-006');
      expect(json['chick_count'], 3000);
      expect(json['price_per_chick'], 7.50);
      expect(json['total_amount'], 22500.0);
      expect(json['chick_sex'], 'male');
    });

    test('hatchabilityPct is less than fertilityPct (real-world constraint)', () {
      final sale = ChickSale.fromJson({
        'id': 'cs-4',
        'flock_id': 'flock-006',
        'hatch_date': '2024-04-01',
        'sale_date': '2024-04-02',
        'buyer_name': 'Hatchery X',
        'chick_count': 4000,
        'price_per_chick': 8.00,
        'total_amount': 32000.0,
        'chick_sex': 'straight_run',
        'fertility_pct': 94.0,
        'hatchability_pct': 85.0,
      });
      expect(sale.hatchabilityPct!, lessThan(sale.fertilityPct!));
    });
  });

  // =========================================================================
  // MortalityCause
  // =========================================================================

  group('MortalityCause', () {
    test('allValues has 7 entries', () {
      expect(MortalityCause.allValues.length, 7);
    });

    test('label returns human-readable strings for all values', () {
      expect(MortalityCause.label(MortalityCause.sds), contains('Sudden Death'));
      expect(MortalityCause.label(MortalityCause.ascites), contains('Ascites'));
      expect(MortalityCause.label(MortalityCause.suffocation), contains('Suffocation'));
      expect(MortalityCause.label(MortalityCause.cull), contains('Culled'));
      expect(MortalityCause.label(MortalityCause.disease), contains('Disease'));
      expect(MortalityCause.label(MortalityCause.unknown), 'Unknown');
      expect(MortalityCause.label(MortalityCause.other), 'Other');
    });
  });
}
