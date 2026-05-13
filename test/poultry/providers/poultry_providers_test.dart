// Provider integration tests — verify Riverpod providers correctly expose
// poultry flock data for all 4 farming types, and that status/edit overrides
// work correctly.
//
// Requires TestWidgetsFlutterBinding for rootBundle asset access.
// Run with:  flutter test test/poultry/providers/poultry_providers_test.dart
//
// NOTE: flocksProvider is Provider<AsyncValue<List<PoultryFlock>>> (autoDispose).
//       We resolve async data via a ProviderContainer listener on the provider.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/poultry/models/poultry_flock.dart';
import 'package:mobile_app/features/poultry/providers/poultry_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  // =========================================================================
  // flocksProvider — full list
  // =========================================================================

  group('flocksProvider', () {
    test('resolves to AsyncData with 14 flocks', () async {
      final flocks = await _waitForFlocks(container);
      expect(flocks.length, 14);
    });

    test('contains all 4 core production types', () async {
      final flocks = await _waitForFlocks(container);
      expect(flocks.any((f) => f.isBroiler), isTrue, reason: 'Missing broiler flocks');
      expect(flocks.any((f) => f.isLayer), isTrue, reason: 'Missing layer flocks');
      expect(flocks.any((f) => f.isBreeder), isTrue, reason: 'Missing breeder flocks');
      expect(flocks.any((f) => f.isHatchery), isTrue, reason: 'Missing hatchery flock — flock-014 must exist in mock data with productionType="hatchery"');
    });

    test('broiler count is 3', () async {
      final flocks = await _waitForFlocks(container);
      expect(flocks.where((f) => f.isBroiler).length, 3);
    });

    test('layer count is 3', () async {
      final flocks = await _waitForFlocks(container);
      expect(flocks.where((f) => f.isLayer).length, 3);
    });

    test('breeder count is 2', () async {
      final flocks = await _waitForFlocks(container);
      expect(flocks.where((f) => f.isBreeder).length, 2);
    });

    test('active flock count is 12', () async {
      final flocks = await _waitForFlocks(container);
      expect(flocks.where((f) => f.isActive).length, 12);
    });

    test('addedFlocksProvider: new flock appears in flocksProvider', () async {
      // Before adding: 14 mock flocks
      final before = await _waitForFlocks(container);
      expect(before.length, 14);

      // Add a flock in-memory
      const newId = 'flock-test-new';
      container.read(addedFlocksProvider.notifier).addFlock(
            const PoultryFlock(
              id: newId,
              farmId: 'farm-001',
              batchName: 'Test Batch',
              species: 'chicken',
              productionType: 'broiler',
              strain: 'Ross 308',
              houseId: 'house-99',
              status: 'active',
              placementDate: '2026-06-01',
              placementCount: 1000,
              currentCount: 1000,
              mortalityTotal: 0,
              mortalityPct: 0.0,
              dayOfAge: 1,
            ),
          );

      // After: 15 flocks, new one first
      final after = await _waitForFlocks(container);
      expect(after.length, 15, reason: 'Added flock should appear in flocksProvider');
      expect(after.first.id, newId, reason: 'Newly added flock should be first in list');
    });
  });

  // =========================================================================
  // flockDetailProvider — per-flock lookup
  // =========================================================================

  group('flockDetailProvider', () {
    test('flock-001 resolves to active broiler', () async {
      final flock = await _waitForDetail(container, 'flock-001');
      expect(flock, isNotNull);
      expect(flock!.isBroiler, isTrue);
      expect(flock.isActive, isTrue);
    });

    test('flock-002 resolves to active layer', () async {
      final flock = await _waitForDetail(container, 'flock-002');
      expect(flock, isNotNull);
      expect(flock!.isLayer, isTrue);
      expect(flock.isActive, isTrue);
    });

    test('flock-006 resolves to active breeder', () async {
      final flock = await _waitForDetail(container, 'flock-006');
      expect(flock, isNotNull);
      expect(flock!.isBreeder, isTrue);
      expect(flock.isActive, isTrue);
    });

    test('flock-003 resolves to duck flock', () async {
      final flock = await _waitForDetail(container, 'flock-003');
      expect(flock, isNotNull);
      expect(flock!.isDuck, isTrue);
    });

    test('flock-011 resolves to turkey flock', () async {
      final flock = await _waitForDetail(container, 'flock-011');
      expect(flock, isNotNull);
      expect(flock!.isTurkey, isTrue);
    });

    test('flock-013 resolves to quail flock', () async {
      final flock = await _waitForDetail(container, 'flock-013');
      expect(flock, isNotNull);
      expect(flock!.isQuail, isTrue);
    });

    test('nonexistent id resolves to null', () async {
      final flock = await _waitForDetail(container, 'nonexistent-id');
      expect(flock, isNull);
    });

    test('flock-004 is harvested (not active)', () async {
      final flock = await _waitForDetail(container, 'flock-004');
      expect(flock, isNotNull);
      expect(flock!.isActive, isFalse);
    });
  });

  // =========================================================================
  // flockStatusOverrideProvider — status overrides
  // =========================================================================

  group('flockStatusOverrideProvider', () {
    test('initially empty', () {
      final overrides = container.read(flockStatusOverrideProvider);
      expect(overrides, isEmpty);
    });

    test('setStatus stores the override', () {
      container
          .read(flockStatusOverrideProvider.notifier)
          .setStatus('flock-001', 'depleted');

      final overrides = container.read(flockStatusOverrideProvider);
      expect(overrides['flock-001'], 'depleted');
    });

    test('status override makes flock-001 status depleted via flockDetailProvider',
        () async {
      // Warm the cache
      await _waitForFlocks(container);

      // Apply override
      container
          .read(flockStatusOverrideProvider.notifier)
          .setStatus('flock-001', 'depleted');

      // flocksProvider / flockDetailProvider are synchronous Providers that
      // derive their value from _mockFlocksProvider (already resolved).
      // Read the detail provider synchronously after applying the override.
      final flockAsync = container.read(flockDetailProvider('flock-001'));
      expect(flockAsync.hasValue, isTrue);
      expect(flockAsync.value!.status, 'depleted');
    });

    test('can set independent statuses for multiple flocks', () {
      container
          .read(flockStatusOverrideProvider.notifier)
          .setStatus('flock-001', 'depleted');
      container
          .read(flockStatusOverrideProvider.notifier)
          .setStatus('flock-007', 'harvested');

      final overrides = container.read(flockStatusOverrideProvider);
      expect(overrides['flock-001'], 'depleted');
      expect(overrides['flock-007'], 'harvested');
      expect(overrides.containsKey('flock-002'), isFalse);
    });
  });

  // =========================================================================
  // flockEditProvider — field edits
  // =========================================================================

  group('flockEditProvider', () {
    test('initially empty', () {
      final edits = container.read(flockEditProvider);
      expect(edits, isEmpty);
    });

    test('update stores field for a flock', () {
      container.read(flockEditProvider.notifier).update('flock-001', {
        'batchName': 'Updated Batch Name',
      });

      final edits = container.read(flockEditProvider);
      expect(edits.containsKey('flock-001'), isTrue);
      expect(edits['flock-001']!['batchName'], 'Updated Batch Name');
    });

    test('update merges fields for the same flock', () {
      container.read(flockEditProvider.notifier).update('flock-001', {
        'batchName': 'Name A',
      });
      container.read(flockEditProvider.notifier).update('flock-001', {
        'strain': 'Ross 308',
      });

      final edits = container.read(flockEditProvider);
      expect(edits['flock-001']!['batchName'], 'Name A');
      expect(edits['flock-001']!['strain'], 'Ross 308');
    });

    test('updates for different flocks are stored independently', () {
      container
          .read(flockEditProvider.notifier)
          .update('flock-001', {'batchName': 'Broiler A'});
      container
          .read(flockEditProvider.notifier)
          .update('flock-002', {'batchName': 'Layer B'});

      final edits = container.read(flockEditProvider);
      expect(edits['flock-001']!['batchName'], 'Broiler A');
      expect(edits['flock-002']!['batchName'], 'Layer B');
    });

    test('edit applied to flock via flockDetailProvider', () async {
      await _waitForFlocks(container);

      container.read(flockEditProvider.notifier).update('flock-001', {
        'batchName': 'Custom Batch Name',
      });

      final flockAsync = container.read(flockDetailProvider('flock-001'));
      expect(flockAsync.hasValue, isTrue);
      expect(flockAsync.value!.batchName, 'Custom Batch Name');
    });
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Waits for [flocksProvider] (Provider of AsyncValue) to reach AsyncData.
///
/// Strategy: listen to the provider and complete when AsyncData arrives.
/// [flocksProvider] is synchronous once its backing FutureProvider resolves,
/// so we use a listener and fireImmediately to pick up the cached value too.
Future<List<PoultryFlock>> _waitForFlocks(ProviderContainer container) {
  final completer = Completer<List<PoultryFlock>>();
  final sub = container.listen<AsyncValue<List<PoultryFlock>>>(
    flocksProvider,
    (_, next) {
      if (next is AsyncData<List<PoultryFlock>> && !completer.isCompleted) {
        completer.complete(next.value);
      } else if (next is AsyncError && !completer.isCompleted) {
        completer.completeError(next.error!, next.stackTrace);
      }
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(sub.close);
}

/// Waits for [flockDetailProvider] with [id] to reach AsyncData.
Future<PoultryFlock?> _waitForDetail(ProviderContainer container, String id) {
  final completer = Completer<PoultryFlock?>();
  final sub = container.listen<AsyncValue<PoultryFlock?>>(
    flockDetailProvider(id),
    (_, next) {
      if (next is AsyncData<PoultryFlock?> && !completer.isCompleted) {
        completer.complete(next.value);
      } else if (next is AsyncError && !completer.isCompleted) {
        completer.completeError(next.error!, next.stackTrace);
      }
    },
    fireImmediately: true,
  );
  return completer.future.whenComplete(sub.close);
}

// ─────────────────────────────────────────────────────────────────────────────

extension on ProviderContainer {
  // ignore: unused_element
}
