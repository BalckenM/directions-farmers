import 'package:drift/drift.dart';

// ── Payroll cache tables ──────────────────────────────────────────────────────
// Each table stores a JSON snapshot of the corresponding domain model plus
// standard cache-management columns (cachedAt).  The app reads from these
// tables for instant offline access and overwrites them on every successful
// API poll.

/// Cached PayrollEmployee records.
class CachedPayrollEmployees extends Table {
  TextColumn get id => text()();
  TextColumn get json => text()();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cached PayRun records.
class CachedPayRuns extends Table {
  TextColumn get id => text()();
  TextColumn get json => text()();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cached Payslip records.
class CachedPayslips extends Table {
  TextColumn get id => text()();
  TextColumn get json => text()();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cached LeaveRequest records.
class CachedLeaveRequests extends Table {
  TextColumn get id => text()();
  TextColumn get json => text()();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cached LeaveBalance records (one per employee+leaveType pair).
class CachedLeaveBalances extends Table {
  TextColumn get id => text()();
  TextColumn get json => text()();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cached AttendanceRecord rows.
class CachedAttendanceRecords extends Table {
  TextColumn get id => text()();
  TextColumn get json => text()();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cached ComplianceAlert rows.
class CachedComplianceAlerts extends Table {
  TextColumn get id => text()();
  TextColumn get json => text()();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cached PayGroup records.
class CachedPayGroups extends Table {
  TextColumn get id => text()();
  TextColumn get json => text()();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
