import '../models/movement_record.dart';
import 'traceability_data_source.dart';

class TraceabilityRemoteDataSource implements TraceabilityDataSource {
  @override
  Future<List<MovementRecord>> getMovementRecords() =>
      throw UnimplementedError('TraceabilityRemoteDataSource.getMovementRecords not implemented');
}
