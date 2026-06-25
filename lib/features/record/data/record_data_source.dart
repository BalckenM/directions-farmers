import 'package:mobile_app/features/record/models/feed_log.dart';

abstract class RecordDataSource {
  Future<List<FeedLog>> getFeedLogs();
  Future<void> addFeedLog(FeedLog log);
}
