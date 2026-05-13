import '../models/cattle_animal.dart';
import '../models/cattle_records.dart';

/// Contract for all cattle data operations (GET / POST / PUT / PATCH / DELETE).
///
/// Implemented by [CattleMockDataSource] (development) and
/// [CattleRemoteDataSource] (production).
abstract class CattleDataSource {
  // ── GET ───────────────────────────────────────────────────────────────────
  Future<List<CattleAnimal>> getAnimals();
  Future<List<WeightRecord>> getWeightRecords();
  Future<List<BreedingRecord>> getBreedingRecords();
  Future<List<PregnancyCheck>> getPregnancyChecks();
  Future<List<CalvingEvent>> getCalvingEvents();
  Future<List<DailyMilkRecord>> getMilkRecords();
  Future<List<CattleHealthEvent>> getHealthEvents();
  Future<List<CattleMedicationLog>> getMedicationLogs();
  Future<List<CattleVaccination>> getVaccinations();
  Future<List<CattleSaleRecord>> getSaleRecords();
  Future<List<CattleFeedRecord>> getFeedRecords();
  Future<List<PastureRecord>> getPastureRecords();
  Future<List<BodyConditionRecord>> getBodyConditionRecords();
  Future<List<DippingRecord>> getDippingRecords();

  // ── Animals (POST / PUT / DELETE) ────────────────────────────────────────
  Future<CattleAnimal> createAnimal(CattleAnimal animal);
  Future<CattleAnimal> updateAnimal(CattleAnimal animal);
  Future<void> deleteAnimal(String id);

  // ── Weight records (POST / DELETE) ───────────────────────────────────────
  Future<WeightRecord> createWeightRecord(WeightRecord record);
  Future<void> deleteWeightRecord(String id);

  // ── Breeding records (POST / PUT) ─────────────────────────────────────────
  Future<BreedingRecord> createBreedingRecord(BreedingRecord record);
  Future<BreedingRecord> updateBreedingRecord(BreedingRecord record);

  // ── Pregnancy checks (POST) ───────────────────────────────────────────────
  Future<PregnancyCheck> createPregnancyCheck(PregnancyCheck check);

  // ── Calving events (POST) ─────────────────────────────────────────────────
  Future<CalvingEvent> createCalvingEvent(CalvingEvent event);

  // ── Milk records (POST / DELETE) ──────────────────────────────────────────
  Future<DailyMilkRecord> createMilkRecord(DailyMilkRecord record);
  Future<void> deleteMilkRecord(String id);

  // ── Health events (POST / PUT) ────────────────────────────────────────────
  Future<CattleHealthEvent> createHealthEvent(CattleHealthEvent event);
  Future<CattleHealthEvent> updateHealthEvent(CattleHealthEvent event);

  // ── Medication logs (POST) ────────────────────────────────────────────────
  Future<CattleMedicationLog> createMedicationLog(CattleMedicationLog log);

  // ── Vaccinations (POST / PATCH) ───────────────────────────────────────────
  Future<CattleVaccination> createVaccination(CattleVaccination vaccination);
  Future<CattleVaccination> markVaccinationGiven(
    String id,
    String givenDate, {
    String? batchNumber,
  });

  // ── Sale records (POST / PUT / DELETE) ────────────────────────────────────
  Future<CattleSaleRecord> createSaleRecord(CattleSaleRecord record);
  Future<CattleSaleRecord> updateSaleRecord(CattleSaleRecord record);
  Future<void> deleteSaleRecord(String id);

  // ── Feed records (POST / DELETE) ──────────────────────────────────────────
  Future<CattleFeedRecord> createFeedRecord(CattleFeedRecord record);
  Future<void> deleteFeedRecord(String id);

  // ── Pasture records (POST / PATCH) ────────────────────────────────────────
  Future<PastureRecord> createPastureRecord(PastureRecord record);
  Future<PastureRecord> exitPasture(String id, String exitDate);

  // ── Body-condition records (POST) ─────────────────────────────────────────
  Future<BodyConditionRecord> createBodyConditionRecord(
      BodyConditionRecord record);

  // ── Dipping records (POST) ────────────────────────────────────────────────
  Future<DippingRecord> createDippingRecord(DippingRecord record);
}
