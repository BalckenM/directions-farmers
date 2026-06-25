import '../models/breeding_event.dart';
import '../models/health_event.dart';
import '../models/weight_record.dart';
import 'events_data_source.dart';

// Stub — events module not yet active. No HTTP calls are made.
class EventsRemoteDataSource implements EventsDataSource {
  EventsRemoteDataSource(dynamic _);

  @override Future<List<HealthEvent>> getHealthEvents() async => const [];
  @override Future<List<WeightRecord>> getWeightRecords() async => const [];
  @override Future<List<BreedingEvent>> getBreedingEvents() async => const [];
  @override Future<void> addHealthEvent(HealthEvent event) async {}
  @override Future<void> addWeightRecord(WeightRecord record) async {}
  @override Future<void> addBreedingEvent(BreedingEvent event) async {}
}
