import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/record_data_source.dart';
import '../data/record_mock_data_source.dart';
import '../data/record_repository.dart';

final recordDataSourceProvider = Provider<RecordDataSource>(
  (ref) => RecordMockDataSource(),
);

final recordRepositoryProvider = Provider<RecordRepository>(
  (ref) => RecordRepository(ref.watch(recordDataSourceProvider)),
);
