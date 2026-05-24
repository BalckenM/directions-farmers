import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/traceability_data_source.dart';
import '../data/traceability_mock_data_source.dart';
import '../data/traceability_repository.dart';
import '../models/movement_record.dart';

final traceabilityDataSourceProvider = Provider<TraceabilityDataSource>(
  (ref) => TraceabilityMockDataSource(),
);

final traceabilityRepositoryProvider = Provider<TraceabilityRepository>(
  (ref) => TraceabilityRepository(ref.watch(traceabilityDataSourceProvider)),
);

final movementRecordsProvider =
    FutureProvider.autoDispose<List<MovementRecord>>(
      (ref) => ref.watch(traceabilityRepositoryProvider).getMovementRecords(),
    );
