import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/events_repository.dart';
import '../models/breeding_event.dart';
import '../models/health_event.dart';
import '../models/weight_record.dart';
import 'events_providers.dart';

class EventsActionNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  EventsRepository get _repo => ref.read(eventsRepositoryProvider);

  Future<void> addHealthEvent(HealthEvent event) async {
    state = const AsyncValue.loading();
    try {
      await _repo.addHealthEvent(event);
      ref.invalidate(healthEventsProvider);
      ref.invalidate(healthEventsBySpeciesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> addWeightRecord(WeightRecord record) async {
    state = const AsyncValue.loading();
    try {
      await _repo.addWeightRecord(record);
      ref.invalidate(weightRecordsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> addBreedingEvent(BreedingEvent event) async {
    state = const AsyncValue.loading();
    try {
      await _repo.addBreedingEvent(event);
      ref.invalidate(breedingEventsProvider);
      ref.invalidate(breedingEventsBySpeciesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final eventsActionProvider =
    NotifierProvider<EventsActionNotifier, AsyncValue<void>>(
      EventsActionNotifier.new,
    );
