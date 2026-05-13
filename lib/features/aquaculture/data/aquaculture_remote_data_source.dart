import '../models/aquaculture_unit.dart';
import '../models/water_quality_log.dart';
import 'aquaculture_data_source.dart';

/// Stub remote data source — replace with real Dio calls when backend is ready.
class AquacultureRemoteDataSource implements AquacultureDataSource {
  @override
  Future<List<AquacultureUnit>> getUnits() =>
      throw UnimplementedError('AquacultureRemoteDataSource.getUnits not implemented');

  @override
  Future<List<WaterQualityLog>> getWaterQualityLogs() =>
      throw UnimplementedError('AquacultureRemoteDataSource.getWaterQualityLogs not implemented');
}
