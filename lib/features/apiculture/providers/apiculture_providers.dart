import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/apiculture_repository.dart';
import '../models/apiculture.dart';

// ── Apiaries ──────────────────────────────────────────────────────────────────

final _mockApiariesProvider = FutureProvider<List<Apiary>>((ref) {
  return ref.read(apicultureRepositoryProvider).getApiaries();
});

final apiariesProvider =
    Provider.autoDispose<AsyncValue<List<Apiary>>>((ref) {
  return ref.watch(_mockApiariesProvider);
});

// ── Hives ─────────────────────────────────────────────────────────────────────

final _mockHivesProvider = FutureProvider<List<Hive>>((ref) {
  return ref.read(apicultureRepositoryProvider).getHives();
});

final hivesProvider =
    Provider.autoDispose<AsyncValue<List<Hive>>>((ref) {
  return ref.watch(_mockHivesProvider);
});

/// Hives for a specific apiary.
final apiaryHivesProvider =
    Provider.autoDispose.family<AsyncValue<List<Hive>>, String>(
        (ref, apiaryId) {
  return ref.watch(_mockHivesProvider).whenData((hives) =>
      hives.where((h) => h.apiaryId == apiaryId).toList());
});

/// Single hive by id.
final hiveDetailProvider =
    Provider.autoDispose.family<AsyncValue<Hive?>, String>((ref, hiveId) {
  return ref.watch(_mockHivesProvider).whenData((hives) {
    try {
      return hives.firstWhere((h) => h.id == hiveId);
    } catch (_) {
      return null;
    }
  });
});

// ── Hive Inspections ──────────────────────────────────────────────────────────

final _mockInspectionsProvider = FutureProvider<List<HiveInspection>>((ref) {
  return ref.read(apicultureRepositoryProvider).getHiveInspections();
});

/// Inspection history for a specific hive, sorted newest-first.
final hiveInspectionHistoryProvider =
    Provider.autoDispose.family<AsyncValue<List<HiveInspection>>, String>(
        (ref, hiveId) {
  return ref.watch(_mockInspectionsProvider).whenData((inspections) {
    final filtered = inspections
        .where((i) => i.hiveId == hiveId)
        .toList()
      ..sort((a, b) => b.inspectionDate.compareTo(a.inspectionDate));
    return filtered;
  });
});
