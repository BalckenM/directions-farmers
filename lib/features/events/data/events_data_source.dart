import 'package:mobile_app/features/events/models/breeding_event.dart';
import 'package:mobile_app/features/events/models/health_event.dart';
import 'package:mobile_app/features/events/models/weight_record.dart';

/// Contract that all events data sources must fulfil.
abstract class EventsDataSource {
  Future<List<HealthEvent>> getHealthEvents();
  Future<List<WeightRecord>> getWeightRecords();
  Future<List<BreedingEvent>> getBreedingEvents();

  Future<void> addHealthEvent(HealthEvent event);
  Future<void> addWeightRecord(WeightRecord record);
  Future<void> addBreedingEvent(BreedingEvent event);
}
