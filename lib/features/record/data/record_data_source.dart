import '../models/feed_log.dart';

abstract class RecordDataSource {
  Future<List<FeedLog>> getFeedLogs();
}
