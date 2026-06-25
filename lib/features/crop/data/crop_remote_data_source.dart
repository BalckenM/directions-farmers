import 'crop_data_source.dart';
import '../models/advisory_content.dart';
import '../models/calendar_event.dart';
import '../models/crop.dart';
import '../models/crop_category.dart';
import '../models/crop_expense.dart';
import '../models/crop_field.dart';
import '../models/crop_sale.dart';
import '../models/crop_season.dart';
import '../models/crop_task.dart';
import '../models/harvest_record.dart';
import '../models/pest_observation.dart';
import '../models/planting_plan.dart';
import '../models/spray_record.dart';
import '../models/weather_alert.dart';

// Stub — crop module not yet active. No HTTP calls are made.
class CropRemoteDataSource implements CropDataSource {
  CropRemoteDataSource(dynamic _);

  @override Future<List<CropCategory>> getCropCategories() async => const [];
  @override Future<List<Crop>> getCrops() async => const [];
  @override Future<List<CropField>> getCropFields() async => const [];
  @override Future<List<CropSeason>> getSeasons() async => const [];
  @override Future<List<PlantingPlan>> getPlantingPlans() async => const [];
  @override Future<List<CalendarEvent>> getCalendarEvents() async => const [];
  @override Future<List<CropTask>> getCropTasks() async => const [];
  @override Future<List<WeatherAlert>> getWeatherAlerts() async => const [];
  @override Future<List<PestObservation>> getPestObservations() async => const [];
  @override Future<List<SprayRecord>> getSprayRecords() async => const [];
  @override Future<List<CropExpense>> getCropExpenses() async => const [];
  @override Future<List<HarvestRecord>> getCropHarvestRecords() async => const [];
  @override Future<List<CropSale>> getCropSales() async => const [];
  @override Future<List<AdvisoryContent>> getAdvisoryContent() async => const [];

  @override Future<CropField> addField(CropField field) async => field;
  @override Future<CropField> updateField(CropField updated) async => updated;
  @override Future<void> deleteField(String id) async {}
  @override Future<CropSeason> addSeason(CropSeason season) async => season;
  @override Future<CropSeason> updateSeason(CropSeason updated) async => updated;
  @override Future<void> deleteSeason(String id) async {}
  @override Future<PlantingPlan> addPlantingPlan(PlantingPlan plan) async => plan;
  @override Future<PlantingPlan> updatePlantingPlan(PlantingPlan updated) async => updated;
  @override Future<void> deletePlantingPlan(String id) async {}
  @override Future<CropTask> addTask(CropTask task) async => task;
  @override Future<CropTask> updateTask(CropTask updated) async => updated;
  @override Future<void> deleteTask(String id) async {}
  @override Future<PestObservation> addPestObservation(PestObservation obs) async => obs;
  @override Future<PestObservation> updatePestObservation(PestObservation updated) async => updated;
  @override Future<void> deletePestObservation(String id) async {}
  @override Future<SprayRecord> addSprayRecord(SprayRecord record) async => record;
  @override Future<SprayRecord> updateSprayRecord(SprayRecord updated) async => updated;
  @override Future<void> deleteSprayRecord(String id) async {}
  @override Future<CropExpense> addExpense(CropExpense expense) async => expense;
  @override Future<CropExpense> updateExpense(CropExpense updated) async => updated;
  @override Future<void> deleteExpense(String id) async {}
  @override Future<HarvestRecord> addHarvestRecord(HarvestRecord record) async => record;
  @override Future<HarvestRecord> updateHarvestRecord(HarvestRecord updated) async => updated;
  @override Future<void> deleteHarvestRecord(String id) async {}
  @override Future<CalendarEvent> addCalendarEvent(CalendarEvent event) async => event;
  @override Future<CalendarEvent> updateCalendarEvent(CalendarEvent updated) async => updated;
  @override Future<void> deleteCalendarEvent(String id) async {}
  @override Future<CropSale> addSale(CropSale sale) async => sale;
  @override Future<CropSale> updateSale(CropSale updated) async => updated;
  @override Future<void> deleteSale(String id) async {}
}
