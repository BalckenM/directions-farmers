import '../models/goat_animal.dart';
import '../models/goat_records.dart';
import 'goat_data_source.dart';

// Stub — goat module not yet active. No HTTP calls are made.
class GoatRemoteDataSource implements GoatDataSource {
  GoatRemoteDataSource(dynamic _);

  @override Future<List<GoatAnimal>> getAnimals() async => const [];
  @override Future<List<WeightRecord>> getWeightRecords() async => const [];
  @override Future<List<MatingRecord>> getMatingRecords() async => const [];
  @override Future<List<PregnancyCheck>> getPregnancyChecks() async => const [];
  @override Future<List<KiddingEvent>> getKiddingEvents() async => const [];
  @override Future<List<DailyMilkRecord>> getMilkRecords() async => const [];
  @override Future<List<ShearingRecord>> getShearingRecords() async => const [];
  @override Future<List<GoatHealthEvent>> getHealthEvents() async => const [];
  @override Future<List<GoatMedicationLog>> getMedicationLogs() async => const [];
  @override Future<List<GoatVaccination>> getVaccinations() async => const [];
  @override Future<List<GoatSaleRecord>> getSaleRecords() async => const [];
  @override Future<List<GoatFeedRecord>> getFeedRecords() async => const [];
  @override Future<List<PastureRecord>> getPastureRecords() async => const [];
  @override Future<List<FamachaRecord>> getFamachaRecords() async => const [];
  @override Future<List<BodyConditionRecord>> getBodyConditionRecords() async => const [];

  @override Future<GoatAnimal> createAnimal(GoatAnimal animal) async => animal;
  @override Future<GoatAnimal> updateAnimal(GoatAnimal animal) async => animal;
  @override Future<void> deleteAnimal(String id) async {}
  @override Future<WeightRecord> createWeightRecord(WeightRecord record) async => record;
  @override Future<void> deleteWeightRecord(String id) async {}
  @override Future<MatingRecord> createMatingRecord(MatingRecord record) async => record;
  @override Future<MatingRecord> updateMatingRecord(MatingRecord record) async => record;
  @override Future<PregnancyCheck> createPregnancyCheck(PregnancyCheck check) async => check;
  @override Future<KiddingEvent> createKiddingEvent(KiddingEvent event) async => event;
  @override Future<DailyMilkRecord> createMilkRecord(DailyMilkRecord record) async => record;
  @override Future<void> deleteMilkRecord(String id) async {}
  @override Future<ShearingRecord> createShearingRecord(ShearingRecord record) async => record;
  @override Future<GoatHealthEvent> createHealthEvent(GoatHealthEvent event) async => event;
  @override Future<GoatHealthEvent> updateHealthEvent(GoatHealthEvent event) async => event;
  @override Future<GoatMedicationLog> createMedicationLog(GoatMedicationLog log) async => log;
  @override Future<GoatVaccination> createVaccination(GoatVaccination v) async => v;
  @override Future<GoatVaccination> markVaccinationGiven(String id, String givenDate, {String? batchNumber}) async => throw UnsupportedError('module not active');
  @override Future<GoatSaleRecord> createSaleRecord(GoatSaleRecord record) async => record;
  @override Future<GoatSaleRecord> updateSaleRecord(GoatSaleRecord record) async => record;
  @override Future<void> deleteSaleRecord(String id) async {}
  @override Future<GoatFeedRecord> createFeedRecord(GoatFeedRecord record) async => record;
  @override Future<void> deleteFeedRecord(String id) async {}
  @override Future<PastureRecord> createPastureRecord(PastureRecord record) async => record;
  @override Future<PastureRecord> exitPasture(String id, String exitDate) async => throw UnsupportedError('module not active');
  @override Future<FamachaRecord> createFamachaRecord(FamachaRecord record) async => record;
  @override Future<BodyConditionRecord> createBodyConditionRecord(BodyConditionRecord record) async => record;
}
