import '../models/poultry_flock.dart';
import '../models/flock.dart';
import '../models/inventory_item.dart';

abstract class PoultryDataSource {
  Future<List<PoultryFlock>> getFlocks();
  Future<List<DailyRecord>> getDailyRecords();
  Future<List<VaccinationSchedule>> getVaccinationSchedules();
  Future<List<FeedPhase>> getFeedPhases();
  Future<List<HarvestRecord>> getHarvestRecords();
  Future<List<MedicationLog>> getMedicationLogs();
  Future<List<DiseaseEvent>> getDiseaseEvents();
  Future<List<EnvironmentReading>> getEnvironmentReadings();
  Future<List<InventoryItem>> getInventoryItems();
  Future<List<EggSale>> getEggSales();
  Future<List<ChickSale>> getChickSales();
}
