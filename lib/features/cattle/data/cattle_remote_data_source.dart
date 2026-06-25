import '../models/cattle_animal.dart';
import '../models/cattle_records.dart';
import 'cattle_data_source.dart';

// Stub — cattle module not yet active. No HTTP calls are made.
class CattleRemoteDataSource implements CattleDataSource {
  CattleRemoteDataSource(dynamic _);

  @override Future<List<CattleAnimal>> getAnimals() async => const [];
  @override Future<List<WeightRecord>> getWeightRecords() async => const [];
  @override Future<List<BreedingRecord>> getBreedingRecords() async => const [];
  @override Future<List<PregnancyCheck>> getPregnancyChecks() async => const [];
  @override Future<List<CalvingEvent>> getCalvingEvents() async => const [];
  @override Future<List<DailyMilkRecord>> getMilkRecords() async => const [];
  @override Future<List<CattleHealthEvent>> getHealthEvents() async => const [];
  @override Future<List<CattleMedicationLog>> getMedicationLogs() async => const [];
  @override Future<List<CattleVaccination>> getVaccinations() async => const [];
  @override Future<List<CattleSaleRecord>> getSaleRecords() async => const [];
  @override Future<List<CattleFeedRecord>> getFeedRecords() async => const [];
  @override Future<List<PastureRecord>> getPastureRecords() async => const [];
  @override Future<List<BodyConditionRecord>> getBodyConditionRecords() async => const [];
  @override Future<List<DippingRecord>> getDippingRecords() async => const [];

  @override Future<CattleAnimal> createAnimal(CattleAnimal animal) async => animal;
  @override Future<CattleAnimal> updateAnimal(CattleAnimal animal) async => animal;
  @override Future<void> deleteAnimal(String id) async {}
  @override Future<WeightRecord> createWeightRecord(WeightRecord record) async => record;
  @override Future<void> deleteWeightRecord(String id) async {}
  @override Future<BreedingRecord> createBreedingRecord(BreedingRecord record) async => record;
  @override Future<BreedingRecord> updateBreedingRecord(BreedingRecord record) async => record;
  @override Future<PregnancyCheck> createPregnancyCheck(PregnancyCheck check) async => check;
  @override Future<CalvingEvent> createCalvingEvent(CalvingEvent event) async => event;
  @override Future<DailyMilkRecord> createMilkRecord(DailyMilkRecord record) async => record;
  @override Future<void> deleteMilkRecord(String id) async {}
  @override Future<CattleHealthEvent> createHealthEvent(CattleHealthEvent event) async => event;
  @override Future<CattleHealthEvent> updateHealthEvent(CattleHealthEvent event) async => event;
  @override Future<CattleMedicationLog> createMedicationLog(CattleMedicationLog log) async => log;
  @override Future<CattleVaccination> createVaccination(CattleVaccination v) async => v;
  @override Future<CattleVaccination> markVaccinationGiven(String id, String givenDate, {String? batchNumber}) async => throw UnsupportedError('module not active');
  @override Future<CattleSaleRecord> createSaleRecord(CattleSaleRecord record) async => record;
  @override Future<CattleSaleRecord> updateSaleRecord(CattleSaleRecord record) async => record;
  @override Future<void> deleteSaleRecord(String id) async {}
  @override Future<CattleFeedRecord> createFeedRecord(CattleFeedRecord record) async => record;
  @override Future<void> deleteFeedRecord(String id) async {}
  @override Future<PastureRecord> createPastureRecord(PastureRecord record) async => record;
  @override Future<PastureRecord> exitPasture(String id, String exitDate) async => throw UnsupportedError('module not active');
  @override Future<BodyConditionRecord> createBodyConditionRecord(BodyConditionRecord record) async => record;
  @override Future<DippingRecord> createDippingRecord(DippingRecord record) async => record;
}
