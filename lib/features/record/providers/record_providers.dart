import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/record_data_source.dart';
import '../data/record_remote_data_source.dart';
import '../data/record_repository.dart';

final recordDataSourceProvider = Provider<RecordDataSource>(
  (ref) => RecordRemoteDataSource(ref.read(apiDioProvider)),
);

final recordRepositoryProvider = Provider<RecordRepository>(
  (ref) => RecordRepository(ref.watch(recordDataSourceProvider)),
);
