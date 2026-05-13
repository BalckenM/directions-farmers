import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Connectivity states exposed to the UI layer.
enum ConnectivityStatus { online, offline }

/// Stream-based Riverpod provider that tracks network connectivity.
final connectivityStatusProvider =
    StreamProvider<ConnectivityStatus>((ref) async* {
  final connectivity = Connectivity();

  // Emit the current status immediately on first listen.
  final initial = await connectivity.checkConnectivity();
  yield _mapResult(initial);

  // Then emit whenever connectivity changes.
  yield* connectivity.onConnectivityChanged.map(_mapResult);
});

/// Convenience provider that returns true when the device is online.
final isOnlineProvider = Provider<bool>((ref) {
  final status = ref.watch(connectivityStatusProvider);
  return status.when(
    data: (s) => s == ConnectivityStatus.online,
    loading: () => false,
    error: (_, _) => false,
  );
});

ConnectivityStatus _mapResult(List<ConnectivityResult> results) {
  if (results.isEmpty) return ConnectivityStatus.offline;
  return results.any((r) => r != ConnectivityResult.none)
      ? ConnectivityStatus.online
      : ConnectivityStatus.offline;
}
