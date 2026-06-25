import 'poultry_data_source.dart';
import '../models/poultry_flock.dart';
import '../models/flock.dart';
import '../models/inventory_item.dart';

// Stub — poultry module not yet active. No HTTP calls are made.
class PoultryRemoteDataSource implements PoultryDataSource {
  PoultryRemoteDataSource(dynamic _);

  @override Future<List<PoultryFlock>> getFlocks() async => const [];
  @override Future<List<DailyRecord>> getDailyRecords() async => const [];
  @override Future<List<VaccinationSchedule>> getVaccinationSchedules() async => const [];
  @override Future<List<FeedPhase>> getFeedPhases() async => const [];
  @override Future<List<HarvestRecord>> getHarvestRecords() async => const [];
  @override Future<List<MedicationLog>> getMedicationLogs() async => const [];
  @override Future<List<DiseaseEvent>> getDiseaseEvents() async => const [];
  @override Future<List<EnvironmentReading>> getEnvironmentReadings() async => const [];
  @override Future<List<InventoryItem>> getInventoryItems() async => const [];
  @override Future<List<EggSale>> getEggSales() async => const [];
  @override Future<List<ChickSale>> getChickSales() async => const [];
}
