# Payroll Module — Backend Development Plan

**Audit Date:** 2026-06-04 (revised after full source read)  
**Scope:** Backend gaps vs. what the Flutter frontend actually requires  
**Rule:** No Flutter edits. All fixes are backend-only.

---

## Audit Method

The first audit used a subagent which inferred API calls from folder names and models without reading the actual source files. This revision is based on reading:

- `payroll_data_source.dart` — every abstract method
- `payroll_remote_data_source.dart` — every exact HTTP call, URL, and request body
- Every model's `fromJson()` — exact field names and types Flutter expects in responses
- Every compliance/disbursement/contract screen — what data they display and how

---

## Status Legend

| Symbol | Meaning                          |
| ------ | -------------------------------- |
| ✅     | Implemented and correct          |
| ⚠️     | Partially implemented / has bugs |
| ❌     | Missing entirely                 |
| 🔴     | Critical — blocks core workflow  |
| 🟠     | Medium — feature incomplete      |
| 🟡     | Low — minor or cosmetic          |

---

## Summary of Gaps (corrected)

| Category                          | Total Issues | Critical | Medium | Low   |
| --------------------------------- | ------------ | -------- | ------ | ----- |
| Missing endpoints                 | 11           | 4        | 5      | 2     |
| Broken service logic              | 6            | 4        | 2      | 0     |
| **DB column mismatches (new)**    | **8**        | **5**    | **3**  | **0** |
| Data mapping / field name bugs    | 6            | 3        | 2      | 1     |
| Validator missing required fields | 5            | 3        | 2      | 0     |
| DB schema gaps                    | 5            | 1        | 3      | 1     |
| Test coverage                     | 6            | 3        | 2      | 1     |

---

## What the First Audit Missed (Critical Corrections)

### A. `EmployerConfig` is never sent to the backend

`PayrollRemoteDataSource.updateEmployerConfig()` stores the config **in local memory only** — no API call is made. The backend `PUT /employer-config` endpoint exists but is never called from Flutter in the current implementation.  
**Impact:** Employer registration details (name, tax number, UIF number, PAYE number) are never persisted.  
**What this means for backend:** The endpoint exists but is unreachable. The Flutter model must eventually call it. Backend fields must match Flutter's `EmployerConfig` model: `name`, `registrationNumber`, `uifReferenceNumber`, `payeNumber`.

### B. PAYE / COIDA / EMP501 / SDL are computed client-side

`paye_screen.dart`, `coida_screen.dart`, `emp501_screen.dart`, `sdl_screen.dart` all compute their reports **locally from the in-memory payslip cache** using `SaStatutory` and `Emp501Service` Dart classes.  
**Impact:** These screens do NOT call any backend report endpoints. They depend entirely on payslips being correctly and fully populated.  
**What this means for backend:** The payslip response MUST include all earnings breakdown fields (`basicWage`, `overtimePay`, `holidayPay`, `inKindHousing`, `inKindFood`, `otherEarnings`) or every compliance screen shows zeros.

### C. `WorkerDispute` model exists but no backend or data source methods

`worker_dispute.dart` is a full model with `DisputeType` and `DisputeStatus` enums. The `worker_disputes_screen.dart` exists. But `PayrollDataSource` has no dispute methods and `PayrollRemoteDataSource` makes zero API calls for disputes.  
**Impact:** Worker disputes are not wired up to the backend yet. Needs full endpoint set.

### D. Compliance screens were 7 screens, not 2

The original audit listed only `compliance_dashboard_screen` and `audit_trail_screen`. The actual screens are:

- `compliance_screen.dart`
- `compliance_alert_detail_screen.dart`
- `coida_screen.dart`
- `paye_screen.dart`
- `sdl_screen.dart`
- `uif_returns_screen.dart`
- `emp501_screen.dart`

### E. Disbursements screen was missed entirely

`DisbursementsScreen` uses `TransactionStatus` values `initiated`, `processing`, `completed`, `failed`, `reversed`. The backend `payroll_transactions` table has **no `status` column** — it only has `type`, `amount`, `description`, `transaction_date`. This is a blocking DB mismatch.

---

## Phase 0 — Database Column Fixes (must run before anything else)

These are structural mismatches between what Flutter's `fromJson()` parses and what the DB stores.

---

### 0.1 🔴 `payroll_employees` — 4 missing / misnamed columns

Flutter `PayrollEmployee.fromJson()` reads these exact keys:

```
idOrPassportNumber   → DB has: id_number         (rename required)
address              → DB has: address            ✅ (added in migration 0017)
nextOfKinName        → DB has: next_of_kin_name   ✅ (added in migration 0017)
nextOfKinPhone       → DB has: next_of_kin_phone  ✅ (added in migration 0017)
occupationTitle      → DB has: occupation_title   ✅ (added in migration 0017)
foodValuePerMonth    → DB: MISSING
```

**Migration needed:**

```sql
ALTER TABLE payroll_employees
  RENAME COLUMN id_number TO id_or_passport_number;

ALTER TABLE payroll_employees
  ADD COLUMN food_value_per_month DECIMAL(8,2) NULL;
```

**Backend mapping fix:** `employees.service.ts` must map `id_or_passport_number` → `idOrPassportNumber`

---

### 0.2 🔴 `payroll_payslips` — 8 missing columns

Flutter `Payslip.fromJson()` reads:

```
basicWage            → DB: MISSING
overtimePay          → DB: MISSING
holidayPay           → DB: MISSING
inKindHousing        → DB: MISSING
inKindFood           → DB: MISSING
otherEarnings        → DB: MISSING
leaveBalanceSnapshot → DB: MISSING  (JSON object: { leaveTypeName: daysBalance })
payslipNumber        → DB: MISSING
periodStart          → DB: MISSING  (only pay_run has period; payslip needs its own)
periodEnd            → DB: MISSING
payDate              → DB: MISSING
```

Current DB only has: `gross_pay`, `total_deductions`, `net_pay`, `pdf_data`, `line_items`.

**Migration needed:**

```sql
ALTER TABLE payroll_payslips
  ADD COLUMN basic_wage DECIMAL(10,2) NOT NULL DEFAULT 0,
  ADD COLUMN overtime_pay DECIMAL(10,2) NOT NULL DEFAULT 0,
  ADD COLUMN holiday_pay DECIMAL(10,2) NOT NULL DEFAULT 0,
  ADD COLUMN in_kind_housing DECIMAL(10,2) NOT NULL DEFAULT 0,
  ADD COLUMN in_kind_food DECIMAL(10,2) NOT NULL DEFAULT 0,
  ADD COLUMN other_earnings DECIMAL(10,2) NOT NULL DEFAULT 0,
  ADD COLUMN leave_balance_snapshot TEXT,
  ADD COLUMN payslip_number VARCHAR(50),
  ADD COLUMN period_start DATE,
  ADD COLUMN period_end DATE,
  ADD COLUMN pay_date DATE;
```

---

### 0.3 🔴 `payroll_transactions` — 7 missing columns

Flutter `PaymentTransaction.fromJson()` reads:

```
method          → DB: MISSING  ('bank', 'cash', 'ewallet')
status          → DB: MISSING  (initiated/processing/completed/failed/reversed)
reference       → DB: MISSING
bankName        → DB: MISSING
accountNumber   → DB: MISSING
initiatedAt     → DB: MISSING
completedAt     → DB: MISSING
failureReason   → DB: MISSING
currency        → DB: MISSING
```

**Migration needed:**

```sql
ALTER TABLE payroll_transactions
  ADD COLUMN method VARCHAR(20) NOT NULL DEFAULT 'bank',
  ADD COLUMN status VARCHAR(20) NOT NULL DEFAULT 'initiated',
  ADD COLUMN reference VARCHAR(100),
  ADD COLUMN bank_name VARCHAR(100),
  ADD COLUMN account_number VARCHAR(50),
  ADD COLUMN currency VARCHAR(3) DEFAULT 'ZAR',
  ADD COLUMN initiated_at DATETIME,
  ADD COLUMN completed_at DATETIME,
  ADD COLUMN failure_reason TEXT;
```

---

### 0.4 🔴 `payroll_communications` — 5 missing columns

Flutter `CommunicationLog.fromJson()` reads:

```
templateCode           → DB: MISSING
recipientEmployeeIds   → DB has: employee_id (singular, not array)
sentByUserId           → DB: MISSING
deliveredCount         → DB: MISSING
failedCount            → DB: MISSING
```

**Migration needed:**

```sql
ALTER TABLE payroll_communications
  ADD COLUMN template_code VARCHAR(50),
  ADD COLUMN recipient_employee_ids TEXT,  -- JSON array
  ADD COLUMN sent_by_user_id VARCHAR(36),
  ADD COLUMN delivered_count INT DEFAULT 0,
  ADD COLUMN failed_count INT DEFAULT 0;
```

---

### 0.5 🔴 `payroll_contracts` — field name mismatch

Flutter `EmploymentContract.fromJson()` reads:

```
type                → DB: contract_type   ✅ (maps fine if service maps it)
grossMonthlySalary  → DB: base_salary     ← DIFFERENT NAME
jobDescription      → DB: job_description ✅
signedByName        → DB: MISSING
signatureImageBase64 → DB: MISSING
version             → DB: MISSING
```

**Migration needed:**

```sql
ALTER TABLE payroll_contracts
  ADD COLUMN signed_by_name VARCHAR(255),
  ADD COLUMN signature_image_base64 MEDIUMTEXT,
  ADD COLUMN version INT DEFAULT 1;
```

**Mapping fix:** `base_salary` → `grossMonthlySalary` in service

---

### 0.6 🟠 `payroll_employer_config` — field name mismatch

Flutter `EmployerConfig` reads: `name`, `registrationNumber`, `uifReferenceNumber`, `payeNumber`  
Backend DB has: `company_name`, `tax_number`, `uif_number`, `sdl_number`, `pay_day`  
Missing from DB: `registrationNumber`, `payeNumber` as separate fields

**Migration needed:**

```sql
ALTER TABLE payroll_employer_config
  ADD COLUMN registration_number VARCHAR(50),
  ADD COLUMN paye_number VARCHAR(50);
```

---

### 0.7 🟠 `payroll_pay_runs` — missing approval chain column

Flutter `PayRun` has `approvalChain: List<ApprovalEntry>` where each entry has `userId`, `displayName`, `role`, `decidedAt`, `approved`, `comment`.

**Migration needed:**

```sql
ALTER TABLE payroll_pay_runs
  ADD COLUMN approval_chain TEXT,   -- JSON array of ApprovalEntry
  ADD COLUMN disbursed_at DATETIME;
```

---

### 0.8 🔴 Missing `payroll_worker_disputes` table

Flutter `WorkerDispute` model has `id`, `employeeId`, `employeeName`, `type` (enum), `status` (enum), `description`, `relatedPayRunId`, `relatedPayslipId`, `filedAt`, `resolvedAt`, `resolvedBy`, `resolutionNote`.

**Migration needed:**

```sql
CREATE TABLE payroll_worker_disputes (
  id VARCHAR(36) PRIMARY KEY,
  farm_owner_id VARCHAR(36) NOT NULL,
  employee_id VARCHAR(36) NOT NULL,
  type VARCHAR(50) NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'open',
  description TEXT NOT NULL,
  related_pay_run_id VARCHAR(36),
  related_payslip_id VARCHAR(36),
  filed_at DATETIME NOT NULL,
  resolved_at DATETIME,
  resolved_by VARCHAR(255),
  resolution_note TEXT,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  INDEX farm_owner_idx (farm_owner_id),
  INDEX employee_idx (employee_id)
);
```

**New endpoints needed:**

```
GET    /payroll/worker-disputes
POST   /payroll/worker-disputes
GET    /payroll/worker-disputes/:id
PUT    /payroll/worker-disputes/:id
PATCH  /payroll/worker-disputes/:id/resolve
PATCH  /payroll/worker-disputes/:id/dismiss
```

---

## Phase 1 — Critical Blockers (Core Pay Run Workflow)

These must be done first. Without them, no pay run can complete end-to-end.

---

### 1.1 🔴 Payslip Generation Engine

**File:** `backend/src/services/payroll/payslips.service.ts`  
**Problem:** Service is read-only. No `generatePayslips()` method exists. The frontend `run_payroll_screen` triggers a pay run calculation and expects payslips to be generated.

**What to build:**

- `generatePayslips(farmOwnerId, payRunId)` — iterates all employees in the pay group, calculates gross/deductions/net per employee, inserts rows into `payroll_payslips`
- Called automatically when `POST /pay-runs/calculate` is hit
- Apply all active `payroll_deduction_rules` for the farm (UIF, PAYE, voluntary deductions)
- Apply all active `payroll_garnishee_orders` for each employee
- Apply `BCEA §34` deduction floor — net pay cannot go below NMWA minimum wage for the period
- Store `line_items` as JSON array: `[{ code, name, amount, isStatutory }]`
- Store a snapshot of `leaveBalance` per employee at time of generation (required for accurate historical payslips)
- If any employee breaches NMWA, auto-insert a `payroll_compliance_alerts` row

**New endpoint needed:**

```
POST /api/v1/payroll/pay-runs/:id/calculate
```

(Route already declared — implement the controller and service logic)

---

### 1.2 🔴 Pay Run Status Transitions

**File:** `backend/src/services/payroll/pay-runs.service.ts`  
**Problem:** `finalizePayRun()` saves status as `"finalized"` but the Flutter model expects `"pending_approval"`. `approvePayRun()` and `disbursePayRun()` are barely implemented.

**Fix:**

- Rename transition: `finalizePayRun` → sets status to `"pending_approval"`
- `approvePayRun(farmOwnerId, id, approverUserId)` → sets status to `"approved"`, records who approved and when in `payroll_audit_log`
- `disbursePayRun(farmOwnerId, id)` → sets status to `"disbursed"`, sets `disbursed_at`, generates `payroll_transactions` rows for each payslip

**Status enum (must match Flutter):**

```
draft → calculated → pending_approval → approved → disbursed
```

---

### 1.3 🔴 Leave Balance Auto-Update on Approval

**File:** `backend/src/services/payroll/leave.service.ts`  
**Problem:** When a leave request is approved, `payroll_leave_balances` is NOT decremented.

**Fix in `approveLeaveRequest()`:**

1. Look up the employee's current balance for the leave type
2. Subtract `daysRequested` from balance
3. Upsert the balance row
4. If balance would go negative, still approve (unpaid leave) but log a compliance alert

---

### 1.4 🔴 PAYE Calculation Service

**File:** `backend/src/services/payroll/` — does not exist  
**Problem:** PAYE seeded at 0%. No bracket calculation logic. Frontend expects PAYE line on payslip.

**What to build:** `paye.service.ts`

- South African PAYE brackets for 2025/26 tax year
- Inputs: `annualGross`, `monthlyGross`, `age`, `medicalAidDependants` (optional)
- Output: `{ paye, uif, netAfterStatutory }`
- Used by payslip generation engine (1.1 above)
- UIF: 1% of gross, capped at `R177.12/month` (max contribution)
- SDL: 1% of gross (employer pays; no employee deduction)
- ETI: check if employee age is 18–35 and meets criteria; calculate incentive

---

### 1.5 🔴 Compliance Alert Auto-Generation

**File:** `backend/src/services/payroll/compliance.service.ts`  
**Problem:** Alerts are only resolved manually. Nothing creates them automatically.

**What to build:** `runComplianceChecks(farmOwnerId, payRunId)`

- Called at the end of every `calculatePayRun()`
- Checks:
  - NMWA: hourly rate below R27.58/hr (2025 rate) → `NMWA_BREACH`
  - UIF: employee missing ID number or tax number → `UIF_MISSING_DETAILS`
  - BCEA §34: any deduction pushes net below wage floor → `BCEA_DEDUCTION_FLOOR`
  - Contract expiry: any employee on fixed-term contract expiring within 30 days → `CONTRACT_EXPIRY`
  - Leave balance negative after deduction → `LEAVE_BALANCE_NEGATIVE`
- Insert one row per violation per employee into `payroll_compliance_alerts`
- Do not duplicate: check if alert with same `alert_type + employee_id + pay_run_id` exists

---

## Phase 2 — Missing Endpoints

---

### 2.1 🟠 Bulk Employee Import

**Endpoint:** `POST /api/v1/payroll/employees/bulk`  
**Frontend:** `employee_import_screen.dart` sends a CSV or JSON array  
**What to build:**

- Accept `multipart/form-data` with a CSV file, or a JSON body with `employees[]` array
- Validate each row against `createEmployeeSchema`
- Insert valid rows; return a summary: `{ inserted: N, failed: M, errors: [{row, reason}] }`
- Limit: 500 employees per import

---

### 2.2 🟠 Retroactive Pay Adjustment

**Endpoint:** `POST /api/v1/payroll/pay-runs/:id/adjust`  
**Frontend:** `retroactive_pay_screen.dart`  
**What to build:**

- Accept `{ employeeId, adjustmentType, amount, reason, period }`
- Allowed `adjustmentType`: `"backpay"`, `"correction"`, `"bonus"`, `"deduction_reversal"`
- Create a new payslip line item in the existing payslip for that pay run
- Recalculate `gross_pay`, `total_deductions`, `net_pay` on the payslip
- Update `payroll_pay_runs` totals
- Log to `payroll_audit_log`: who adjusted, what changed, before/after

---

### 2.3 🟠 Payroll Summary Report

**Endpoint:** `GET /api/v1/payroll/reports/payroll-summary`  
**Query params:** `?periodStart=&periodEnd=&payGroupId=`  
**Frontend:** `payroll_summary_report_screen.dart`  
**What to return:**

```json
{
  "period": { "start": "...", "end": "..." },
  "totalGross": 0.00,
  "totalDeductions": 0.00,
  "totalNet": 0.00,
  "employeeCount": 0,
  "byEmployee": [{ "employeeId", "name", "gross", "deductions", "net" }],
  "byDeductionType": [{ "code", "name", "total" }]
}
```

---

### 2.4 🟠 Compliance/Statutory Export

**Endpoint:** `GET /api/v1/payroll/reports/compliance`  
**Query params:** `?type=emp201|uif|irp5&period=&format=json|csv`  
**Frontend:** `compliance_report_screen.dart`  
**What to build:**

- `emp201`: monthly EMP201 return (PAYE + UIF + SDL totals per period)
- `uif`: UI-19 format export (employee list + UIF contributions)
- `irp5`: IRP5 certificate data per employee for tax year
- CSV format: downloadable file; JSON for in-app preview

---

### 2.5 🟠 Attendance Summary/Stats

**Endpoint:** `GET /api/v1/payroll/attendance/stats`  
**Query params:** `?employeeId=&periodStart=&periodEnd=`  
**Frontend:** `attendance_summary_screen.dart`  
**What to return:**

```json
{
  "employeeId": "...",
  "period": { "start": "...", "end": "..." },
  "presentDays": 0,
  "absentDays": 0,
  "lateDays": 0,
  "leaveDays": 0,
  "totalHoursWorked": 0.0,
  "averageHoursPerDay": 0.0
}
```

---

### 2.6 🟡 Bulk Shift Assignment

**Endpoint:** `POST /api/v1/payroll/shifts/bulk`  
**Body:** `{ employeeIds: [], shiftDate, startTime, endTime, shiftType, notes }`  
**Purpose:** Assign same shift to multiple workers at once (roster screen)

---

## Phase 3 — Service Logic Fixes

---

### 3.1 🟠 Fix `sendCommunication` Hardcoded Channel

**File:** `backend/src/services/payroll/communications.service.ts`  
**Problem:** `channel` is hardcoded to `"system"` regardless of input.

**Fix:**

- Pass `input.channel` to the DB insert
- Add channel routing:
  - `"system"`: store in DB only (current behavior)
  - `"sms"` / `"whatsapp"`: log intent to `payroll_communications`; flag `sent_at` as null until integration provider (Twilio/Africa's Talking) is configured
  - Return error if channel requires external integration not yet configured

---

### 3.2 🟠 Fix `mapDisbursementMethod` Silent Default

**File:** `backend/src/services/payroll/employees.service.ts`  
**Problem:** Unknown disbursement method silently defaults to `"cash"`.

**Fix:**

```typescript
function mapDisbursementMethod(v: string | null | undefined): string {
  const map: Record<string, string> = {
    bank_transfer: "bank",
    bank: "bank",
    mtn_ewallet: "mtnEwallet",
    orange_money: "orangeMoney",
    cash: "cash",
  };
  if (v && !map[v]) {
    // Log unknown value; don't silently discard
    console.warn(`Unknown disbursement_method: "${v}", storing as-is`);
    return v;
  }
  return map[v ?? ""] ?? "cash";
}
```

---

### 3.3 🟠 Fix Pay Date Fallback in Pay Runs

**File:** `backend/src/services/payroll/pay-runs.service.ts`  
**Problem:** `payDate` falls back to `periodEnd` or current time if missing.

**Fix:** Make `payDate` required in `createPayRunSchema` (already is) and throw validation error rather than silently using a fallback.

---

### 3.4 🟡 Add Leave Balance Accrual Job

**File:** `backend/src/jobs/`  
**What to build:** A scheduled job `accrue-leave.job.ts` that:

- Runs monthly (1st of every month)
- For each active employee in each farm:
  - Calculates monthly accrual: `(accrualDaysPerYear / 12)` per leave type
  - Upserts `payroll_leave_balances` (add accrued days to current balance)
  - Caps balance at max carry-over (configurable per leave type; default = `accrualDaysPerYear`)
- Logs to `payroll_audit_log`

---

## Phase 4 — Validator & Schema Fixes

---

### 4.1 🟠 Add Approval Chain to Pay Run Schema

**File:** `backend/src/validators/payroll/payroll.validator.ts`

Add to `createPayRunSchema`:

```typescript
requiredApprovers: z.array(z.string().uuid()).min(1).max(5).optional(),
```

Add `payroll_pay_run_approvals` table (or store as JSON column in `payroll_pay_runs`):

```sql
ALTER TABLE payroll_pay_runs ADD COLUMN required_approvers TEXT; -- JSON UUID array
ALTER TABLE payroll_pay_runs ADD COLUMN approved_by TEXT;        -- JSON: [{userId, at}]
```

---

### 4.2 🟡 Add Composite Unique Index on `employee_number`

**Migration:** Add unique constraint per farm:

```sql
ALTER TABLE payroll_employees
  ADD UNIQUE KEY unique_employee_number_per_farm (farm_owner_id, employee_number);
```

---

### 4.3 🟡 Add Composite Index on Attendance Date Range Queries

**Migration:**

```sql
ALTER TABLE payroll_attendance_records
  ADD INDEX employee_date_idx (employee_id, attendance_date);

ALTER TABLE payroll_shifts
  ADD INDEX employee_date_idx (employee_id, shift_date);

ALTER TABLE payroll_piecework_logs
  ADD INDEX employee_date_idx (employee_id, work_date);
```

---

## Phase 5 — Test Coverage (Backend)

All tests go in `backend/tests/` using vitest.

---

### 5.1 🔴 Pay Run Calculation Tests

File: `backend/tests/payroll/pay-runs.test.ts`

| Test                                                                                     | Scenario                                    |
| ---------------------------------------------------------------------------------------- | ------------------------------------------- |
| Calculate gross from hourly rate × hours worked                                          | Standard 45-hr week                         |
| NMWA floor enforcement                                                                   | Hourly rate below R27.58 → compliance alert |
| UIF deduction: 1% capped at R177.12                                                      | Normal gross; verify cap                    |
| PAYE bracket: R0–R237,100 annual → 18%                                                   | Low income bracket                          |
| BCEA §34 deduction floor                                                                 | Large voluntary deduction blocked           |
| Garnishee order applied before voluntary deductions                                      | Priority ordering                           |
| Net pay calculation after all deductions                                                 | End-to-end                                  |
| Pay run status transitions: draft → calculated → pending_approval → approved → disbursed | State machine                               |

---

### 5.2 🔴 Leave Service Tests

File: `backend/tests/payroll/leave.test.ts`

| Test                                       | Scenario                             |
| ------------------------------------------ | ------------------------------------ |
| Create leave request: valid                | Correct dates, available balance     |
| Create leave request: insufficient balance | Should still allow (unpaid), flag it |
| Approve leave: balance decrements          | Balance = before - daysRequested     |
| Reject leave: balance unchanged            | Rejection does not affect balance    |
| Cancel approved leave: balance restored    | Restoration logic                    |
| Leave accrual: 1 month → 1.25 days annual  | Standard BCEA rate                   |
| Leave accrual: pro-rata for partial year   | Join mid-year                        |

---

### 5.3 🟠 Employee Service Tests

File: `backend/tests/payroll/employees.test.ts`

| Test                                             | Scenario             |
| ------------------------------------------------ | -------------------- |
| Create employee with all fields                  | Full payload         |
| Create employee duplicate employee_number        | Expect 409           |
| Terminate employee: status + end_date set        | Termination logic    |
| List employees: pagination                       | page=2, limit=10     |
| List employees: filter by status=active          | Only active returned |
| Update disbursement method: unknown value logged | No silent default    |

---

### 5.4 🟠 Compliance Alert Tests

File: `backend/tests/payroll/compliance.test.ts`

| Test                                               | Scenario                         |
| -------------------------------------------------- | -------------------------------- |
| NMWA breach generates alert                        | Rate below minimum               |
| No duplicate alerts for same employee + pay run    | Idempotency                      |
| Resolve alert: is_resolved = true, resolved_at set | Resolve endpoint                 |
| BCEA §34 deduction floor alert                     | Deduction pushes net below floor |

---

## Execution Order

| Priority | Phase                                          | Estimated Effort |
| -------- | ---------------------------------------------- | ---------------- |
| 1        | Phase 1.1 — Payslip generation engine          | Large            |
| 2        | Phase 1.2 — Pay run status transitions         | Medium           |
| 3        | Phase 1.4 — PAYE calculation service           | Medium           |
| 4        | Phase 1.3 — Leave balance on approval          | Small            |
| 5        | Phase 1.5 — Compliance alert auto-generation   | Medium           |
| 6        | Phase 2.1 — Bulk employee import               | Medium           |
| 7        | Phase 2.3 — Payroll summary report             | Small            |
| 8        | Phase 2.4 — Statutory export (EMP201/UIF/IRP5) | Large            |
| 9        | Phase 3.1–3.3 — Service bugs                   | Small            |
| 10       | Phase 2.2 — Retroactive adjustment             | Medium           |
| 11       | Phase 2.5 — Attendance stats                   | Small            |
| 12       | Phase 4.1–4.3 — Validator/schema fixes         | Small            |
| 13       | Phase 3.4 — Leave accrual job                  | Medium           |
| 14       | Phase 5 — Backend tests                        | Large            |

---

## Files to Create/Modify

### New Files

| File                                                    | Purpose                      |
| ------------------------------------------------------- | ---------------------------- |
| `backend/src/services/payroll/paye.service.ts`          | SA PAYE/UIF/SDL calculator   |
| `backend/src/jobs/accrue-leave.job.ts`                  | Monthly leave accrual cron   |
| `backend/src/controllers/payroll/reports.controller.ts` | Payroll + compliance reports |
| `backend/src/routes/payroll/reports.routes.ts`          | Report endpoints             |
| `backend/tests/payroll/pay-runs.test.ts`                | Pay run tests                |
| `backend/tests/payroll/leave.test.ts`                   | Leave service tests          |
| `backend/tests/payroll/employees.test.ts`               | Employee service tests       |
| `backend/tests/payroll/compliance.test.ts`              | Compliance tests             |

### Modify

| File                                                     | Change                                             |
| -------------------------------------------------------- | -------------------------------------------------- |
| `backend/src/services/payroll/payslips.service.ts`       | Add `generatePayslips()`                           |
| `backend/src/services/payroll/pay-runs.service.ts`       | Fix status transitions; implement approve/disburse |
| `backend/src/services/payroll/leave.service.ts`          | Auto-update balance on approve                     |
| `backend/src/services/payroll/compliance.service.ts`     | Add `runComplianceChecks()`                        |
| `backend/src/services/payroll/communications.service.ts` | Fix hardcoded channel                              |
| `backend/src/services/payroll/employees.service.ts`      | Fix silent disbursement default                    |
| `backend/src/validators/payroll/payroll.validator.ts`    | Add approval chain fields                          |
| `backend/src/routes/payroll/employees.routes.ts`         | Add `/bulk` route                                  |
| `backend/src/routes/payroll/pay-runs.routes.ts`          | Add `/adjust` route                                |
| `backend/src/routes/payroll/operations.routes.ts`        | Add `/attendance/stats`, `/shifts/bulk`            |
| `backend/src/db/seeds/010_payroll.seed.ts`               | Fix PAYE placeholder (0% → bracket reference)      |
