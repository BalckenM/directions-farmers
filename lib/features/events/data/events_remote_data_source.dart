import '../models/breeding_event.dart';
import '../models/health_event.dart';
import '../models/weight_record.dart';
import 'events_data_source.dart';

/// Stub remote data source — replace with real Dio calls when backend is ready.
class EventsRemoteDataSource implements EventsDataSource {
  @override
  Future<List<HealthEvent>> getHealthEvents() =>
      throw UnimplementedError('EventsRemoteDataSource.getHealthEvents not implemented');

  @override
  Future<List<WeightRecord>> getWeightRecords() =>
      throw UnimplementedError('EventsRemoteDataSource.getWeightRecords not implemented');

  @override
  Future<List<BreedingEvent>> getBreedingEvents() =>
      throw UnimplementedError('EventsRemoteDataSource.getBreedingEvents not implemented');
}
