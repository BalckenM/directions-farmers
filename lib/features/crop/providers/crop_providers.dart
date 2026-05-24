import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../data/advisor_data_source.dart';
import '../data/advisor_mock_data_source.dart';
import '../data/advisor_remote_data_source.dart';
import '../data/advisor_repository.dart';
import '../data/crop_data_source.dart';
import '../data/crop_mock_data_source.dart';
import '../data/crop_repository.dart';
import '../data/disease_data_source.dart';
import '../data/disease_mock_data_source.dart';
import '../data/disease_remote_data_source.dart';
import '../data/disease_repository.dart';
import '../data/weather_data_source.dart';
import '../data/weather_mock_data_source.dart';
import '../data/weather_repository.dart';
import '../models/advisor_models.dart';
import '../models/advisory_content.dart';
import '../models/calendar_event.dart';
import '../models/crop.dart';
import '../models/crop_category.dart';
import '../models/crop_expense.dart';
import '../models/crop_field.dart';
import '../models/crop_sale.dart';
import '../models/crop_season.dart';
import '../models/crop_task.dart';
import '../models/disease_detection.dart';
import '../models/farm_weather.dart';
import '../models/harvest_record.dart';
import '../models/pest_observation.dart';
import '../models/planting_plan.dart';
import '../models/spray_record.dart';
import '../models/weather_alert.dart';

// ── Farm Identity ─────────────────────────────────────────────────────────────

/// Resolves the active farm ID for the currently signed-in user.
///
/// • Mock mode  — always returns the seeded mock constant ('FARM-001') so all
///   pre-populated mock data is visible immediately after login.
/// • Live mode  — returns the authenticated user's id, which the real API uses
///   as the farm-owner identifier.  Falls back to 'FARM-001' when unauthenticated
///   (only happens during onboarding before the session is established).
final currentFarmIdProvider = Provider<String>((ref) {
  if (AppConstants.useMockData) return 'FARM-001';
  return ref.watch(currentUserProvider)?.id ?? 'FARM-001';
});

// ── Repository ───────────────────────────────────────────────────────────────

final cropDataSourceProvider = Provider<CropDataSource>(
  (ref) => CropMockDataSource(),
);

final cropRepositoryProvider = Provider<CropRepository>(
  (ref) => CropRepository(ref.watch(cropDataSourceProvider)),
);

// ── Crop Catalog ─────────────────────────────────────────────────────────────

final cropCategoriesProvider = FutureProvider<List<CropCategory>>((ref) async {
  return ref.watch(cropRepositoryProvider).getCropCategories();
});

final cropsProvider = FutureProvider.family<List<Crop>, String?>((
  ref,
  categoryId,
) async {
  return ref.watch(cropRepositoryProvider).getCrops(categoryId: categoryId);
});

final cropByIdProvider = FutureProvider.family<Crop?, String>((ref, id) async {
  return ref.watch(cropRepositoryProvider).getCropById(id);
});

// ── Fields ───────────────────────────────────────────────────────────────────

/// Reactive fields list — invalidated after add/update/delete.
final cropFieldsProvider = FutureProvider.family<List<CropField>, String?>((
  ref,
  farmId,
) async {
  return ref.watch(cropRepositoryProvider).getFields(farmId: farmId);
});

final cropFieldByIdProvider = FutureProvider.family<CropField?, String>((
  ref,
  id,
) async {
  return ref.watch(cropRepositoryProvider).getFieldById(id);
});

// ── Seasons ──────────────────────────────────────────────────────────────────

final seasonsProvider = FutureProvider.family<List<CropSeason>, String?>((
  ref,
  farmId,
) async {
  return ref.watch(cropRepositoryProvider).getSeasons(farmId: farmId);
});

// ── Planting Plans ────────────────────────────────────────────────────────────

final plantingPlansProvider =
    FutureProvider.family<List<PlantingPlan>, String?>((ref, fieldId) async {
      return ref
          .watch(cropRepositoryProvider)
          .getPlantingPlans(fieldId: fieldId);
    });

// ── Calendar Events ───────────────────────────────────────────────────────────

final calendarEventsProvider =
    FutureProvider.family<List<CalendarEvent>, String?>((ref, fieldId) async {
      return ref
          .watch(cropRepositoryProvider)
          .getCalendarEvents(fieldId: fieldId);
    });

final upcomingCalendarEventsProvider = FutureProvider<List<CalendarEvent>>((
  ref,
) async {
  final all = await ref.watch(cropRepositoryProvider).getCalendarEvents();
  final now = DateTime.now();
  return all
      .where((e) => e.scheduledDate.isAfter(now) && !e.isCompleted)
      .take(10)
      .toList();
});

// ── Tasks ─────────────────────────────────────────────────────────────────────

final cropTasksProvider = FutureProvider.family<List<CropTask>, String?>((
  ref,
  farmId,
) async {
  return ref.watch(cropRepositoryProvider).getTasks(farmId: farmId);
});

final openCropTasksProvider = FutureProvider<List<CropTask>>((ref) async {
  final all = await ref.watch(cropRepositoryProvider).getTasks();
  return all.where((t) => !t.isCompleted).toList();
});

final overdueCropTasksProvider = FutureProvider<List<CropTask>>((ref) async {
  final all = await ref.watch(cropRepositoryProvider).getTasks();
  return all.where((t) => t.isOverdue).toList();
});

// ── Weather Alerts ────────────────────────────────────────────────────────────

final weatherAlertsProvider =
    FutureProvider.family<List<WeatherAlert>, String?>((ref, farmId) async {
      return ref.watch(cropRepositoryProvider).getWeatherAlerts(farmId: farmId);
    });

final actionRequiredAlertsProvider = FutureProvider<List<WeatherAlert>>((
  ref,
) async {
  final all = await ref.watch(cropRepositoryProvider).getWeatherAlerts();
  return all.where((a) => a.actionRequired && a.isActive).toList();
});

// ── Pest Observations ─────────────────────────────────────────────────────────

final pestObservationsProvider =
    FutureProvider.family<List<PestObservation>, String?>((ref, fieldId) async {
      return ref
          .watch(cropRepositoryProvider)
          .getPestObservations(fieldId: fieldId);
    });

final sprayRecordsProvider = FutureProvider.family<List<SprayRecord>, String?>((
  ref,
  fieldId,
) async {
  return ref.watch(cropRepositoryProvider).getSprayRecords(fieldId: fieldId);
});

// ── Expenses ──────────────────────────────────────────────────────────────────

final cropExpensesProvider = FutureProvider.family<List<CropExpense>, String?>((
  ref,
  farmId,
) async {
  return ref.watch(cropRepositoryProvider).getExpenses(farmId: farmId);
});

final totalExpensesProvider = FutureProvider<double>((ref) async {
  final all = await ref.watch(cropRepositoryProvider).getExpenses();
  return all.fold<double>(0.0, (sum, e) => sum + e.amountZar);
});

// ── Harvest ───────────────────────────────────────────────────────────────────

final harvestRecordsProvider =
    FutureProvider.family<List<HarvestRecord>, String?>((ref, fieldId) async {
      return ref
          .watch(cropRepositoryProvider)
          .getHarvestRecords(fieldId: fieldId);
    });

// ── Sales ─────────────────────────────────────────────────────────────────────

final cropSalesProvider = FutureProvider.family<List<CropSale>, String?>((
  ref,
  farmId,
) async {
  return ref.watch(cropRepositoryProvider).getSales(farmId: farmId);
});

final totalRevenueProvider = FutureProvider<double>((ref) async {
  final all = await ref.watch(cropRepositoryProvider).getSales();
  return all.fold<double>(0.0, (sum, s) => sum + s.totalAmountZar);
});

// ── Profitability (computed) ──────────────────────────────────────────────────

final grossMarginProvider = FutureProvider<GrossMargin>((ref) async {
  final revenue = await ref.watch(totalRevenueProvider.future);
  final costs = await ref.watch(totalExpensesProvider.future);
  final margin = revenue - costs;
  final marginPct = revenue > 0 ? (margin / revenue) * 100 : 0.0;
  return GrossMargin(
    revenue: revenue,
    costs: costs,
    margin: margin,
    marginPct: marginPct,
  );
});

class GrossMargin {
  const GrossMargin({
    required this.revenue,
    required this.costs,
    required this.margin,
    required this.marginPct,
  });
  final double revenue;
  final double costs;
  final double margin;
  final double marginPct;
}

// ── Advisory ─────────────────────────────────────────────────────────────────

final advisoryContentProvider =
    FutureProvider.family<List<AdvisoryContent>, String?>((
      ref,
      category,
    ) async {
      return ref
          .watch(cropRepositoryProvider)
          .getAdvisoryContent(category: category);
    });

final latestAdvisoryProvider = FutureProvider<AdvisoryContent?>((ref) async {
  final all = await ref.watch(cropRepositoryProvider).getAdvisoryContent();
  return all.isNotEmpty ? all.first : null;
});

// ── Weather ───────────────────────────────────────────────────────────────────

final weatherDataSourceProvider = Provider<WeatherDataSource>(
  (ref) => WeatherMockDataSource(),
);

final weatherRepositoryProvider = Provider<WeatherRepository>(
  (ref) => WeatherRepository(ref.watch(weatherDataSourceProvider)),
);

final currentWeatherProvider = FutureProvider.family<FarmWeather, String>((
  ref,
  farmId,
) async {
  return ref.watch(weatherRepositoryProvider).getCurrentWeather(farmId);
});

final weatherForecastProvider =
    FutureProvider.family<List<WeatherForecastDay>, String>((
      ref,
      farmId,
    ) async {
      return ref.watch(weatherRepositoryProvider).getForecast(farmId);
    });

final agriculturalAlertsProvider =
    FutureProvider.family<List<WeatherAlert>, String>((ref, farmId) async {
      return ref.watch(weatherRepositoryProvider).getAgriculturalAlerts(farmId);
    });

// ── Disease Detection ─────────────────────────────────────────────────────────

final diseaseDataSourceProvider = Provider<DiseaseDataSource>(
  (ref) => AppConstants.useMockData
      ? DiseaseMockDataSource()
      : DiseaseRemoteDataSource(),
);

final diseaseRepositoryProvider = Provider<DiseaseRepository>(
  (ref) => DiseaseRepository(ref.watch(diseaseDataSourceProvider)),
);

final diseaseLibraryProvider = FutureProvider<List<DiseaseInfo>>((ref) async {
  return ref.watch(diseaseRepositoryProvider).getDiseaseLibrary();
});

// ── Advisor ───────────────────────────────────────────────────────────────────

final advisorDataSourceProvider = Provider<AdvisorDataSource>(
  (ref) => AppConstants.useMockData
      ? AdvisorMockDataSource()
      : AdvisorRemoteDataSource(),
);

final advisorRepositoryProvider = Provider<AdvisorRepository>(
  (ref) => AdvisorRepository(ref.watch(advisorDataSourceProvider)),
);

final dailyAdvisorBriefingProvider =
    FutureProvider.family<List<AdvisorResponse>, String>((ref, farmId) async {
      return ref.watch(advisorRepositoryProvider).getDailyBriefing(farmId);
    });
