import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/failure.dart';
import '../models/breeding_event.dart';
import '../models/health_event.dart';
import '../models/weight_record.dart';
import 'events_data_source.dart';
import 'events_mock_data_source.dart';
import 'events_remote_data_source.dart';

class EventsRepository {
  EventsRepository(this._source);

  final EventsDataSource _source;

  Future<List<HealthEvent>> getHealthEvents() async {
    try {
      return await _source.getHealthEvents();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<List<WeightRecord>> getWeightRecords() async {
    try {
      return await _source.getWeightRecords();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<List<BreedingEvent>> getBreedingEvents() async {
    try {
      return await _source.getBreedingEvents();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<void> addHealthEvent(HealthEvent event) async {
    try {
      await _source.addHealthEvent(event);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<void> addWeightRecord(WeightRecord record) async {
    try {
      await _source.addWeightRecord(record);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<void> addBreedingEvent(BreedingEvent event) async {
    try {
      await _source.addBreedingEvent(event);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }
}

final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  final EventsDataSource source = AppConstants.useMockData
      ? EventsMockDataSource()
      : EventsRemoteDataSource();
  return EventsRepository(source);
});

final healthEventsProvider =
    FutureProvider.autoDispose<List<HealthEvent>>((ref) {
  return ref.watch(eventsRepositoryProvider).getHealthEvents();
});

/// Same as [healthEventsProvider] but filtered by [animalType].
/// Pass an empty string to get all species.
final healthEventsBySpeciesProvider =
    FutureProvider.autoDispose.family<List<HealthEvent>, String>(
        (ref, species) async {
  final events =
      await ref.watch(eventsRepositoryProvider).getHealthEvents();
  if (species.isEmpty) return events;
  return events.where((e) => e.animalType == species).toList();
});
