import '../models/aquaculture_unit.dart';
import '../models/water_quality_log.dart';

/// Contract that all aquaculture data sources must fulfil.
abstract class AquacultureDataSource {
  Future<List<AquacultureUnit>> getUnits();
  Future<List<WaterQualityLog>> getWaterQualityLogs();
}
