# Flutter Payroll Module — Complete API & Feature Audit

> **Rule: Flutter ALWAYS adapts to backend. Backend is source of truth.**
> Last updated: 2026-06-15
> Source-read: every screen file, every model, full `payroll_remote_data_source.dart`, all backend route files.

---

## Table of Contents

1. [Flutter Payroll Screens Index](#1-flutter-payroll-screens-index)
2. [Models — Flutter vs Backend Field Mapping](#2-models--flutter-vs-backend-field-mapping)
3. [Complete API Call Audit (Every Endpoint)](#3-complete-api-call-audit-every-endpoint)
4. [Preload Phase Analysis](#4-preload-phase-analysis)
5. [Screens — Per-Screen Feature Audit](#5-screens--per-screen-feature-audit)
6. [Status Enum Mismatches](#6-status-enum-mismatches)
7. [Body Shape Mismatches (Write Operations)](#7-body-shape-mismatches-write-operations)
8. [What Backend Still Needs to Build](#8-what-backend-still-needs-to-build)
9. [What Backend Already Has (Flutter Wrong URL)](#9-what-backend-already-has-flutter-wrong-url)
10. [Priority Fix Order](#10-priority-fix-order)

---

## 1. Flutter Payroll Screens Index

### 46 screen files total across 17 feature areas:

| Folder                    | Screen Files                                                                                                                                                                                                            |
| ------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `screens/`                | `payroll_hub_screen.dart`                                                                                                                                                                                               |
| `screens/attendance/`     | `attendance_exceptions_screen.dart`, `attendance_log_screen.dart`, `clock_in_screen.dart`                                                                                                                               |
| `screens/audit/`          | `audit_log_screen.dart`                                                                                                                                                                                                 |
| `screens/communications/` | `communications_screen.dart`, `compose_message_screen.dart`                                                                                                                                                             |
| `screens/compliance/`     | `compliance_screen.dart`, `compliance_alert_detail_screen.dart`, `coida_screen.dart`, `emp501_screen.dart`, `paye_screen.dart`, `sdl_screen.dart`, `uif_returns_screen.dart`                                            |
| `screens/contracts/`      | `contract_list_screen.dart`, `contract_detail_screen.dart`, `contract_sign_screen.dart`, `generate_contract_screen.dart`                                                                                                |
| `screens/deductions/`     | `deductions_screen.dart`, `garnishee_orders_screen.dart`, `benefit_contributions_screen.dart`, `add_edit_garnishee_screen.dart`                                                                                         |
| `screens/disbursements/`  | `disbursements_screen.dart`, `payment_history_screen.dart`, `transaction_detail_screen.dart`                                                                                                                            |
| `screens/employees/`      | `employee_list_screen.dart`, `employee_detail_screen.dart`, `add_edit_employee_screen.dart`, `employee_import_screen.dart`, `termination_screen.dart`, `worker_disputes_screen.dart`, `worker_self_service_screen.dart` |
| `screens/incidents/`      | `incidents_screen.dart`                                                                                                                                                                                                 |
| `screens/leave/`          | `leave_dashboard_screen.dart`, `leave_request_screen.dart`, `leave_approval_screen.dart`, `leave_balance_screen.dart`                                                                                                   |
| `screens/pay_groups/`     | `pay_groups_screen.dart`, `add_edit_pay_group_screen.dart`                                                                                                                                                              |
| `screens/pay_runs/`       | `pay_run_list_screen.dart`, `pay_run_detail_screen.dart`, `run_payroll_screen.dart`, `payroll_approval_screen.dart`, `retroactive_pay_screen.dart`                                                                      |
| `screens/pay_structures/` | `pay_structures_screen.dart`, `add_edit_pay_structure_screen.dart`                                                                                                                                                      |
| `screens/payslips/`       | `payslip_list_screen.dart`, `payslip_detail_screen.dart`                                                                                                                                                                |
| `screens/reports/`        | `payroll_reports_screen.dart`                                                                                                                                                                                           |
| `screens/roster/`         | `roster_board_screen.dart`, `add_shift_screen.dart`, `piecework_logs_screen.dart`, `add_piecework_log_screen.dart`, `task_sheet_screen.dart`                                                                            |
| `screens/settings/`       | `employer_config_screen.dart`                                                                                                                                                                                           |

### 26 model files total:

`PayrollEmployee`, `EmploymentContract`, `PayGroup`, `PayStructure`, `Shift`, `TaskAssignment`, `AttendanceRecord`, `PieceworkLog`, `PayRun`, `Payslip`, `DeductionRule`, `GarnisheeOrder`, `LeaveType`, `LeaveBalance`, `LeaveRequest`, `PaymentTransaction`, `ComplianceAlert`, `AuditLogEntry`, `IncidentRecord`, `CommunicationLog`, `WorkerDispute`, `BenefitContribution`, `EmployerConfig`, `PayrollRole` (+ freezed/json variants)

---

## 2. Models — Flutter vs Backend Field Mapping

### 2.1 PayrollEmployee

Flutter `PayrollEmployee` model vs backend `Employee` record:

| Flutter Field               | Backend Field                   | Notes                                                                                 |
| --------------------------- | ------------------------------- | ------------------------------------------------------------------------------------- |
| `id` (String)               | `id` (Int)                      | **TYPE MISMATCH** — backend uses integer IDs                                          |
| `firstName`                 | `user.name`                     | Backend sends full name as one string, no split                                       |
| `lastName`                  | `user.name`                     | Same — must split on first space                                                      |
| `idOrPassportNumber`        | `national_id`                   | Different field name                                                                  |
| `phone`                     | `phone`                         | ✅ exists                                                                             |
| `email`                     | `user.email`                    | Nested in `user` object                                                               |
| `address`                   | `address`                       | ✅ exists                                                                             |
| `nextOfKinName`             | `emergency_contact`             | Backend uses `emergency_contact` (JSON blob)                                          |
| `nextOfKinPhone`            | `emergency_contact`             | Same blob                                                                             |
| `status` (EmploymentStatus) | `employment_status`             | Enum values differ — see §6                                                           |
| `engagementType`            | `agr_employment_type`           | Ag-specific; standard is `employment_type`                                            |
| `occupationTitle`           | `job_title`                     | Different field name                                                                  |
| `payGroupId`                | No direct field                 | Employee has no `payroll_group_id` — membership is in `PayrollGroupMember` join table |
| `payStructureId`            | No field                        | **DOES NOT EXIST on backend** — no pay structure concept                              |
| `startDate`                 | `start_date`                    | snake_case                                                                            |
| `endDate`                   | `end_date`                      | snake_case                                                                            |
| `bankName`                  | `bank_name`                     | ✅                                                                                    |
| `bankAccountNumber`         | `bank_account_no`               | Different suffix                                                                      |
| `bankBranchCode`            | `bank_branch`                   | Different name                                                                        |
| `disbursementMethod`        | No field                        | **DOES NOT EXIST** — backend uses bank transfer only                                  |
| `preferredLanguage`         | No field                        | **DOES NOT EXIST on backend**                                                         |
| `hasHousingBenefit`         | `agr_housing_provided`          | Ag-specific field                                                                     |
| `housingValuePerMonth`      | `agr_housing_value`             | Ag-specific field                                                                     |
| `hasFoodBenefit`            | `agr_meals_provided`            | Ag-specific field                                                                     |
| `foodValuePerMonth`         | `agr_meals_daily_value`         | Ag-specific field                                                                     |
| `dateOfBirth`               | `date_of_birth`                 | snake_case                                                                            |
| `profileImageUrl`           | `photo_url` / `photo_upload_id` | Backend serves photo via `GET /employees/:id/photo`                                   |

### 2.2 PayRun

| Flutter Field           | Backend Field          | Notes                                     |
| ----------------------- | ---------------------- | ----------------------------------------- |
| `id` (String)           | `id` (Int)             | Type mismatch                             |
| `payGroupId`            | `payroll_group_id`     | Different name                            |
| `periodStart`           | `period_start`         | snake_case                                |
| `periodEnd`             | `period_end`           | snake_case                                |
| `payDate`               | `pay_date`             | snake_case                                |
| `status` (PayRunStatus) | `status`               | Enum values completely different — see §6 |
| `totalGross`            | `total_gross`          | snake_case                                |
| `totalDeductions`       | No direct field        | Derived: `total_gross - total_net`        |
| `totalNet`              | `total_net`            | ✅                                        |
| `employeeCount`         | `worker_count` / joins | Different name                            |

### 2.3 PayGroup

| Flutter Field              | Backend Field   | Notes                                                             |
| -------------------------- | --------------- | ----------------------------------------------------------------- |
| `frequency` (PayFrequency) | `pay_frequency` | snake_case; backend uses: weekly, biweekly, monthly, semi_monthly |
| `payDayOffset`             | `pay_day`       | Different name                                                    |
| `isActive`                 | `is_active`     | ✅                                                                |

### 2.4 LeaveRequest

| Flutter Field      | Backend Field                 | Notes                     |
| ------------------ | ----------------------------- | ------------------------- |
| `leaveTypeId`      | `leave_type_id`               | snake_case                |
| `daysRequested`    | `days`                        | Different name            |
| `reviewedByUserId` | `approved_by` / `reviewed_by` | Different                 |
| `submittedAt`      | `created_at`                  | Backend uses `created_at` |

**Leave cancel:** Flutter calls `PATCH /payroll/leave-requests/:id/cancel` — backend only has `DELETE /leave/:id` (no cancel PATCH endpoint).

### 2.5 AttendanceRecord

| Flutter Field               | Backend Field     | Notes          |
| --------------------------- | ----------------- | -------------- |
| `recordedByUserId`          | `created_by`      | Different      |
| `method` (AttendanceMethod) | `check_in_method` | Different name |
| `clockInTime`               | `check_in`        | Different name |
| `clockOutTime`              | `check_out`       | Different name |
| `shiftId`                   | `shift_id`        | ✅             |

### 2.6 BenefitContribution

| Flutter `BenefitType` enum                                | Backend route                   | Notes                                          |
| --------------------------------------------------------- | ------------------------------- | ---------------------------------------------- |
| `pension`, `provident`, `medicalAid`, `retirementAnnuity` | `GET /benefits/enrolments/list` | Flutter calls `/payroll/benefit-contributions` |

**Backend benefit enrolments** (`GET /benefits/enrolments/list`, `POST /benefits/enrolments`, `PUT /benefits/enrolments/:id`, `DELETE /benefits/enrolments/:id`) map to Flutter's benefit contributions — URL prefix wrong.

### 2.7 AuditLogEntry

| Flutter Field     | Backend Field      | Notes          |
| ----------------- | ------------------ | -------------- |
| `changedByUserId` | `user_id`          | Different      |
| `changedByName`   | `user.name` (join) | Nested         |
| `beforeSnapshot`  | `old_values`       | Different name |
| `afterSnapshot`   | `new_values`       | Different name |
| `occurredAt`      | `created_at`       | Different name |

### 2.8 WorkerDispute

Flutter has `WorkerDispute` with types: `payDiscrepancy`, `leaveBalance`, `overtimePay`, `deductionQuery`, `other`. The backend has **no equivalent model**. The closest backend features are:

- `GET /disciplinary/cases` — disciplinary cases (not disputes)
- `GET /disciplinary/grievances` — worker grievances (partial overlap)
- No "pay discrepancy" dispute type on backend

**Decision needed:** Either build `/payroll/worker-disputes` on backend, OR map Flutter's `WorkerDispute` screen to `POST /disciplinary/grievances` for pay-related disputes.

### 2.9 CommunicationLog

Flutter sends to `POST /payroll/communications` with `{channel, templateCode, subject, body, recipientEmployeeIds, sentByUserId}`. Backend has announcements at `/comms/announcements` (admin-only, board-style). These are **fundamentally different**:

- Flutter: SMS/WhatsApp/email blast to specific employee IDs
- Backend: Company-wide board announcements

**New backend route required:** `POST /payroll/communications` for per-employee targeted messaging.

### 2.10 IncidentRecord

Flutter maps to: `IncidentType` = disciplinary, grievance, healthAndSafety, misconduct, other
Backend maps to: `/disciplinary/cases` (disciplinary, misconduct) + `/disciplinary/grievances` (grievance)
**No health & safety route exists on backend.**

---

## 3. Complete API Call Audit (Every Endpoint)

Legend: ✅ = backend exists and URL correct | 🟡 = backend exists but URL/verb wrong | ❌ = backend does NOT exist at all

### 3.1 Employees (Flutter uses `/payroll/employees/*`)

| Flutter Call                                | Status | Correct Backend Path                                         | Notes                                            |
| ------------------------------------------- | ------ | ------------------------------------------------------------ | ------------------------------------------------ |
| `GET /payroll/employees?page=N&limit=500`   | 🟡     | `GET /employees?page=N&limit=N`                              | Wrong prefix                                     |
| `POST /payroll/employees`                   | 🟡     | `POST /employees`                                            | Wrong prefix; body field names differ (see §7.1) |
| `PUT /payroll/employees/:id`                | 🟡     | `PUT /employees/:id`                                         | Wrong prefix                                     |
| `POST /payroll/employees/:id/profile-image` | 🟡     | `POST /employees/:id/photo`                                  | Wrong prefix AND path suffix                     |
| `POST /payroll/employees/import`            | 🟡     | `POST /employees/import`                                     | Wrong prefix                                     |
| `PATCH /payroll/employees/:id/terminate`    | 🟡     | `PUT /employees/:id` with `{employment_status:'terminated'}` | No separate terminate endpoint on backend        |

### 3.2 Payroll Groups (Flutter uses `/payroll/pay-groups/*`)

| Flutter Call                               | Status | Correct Backend Path      | Notes                                         |
| ------------------------------------------ | ------ | ------------------------- | --------------------------------------------- |
| `GET /payroll/pay-groups`                  | 🟡     | `GET /payroll-groups`     | Wrong prefix AND resource name                |
| `POST /payroll/pay-groups`                 | 🟡     | `POST /payroll-groups`    | Wrong prefix AND name                         |
| `PUT /payroll/pay-groups/:id`              | 🟡     | `PUT /payroll-groups/:id` | Wrong prefix AND name                         |
| `PATCH /payroll/pay-groups/:id/deactivate` | ❌     | No deactivate endpoint    | Backend only has `DELETE /payroll-groups/:id` |

### 3.3 Pay Structures (Flutter uses `/payroll/pay-structures/*`)

| Flutter Call                      | Status | Correct Backend Path | Notes                               |
| --------------------------------- | ------ | -------------------- | ----------------------------------- |
| `GET /payroll/pay-structures`     | ❌     | **DOES NOT EXIST**   | Entire feature missing from backend |
| `POST /payroll/pay-structures`    | ❌     | **DOES NOT EXIST**   | Build needed                        |
| `PUT /payroll/pay-structures/:id` | ❌     | **DOES NOT EXIST**   | Build needed                        |

**Note:** Pay structures define wage types (monthly salary, hourly, daily, piecework) with base rate and overtime multipliers. This is a high-priority gap — it feeds into payroll calculation.

### 3.4 Pay Runs (Flutter uses `/payroll/pay-runs/*`)

| Flutter Call                           | Status | Correct Backend Path         | Notes                                       |
| -------------------------------------- | ------ | ---------------------------- | ------------------------------------------- |
| `GET /payroll/pay-runs?limit=100`      | 🟡     | `GET /payroll`               | Wrong path                                  |
| `POST /payroll/pay-runs/calculate`     | 🟡     | `POST /payroll/run`          | Wrong path; body fields differ (see §7.4)   |
| `PATCH /payroll/pay-runs/:id/approve`  | 🟡     | `PATCH /payroll/:id/approve` | Wrong prefix                                |
| `PATCH /payroll/pay-runs/:id/disburse` | 🟡     | `PATCH /payroll/:id/pay`     | Wrong prefix AND verb (`disburse` vs `pay`) |

**Missing Flutter → Backend transitions:**

- Flutter has no `complete` step — backend requires `draft → completed → approved → paid`
- Flutter jumps `calculated → approved → disbursed` — this maps to `draft → approved → paid` but skips `completed`
- Flutter's `retroactive_pay_screen.dart` has no backend equivalent

### 3.5 Payslips (Flutter uses `/payroll/payslips/*`)

| Flutter Call                      | Status | Correct Backend Path | Notes        |
| --------------------------------- | ------ | -------------------- | ------------ |
| `GET /payroll/payslips?limit=200` | 🟡     | `GET /payslips`      | Wrong prefix |

**Backend payslips routes that exist:**

- `GET /payslips` — list all payslips for company
- `GET /payslips/:id` — single payslip
- `GET /payslips/:id/pdf` — PDF download

### 3.6 Shifts (Flutter uses `/payroll/shifts/*`)

| Flutter Call                 | Status | Correct Backend Path            | Notes                                |
| ---------------------------- | ------ | ------------------------------- | ------------------------------------ |
| `GET /payroll/shifts`        | 🟡     | `GET /attendance/shifts`        | Wrong prefix                         |
| `POST /payroll/shifts`       | 🟡     | `POST /attendance/shifts`       | Wrong prefix                         |
| `PUT /payroll/shifts/:id`    | 🟡     | `PATCH /attendance/shifts/:id`  | Wrong prefix AND verb (PUT vs PATCH) |
| `DELETE /payroll/shifts/:id` | 🟡     | `DELETE /attendance/shifts/:id` | Wrong prefix                         |

### 3.7 Attendance (Flutter uses `/payroll/attendance/*`)

| Flutter Call                               | Status | Correct Backend Path            | Notes                 |
| ------------------------------------------ | ------ | ------------------------------- | --------------------- |
| `GET /payroll/attendance?page=N&limit=500` | 🟡     | `GET /attendance/records`       | Wrong prefix          |
| `POST /payroll/attendance`                 | 🟡     | `POST /attendance/records`      | Wrong prefix          |
| `PUT /payroll/attendance/:id`              | 🟡     | `PATCH /attendance/records/:id` | Wrong prefix AND verb |

**Additional backend attendance routes Flutter doesn't use yet:**

- `POST /attendance/clock-in` — GPS/QR clock in (for `clock_in_screen.dart`)
- `POST /attendance/clock-out` — clock out
- `GET /attendance/my-status` — self-service current status
- `GET /attendance/my-records` — self-service history
- `GET /attendance/summaries` — aggregated summaries
- `GET /attendance/overtime` — overtime records

### 3.8 Task Assignments (Flutter uses `/payroll/task-assignments/*`)

| Flutter Call                           | Status | Correct Backend Path | Notes        |
| -------------------------------------- | ------ | -------------------- | ------------ |
| `GET /payroll/task-assignments`        | ❌     | **DOES NOT EXIST**   | Build needed |
| `POST /payroll/task-assignments`       | ❌     | **DOES NOT EXIST**   | Build needed |
| `PUT /payroll/task-assignments/:id`    | ❌     | **DOES NOT EXIST**   | Build needed |
| `DELETE /payroll/task-assignments/:id` | ❌     | **DOES NOT EXIST**   | Build needed |

### 3.9 Piecework (Flutter uses `/payroll/piecework/*`)

| Flutter Call                               | Status | Correct Backend Path | Notes        |
| ------------------------------------------ | ------ | -------------------- | ------------ |
| `GET /payroll/piecework`                   | ❌     | **DOES NOT EXIST**   | Build needed |
| `POST /payroll/piecework`                  | ❌     | **DOES NOT EXIST**   | Build needed |
| `DELETE /payroll/piecework/:id?reason=...` | ❌     | **DOES NOT EXIST**   | Build needed |

### 3.10 Deduction Rules (Flutter uses `/payroll/deductions/*`)

| Flutter Call                               | Status | Correct Backend Path | Notes        |
| ------------------------------------------ | ------ | -------------------- | ------------ |
| `GET /payroll/deductions`                  | ❌     | **DOES NOT EXIST**   | Build needed |
| `POST /payroll/deductions`                 | ❌     | **DOES NOT EXIST**   | Build needed |
| `PUT /payroll/deductions/:id`              | ❌     | **DOES NOT EXIST**   | Build needed |
| `PATCH /payroll/deductions/:id/deactivate` | ❌     | **DOES NOT EXIST**   | Build needed |

### 3.11 Garnishee Orders (Flutter uses `/payroll/garnishee-orders/*`)

| Flutter Call                        | Status | Correct Backend Path | Notes        |
| ----------------------------------- | ------ | -------------------- | ------------ |
| `GET /payroll/garnishee-orders`     | ❌     | **DOES NOT EXIST**   | Build needed |
| `POST /payroll/garnishee-orders`    | ❌     | **DOES NOT EXIST**   | Build needed |
| `PUT /payroll/garnishee-orders/:id` | ❌     | **DOES NOT EXIST**   | Build needed |

### 3.12 Leave (Flutter uses `/payroll/leave-*`)

| Flutter Call                                | Status | Correct Backend Path       | Notes                                 |
| ------------------------------------------- | ------ | -------------------------- | ------------------------------------- |
| `GET /payroll/leave-requests`               | 🟡     | `GET /leave`               | Wrong prefix                          |
| `POST /payroll/leave-requests`              | 🟡     | `POST /leave`              | Wrong prefix; body differs (see §7.9) |
| `PATCH /payroll/leave-requests/:id/approve` | 🟡     | `PATCH /leave/:id/approve` | Wrong prefix                          |
| `PATCH /payroll/leave-requests/:id/reject`  | 🟡     | `PATCH /leave/:id/reject`  | Wrong prefix                          |
| `PATCH /payroll/leave-requests/:id/cancel`  | 🟡     | `DELETE /leave/:id`        | No cancel — backend deletes instead   |
| `DELETE /payroll/leave-requests/:id`        | 🟡     | `DELETE /leave/:id`        | Wrong prefix                          |
| `GET /payroll/leave-balances`               | 🟡     | `GET /leave/balances`      | Wrong prefix                          |
| `GET /payroll/leave-types`                  | 🟡     | `GET /leave/types`         | Wrong prefix                          |

### 3.13 Contracts (Flutter uses `/payroll/contracts/*`)

| Flutter Call                         | Status | Correct Backend Path | Notes        |
| ------------------------------------ | ------ | -------------------- | ------------ |
| `GET /payroll/contracts` (paginated) | ❌     | **DOES NOT EXIST**   | Build needed |
| `POST /payroll/contracts`            | ❌     | **DOES NOT EXIST**   | Build needed |
| `PUT /payroll/contracts/:id`         | ❌     | **DOES NOT EXIST**   | Build needed |
| `PATCH /payroll/contracts/:id/void`  | ❌     | **DOES NOT EXIST**   | Build needed |

### 3.14 Payment Transactions (Flutter uses `/payroll/transactions/*`)

| Flutter Call                          | Status | Correct Backend Path | Notes        |
| ------------------------------------- | ------ | -------------------- | ------------ |
| `GET /payroll/transactions?limit=200` | ❌     | **DOES NOT EXIST**   | Build needed |
| `POST /payroll/transactions`          | ❌     | **DOES NOT EXIST**   | Build needed |

### 3.15 Compliance Alerts (Flutter uses `/payroll/compliance-alerts/*`)

| Flutter Call                                                    | Status | Correct Backend Path | Notes        |
| --------------------------------------------------------------- | ------ | -------------------- | ------------ |
| `GET /payroll/compliance-alerts?limit=200`                      | ❌     | **DOES NOT EXIST**   | Build needed |
| `GET /payroll/compliance-alerts?limit=200&includeResolved=true` | ❌     | **DOES NOT EXIST**   | Build needed |
| `PATCH /payroll/compliance-alerts/:id/resolve`                  | ❌     | **DOES NOT EXIST**   | Build needed |

### 3.16 Audit Log (Flutter uses `/payroll/audit-log`)

| Flutter Call             | Status | Correct Backend Path | Notes        |
| ------------------------ | ------ | -------------------- | ------------ |
| `GET /payroll/audit-log` | 🟡     | `GET /audit`         | Wrong prefix |

**Backend audit fields differ** from Flutter `AuditLogEntry` — see §2.7.

### 3.17 Incidents (Flutter uses `/payroll/incidents/*`)

| Flutter Call                              | Status | Correct Backend Path | Notes                                                  |
| ----------------------------------------- | ------ | -------------------- | ------------------------------------------------------ |
| `GET /payroll/incidents`                  | ❌     | **DOES NOT EXIST**   | Closest: `GET /disciplinary/cases` but different shape |
| `POST /payroll/incidents`                 | ❌     | **DOES NOT EXIST**   | Closest: `POST /disciplinary/cases`                    |
| `PUT /payroll/incidents/:id`              | ❌     | **DOES NOT EXIST**   | Closest: `PUT /disciplinary/cases/:id`                 |
| `PATCH /payroll/incidents/:id/deactivate` | ❌     | **DOES NOT EXIST**   | Build or map to disciplinary close                     |

### 3.18 Communications (Flutter uses `/payroll/communications/*`)

| Flutter Call                   | Status | Correct Backend Path | Notes                             |
| ------------------------------ | ------ | -------------------- | --------------------------------- |
| `GET /payroll/communications`  | ❌     | **DOES NOT EXIST**   | Backend announcements ≠ this      |
| `POST /payroll/communications` | ❌     | **DOES NOT EXIST**   | Need per-employee SMS/email blast |

### 3.19 Worker Disputes (Flutter uses `/payroll/worker-disputes/*`)

| Flutter Call                                 | Status | Correct Backend Path | Notes                                       |
| -------------------------------------------- | ------ | -------------------- | ------------------------------------------- |
| `GET /payroll/worker-disputes`               | ❌     | **DOES NOT EXIST**   | Closest: `GET /disciplinary/grievances`     |
| `POST /payroll/worker-disputes`              | ❌     | **DOES NOT EXIST**   | Closest: `POST /disciplinary/grievances`    |
| `PUT /payroll/worker-disputes/:id`           | ❌     | **DOES NOT EXIST**   | Closest: `PUT /disciplinary/grievances/:id` |
| `PATCH /payroll/worker-disputes/:id/resolve` | ❌     | **DOES NOT EXIST**   | Build needed                                |
| `PATCH /payroll/worker-disputes/:id/dismiss` | ❌     | **DOES NOT EXIST**   | Build needed                                |

### 3.20 Benefit Contributions (Flutter uses `/payroll/benefit-contributions/*`)

| Flutter Call                                | Status | Correct Backend Path              | Notes                 |
| ------------------------------------------- | ------ | --------------------------------- | --------------------- |
| `GET /payroll/benefit-contributions`        | 🟡     | `GET /benefits/enrolments/list`   | Wrong prefix AND path |
| `POST /payroll/benefit-contributions`       | 🟡     | `POST /benefits/enrolments`       | Wrong prefix AND path |
| `PUT /payroll/benefit-contributions/:id`    | 🟡     | `PUT /benefits/enrolments/:id`    | Wrong prefix AND path |
| `DELETE /payroll/benefit-contributions/:id` | 🟡     | `DELETE /benefits/enrolments/:id` | Wrong prefix AND path |

### 3.21 Employer Config (Flutter uses `/payroll/employer-config`)

| Flutter Call                   | Status | Correct Backend Path | Notes        |
| ------------------------------ | ------ | -------------------- | ------------ |
| `GET /payroll/employer-config` | ❌     | **DOES NOT EXIST**   | Build needed |
| `PUT /payroll/employer-config` | ❌     | **DOES NOT EXIST**   | Build needed |

---

## 4. Preload Phase Analysis

Flutter preloads in two phases. Status of each call:

### Phase 1 — Critical (blocks UI render)

| Call                                       | Status       | Fix                     |
| ------------------------------------------ | ------------ | ----------------------- |
| `GET /payroll/employees`                   | 🟡 URL wrong | → `GET /employees`      |
| `GET /payroll/pay-groups`                  | 🟡 URL wrong | → `GET /payroll-groups` |
| `GET /payroll/pay-structures`              | ❌ Not built | Build backend route     |
| `GET /payroll/pay-runs?limit=100`          | 🟡 URL wrong | → `GET /payroll`        |
| `GET /payroll/compliance-alerts?limit=200` | ❌ Not built | Build backend route     |
| `GET /payroll/leave-requests`              | 🟡 URL wrong | → `GET /leave`          |
| `GET /payroll/leave-balances`              | 🟡 URL wrong | → `GET /leave/balances` |
| `GET /payroll/employer-config`             | ❌ Not built | Build backend route     |

**Result:** Phase 1 makes **8 API calls**. **3 will always fail** (404). **5 return data but with wrong shape** (snake_case vs camelCase).

### Phase 2 — Background (loads after UI shows)

| Call                                  | Status       | Fix                               |
| ------------------------------------- | ------------ | --------------------------------- |
| `GET /payroll/contracts`              | ❌ Not built | Build backend route               |
| `GET /payroll/payslips?limit=200`     | 🟡 URL wrong | → `GET /payslips`                 |
| `GET /payroll/deductions`             | ❌ Not built | Build backend route               |
| `GET /payroll/garnishee-orders`       | ❌ Not built | Build backend route               |
| `GET /payroll/leave-types`            | 🟡 URL wrong | → `GET /leave/types`              |
| `GET /payroll/transactions?limit=200` | ❌ Not built | Build backend route               |
| `GET /payroll/audit-log`              | 🟡 URL wrong | → `GET /audit`                    |
| `GET /payroll/incidents`              | ❌ Not built | Build or map to disciplinary      |
| `GET /payroll/communications`         | ❌ Not built | Build backend route               |
| `GET /payroll/shifts`                 | 🟡 URL wrong | → `GET /attendance/shifts`        |
| `GET /payroll/task-assignments`       | ❌ Not built | Build backend route               |
| `GET /payroll/attendance`             | 🟡 URL wrong | → `GET /attendance/records`       |
| `GET /payroll/piecework`              | ❌ Not built | Build backend route               |
| `GET /payroll/worker-disputes`        | ❌ Not built | Build or map to disciplinary      |
| `GET /payroll/benefit-contributions`  | 🟡 URL wrong | → `GET /benefits/enrolments/list` |

**Result:** Phase 2 makes **15 API calls**. **8 will always fail** (404). **7 return data but with wrong URLs and snake_case fields.**

---

## 5. Screens — Per-Screen Feature Audit

### 5.1 PayrollHubScreen (Dashboard)

**Reads:** allPayRunsProvider, criticalAlertsProvider, pendingLeaveRequestsProvider, employeesProvider, leaveTypesProvider, payrollDashboardStatsProvider
**Chart:** Pay run bar chart over time
**Actions:** → ComplianceScreen, → PayrollReportsScreen
**Blocking issues:** complianceAlerts and employees fetched from wrong URLs — dashboard stats will show 0/empty on first load.

### 5.2 Employee Screens

#### EmployeeListScreen

**Reads:** employees list, departments
**Actions:** search, filter, tap to detail, FAB → add employee
**Issues:**

- Calls `GET /payroll/employees` → must be `GET /employees`
- Flutter `PayrollEmployee.fromJson` tries to parse `firstName`/`lastName` but backend sends `user.name` (single string)
- `employeeId` is Int on backend, String in Flutter model

#### AddEditEmployeeScreen

**Writes:** `POST /payroll/employees` and `PUT /payroll/employees/:id`
**Body sent:** `{firstName, lastName, idOrPassportNumber, phone, email, address, nextOfKinName, nextOfKinPhone, status, engagementType, occupationTitle, payGroupId, payStructureId, startDate, disbursementMethod, preferredLanguage, hasHousingBenefit, housingValuePerMonth, hasFoodBenefit, foodValuePerMonth}`
**Backend expects:** `{name, email, role, job_title, start_date, gross_salary, department_id, bank_name, bank_account_no, bank_branch, agr_employment_type, agr_housing_provided, ...}`
**Critical body mismatch** — see §7.1

#### EmployeeDetailScreen

**Reads:** employee, contracts, payslips, attendance, leave, incidents
**Issues:** All sub-reads have wrong URL prefixes

#### EmployeeImportScreen

**Action:** `POST /payroll/employees/import` with `{employees: [...]}` array
**Backend:** `POST /employees/import` takes a **file upload** (CSV/XLSX via multipart form), NOT a JSON array
**This is a fundamental interface mismatch** — Flutter sends JSON, backend expects a file.

#### TerminationScreen

**Action:** `PATCH /payroll/employees/:id/terminate` with `{terminationDate, reason}`
**Backend:** No separate terminate endpoint — must call `PUT /employees/:id` with `{employment_status: 'terminated', end_date: terminationDate, separation_reason: reason}`

#### WorkerDisputesScreen

**Reads:** worker disputes
**Writes:** file, update, resolve, dismiss disputes
**Issues:** Entire `/payroll/worker-disputes/*` namespace doesn't exist on backend

#### WorkerSelfServiceScreen

**Reads:** own employee record, own payslips, own leave requests, own attendance
**Fix:** Use `GET /employees/:id` (self), `GET /payslips?employee_id=N`, `GET /leave?employee_id=N`, `GET /attendance/my-records`

### 5.3 Pay Run Screens

#### PayRunListScreen

**Reads:** `GET /payroll/pay-runs` → fix to `GET /payroll`

#### RunPayrollScreen (4-step wizard)

**Step 1:** Select pay group + period
**Step 2:** Pre-run report (checks employees + compliance alerts)
**Step 3:** Review calculation (calls `POST /payroll/pay-runs/calculate`)
**Step 4:** Disburse (calls `PATCH /payroll/pay-runs/:id/disburse`)
**Issues:**

- `POST /payroll/pay-runs/calculate` → backend is `POST /payroll/run` (different path and body)
- Flutter body: `{payGroupId, periodStart, periodEnd, payDate}` — backend: `{pay_group_id, period_start, period_end, ...}` (snake_case)
- Flutter action `disburse` → backend action `pay` (`PATCH /payroll/:id/pay`)
- Flutter status `disbursed` → backend status `paid`
- Flutter has no `complete` step (backend requires `draft → completed → approved → paid`)

#### PayrollApprovalScreen

**Action:** `PATCH /payroll/pay-runs/:id/approve` with `{approverUserId}` in body
**Backend:** `PATCH /payroll/:id/approve` — no `approverUserId` needed in body (uses `req.user.id`)

#### RetroactivePayScreen

**No backend equivalent.** Flutter has UI for retroactive pay adjustments — backend has `POST /payroll/:id/adjustments` for bonus/deduction line items. This should be wired to the adjustments endpoint.

### 5.4 Payslip Screens

**Reads:** `GET /payroll/payslips` → fix to `GET /payslips`
**Detail:** `GET /payslips/:id` exists on backend
**PDF download:** Backend has `GET /payslips/:id/pdf` — Flutter may not call this yet

### 5.5 Pay Groups Screens

**CRUD:** All calls use wrong prefix `/payroll/pay-groups` → should be `/payroll-groups`
**Deactivate:** Flutter calls `PATCH .../deactivate` — backend only has `DELETE /payroll-groups/:id`

### 5.6 Pay Structures Screens

**All calls fail.** Backend has no `/payroll/pay-structures` endpoint. Must build.
Pay structures define `WageType` (monthlySalary, hourlyRate, dailyRate, piecework) + baseRate + overtime multipliers. This feeds directly into payroll calculation.

### 5.7 Attendance Screens

#### AttendanceLogScreen

**Reads:** `GET /payroll/attendance` → fix to `GET /attendance/records`
**Writes:** `POST /payroll/attendance` → `POST /attendance/records`; `PUT /payroll/attendance/:id` → `PATCH /attendance/records/:id`

#### ClockInScreen

**Actions:** clock-in / clock-out
**Should call:** `POST /attendance/clock-in` and `POST /attendance/clock-out` — backend has these!
**Currently calls:** Unknown (screen exists but was not fully read) — likely calls the wrong path

#### AttendanceExceptionsScreen

**Reads:** filtered attendance records + summaries
**Should also use:** `GET /attendance/summaries` which exists on backend

### 5.8 Leave Screens

#### LeaveDashboardScreen

**Reads:** leave requests + leave balances
**Wrong URLs:** `/payroll/leave-requests` → `/leave`; `/payroll/leave-balances` → `/leave/balances`

#### LeaveRequestScreen

**Writes:** `POST /payroll/leave-requests` → `POST /leave`
**Body mismatch:** Flutter sends `{employeeId, leaveTypeId, startDate, endDate, daysRequested, reason}` — backend expects `{employee_id, leave_type_id, start_date, end_date, days, reason}`

#### LeaveApprovalScreen

**Actions:** approve/reject
**Wrong URLs:** `/payroll/leave-requests/:id/approve` → `/leave/:id/approve`
**Body mismatch:** Flutter sends `{approverId}` — backend doesn't need approverId in body (uses req.user.id)

#### LeaveBalanceScreen

**Reads:** `/payroll/leave-balances` → fix to `/leave/balances`

### 5.9 Compliance Screens

#### ComplianceScreen

**Reads:** `GET /payroll/compliance-alerts` — **DOES NOT EXIST** on backend
**Action:** `PATCH /payroll/compliance-alerts/:id/resolve` — **DOES NOT EXIST**
**This entire feature has no backend support.**

#### CoidaScreen, Emp501Screen, PayeScreen, SdlScreen, UifReturnsScreen

**These are compliance REPORTING screens.** They read payroll run data and calculate statutory figures.
**Fix:** These should read from `GET /payroll/:id/emp201-export`, `GET /payroll/:id/uif-export` (already exist on backend). The screens currently have no direct API call — they compute from in-memory data.
**Issue:** They depend on the `PayRun` and `Payslip` caches which are loaded from wrong URLs.

### 5.10 Contract Screens

**All 4 contract screens** (list, detail, sign, generate) depend on:

- `GET /payroll/contracts` — **DOES NOT EXIST**
- `POST /payroll/contracts` — **DOES NOT EXIST**
- `PUT /payroll/contracts/:id` — **DOES NOT EXIST**
- `PATCH /payroll/contracts/:id/void` — **DOES NOT EXIST**

**ContractSignScreen** uses a signature capture widget (draws on canvas) and stores `signatureImageBase64` in the contract. Backend must store this when contracts are built.

**GenerateContractScreen** generates contract HTML/PDF. Backend must have PDF generation. Backend already has `PayslipPdfService.js` — a contract PDF service is needed.

### 5.11 Deductions Screens

#### DeductionsScreen

**All calls fail** — `/payroll/deductions/*` does not exist.
Flutter model `DeductionRule`: id, code, label, type (statutory/voluntary/benefit/garnishee), basis (percentage/fixedAmount), value, cappedAt, employeeIds[], isActive

#### GarnisheeOrdersScreen

**All calls fail** — `/payroll/garnishee-orders/*` does not exist.
Flutter model `GarnisheeOrder`: id, employeeId, courtOrderRef, creditorName, monthlyDeductionAmount, totalOwed, amountDeducted, status (active/satisfied/suspended/cancelled)

#### BenefitContributionsScreen

**Wrong URL prefix.**

- `GET /payroll/benefit-contributions` → `GET /benefits/enrolments/list`
- `POST /payroll/benefit-contributions` → `POST /benefits/enrolments`
- `PUT /payroll/benefit-contributions/:id` → `PUT /benefits/enrolments/:id`
- `DELETE /payroll/benefit-contributions/:id` → `DELETE /benefits/enrolments/:id`

### 5.12 Disbursement Screens

#### DisbursementsScreen / PaymentHistoryScreen / TransactionDetailScreen

**All calls fail** — `/payroll/transactions/*` does not exist.
Flutter model `PaymentTransaction`: id, payRunId, employeeId, type, description, amount, currency, method, status (initiated/processing/completed/failed/reversed), reference, bankName, accountNumber, transactionDate

These screens track individual bank transfer records per payslip. Backend has no transactions table — payment is tracked at the payroll run level.

### 5.13 Incident Screens

#### IncidentsScreen

**Calls fail** — `/payroll/incidents/*` does not exist.
**Closest backend:** `GET /disciplinary/cases` (for disciplinary/misconduct types) + `GET /disciplinary/grievances` (for grievance type)
**Decision:** Either map Flutter `IncidentRecord` to disciplinary routes, or build `/payroll/incidents`.

### 5.14 Communications Screens

#### CommunicationsScreen / ComposeMessageScreen

**All calls fail** — `/payroll/communications/*` does not exist.
Flutter `CommunicationLog` supports channels: `sms`, `whatsapp`, `email`, `inApp`, `push`.
Backend `/comms/announcements` is board-style admin posts — completely different concept.
**Backend build needed:** Targeted multi-channel messaging to employee IDs.

### 5.15 Roster Screens

#### RosterBoardScreen

**Reads:** shifts + task assignments + attendance

- Shifts: `/payroll/shifts` → fix to `/attendance/shifts` ✅ backend exists
- Task assignments: `/payroll/task-assignments` — ❌ does not exist
- Attendance: `/payroll/attendance` → fix to `/attendance/records` ✅ backend exists

#### AddShiftScreen

**Writes:** `POST /payroll/shifts` → fix to `POST /attendance/shifts`

#### PieceworkLogsScreen / AddPieceworkLogScreen

**All calls fail** — `/payroll/piecework` does not exist.

#### TaskSheetScreen

**Reads:** task assignments — does not exist on backend.

### 5.16 Settings Screen

#### EmployerConfigScreen

**All calls fail** — `/payroll/employer-config` does not exist.
Flutter `EmployerConfig` fields: name, companyName, registrationNumber, payeNumber, taxNumber, uifReferenceNumber, sdlNumber, payDay, overtimeMultiplier, currency
**Backend has `CompanySetting` model** — employer config likely maps to company settings. Must confirm field names.

### 5.17 Reports Screen

#### PayrollReportsScreen

**Reads from in-memory cache** (no direct API call). Aggregates data from already-loaded pay runs, payslips, employees.
**Issue:** All underlying data comes from wrong URLs — fix the URL prefixes and this screen should work.
**Existing backend exports Flutter could call:**

- `GET /payroll/:id/emp201-export`
- `GET /payroll/:id/uif-export`
- `GET /payroll/:id/eft-export`
- `GET /payroll/:id/gl-export`
- `GET /payroll/:id/payslips/zip`

---

## 6. Status Enum Mismatches

### 6.1 PayRun Status

| Flutter `PayRunStatus` | Backend status | Mapping                                                |
| ---------------------- | -------------- | ------------------------------------------------------ |
| `draft`                | `draft`        | ✅                                                     |
| `calculated`           | (none)         | Remove — backend goes straight from draft to completed |
| `pendingApproval`      | `completed`    | Map: Flutter `pendingApproval` ↔ backend `completed`   |
| `approved`             | `approved`     | ✅                                                     |
| `disbursed`            | `paid`         | Rename: Flutter `disbursed` → backend `paid`           |
| `cancelled`            | `cancelled`    | ✅                                                     |
| (none)                 | `rejected`     | Flutter missing this state                             |

**Flutter workflow:** `draft → calculated → pendingApproval → approved → disbursed`
**Backend workflow:** `draft → completed → approved → paid` (plus `rejected`, `cancelled`)

### 6.2 Employee Status

| Flutter `EmploymentStatus` | Backend `employment_status` |
| -------------------------- | --------------------------- |
| `active`                   | `active`                    |
| `inactive`                 | `suspended` (closest)       |
| `terminated`               | `terminated`                |
| (none)                     | `on_leave`                  |

### 6.3 Engagement Type

| Flutter `EngagementType` | Backend `agr_employment_type` / `employment_type` |
| ------------------------ | ------------------------------------------------- |
| `permanent`              | `permanent` / `full_time`                         |
| `seasonal`               | `seasonal`                                        |
| `casual`                 | `daily_casual` (agr) / `part_time`                |
| `contractor`             | `contract`                                        |

### 6.4 Leave Status

| Flutter `LeaveStatus` | Backend `status`       |
| --------------------- | ---------------------- |
| `pending`             | `pending`              |
| `approved`            | `approved`             |
| `rejected`            | `rejected`             |
| `cancelled`           | No cancel — use DELETE |

### 6.5 Disbursement Method

| Flutter `DisbursementMethod` | Backend                 |
| ---------------------------- | ----------------------- |
| `bank`                       | Bank transfer (default) |
| `cash`                       | No equivalent           |
| `mtnEwallet`                 | No equivalent           |
| `orangeMoney`                | No equivalent           |

---

## 7. Body Shape Mismatches (Write Operations)

### 7.1 POST /employees — Create Employee

```dart
// Flutter sends:
{
  "firstName": "Jane",
  "lastName": "Farmer",
  "idOrPassportNumber": "8001015009087",
  "phone": "0821234567",
  "email": "jane@farm.co.za",
  "address": "123 Farm Road",
  "nextOfKinName": "John Farmer",
  "nextOfKinPhone": "0827654321",
  "status": "active",
  "engagementType": "seasonal",
  "occupationTitle": "Picker",
  "payGroupId": "pg-1",
  "payStructureId": "ps-1",
  "startDate": "2026-01-01",
  "disbursementMethod": "bank",
  "preferredLanguage": "en",
  "hasHousingBenefit": true,
  "housingValuePerMonth": 500.0,
  "hasFoodBenefit": false
}

// Backend expects:
{
  "name": "Jane Farmer",             // full name, not split
  "email": "jane@farm.co.za",
  "role": "employee",                // required
  "job_title": "Picker",             // not occupationTitle
  "start_date": "2026-01-01",
  "gross_salary": 5000.00,           // required, not in Flutter model
  "department_id": 3,
  "national_id": "8001015009087",    // not idOrPassportNumber
  "phone": "0821234567",
  "address": "123 Farm Road",
  "emergency_contact": { "name": "John Farmer", "phone": "0827654321" },
  "agr_employment_type": "seasonal",
  "agr_housing_provided": true,
  "agr_housing_value": 500.00
  // payGroupId and payStructureId are NOT employee fields on backend
}
```

### 7.2 POST /payroll-groups — Create Pay Group

```dart
// Flutter sends:
{
  "name": "Weekly Pickers",
  "frequency": "weekly",
  "payDayOffset": 3,
  "description": "...",
  "isActive": true
}

// Backend expects:
{
  "name": "Weekly Pickers",
  "pay_frequency": "weekly",    // not frequency
  "pay_day": 3,                 // not payDayOffset
  "description": "..."
  // is_active defaults to true
}
```

### 7.3 POST /leave — Create Leave Request

```dart
// Flutter sends:
{
  "employeeId": "emp-1",
  "leaveTypeId": "lt-1",
  "startDate": "2026-07-01",
  "endDate": "2026-07-05",
  "daysRequested": 5.0,
  "reason": "Holiday"
}

// Backend expects:
{
  "employee_id": 1,             // integer, not string
  "leave_type_id": 1,           // integer, not string
  "start_date": "2026-07-01",
  "end_date": "2026-07-05",
  "days": 5.0,                  // not daysRequested
  "reason": "Holiday"
}
```

### 7.4 POST /payroll/run — Create Pay Run

```dart
// Flutter sends to POST /payroll/pay-runs/calculate:
{
  "payGroupId": "pg-1",
  "periodStart": "2026-06-01",
  "periodEnd": "2026-06-30",
  "payDate": "2026-06-25"
}

// Backend expects at POST /payroll/run:
{
  "pay_group_id": 1,            // integer, not string; snake_case
  "period_start": "2026-06-01",
  "period_end": "2026-06-30",
  "pay_date": "2026-06-25"
}
```

### 7.5 PATCH /payroll/:id/approve — Approve Run

```dart
// Flutter sends:
{ "approverUserId": "user-1" }

// Backend does NOT expect approverUserId in body
// Uses req.user.id automatically — send empty body {}
```

### 7.6 POST /payroll/communications

```dart
// Flutter sends:
{
  "channel": "sms",
  "templateCode": "PAYSLIP_READY",
  "subject": "Your payslip is ready",
  "body": "Hi {{name}}, your payslip for June 2026 is ready.",
  "recipientEmployeeIds": ["1", "2", "3"],
  "sentByUserId": "user-1"
}

// Backend: NO EQUIVALENT — must build this endpoint
// Closest existing: POST /comms/announcements (completely different)
```

### 7.7 PUT /payroll/shifts/:id (Flutter) vs PATCH /attendance/shifts/:id (Backend)

```dart
// Flutter uses PUT, backend uses PATCH
// Also: Flutter sends Shift.toJson() with camelCase fields
// Backend expects snake_case
```

### 7.8 PATCH /payroll/leave-requests/:id/cancel

```dart
// Flutter calls: PATCH /payroll/leave-requests/:id/cancel
// Backend has: DELETE /leave/:id  (no cancel verb)
// Flutter must call DELETE /leave/:id instead
```

---

## 8. What Backend Still Needs to Build

Grouped by feature area with suggested route paths and Flutter model references:

### Priority 🔴 HIGH — Blocks core payroll screens

| Feature                  | Routes to Build                                                                                                  | Flutter Model        |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------- | -------------------- |
| **Pay Structures**       | `GET/POST /payroll/pay-structures`, `GET/PUT/DELETE /payroll/pay-structures/:id`                                 | `PayStructure`       |
| **Employment Contracts** | `GET/POST /payroll/contracts` (paginated), `GET/PUT /payroll/contracts/:id`, `PATCH /payroll/contracts/:id/void` | `EmploymentContract` |
| **Employer Config**      | `GET /payroll/employer-config`, `PUT /payroll/employer-config`                                                   | `EmployerConfig`     |
| **Compliance Alerts**    | `GET /payroll/compliance-alerts`, `PATCH /payroll/compliance-alerts/:id/resolve`                                 | `ComplianceAlert`    |
| **Deduction Rules**      | `GET/POST /payroll/deductions`, `PUT /payroll/deductions/:id`, `PATCH /payroll/deductions/:id/deactivate`        | `DeductionRule`      |

### Priority 🟡 MEDIUM — Blocks financial / HR tracking screens

| Feature                  | Routes to Build                                                                                                           | Flutter Model        |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------- | -------------------- |
| **Garnishee Orders**     | `GET/POST /payroll/garnishee-orders`, `GET/PUT /payroll/garnishee-orders/:id`                                             | `GarnisheeOrder`     |
| **Payment Transactions** | `GET /payroll/transactions`, `POST /payroll/transactions`                                                                 | `PaymentTransaction` |
| **Worker Disputes**      | `GET/POST /payroll/worker-disputes`, `PUT /payroll/worker-disputes/:id`, `PATCH .../:id/resolve`, `PATCH .../:id/dismiss` | `WorkerDispute`      |
| **Incidents**            | `GET/POST /payroll/incidents`, `PUT /payroll/incidents/:id`, `PATCH /payroll/incidents/:id/deactivate`                    | `IncidentRecord`     |
| **Communications**       | `GET /payroll/communications`, `POST /payroll/communications`                                                             | `CommunicationLog`   |

### Priority 🟢 LOW — Farm-specific / advanced features

| Feature              | Routes to Build                                                                                                   | Flutter Model    |
| -------------------- | ----------------------------------------------------------------------------------------------------------------- | ---------------- |
| **Task Assignments** | `GET/POST /payroll/task-assignments`, `PUT /payroll/task-assignments/:id`, `DELETE /payroll/task-assignments/:id` | `TaskAssignment` |
| **Piecework Logs**   | `GET/POST /payroll/piecework`, `DELETE /payroll/piecework/:id`                                                    | `PieceworkLog`   |

### Routes already built for Farm Pay (correct URL)

These exist — Flutter just needs to call them:

- `GET/POST /payroll/seasons`, `PATCH/DELETE /payroll/seasons/:id`
- `GET/POST /payroll/task-rates`, `PATCH /payroll/task-rates/:id`
- `GET/POST /payroll/bonus-rules`, `PATCH /payroll/bonus-rules/:id`
- `GET/POST /payroll/advances`, `PATCH /payroll/advances/:id/approve|reject|cancel`
- `GET/POST /payroll/cash-payments`
- `GET /payroll/:id/farm-pay-run`

---

## 9. What Backend Already Has (Flutter Wrong URL)

These backend routes exist and work correctly. Flutter just calls the wrong URL:

| Flutter Calls                               | Backend Actual URL                      | Fix                                    |
| ------------------------------------------- | --------------------------------------- | -------------------------------------- |
| `GET /payroll/employees`                    | `GET /employees`                        | Change prefix                          |
| `POST /payroll/employees`                   | `POST /employees`                       | Change prefix                          |
| `PUT /payroll/employees/:id`                | `PUT /employees/:id`                    | Change prefix                          |
| `POST /payroll/employees/:id/profile-image` | `POST /employees/:id/photo`             | Change prefix + suffix                 |
| `POST /payroll/employees/import`            | `POST /employees/import` (file upload!) | Change prefix; change body to FormData |
| `GET /payroll/pay-groups`                   | `GET /payroll-groups`                   | Change path                            |
| `POST /payroll/pay-groups`                  | `POST /payroll-groups`                  | Change path                            |
| `PUT /payroll/pay-groups/:id`               | `PUT /payroll-groups/:id`               | Change path                            |
| `GET /payroll/pay-runs?limit=100`           | `GET /payroll`                          | Change path                            |
| `POST /payroll/pay-runs/calculate`          | `POST /payroll/run`                     | Change path + body                     |
| `PATCH /payroll/pay-runs/:id/approve`       | `PATCH /payroll/:id/approve`            | Remove `pay-runs` segment              |
| `PATCH /payroll/pay-runs/:id/disburse`      | `PATCH /payroll/:id/pay`                | Remove segment, change verb            |
| `GET /payroll/payslips?limit=200`           | `GET /payslips`                         | Change prefix                          |
| `GET /payroll/shifts`                       | `GET /attendance/shifts`                | Change prefix                          |
| `POST /payroll/shifts`                      | `POST /attendance/shifts`               | Change prefix                          |
| `PUT /payroll/shifts/:id`                   | `PATCH /attendance/shifts/:id`          | Change prefix + verb                   |
| `DELETE /payroll/shifts/:id`                | `DELETE /attendance/shifts/:id`         | Change prefix                          |
| `GET /payroll/attendance`                   | `GET /attendance/records`               | Change prefix                          |
| `POST /payroll/attendance`                  | `POST /attendance/records`              | Change prefix                          |
| `PUT /payroll/attendance/:id`               | `PATCH /attendance/records/:id`         | Change prefix + verb                   |
| `GET /payroll/leave-requests`               | `GET /leave`                            | Change path                            |
| `POST /payroll/leave-requests`              | `POST /leave`                           | Change path + body                     |
| `PATCH /payroll/leave-requests/:id/approve` | `PATCH /leave/:id/approve`              | Change path                            |
| `PATCH /payroll/leave-requests/:id/reject`  | `PATCH /leave/:id/reject`               | Change path                            |
| `PATCH /payroll/leave-requests/:id/cancel`  | `DELETE /leave/:id`                     | Change path + method                   |
| `DELETE /payroll/leave-requests/:id`        | `DELETE /leave/:id`                     | Change path                            |
| `GET /payroll/leave-balances`               | `GET /leave/balances`                   | Change path                            |
| `GET /payroll/leave-types`                  | `GET /leave/types`                      | Change path                            |
| `GET /payroll/audit-log`                    | `GET /audit`                            | Change path                            |
| `GET /payroll/benefit-contributions`        | `GET /benefits/enrolments/list`         | Change path                            |
| `POST /payroll/benefit-contributions`       | `POST /benefits/enrolments`             | Change path                            |
| `PUT /payroll/benefit-contributions/:id`    | `PUT /benefits/enrolments/:id`          | Change path                            |
| `DELETE /payroll/benefit-contributions/:id` | `DELETE /benefits/enrolments/:id`       | Change path                            |

---

## 10. Priority Fix Order

### Phase A — Fix Flutter URLs (no backend work, unblocks ~60% of screens)

1. **`payroll_remote_data_source.dart`** — Replace all 33 wrong URL prefixes/paths listed in §9
2. **`PayrollEmployee.fromJson`** — Map `user.name` → split firstName/lastName; `national_id` → `idOrPassportNumber`; `employment_status` → `status` enum; `job_title` → `occupationTitle`
3. **`PayRun.fromJson`** — Map `payroll_group_id` → `payGroupId`; status enum (see §6.1); `total_net` → `totalNet`
4. **`AttendanceRecord.fromJson`** — Map `check_in` → `clockInTime`; `check_out` → `clockOutTime`; `check_in_method` → `method`
5. **`PayGroup.fromJson`** — Map `pay_frequency` → `frequency`; `pay_day` → `payDayOffset`
6. **`LeaveRequest.fromJson`** — Map `days` → `daysRequested`; `created_at` → `submittedAt`
7. **`AuditLogEntry.fromJson`** — Map `old_values` → `beforeSnapshot`; `new_values` → `afterSnapshot`; `created_at` → `occurredAt`
8. **Write operation bodies** — Fix all camelCase → snake_case in POST/PUT/PATCH bodies (see §7)
9. **EmployeeImportScreen** — Change from JSON array to FormData file upload
10. **TerminationScreen** — Change `PATCH .../terminate` to `PUT /employees/:id` with `{employment_status: 'terminated'}`

### Phase B — Build Missing Backend Routes (unblocks remaining ~40% of screens)

Build in this order:

1. `GET/PUT /payroll/employer-config` (settings screen)
2. `GET/POST /payroll/pay-structures` + CRUD (feeds payroll calculation)
3. `GET/POST /payroll/deductions` + CRUD (feeds payslip deductions)
4. `GET/POST /payroll/compliance-alerts` + resolve (dashboard critical metric)
5. `GET/POST /payroll/contracts` + CRUD + void (contracts screens)
6. `GET/POST /payroll/garnishee-orders` + CRUD (deductions screens)
7. `GET/POST /payroll/transactions` (disbursements screens)
8. `GET/POST /payroll/incidents` + CRUD (incidents screen)
9. `GET/POST /payroll/communications` (comms screens)
10. `GET/POST /payroll/worker-disputes` + resolve/dismiss (disputes screen)
11. `GET/POST /payroll/task-assignments` + CRUD (roster/task sheet)
12. `GET/POST /payroll/piecework` + delete (piecework logs)
