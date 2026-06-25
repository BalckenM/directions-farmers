import '../models/feed_log.dart';
import 'record_data_source.dart';

// Stub — record module not yet active. No HTTP calls are made.
class RecordRemoteDataSource implements RecordDataSource {
  RecordRemoteDataSource(dynamic _);

  @override Future<List<FeedLog>> getFeedLogs() async => const [];
  @override Future<void> addFeedLog(FeedLog log) async {}
}
