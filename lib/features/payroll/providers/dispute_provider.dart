// Worker dispute Riverpod provider.
//
// Workers (submitDispute permission) can file disputes.
// Supervisors / payroll managers (resolveDispute permission) can update status.
//
// State is backed by the PayrollRemoteDataSource via payrollDataSourceProvider.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/payroll/data/payroll_data_source.dart';
import 'package:mobile_app/features/payroll/models/worker_dispute.dart';
import 'package:mobile_app/features/payroll/providers/payroll_providers.dart';

// ─── Notifier ─────────────────────────────────────────────────────────────────

class DisputeNotifier extends Notifier<List<WorkerDispute>> {
  PayrollDataSource get _source => ref.read(payrollDataSourceProvider);

  @override
  List<WorkerDispute> build() {
    // Initial state from preloaded cache.
    return List.unmodifiable(_source.getDisputes());
  }

  void _refresh() {
    state = List.unmodifiable(_source.getDisputes());
  }

  /// File a new dispute (requires PayrollPermission.submitDispute check in UI).
  void fileDispute({
    required String employeeId,
    required String employeeName,
    required DisputeType type,
    required String description,
    String? relatedPayRunId,
    String? relatedPayslipId,
  }) {
    final dispute = WorkerDispute(
      id: '', // assigned by server
      employeeId: employeeId,
      employeeName: employeeName,
      type: type,
      status: DisputeStatus.open,
      description: description,
      filedAt: DateTime.now(),
      relatedPayRunId: relatedPayRunId,
      relatedPayslipId: relatedPayslipId,
    );
    _source.fileDispute(dispute);
    _refresh();
  }

  /// Update the status and optionally record a resolution
  /// (requires PayrollPermission.resolveDispute check in UI).
  void updateStatus({
    required String disputeId,
    required DisputeStatus newStatus,
    String? resolvedBy,
    String? resolutionNote,
  }) {
    if (newStatus == DisputeStatus.resolved) {
      _source.resolveDispute(
        disputeId,
        resolvedBy ?? '',
        resolutionNote ?? '',
      );
    } else if (newStatus == DisputeStatus.dismissed) {
      _source.dismissDispute(disputeId, resolvedBy ?? '');
    } else {
      // underReview or open — use generic update
      final existing = state.where((d) => d.id == disputeId).firstOrNull;
      if (existing != null) {
        _source.updateDispute(
          existing.copyWith(
            status: newStatus,
            resolvedBy: resolvedBy,
            resolutionNote: resolutionNote,
          ),
        );
      }
    }
    _refresh();
  }

  /// Returns disputes for a specific employee.
  List<WorkerDispute> forEmployee(String employeeId) =>
      state.where((d) => d.employeeId == employeeId).toList();

  /// Returns all open + under-review disputes (unresolved queue for managers).
  List<WorkerDispute> get openQueue =>
      state.where((d) => !d.status.isClosed).toList();
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final disputeProvider = NotifierProvider<DisputeNotifier, List<WorkerDispute>>(
  DisputeNotifier.new,
);

/// Convenience: disputes for a specific employee (family provider).
final employeeDisputesProvider = Provider.family<List<WorkerDispute>, String>((
  ref,
  employeeId,
) {
  return ref
      .watch(disputeProvider)
      .where((d) => d.employeeId == employeeId)
      .toList();
});

/// All open / under-review disputes (resolver queue).
final openDisputesProvider = Provider<List<WorkerDispute>>((ref) {
  return ref.watch(disputeProvider).where((d) => !d.status.isClosed).toList();
});

