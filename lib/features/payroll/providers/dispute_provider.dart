// Worker dispute Riverpod provider.
//
// Workers (submitDispute permission) can file disputes.
// Supervisors / payroll managers (resolveDispute permission) can update status.
//
// State is in-memory (mock). Backend integration replaces build() and methods.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/worker_dispute.dart';

// ─── Mock seed data ────────────────────────────────────────────────────────────

final _mockDisputes = <WorkerDispute>[
  WorkerDispute(
    id: 'disp-001',
    employeeId: 'emp-001',
    employeeName: 'Sipho Nkosi',
    type: DisputeType.overtimePay,
    status: DisputeStatus.open,
    description:
        'I worked 12 extra hours in March but my payslip only shows 8 overtime hours.',
    filedAt: DateTime(2025, 4, 5),
    relatedPayRunId: 'payrun-2025-03',
  ),
  WorkerDispute(
    id: 'disp-002',
    employeeId: 'emp-003',
    employeeName: 'Maria van der Berg',
    type: DisputeType.leaveBalance,
    status: DisputeStatus.underReview,
    description:
        'My leave balance shows 5 days but I should have 8 days carried over from last year.',
    filedAt: DateTime(2025, 3, 28),
    resolvedBy: 'Jane Manager',
  ),
];

// ─── Notifier ─────────────────────────────────────────────────────────────────

class DisputeNotifier extends Notifier<List<WorkerDispute>> {
  @override
  List<WorkerDispute> build() => List.unmodifiable(_mockDisputes);

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
      id: 'disp-${DateTime.now().millisecondsSinceEpoch}',
      employeeId: employeeId,
      employeeName: employeeName,
      type: type,
      status: DisputeStatus.open,
      description: description,
      filedAt: DateTime.now(),
      relatedPayRunId: relatedPayRunId,
      relatedPayslipId: relatedPayslipId,
    );
    state = List.unmodifiable([...state, dispute]);
  }

  /// Update the status and optionally record a resolution
  /// (requires PayrollPermission.resolveDispute check in UI).
  void updateStatus({
    required String disputeId,
    required DisputeStatus newStatus,
    String? resolvedBy,
    String? resolutionNote,
  }) {
    state = List.unmodifiable(
      state.map((d) {
        if (d.id != disputeId) return d;
        return d.copyWith(
          status: newStatus,
          resolvedAt: newStatus.isClosed ? DateTime.now() : d.resolvedAt,
          resolvedBy: resolvedBy ?? d.resolvedBy,
          resolutionNote: resolutionNote ?? d.resolutionNote,
        );
      }).toList(),
    );
  }

  /// Returns disputes for a specific employee.
  List<WorkerDispute> forEmployee(String employeeId) =>
      state.where((d) => d.employeeId == employeeId).toList();

  /// Returns all open + under-review disputes (unresolved queue for managers).
  List<WorkerDispute> get openQueue =>
      state.where((d) => !d.status.isClosed).toList();
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final disputeProvider =
    NotifierProvider<DisputeNotifier, List<WorkerDispute>>(
  DisputeNotifier.new,
);

/// Convenience: disputes for a specific employee (family provider).
final employeeDisputesProvider =
    Provider.family<List<WorkerDispute>, String>((ref, employeeId) {
  return ref.watch(disputeProvider).where((d) => d.employeeId == employeeId).toList();
});

/// All open / under-review disputes (resolver queue).
final openDisputesProvider = Provider<List<WorkerDispute>>((ref) {
  return ref.watch(disputeProvider).where((d) => !d.status.isClosed).toList();
});
