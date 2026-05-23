import '../models/feed_log.dart';

abstract class RecordDataSource {
  Future<List<FeedLog>> getFeedLogs();
  Future<void> addFeedLog(FeedLog log);
}
