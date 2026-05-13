import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/failure.dart';
import '../models/sow.dart';
import 'pigs_data_source.dart';
import 'pigs_mock_data_source.dart';
import 'pigs_remote_data_source.dart';

class PigsRepository {
  PigsRepository(this._source);

  final PigsDataSource _source;

  Future<List<Sow>> getSows() async {
    try {
      return await _source.getSows();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<Sow?> getSowById(String id) async {
    final sows = await getSows();
    try {
      return sows.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<FarrowingRecord>> getFarrowingRecords() async {
    try {
      return await _source.getFarrowingRecords();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<List<SowServiceRecord>> getSowServiceRecords() async {
    try {
      return await _source.getSowServiceRecords();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }
}

final pigsRepositoryProvider = Provider<PigsRepository>((ref) {
  final PigsDataSource source = AppConstants.useMockData
      ? PigsMockDataSource()
      : PigsRemoteDataSource();
  return PigsRepository(source);
});
