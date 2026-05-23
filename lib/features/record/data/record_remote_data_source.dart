import '../models/feed_log.dart';
import 'record_data_source.dart';

class RecordRemoteDataSource implements RecordDataSource {
  @override
  Future<List<FeedLog>> getFeedLogs() =>
      throw UnimplementedError('RecordRemoteDataSource.getFeedLogs not implemented');

  @override
  Future<void> addFeedLog(FeedLog log) =>
      throw UnimplementedError('RecordRemoteDataSource.addFeedLog not implemented');
}
