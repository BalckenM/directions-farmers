import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/failure.dart';
import '../models/movement_record.dart';
import 'traceability_data_source.dart';
import 'traceability_mock_data_source.dart';
import 'traceability_remote_data_source.dart';

class TraceabilityRepository {
  TraceabilityRepository(this._source);

  final TraceabilityDataSource _source;

  Future<List<MovementRecord>> getMovementRecords() async {
    try {
      return await _source.getMovementRecords();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<void> addMovementRecord(MovementRecord record) async {
    try {
      await _source.addMovementRecord(record);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }
}

final traceabilityRepositoryProvider = Provider<TraceabilityRepository>((ref) {
  final TraceabilityDataSource source = AppConstants.useMockData
      ? TraceabilityMockDataSource()
      : TraceabilityRemoteDataSource();
  return TraceabilityRepository(source);
});
