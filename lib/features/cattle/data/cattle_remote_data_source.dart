import '../models/cattle_animal.dart';
import '../models/cattle_records.dart';
import 'cattle_data_source.dart';

/// Production implementation of [CattleDataSource].
///
/// All methods throw [UnimplementedError] until the backend API is ready.
class CattleRemoteDataSource implements CattleDataSource {
  @override
  Future<List<CattleAnimal>> getAnimals() => throw UnimplementedError();

  @override
  Future<List<WeightRecord>> getWeightRecords() => throw UnimplementedError();

  @override
  Future<List<BreedingRecord>> getBreedingRecords() =>
      throw UnimplementedError();

  @override
  Future<List<PregnancyCheck>> getPregnancyChecks() =>
      throw UnimplementedError();

  @override
  Future<List<CalvingEvent>> getCalvingEvents() => throw UnimplementedError();

  @override
  Future<List<DailyMilkRecord>> getMilkRecords() => throw UnimplementedError();

  @override
  Future<List<CattleHealthEvent>> getHealthEvents() =>
      throw UnimplementedError();

  @override
  Future<List<CattleMedicationLog>> getMedicationLogs() =>
      throw UnimplementedError();

  @override
  Future<List<CattleVaccination>> getVaccinations() =>
      throw UnimplementedError();

  @override
  Future<List<CattleSaleRecord>> getSaleRecords() => throw UnimplementedError();

  @override
  Future<List<CattleFeedRecord>> getFeedRecords() => throw UnimplementedError();

  @override
  Future<List<PastureRecord>> getPastureRecords() => throw UnimplementedError();

  @override
  Future<List<BodyConditionRecord>> getBodyConditionRecords() =>
      throw UnimplementedError();

  @override
  Future<List<DippingRecord>> getDippingRecords() => throw UnimplementedError();

  @override
  Future<CattleAnimal> createAnimal(CattleAnimal animal) =>
      throw UnimplementedError();

  @override
  Future<CattleAnimal> updateAnimal(CattleAnimal animal) =>
      throw UnimplementedError();

  @override
  Future<void> deleteAnimal(String id) => throw UnimplementedError();

  @override
  Future<WeightRecord> createWeightRecord(WeightRecord record) =>
      throw UnimplementedError();

  @override
  Future<void> deleteWeightRecord(String id) => throw UnimplementedError();

  @override
  Future<BreedingRecord> createBreedingRecord(BreedingRecord record) =>
      throw UnimplementedError();

  @override
  Future<BreedingRecord> updateBreedingRecord(BreedingRecord record) =>
      throw UnimplementedError();

  @override
  Future<PregnancyCheck> createPregnancyCheck(PregnancyCheck check) =>
      throw UnimplementedError();

  @override
  Future<CalvingEvent> createCalvingEvent(CalvingEvent event) =>
      throw UnimplementedError();

  @override
  Future<DailyMilkRecord> createMilkRecord(DailyMilkRecord record) =>
      throw UnimplementedError();

  @override
  Future<void> deleteMilkRecord(String id) => throw UnimplementedError();

  @override
  Future<CattleHealthEvent> createHealthEvent(CattleHealthEvent event) =>
      throw UnimplementedError();

  @override
  Future<CattleHealthEvent> updateHealthEvent(CattleHealthEvent event) =>
      throw UnimplementedError();

  @override
  Future<CattleMedicationLog> createMedicationLog(CattleMedicationLog log) =>
      throw UnimplementedError();

  @override
  Future<CattleVaccination> createVaccination(CattleVaccination vaccination) =>
      throw UnimplementedError();

  @override
  Future<CattleVaccination> markVaccinationGiven(
    String id,
    String givenDate, {
    String? batchNumber,
  }) =>
      throw UnimplementedError();

  @override
  Future<CattleSaleRecord> createSaleRecord(CattleSaleRecord record) =>
      throw UnimplementedError();

  @override
  Future<CattleSaleRecord> updateSaleRecord(CattleSaleRecord record) =>
      throw UnimplementedError();

  @override
  Future<void> deleteSaleRecord(String id) => throw UnimplementedError();

  @override
  Future<CattleFeedRecord> createFeedRecord(CattleFeedRecord record) =>
      throw UnimplementedError();

  @override
  Future<void> deleteFeedRecord(String id) => throw UnimplementedError();

  @override
  Future<PastureRecord> createPastureRecord(PastureRecord record) =>
      throw UnimplementedError();

  @override
  Future<PastureRecord> exitPasture(String id, String exitDate) =>
      throw UnimplementedError();

  @override
  Future<BodyConditionRecord> createBodyConditionRecord(
          BodyConditionRecord record) =>
      throw UnimplementedError();

  @override
  Future<DippingRecord> createDippingRecord(DippingRecord record) =>
      throw UnimplementedError();
}
