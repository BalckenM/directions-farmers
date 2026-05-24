
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/failure.dart';
import '../models/goat_animal.dart';
import '../models/goat_records.dart';
import 'goat_data_source.dart';

class GoatRepository {
  GoatRepository(this._source);

  final GoatDataSource _source;

  Future<List<GoatAnimal>> getAnimals() async {
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

  Future<List<MatingRecord>> getMatingRecords() async {
    try {
      return await _source.getMatingRecords();
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

  Future<List<KiddingEvent>> getKiddingEvents() async {
    try {
      return await _source.getKiddingEvents();
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

  Future<List<ShearingRecord>> getShearingRecords() async {
    try {
      return await _source.getShearingRecords();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<List<GoatHealthEvent>> getHealthEvents() async {
    try {
      return await _source.getHealthEvents();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<List<GoatMedicationLog>> getMedicationLogs() async {
    try {
      return await _source.getMedicationLogs();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<List<GoatVaccination>> getVaccinations() async {
    try {
      return await _source.getVaccinations();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<List<GoatSaleRecord>> getSaleRecords() async {
    try {
      return await _source.getSaleRecords();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<List<GoatFeedRecord>> getFeedRecords() async {
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

  Future<List<FamachaRecord>> getFamachaRecords() async {
    try {
      return await _source.getFamachaRecords();
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

  // ── Animal writes ─────────────────────────────────────────────────────────

  Future<GoatAnimal> createAnimal(GoatAnimal animal) async {
    try {
      return await _source.createAnimal(animal);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<GoatAnimal> updateAnimal(GoatAnimal animal) async {
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

  // ── Mating record writes ──────────────────────────────────────────────────

  Future<MatingRecord> createMatingRecord(MatingRecord record) async {
    try {
      return await _source.createMatingRecord(record);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<MatingRecord> updateMatingRecord(MatingRecord record) async {
    try {
      return await _source.updateMatingRecord(record);
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

  // ── Kidding event writes ──────────────────────────────────────────────────

  Future<KiddingEvent> createKiddingEvent(KiddingEvent event) async {
    try {
      return await _source.createKiddingEvent(event);
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

  // ── Shearing record writes ────────────────────────────────────────────────

  Future<ShearingRecord> createShearingRecord(ShearingRecord record) async {
    try {
      return await _source.createShearingRecord(record);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  // ── Health event writes ───────────────────────────────────────────────────

  Future<GoatHealthEvent> createHealthEvent(GoatHealthEvent event) async {
    try {
      return await _source.createHealthEvent(event);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<GoatHealthEvent> updateHealthEvent(GoatHealthEvent event) async {
    try {
      return await _source.updateHealthEvent(event);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  // ── Medication log writes ─────────────────────────────────────────────────

  Future<GoatMedicationLog> createMedicationLog(GoatMedicationLog log) async {
    try {
      return await _source.createMedicationLog(log);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  // ── Vaccination writes ────────────────────────────────────────────────────

  Future<GoatVaccination> createVaccination(GoatVaccination vaccination) async {
    try {
      return await _source.createVaccination(vaccination);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<GoatVaccination> markVaccinationGiven(
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

  Future<GoatSaleRecord> createSaleRecord(GoatSaleRecord record) async {
    try {
      return await _source.createSaleRecord(record);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<GoatSaleRecord> updateSaleRecord(GoatSaleRecord record) async {
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

  Future<GoatFeedRecord> createFeedRecord(GoatFeedRecord record) async {
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

  // ── FAMACHA record writes ─────────────────────────────────────────────────

  Future<FamachaRecord> createFamachaRecord(FamachaRecord record) async {
    try {
      return await _source.createFamachaRecord(record);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  // ── Body-condition record writes ──────────────────────────────────────────

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
}
