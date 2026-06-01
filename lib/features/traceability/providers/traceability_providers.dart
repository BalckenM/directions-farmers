import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/traceability_data_source.dart';
import '../data/traceability_remote_data_source.dart';
import '../data/traceability_repository.dart';
import '../models/movement_record.dart';

final traceabilityDataSourceProvider = Provider<TraceabilityDataSource>(
  (ref) => TraceabilityRemoteDataSource(ref.read(apiDioProvider)),
);

final traceabilityRepositoryProvider = Provider<TraceabilityRepository>(
  (ref) => TraceabilityRepository(ref.watch(traceabilityDataSourceProvider)),
);

final movementRecordsProvider =
    FutureProvider.autoDispose<List<MovementRecord>>(
      (ref) => ref.watch(traceabilityRepositoryProvider).getMovementRecords(),
    );
