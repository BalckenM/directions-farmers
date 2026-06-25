import '../models/movement_record.dart';
import 'traceability_data_source.dart';

// Stub — traceability module not yet active. No HTTP calls are made.
class TraceabilityRemoteDataSource implements TraceabilityDataSource {
  TraceabilityRemoteDataSource(dynamic _);

  @override Future<List<MovementRecord>> getMovementRecords() async => const [];
  @override Future<void> addMovementRecord(MovementRecord record) async {}
}
