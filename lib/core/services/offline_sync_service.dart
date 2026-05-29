import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile_app/core/database/app_database.dart';
import 'package:mobile_app/core/database/database_provider.dart';
import 'package:mobile_app/core/network/api_client.dart';

/// Maximum number of retry attempts before a pending-sync row is abandoned.
const _maxRetries = 5;

/// Delay between flush cycles when online.
const _flushInterval = Duration(seconds: 30);

/// Flushes the [PendingSyncs] queue by replaying each row against the real API.
///
/// Usage:
/// ```dart
/// // Enqueue an operation (call from any repository):
/// await ref.read(offlineSyncServiceProvider).enqueue(
///   method: 'POST',
///   path: '/cattle/events',
///   body: jsonEncode(event.toJson()),
/// );
///
/// // Start the background flush loop (called once from main.dart):
/// ref.read(offlineSyncServiceProvider).startPeriodicFlush();
/// ```
class OfflineSyncService {
  OfflineSyncService({
    required AppDatabase database,
    required ApiClient apiClient,
  }) : _db = database,
       _api = apiClient;

  final AppDatabase _db;
  final ApiClient _api;

  Timer? _timer;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Enqueue an operation that should be replayed when the device is online.
  Future<void> enqueue({
    required String method,
    required String path,
    String? body,
  }) => _db.enqueue(method: method, path: path, body: body);

  /// Start a periodic timer that flushes the queue every [_flushInterval].
  void startPeriodicFlush() {
    _timer?.cancel();
    _timer = Timer.periodic(_flushInterval, (_) => flushQueue());
    // Also attempt an immediate flush on start.
    unawaited(flushQueue());
  }

  /// Cancel the background timer (call from [Provider.onDispose]).
  void dispose() => _timer?.cancel();

  /// Process all rows in the queue in FIFO order.
  ///
  /// Returns the number of successfully synced rows.
  Future<int> flushQueue() async {
    final pending = await _db.getAllPending();
    if (pending.isEmpty) return 0;

    var synced = 0;
    for (final item in pending) {
      if (item.retryCount >= _maxRetries) {
        // Permanently drop rows that have exceeded the retry limit so they
        // do not block newer operations forever.
        await _db.markSynced(item.id);
        debugPrint(
          '[OfflineSyncService] Dropping item ${item.id} after $_maxRetries failed attempts.',
        );
        continue;
      }

      try {
        await _replay(item);
        await _db.markSynced(item.id);
        synced++;
      } catch (e) {
        await _db.incrementRetry(item.id);
        debugPrint(
          '[OfflineSyncService] Retry ${item.retryCount + 1} for item ${item.id}: $e',
        );
        // Stop processing remaining rows — if the network is down, all
        // subsequent calls will also fail.
        break;
      }
    }
    return synced;
  }

  // ── Internals ──────────────────────────────────────────────────────────────

  Future<void> _replay(PendingSync item) async {
    switch (item.method.toUpperCase()) {
      case 'POST':
        await _api.post(item.path, data: item.body);
      case 'PUT':
        await _api.put(item.path, data: item.body);
      case 'PATCH':
        await _api.patch(item.path, data: item.body);
      case 'DELETE':
        await _api.delete(item.path);
      default:
        throw StateError('Unknown HTTP method: ${item.method}');
    }
  }
}

/// Riverpod provider for [OfflineSyncService].
final offlineSyncServiceProvider = Provider<OfflineSyncService>((ref) {
  final service = OfflineSyncService(
    database: ref.watch(appDatabaseProvider),
    apiClient: ref.watch(apiClientProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});
