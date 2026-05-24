import '../models/poultry_flock.dart';
import '../models/flock.dart';
import '../models/inventory_item.dart';
import 'poultry_data_source.dart';

class PoultryRepository {
  PoultryRepository(this._source);

  final PoultryDataSource _source;

  Future<List<PoultryFlock>> getFlocks() => _source.getFlocks();

  Future<PoultryFlock?> getFlockById(String id) async {
    final flocks = await _source.getFlocks();
    try {
      return flocks.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<DailyRecord>> getDailyRecords() => _source.getDailyRecords();

  Future<List<VaccinationSchedule>> getVaccinationSchedules() =>
      _source.getVaccinationSchedules();

  Future<List<FeedPhase>> getFeedPhases() => _source.getFeedPhases();

  Future<List<HarvestRecord>> getHarvestRecords() =>
      _source.getHarvestRecords();

  Future<List<MedicationLog>> getMedicationLogs() =>
      _source.getMedicationLogs();

  Future<List<DiseaseEvent>> getDiseaseEvents() => _source.getDiseaseEvents();

  Future<List<EnvironmentReading>> getEnvironmentReadings() =>
      _source.getEnvironmentReadings();

  Future<List<InventoryItem>> getInventoryItems() =>
      _source.getInventoryItems();

  Future<List<EggSale>> getEggSales() => _source.getEggSales();

  Future<List<ChickSale>> getChickSales() => _source.getChickSales();
}

