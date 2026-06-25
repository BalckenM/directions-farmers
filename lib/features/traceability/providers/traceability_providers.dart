import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/features/traceability/data/traceability_data_source.dart';
import 'package:mobile_app/features/traceability/data/traceability_remote_data_source.dart';
import 'package:mobile_app/features/traceability/data/traceability_repository.dart';
import 'package:mobile_app/features/traceability/models/movement_record.dart';

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
