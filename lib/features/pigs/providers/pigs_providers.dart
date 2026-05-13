import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/pigs_repository.dart';
import '../models/sow.dart';

// ── Sows ──────────────────────────────────────────────────────────────────────

final _mockSowsProvider = FutureProvider<List<Sow>>((ref) {
  return ref.read(pigsRepositoryProvider).getSows();
});

final sowsProvider =
    Provider.autoDispose<AsyncValue<List<Sow>>>((ref) {
  return ref.watch(_mockSowsProvider);
});

final sowDetailProvider =
    Provider.autoDispose.family<AsyncValue<Sow?>, String>((ref, sowId) {
  return ref.watch(_mockSowsProvider).whenData((sows) {
    try {
      return sows.firstWhere((s) => s.id == sowId);
    } catch (_) {
      return null;
    }
  });
});

// ── Farrowing Records ─────────────────────────────────────────────────────────

final _mockFarrowingProvider = FutureProvider<List<FarrowingRecord>>((ref) {
  return ref.read(pigsRepositoryProvider).getFarrowingRecords();
});

/// Farrowing history for a specific sow, sorted newest-first.
final sowFarrowingHistoryProvider =
    Provider.autoDispose.family<AsyncValue<List<FarrowingRecord>>, String>(
        (ref, sowId) {
  return ref.watch(_mockFarrowingProvider).whenData((records) {
    final filtered = records
        .where((r) => r.sowId == sowId)
        .toList()
      ..sort((a, b) =>
          (b.farrowingDate ?? '').compareTo(a.farrowingDate ?? ''));
    return filtered;
  });
});

// ── Service Records ───────────────────────────────────────────────────────────

final _mockServiceRecordsProvider =
    FutureProvider<List<SowServiceRecord>>((ref) {
  return ref.read(pigsRepositoryProvider).getSowServiceRecords();
});

/// Service history for a specific sow.
final sowServiceHistoryProvider =
    Provider.autoDispose.family<AsyncValue<List<SowServiceRecord>>, String>(
        (ref, sowId) {
  return ref.watch(_mockServiceRecordsProvider).whenData((records) {
    final filtered = records
        .where((r) => r.sowId == sowId)
        .toList()
      ..sort((a, b) =>
          (b.serviceDate ?? '').compareTo(a.serviceDate ?? ''));
    return filtered;
  });
});
