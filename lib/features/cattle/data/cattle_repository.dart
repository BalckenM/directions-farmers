import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/failure.dart';
import '../models/cattle_animal.dart';
import '../models/cattle_records.dart';
import 'cattle_data_source.dart';
import 'cattle_mock_data_source.dart';
import 'cattle_remote_data_source.dart';

class CattleRepository {
  CattleRepository(this._source);

  final CattleDataSource _source;

  // ── GET ───────────────────────────────────────────────────────────────────

  Future<List<CattleAnimal>> getAnimals() async {
    try {
      return await _source.getAnimals();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<List<WeightRecord>> getWeightRecords() async {
    try {
      return await _source.getWeightRecords();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<List<BreedingRecord>> getBreedingRecords() async {
    try {
      return await _source.getBreedingRecords();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<List<PregnancyCheck>> getPregnancyChecks() async {
    try {
      return await _source.getPregnancyChecks();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<List<CalvingEvent>> getCalvingEvents() async {
    try {
      return await _source.getCalvingEvents();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<List<DailyMilkRecord>> getMilkRecords() async {
    try {
      return await _source.getMilkRecords();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<List<CattleHealthEvent>> getHealthEvents() async {
    try {
      return await _source.getHealthEvents();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<List<CattleMedicationLog>> getMedicationLogs() async {
    try {
      return await _source.getMedicationLogs();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<List<CattleVaccination>> getVaccinations() async {
    try {
      return await _source.getVaccinations();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<List<CattleSaleRecord>> getSaleRecords() async {
    try {
      return await _source.getSaleRecords();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<List<CattleFeedRecord>> getFeedRecords() async {
    try {
      return await _source.getFeedRecords();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<List<PastureRecord>> getPastureRecords() async {
    try {
      return await _source.getPastureRecords();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<List<BodyConditionRecord>> getBodyConditionRecords() async {
    try {
      return await _source.getBodyConditionRecords();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<List<DippingRecord>> getDippingRecords() async {
    try {
      return await _source.getDippingRecords();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  // ── Animal writes ─────────────────────────────────────────────────────────

  Future<CattleAnimal> createAnimal(CattleAnimal animal) async {
    try {
      return await _source.createAnimal(animal);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<CattleAnimal> updateAnimal(CattleAnimal animal) async {
    try {
      return await _source.updateAnimal(animal);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<void> deleteAnimal(String id) async {
    try {
      return await _source.deleteAnimal(id);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  // ── Weight record writes ──────────────────────────────────────────────────

  Future<WeightRecord> createWeightRecord(WeightRecord record) async {
    try {
      return await _source.createWeightRecord(record);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<void> deleteWeightRecord(String id) async {
    try {
      return await _source.deleteWeightRecord(id);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  // ── Breeding record writes ────────────────────────────────────────────────

  Future<BreedingRecord> createBreedingRecord(BreedingRecord record) async {
    try {
      return await _source.createBreedingRecord(record);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<BreedingRecord> updateBreedingRecord(BreedingRecord record) async {
    try {
      return await _source.updateBreedingRecord(record);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  // ── Pregnancy check writes ────────────────────────────────────────────────

  Future<PregnancyCheck> createPregnancyCheck(PregnancyCheck check) async {
    try {
      return await _source.createPregnancyCheck(check);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  // ── Calving event writes ──────────────────────────────────────────────────

  Future<CalvingEvent> createCalvingEvent(CalvingEvent event) async {
    try {
      return await _source.createCalvingEvent(event);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  // ── Milk record writes ────────────────────────────────────────────────────

  Future<DailyMilkRecord> createMilkRecord(DailyMilkRecord record) async {
    try {
      return await _source.createMilkRecord(record);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<void> deleteMilkRecord(String id) async {
    try {
      return await _source.deleteMilkRecord(id);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  // ── Health event writes ───────────────────────────────────────────────────

  Future<CattleHealthEvent> createHealthEvent(CattleHealthEvent event) async {
    try {
      return await _source.createHealthEvent(event);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<CattleHealthEvent> updateHealthEvent(CattleHealthEvent event) async {
    try {
      return await _source.updateHealthEvent(event);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  // ── Medication log writes ─────────────────────────────────────────────────

  Future<CattleMedicationLog> createMedicationLog(
      CattleMedicationLog log) async {
    try {
      return await _source.createMedicationLog(log);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  // ── Vaccination writes ────────────────────────────────────────────────────

  Future<CattleVaccination> createVaccination(
      CattleVaccination vaccination) async {
    try {
      return await _source.createVaccination(vaccination);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<CattleVaccination> markVaccinationGiven(
    String id,
    String givenDate, {
    String? batchNumber,
  }) async {
    try {
      return await _source.markVaccinationGiven(id, givenDate,
          batchNumber: batchNumber);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  // ── Sale record writes ────────────────────────────────────────────────────

  Future<CattleSaleRecord> createSaleRecord(CattleSaleRecord record) async {
    try {
      return await _source.createSaleRecord(record);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<CattleSaleRecord> updateSaleRecord(CattleSaleRecord record) async {
    try {
      return await _source.updateSaleRecord(record);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<void> deleteSaleRecord(String id) async {
    try {
      return await _source.deleteSaleRecord(id);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  // ── Feed record writes ────────────────────────────────────────────────────

  Future<CattleFeedRecord> createFeedRecord(CattleFeedRecord record) async {
    try {
      return await _source.createFeedRecord(record);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<void> deleteFeedRecord(String id) async {
    try {
      return await _source.deleteFeedRecord(id);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  // ── Pasture record writes ─────────────────────────────────────────────────

  Future<PastureRecord> createPastureRecord(PastureRecord record) async {
    try {
      return await _source.createPastureRecord(record);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<PastureRecord> exitPasture(String id, String exitDate) async {
    try {
      return await _source.exitPasture(id, exitDate);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  // ── Body condition record writes ──────────────────────────────────────────

  Future<BodyConditionRecord> createBodyConditionRecord(
      BodyConditionRecord record) async {
    try {
      return await _source.createBodyConditionRecord(record);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  // ── Dipping record writes ─────────────────────────────────────────────────

  Future<DippingRecord> createDippingRecord(DippingRecord record) async {
    try {
      return await _source.createDippingRecord(record);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }
}

// ── Riverpod provider ─────────────────────────────────────────────────────────

final cattleRepositoryProvider = Provider<CattleRepository>((ref) {
  final source = AppConstants.useMockData
      ? CattleMockDataSource()
      : CattleRemoteDataSource();
  return CattleRepository(source);
});
