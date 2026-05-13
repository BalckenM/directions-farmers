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

abstract class CropDataSource {
  // ── Read ────────────────────────────────────────────────────────────────────
  Future<List<CropCategory>> getCropCategories();
  Future<List<Crop>> getCrops();
  Future<List<CropField>> getCropFields();
  Future<List<CropSeason>> getSeasons();
  Future<List<PlantingPlan>> getPlantingPlans();
  Future<List<CalendarEvent>> getCalendarEvents();
  Future<List<CropTask>> getCropTasks();
  Future<List<WeatherAlert>> getWeatherAlerts();
  Future<List<PestObservation>> getPestObservations();
  Future<List<SprayRecord>> getSprayRecords();
  Future<List<CropExpense>> getCropExpenses();
  Future<List<HarvestRecord>> getCropHarvestRecords();
  Future<List<CropSale>> getCropSales();
  Future<List<AdvisoryContent>> getAdvisoryContent();

  // ── Fields ──────────────────────────────────────────────────────────────────
  Future<CropField> addField(CropField field);
  Future<CropField> updateField(CropField updated);
  Future<void> deleteField(String id);

  // ── Seasons ─────────────────────────────────────────────────────────────────
  Future<CropSeason> addSeason(CropSeason season);
  Future<CropSeason> updateSeason(CropSeason updated);
  Future<void> deleteSeason(String id);

  // ── Planting Plans ───────────────────────────────────────────────────────────
  Future<PlantingPlan> addPlantingPlan(PlantingPlan plan);
  Future<PlantingPlan> updatePlantingPlan(PlantingPlan updated);
  Future<void> deletePlantingPlan(String id);

  // ── Tasks ────────────────────────────────────────────────────────────────────
  Future<CropTask> addTask(CropTask task);
  Future<CropTask> updateTask(CropTask updated);
  Future<void> deleteTask(String id);

  // ── Pest Observations ────────────────────────────────────────────────────────
  Future<PestObservation> addPestObservation(PestObservation obs);
  Future<PestObservation> updatePestObservation(PestObservation updated);
  Future<void> deletePestObservation(String id);

  // ── Spray Records ────────────────────────────────────────────────────────────
  Future<SprayRecord> addSprayRecord(SprayRecord record);
  Future<SprayRecord> updateSprayRecord(SprayRecord updated);
  Future<void> deleteSprayRecord(String id);

  // ── Expenses ─────────────────────────────────────────────────────────────────
  Future<CropExpense> addExpense(CropExpense expense);
  Future<CropExpense> updateExpense(CropExpense updated);
  Future<void> deleteExpense(String id);

  // ── Harvest ──────────────────────────────────────────────────────────────────
  Future<HarvestRecord> addHarvestRecord(HarvestRecord record);
  Future<HarvestRecord> updateHarvestRecord(HarvestRecord updated);
  Future<void> deleteHarvestRecord(String id);

  // ── Sales ─────────────────────────────────────────────────────────────────────
  Future<CropSale> addSale(CropSale sale);
  Future<CropSale> updateSale(CropSale updated);
  Future<void> deleteSale(String id);
}
