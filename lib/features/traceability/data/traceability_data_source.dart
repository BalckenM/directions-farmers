import 'package:mobile_app/features/traceability/models/movement_record.dart';

abstract class TraceabilityDataSource {
  Future<List<MovementRecord>> getMovementRecords();
  Future<void> addMovementRecord(MovementRecord record);
}
