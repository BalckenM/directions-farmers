import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/payroll/data/payroll_remote_data_source.dart';
import 'package:mobile_app/features/payroll/providers/payroll_providers.dart'
    show
        payrollDataSourceProvider,
        employeesProvider,
        payRunsProvider,
        leaveRequestsProvider,
        leaveBalancesProvider,
        complianceAlertsProvider,
        payGroupsProvider;

enum SyncStatus { idle, syncing, error }

class PayrollSyncState {
  const PayrollSyncState({
    this.status = SyncStatus.idle,
    this.lastSyncedAt,
    this.error,
  });

  final SyncStatus status;
  final DateTime? lastSyncedAt;
  final String? error;

  PayrollSyncState copyWith({
    SyncStatus? status,
    DateTime? lastSyncedAt,
    String? error,
  }) => PayrollSyncState(
    status: status ?? this.status,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    error: error,
  );
}

class PayrollSyncNotifier extends Notifier<PayrollSyncState> {
  Timer? _timer;

  /// Sync interval: 5 minutes. The sync re-fetches critical API data so
  /// a shorter interval would hammer the remote DB unnecessarily.
  static const _interval = Duration(minutes: 5);

  @override
  PayrollSyncState build() => const PayrollSyncState();

  void startPolling() {
    if (_timer?.isActive == true) return;
    _sync();
    _timer = Timer.periodic(_interval, (_) => _sync());
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> refresh() => _sync();

  /// Schedules [update] to run outside any active build frame to avoid
  /// triggering setState() / scheduleProviderRefresh() mid-build.
  void _safeUpdate(void Function() update) {
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle ||
        SchedulerBinding.instance.schedulerPhase ==
            SchedulerPhase.postFrameCallbacks) {
      update();
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) => update());
    }
  }

  Future<void> _sync() async {
    if (state.status == SyncStatus.syncing) return;
    _safeUpdate(
      () => state = state.copyWith(status: SyncStatus.syncing, error: null),
    );

    try {
      // Re-fetch critical data from the API into the in-memory cache.
      final source = ref.read(payrollDataSourceProvider);
      if (source is PayrollRemoteDataSource) {
        await source.preloadCritical();
      }

      _safeUpdate(() {
        // Invalidate providers so widgets rebuild with the refreshed cache.
        ref.invalidate(employeesProvider);
        ref.invalidate(payRunsProvider);
        ref.invalidate(leaveRequestsProvider);
        ref.invalidate(leaveBalancesProvider);
        ref.invalidate(complianceAlertsProvider);
        ref.invalidate(payGroupsProvider);

        state = state.copyWith(
          status: SyncStatus.idle,
          lastSyncedAt: DateTime.now(),
        );
      });
    } catch (e) {
      _safeUpdate(
        () => state = state.copyWith(
          status: SyncStatus.error,
          error: e.toString(),
        ),
      );
    }
  }
}

final payrollSyncProvider =
    NotifierProvider<PayrollSyncNotifier, PayrollSyncState>(
      PayrollSyncNotifier.new,
    );
