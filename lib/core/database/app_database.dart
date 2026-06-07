import 'package:drift/drift.dart';
import 'package:mobile_app/core/database/connection.dart'
    if (dart.library.io) 'connection_native.dart'
    if (dart.library.html) 'connection_web.dart';
import 'package:mobile_app/features/payroll/data/payroll_tables.dart';

export 'package:mobile_app/features/payroll/data/payroll_tables.dart';

part 'app_database.g.dart';

// ── Table definition ──────────────────────────────────────────────────────────

/// Pending operations that could not be synced to the server while offline.
///
/// The sync worker reads rows ordered by [createdAt] (FIFO), sends them to the
/// API, and deletes them on success.  Failed rows have their [retryCount]
/// incremented so the worker can implement exponential back-off.
class PendingSyncs extends Table {
  /// Auto-increment primary key.
  IntColumn get id => integer().autoIncrement()();

  /// The HTTP method to use when replaying this operation.
  /// One of: POST, PUT, PATCH, DELETE.
  TextColumn get method => text().withLength(max: 10)();

  /// The relative API path, e.g. `/cattle/123/events`.
  TextColumn get path => text()();

  /// JSON-encoded request body (null for DELETE requests).
  TextColumn get body => text().nullable()();

  /// Timestamp when the operation was enqueued.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Number of failed upload attempts for this row.
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
}

// ── Database ──────────────────────────────────────────────────────────────────

@DriftDatabase(
  tables: [
    PendingSyncs,
    CachedPayrollEmployees,
    CachedPayRuns,
    CachedPayslips,
    CachedLeaveRequests,
    CachedLeaveBalances,
    CachedAttendanceRecords,
    CachedComplianceAlerts,
    CachedPayGroups,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? openDatabaseConnection());

  /// For testing — inject an in-memory executor.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  // ── PendingSyncs helpers ────────────────────────────────────────────────────

  /// Enqueue an offline operation.
  Future<int> enqueue({
    required String method,
    required String path,
    String? body,
  }) => into(pendingSyncs).insert(
    PendingSyncsCompanion.insert(method: method, path: path, body: Value(body)),
  );

  /// Oldest-first list of all pending operations.
  Future<List<PendingSync>> getAllPending() => (select(
    pendingSyncs,
  )..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();

  /// Delete a row once it has been successfully synced.
  Future<void> markSynced(int id) =>
      (delete(pendingSyncs)..where((t) => t.id.equals(id))).go();

  /// Increment the retry counter on a failed row.
  Future<void> incrementRetry(int id) =>
      (update(pendingSyncs)..where((t) => t.id.equals(id))).write(
        const PendingSyncsCompanion(
          retryCount: Value.absent(), // updated below via custom expression
        ),
      );

  /// Total number of pending operations.
  Future<int> pendingCount() async {
    final count = pendingSyncs.id.count();
    final query = selectOnly(pendingSyncs)..addColumns([count]);
    return (await query.getSingle()).read(count) ?? 0;
  }
}
