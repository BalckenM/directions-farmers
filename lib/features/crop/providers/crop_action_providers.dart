import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/crop_repository.dart';
import '../models/calendar_event.dart';
import '../models/crop_expense.dart';
import '../models/crop_field.dart';
import '../models/crop_sale.dart';
import '../models/crop_season.dart';
import '../models/crop_task.dart';
import '../models/harvest_record.dart';
import '../models/pest_observation.dart';
import '../models/planting_plan.dart';
import '../models/spray_record.dart';
import 'crop_providers.dart';

class CropActionNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  CropRepository get _repo => ref.read(cropRepositoryProvider);

  // Fields
  Future<void> addField(CropField field) async {
    state = const AsyncValue.loading();
    try {
      await _repo.addField(field);
      ref.invalidate(cropFieldsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateField(CropField field) async {
    state = const AsyncValue.loading();
    try {
      await _repo.updateField(field);
      ref.invalidate(cropFieldsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteField(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repo.deleteField(id);
      ref.invalidate(cropFieldsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // Seasons
  Future<void> addSeason(CropSeason season) async {
    state = const AsyncValue.loading();
    try {
      await _repo.addSeason(season);
      ref.invalidate(seasonsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateSeason(CropSeason season) async {
    state = const AsyncValue.loading();
    try {
      await _repo.updateSeason(season);
      ref.invalidate(seasonsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteSeason(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repo.deleteSeason(id);
      ref.invalidate(seasonsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // Planting Plans
  Future<void> addPlantingPlan(PlantingPlan plan) async {
    state = const AsyncValue.loading();
    try {
      await _repo.addPlantingPlan(plan);
      ref.invalidate(plantingPlansProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updatePlantingPlan(PlantingPlan plan) async {
    state = const AsyncValue.loading();
    try {
      await _repo.updatePlantingPlan(plan);
      ref.invalidate(plantingPlansProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // Calendar Events
  Future<void> addCalendarEvent(CalendarEvent event) async {
    state = const AsyncValue.loading();
    try {
      await _repo.addCalendarEvent(event);
      ref.invalidate(calendarEventsProvider);
      ref.invalidate(upcomingCalendarEventsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateCalendarEvent(CalendarEvent event) async {
    state = const AsyncValue.loading();
    try {
      await _repo.updateCalendarEvent(event);
      ref.invalidate(calendarEventsProvider);
      ref.invalidate(upcomingCalendarEventsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteCalendarEvent(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repo.deleteCalendarEvent(id);
      ref.invalidate(calendarEventsProvider);
      ref.invalidate(upcomingCalendarEventsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // Tasks
  Future<void> addTask(CropTask task) async {
    state = const AsyncValue.loading();
    try {
      await _repo.addTask(task);
      ref.invalidate(cropTasksProvider);
      ref.invalidate(openCropTasksProvider);
      ref.invalidate(overdueCropTasksProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateTask(CropTask task) async {
    state = const AsyncValue.loading();
    try {
      await _repo.updateTask(task);
      ref.invalidate(cropTasksProvider);
      ref.invalidate(openCropTasksProvider);
      ref.invalidate(overdueCropTasksProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repo.deleteTask(id);
      ref.invalidate(cropTasksProvider);
      ref.invalidate(openCropTasksProvider);
      ref.invalidate(overdueCropTasksProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // Expenses
  Future<void> addExpense(CropExpense expense) async {
    state = const AsyncValue.loading();
    try {
      await _repo.addExpense(expense);
      ref.invalidate(cropExpensesProvider);
      ref.invalidate(totalExpensesProvider);
      ref.invalidate(grossMarginProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateExpense(CropExpense expense) async {
    state = const AsyncValue.loading();
    try {
      await _repo.updateExpense(expense);
      ref.invalidate(cropExpensesProvider);
      ref.invalidate(totalExpensesProvider);
      ref.invalidate(grossMarginProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteExpense(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repo.deleteExpense(id);
      ref.invalidate(cropExpensesProvider);
      ref.invalidate(totalExpensesProvider);
      ref.invalidate(grossMarginProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // Harvest
  Future<void> addHarvestRecord(HarvestRecord record) async {
    state = const AsyncValue.loading();
    try {
      await _repo.addHarvestRecord(record);
      ref.invalidate(harvestRecordsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateHarvestRecord(HarvestRecord record) async {
    state = const AsyncValue.loading();
    try {
      await _repo.updateHarvestRecord(record);
      ref.invalidate(harvestRecordsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // Sales
  Future<void> addSale(CropSale sale) async {
    state = const AsyncValue.loading();
    try {
      await _repo.addSale(sale);
      ref.invalidate(cropSalesProvider);
      ref.invalidate(totalRevenueProvider);
      ref.invalidate(grossMarginProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> updateSale(CropSale sale) async {
    state = const AsyncValue.loading();
    try {
      await _repo.updateSale(sale);
      ref.invalidate(cropSalesProvider);
      ref.invalidate(totalRevenueProvider);
      ref.invalidate(grossMarginProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // Pest Observations
  Future<void> addPestObservation(PestObservation obs) async {
    state = const AsyncValue.loading();
    try {
      await _repo.addPestObservation(obs);
      ref.invalidate(pestObservationsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // Spray Records
  Future<void> addSprayRecord(SprayRecord record) async {
    state = const AsyncValue.loading();
    try {
      await _repo.addSprayRecord(record);
      ref.invalidate(sprayRecordsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> deleteSprayRecord(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repo.deleteSprayRecord(id);
      ref.invalidate(sprayRecordsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final cropActionProvider =
    NotifierProvider<CropActionNotifier, AsyncValue<void>>(
      CropActionNotifier.new,
    );
