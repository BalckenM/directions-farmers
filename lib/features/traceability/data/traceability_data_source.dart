import '../models/movement_record.dart';

abstract class TraceabilityDataSource {
  Future<List<MovementRecord>> getMovementRecords();
  Future<void> addMovementRecord(MovementRecord record);
}
