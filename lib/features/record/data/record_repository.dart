import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/failure.dart';
import '../models/feed_log.dart';
import 'record_data_source.dart';
import 'record_mock_data_source.dart';
import 'record_remote_data_source.dart';

class RecordRepository {
  RecordRepository(this._source);

  final RecordDataSource _source;

  Future<List<FeedLog>> getFeedLogs() async {
    try {
      return await _source.getFeedLogs();
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw UnexpectedFailure(e.toString());
    }
  }

  Future<void> addFeedLog(FeedLog log) async {
    try {
      await _source.addFeedLog(log);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw UnexpectedFailure(e.toString());
    }
  }
}

final recordRepositoryProvider = Provider<RecordRepository>((ref) {
  final RecordDataSource source = AppConstants.useMockData
      ? RecordMockDataSource()
      : RecordRemoteDataSource();
  return RecordRepository(source);
});
