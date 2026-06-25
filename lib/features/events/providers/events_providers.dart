import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/features/events/data/events_data_source.dart';
import 'package:mobile_app/features/events/data/events_remote_data_source.dart';
import 'package:mobile_app/features/events/data/events_repository.dart';
import 'package:mobile_app/features/events/models/breeding_event.dart';
import 'package:mobile_app/features/events/models/health_event.dart';
import 'package:mobile_app/features/events/models/weight_record.dart';

final eventsDataSourceProvider = Provider<EventsDataSource>(
  (ref) => EventsRemoteDataSource(ref.read(apiDioProvider)),
);

final eventsRepositoryProvider = Provider<EventsRepository>(
  (ref) => EventsRepository(ref.watch(eventsDataSourceProvider)),
);

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

final breedingEventsProvider =
    FutureProvider.autoDispose<List<BreedingEvent>>((ref) {
  return ref.watch(eventsRepositoryProvider).getBreedingEvents();
});

/// Same as [breedingEventsProvider] but filtered by [animalType].
/// Pass an empty string to get all species.
final breedingEventsBySpeciesProvider =
    FutureProvider.autoDispose.family<List<BreedingEvent>, String>(
        (ref, species) async {
  final all = await ref.watch(eventsRepositoryProvider).getBreedingEvents();
  if (species.isEmpty) return all;
  return all.where((e) => e.animalType == species).toList();
});

final weightRecordsProvider =
    FutureProvider.autoDispose<List<WeightRecord>>((ref) {
  return ref.watch(eventsRepositoryProvider).getWeightRecords();
});
