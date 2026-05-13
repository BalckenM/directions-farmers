import '../models/goat_animal.dart';
import '../models/goat_records.dart';

/// Contract for all goat data operations (GET / POST / PUT / PATCH / DELETE).
///
/// Implemented by [GoatMockDataSource] (development) and
/// [GoatRemoteDataSource] (production).
abstract class GoatDataSource {
  // ── GET ──────────────────────────────────────────────────────────────────
  Future<List<GoatAnimal>> getAnimals();
  Future<List<WeightRecord>> getWeightRecords();
  Future<List<MatingRecord>> getMatingRecords();
  Future<List<PregnancyCheck>> getPregnancyChecks();
  Future<List<KiddingEvent>> getKiddingEvents();
  Future<List<DailyMilkRecord>> getMilkRecords();
  Future<List<ShearingRecord>> getShearingRecords();
  Future<List<GoatHealthEvent>> getHealthEvents();
  Future<List<GoatMedicationLog>> getMedicationLogs();
  Future<List<GoatVaccination>> getVaccinations();
  Future<List<GoatSaleRecord>> getSaleRecords();
  Future<List<GoatFeedRecord>> getFeedRecords();
  Future<List<PastureRecord>> getPastureRecords();
  Future<List<FamachaRecord>> getFamachaRecords();
  Future<List<BodyConditionRecord>> getBodyConditionRecords();

  // ── Animals (POST / PUT / DELETE) ────────────────────────────────────────
  Future<GoatAnimal> createAnimal(GoatAnimal animal);
  Future<GoatAnimal> updateAnimal(GoatAnimal animal);
  Future<void> deleteAnimal(String id);

  // ── Weight records (POST / DELETE) ───────────────────────────────────────
  Future<WeightRecord> createWeightRecord(WeightRecord record);
  Future<void> deleteWeightRecord(String id);

  // ── Mating records (POST / PUT) ───────────────────────────────────────────
  Future<MatingRecord> createMatingRecord(MatingRecord record);
  Future<MatingRecord> updateMatingRecord(MatingRecord record);

  // ── Pregnancy checks (POST) ───────────────────────────────────────────────
  Future<PregnancyCheck> createPregnancyCheck(PregnancyCheck check);

  // ── Kidding events (POST) ─────────────────────────────────────────────────
  Future<KiddingEvent> createKiddingEvent(KiddingEvent event);

  // ── Milk records (POST / DELETE) ──────────────────────────────────────────
  Future<DailyMilkRecord> createMilkRecord(DailyMilkRecord record);
  Future<void> deleteMilkRecord(String id);

  // ── Shearing records (POST) ───────────────────────────────────────────────
  Future<ShearingRecord> createShearingRecord(ShearingRecord record);

  // ── Health events (POST / PUT) ────────────────────────────────────────────
  Future<GoatHealthEvent> createHealthEvent(GoatHealthEvent event);
  Future<GoatHealthEvent> updateHealthEvent(GoatHealthEvent event);

  // ── Medication logs (POST) ────────────────────────────────────────────────
  Future<GoatMedicationLog> createMedicationLog(GoatMedicationLog log);

  // ── Vaccinations (POST / PATCH) ───────────────────────────────────────────
  Future<GoatVaccination> createVaccination(GoatVaccination vaccination);
  Future<GoatVaccination> markVaccinationGiven(
    String id,
    String givenDate, {
    String? batchNumber,
  });

  // ── Sale records (POST / PUT / DELETE) ────────────────────────────────────
  Future<GoatSaleRecord> createSaleRecord(GoatSaleRecord record);
  Future<GoatSaleRecord> updateSaleRecord(GoatSaleRecord record);
  Future<void> deleteSaleRecord(String id);

  // ── Feed records (POST / DELETE) ──────────────────────────────────────────
  Future<GoatFeedRecord> createFeedRecord(GoatFeedRecord record);
  Future<void> deleteFeedRecord(String id);

  // ── Pasture records (POST / PATCH) ────────────────────────────────────────
  Future<PastureRecord> createPastureRecord(PastureRecord record);
  Future<PastureRecord> exitPasture(String id, String exitDate);

  // ── FAMACHA records (POST) ────────────────────────────────────────────────
  Future<FamachaRecord> createFamachaRecord(FamachaRecord record);

  // ── Body-condition records (POST) ─────────────────────────────────────────
  Future<BodyConditionRecord> createBodyConditionRecord(
      BodyConditionRecord record);
}
