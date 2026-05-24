import '../../../core/errors/app_exception.dart';
import '../../../core/errors/failure.dart';
import '../models/aquaculture_unit.dart';
import '../models/water_quality_log.dart';
import 'aquaculture_data_source.dart';

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

