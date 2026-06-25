import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/features/record/data/record_data_source.dart';
import 'package:mobile_app/features/record/data/record_remote_data_source.dart';
import 'package:mobile_app/features/record/data/record_repository.dart';

final recordDataSourceProvider = Provider<RecordDataSource>(
  (ref) => RecordRemoteDataSource(ref.read(apiDioProvider)),
);

final recordRepositoryProvider = Provider<RecordRepository>(
  (ref) => RecordRepository(ref.watch(recordDataSourceProvider)),
);
