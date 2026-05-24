import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/aquaculture_data_source.dart';
import '../data/aquaculture_mock_data_source.dart';
import '../data/aquaculture_repository.dart';
import '../models/aquaculture_unit.dart';
import '../models/water_quality_log.dart';

final aquacultureDataSourceProvider = Provider<AquacultureDataSource>(
  (ref) => AquacultureMockDataSource(),
);

final aquacultureRepositoryProvider = Provider<AquacultureRepository>(
  (ref) => AquacultureRepository(ref.watch(aquacultureDataSourceProvider)),
);

// ── Units ─────────────────────────────────────────────────────────────────────

final _mockAquaUnitsProvider = FutureProvider<List<AquacultureUnit>>((ref) {
  return ref.watch(aquacultureRepositoryProvider).getUnits();
});

final aquacultureUnitsProvider =
    Provider.autoDispose<AsyncValue<List<AquacultureUnit>>>((ref) {
  return ref.watch(_mockAquaUnitsProvider);
});

final aquacultureUnitDetailProvider =
    Provider.autoDispose.family<AsyncValue<AquacultureUnit?>, String>(
        (ref, unitId) {
  return ref.watch(_mockAquaUnitsProvider).whenData((units) {
    try {
      return units.firstWhere((u) => u.id == unitId);
    } catch (_) {
      return null;
    }
  });
});

// ── Water Quality Logs ────────────────────────────────────────────────────────

final _mockWaterQualityProvider = FutureProvider<List<WaterQualityLog>>((ref) {
  return ref.watch(aquacultureRepositoryProvider).getWaterQualityLogs();
});

/// Water quality logs for a specific pond/unit, sorted newest-first.
final unitWaterQualityProvider =
    Provider.autoDispose.family<AsyncValue<List<WaterQualityLog>>, String>(
        (ref, pondId) {
  return ref.watch(_mockWaterQualityProvider).whenData((logs) {
    final filtered = logs
        .where((l) => l.pondId == pondId)
        .toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return filtered;
  });
});
