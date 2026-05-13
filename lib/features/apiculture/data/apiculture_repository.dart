import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/failure.dart';
import '../models/apiculture.dart';
import 'apiculture_data_source.dart';
import 'apiculture_mock_data_source.dart';
import 'apiculture_remote_data_source.dart';

class ApicultureRepository {
  ApicultureRepository(this._source);

  final ApicultureDataSource _source;

  /// Returns all apiaries.
  Future<List<Apiary>> getApiaries() async {
    try {
      return await _source.getApiaries();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  /// Returns all hives across all apiaries.
  Future<List<Hive>> getHives() async {
    try {
      return await _source.getHives();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<Hive?> getHiveById(String id) async {
    final hives = await getHives();
    try {
      return hives.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<HiveInspection>> getHiveInspections() async {
    try {
      return await _source.getHiveInspections();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }
}

final apicultureRepositoryProvider = Provider<ApicultureRepository>((ref) {
  final ApicultureDataSource source = AppConstants.useMockData
      ? ApicultureMockDataSource()
      : ApicultureRemoteDataSource();
  return ApicultureRepository(source);
});
