import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/failure.dart';
import '../models/aquaculture_unit.dart';
import '../models/water_quality_log.dart';
import 'aquaculture_data_source.dart';
import 'aquaculture_mock_data_source.dart';
import 'aquaculture_remote_data_source.dart';

class AquacultureRepository {
  AquacultureRepository(this._source);

  final AquacultureDataSource _source;

  Future<List<AquacultureUnit>> getUnits() async {
    try {
      return await _source.getUnits();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<AquacultureUnit?> getUnitById(String id) async {
    final units = await getUnits();
    try {
      return units.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<WaterQualityLog>> getWaterQualityLogs() async {
    try {
      return await _source.getWaterQualityLogs();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }
}

final aquacultureRepositoryProvider = Provider<AquacultureRepository>((ref) {
  final AquacultureDataSource source = AppConstants.useMockData
      ? AquacultureMockDataSource()
      : AquacultureRemoteDataSource();
  return AquacultureRepository(source);
});
