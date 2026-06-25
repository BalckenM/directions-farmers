# Flutter ↔ Backend Integration Audit

> **Rule: Flutter ALWAYS adapts to backend. Backend is the source of truth.**
> Last updated: 2026-06-15

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Auth Mismatches](#1-auth-mismatches)
3. [Payroll URL Prefix Errors](#2-payroll-url-prefix-errors)
4. [Farm Pay Plugin Routes](#3-farm-pay-plugin-routes)
5. [Backend Routes Still Missing](#4-backend-routes-still-missing)
6. [Flutter AuthUser Model Mapping](#5-flutter-authuser-model-mapping)
7. [Registration Wizard](#6-registration-wizard)
8. [Action Plan](#7-action-plan)

---

## Architecture Overview

| Layer                | Stack                                        | Base URL                                                                                                      |
| -------------------- | -------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| **Backend**          | Node.js / Express 5 / Sequelize / PostgreSQL | `/api/v1`                                                                                                     |
| **Vue Web Frontend** | Vue 3 / Pinia / `VITE_API_URL` env var       | `/api/v1`                                                                                                     |
| **Flutter Mobile**   | Dart / Flutter / Riverpod / Dio              | `http://localhost:3000/v1` (dev) / `https://backendfarmers--directions-payroll.us-east4.hosted.app/v1` (prod) |

**Auth mechanism:** JWT RS256 access token (Bearer) + HS256 refresh token in HttpOnly cookie `refresh_token`. Multi-tenant: every request scoped by `req.companyId` extracted from the JWT `company_id` claim.

---

## 1. Auth Mismatches

### 1.1 Token Strategy — Breaking Mismatch

The backend **only** delivers the refresh token via an **HttpOnly cookie** (`Set-Cookie: refresh_token=...`). It is **never** returned in the JSON body. Flutter currently tries to read `refreshToken` from the response body and store it in `SecureStorage`. This must be fixed.

| #   | Flutter (Current — Wrong)                             | Backend (Correct)                                                       |
| --- | ----------------------------------------------------- | ----------------------------------------------------------------------- |
| 1   | Reads `data['accessToken']` (camelCase)               | Returns `access_token` (snake_case)                                     |
| 2   | Reads `data['refreshToken']` from JSON body           | Never in body — delivered via HttpOnly `Set-Cookie` header              |
| 3   | Stores refresh token in `SecureStorage`               | Cookie managed automatically by `Dio` cookie jar                        |
| 4   | Calls `POST /auth/refresh` with body `{refreshToken}` | `POST /auth/refresh` reads `req.cookies.refresh_token` — no body needed |
| 5   | Calls `GET /auth/me` separately after login           | User object returned **inline** in the login response as `data['user']` |

**Files to fix:**

- `lib/features/auth/data/auth_remote_data_source.dart`
- `lib/core/network/api_client.dart` (401 interceptor — remove body, rely on cookie)

### 1.2 Login Response Shape

```dart
// Flutter currently expects:
data['accessToken']   // WRONG
data['refreshToken']  // WRONG — doesn't exist in body

// Backend actually returns:
// POST /auth/login → 200
{
  "access_token": "eyJ...",      // <-- snake_case
  "user": {
    "id": 1,
    "name": "Jane Farmer",
    "email": "jane@farm.co.za",
    "role": "super_admin",
    "role_label": "Super Admin",
    "employee_id": null,
    "mfa_enabled": false,
    "permissions": ["payroll:view", "payroll:run", "farm:manage"],
    "company_id": 5,
    "subscription_status": "active",
    "features": ["payroll", "leave", "attendance", "farm_pay"]
  }
  // refresh_token is in Set-Cookie header, NOT here
}
```

### 1.3 MFA Challenge Field Names

```dart
// Flutter sends:
{ "token": pendingToken, "tempToken": tempToken }  // WRONG

// Backend expects (POST /auth/mfa/challenge):
{ "challenge_token": pendingToken, "totp_code": code }  // CORRECT
```

### 1.4 Social Login / SSO

```dart
// Flutter calls:
POST /auth/social   // DOES NOT EXIST

// Backend only has:
POST /auth/microsoft  // Microsoft SSO (OAuth PKCE)
```

### 1.5 Farm Team Routes — Removed

Flutter calls routes that were never built:

```
GET  /farm/team       → DOES NOT EXIST  →  Use GET /employees
POST /farm/staff      → DOES NOT EXIST  →  Use POST /users (invite flow)
DELETE /farm/staff/:id → DOES NOT EXIST  →  Use DELETE /users/:id
```

---

## 2. Payroll URL Prefix Errors

Flutter adds a `/payroll/` prefix to routes that are **not** under `/payroll` on the backend. The `/payroll` namespace is only for **payroll runs and Farm Pay plugin** routes.

### 2.1 Employees

| Flutter (Wrong)                        | Backend (Correct)      | Method             |
| -------------------------------------- | ---------------------- | ------------------ |
| `/payroll/employees`                   | `/employees`           | GET (list)         |
| `/payroll/employees`                   | `/employees`           | POST (create)      |
| `/payroll/employees/:id`               | `/employees/:id`       | GET / PUT / DELETE |
| `/payroll/employees/:id/profile-image` | `/employees/:id/photo` | POST               |

### 2.2 Payroll Groups

| Flutter (Wrong)           | Backend (Correct)     | Method             |
| ------------------------- | --------------------- | ------------------ |
| `/payroll/pay-groups`     | `/payroll-groups`     | GET / POST         |
| `/payroll/pay-groups/:id` | `/payroll-groups/:id` | GET / PUT / DELETE |

### 2.3 Payroll Runs

| Flutter (Wrong)                       | Backend (Correct)            | Method                |
| ------------------------------------- | ---------------------------- | --------------------- |
| `GET /payroll/pay-runs`               | `GET /payroll`               | List runs             |
| `POST /payroll/pay-runs`              | `POST /payroll/run`          | Create & process run  |
| `/payroll/pay-runs/:id`               | `/payroll/:id`               | GET run with payslips |
| `/payroll/pay-runs/:id/complete`      | `/payroll/:id/complete`      | PATCH                 |
| `/payroll/pay-runs/:id/approve`       | `/payroll/:id/approve`       | PATCH                 |
| `/payroll/pay-runs/:id/pay`           | `/payroll/:id/pay`           | PATCH                 |
| `/payroll/pay-runs/:id/reject`        | `/payroll/:id/reject`        | PATCH                 |
| `/payroll/pay-runs/:id/cancel`        | `/payroll/:id/cancel`        | PATCH                 |
| `/payroll/pay-runs/:id/recalculate`   | `/payroll/:id/recalculate`   | PATCH                 |
| `/payroll/pay-runs/bulk-approve`      | `/payroll/bulk-approve`      | POST                  |
| `/payroll/pay-runs/:id/email`         | `/payroll/:id/email`         | POST                  |
| `/payroll/pay-runs/:id/anomalies`     | `/payroll/:id/anomalies`     | GET                   |
| `/payroll/pay-runs/:id/eft-export`    | `/payroll/:id/eft-export`    | GET                   |
| `/payroll/pay-runs/:id/uif-export`    | `/payroll/:id/uif-export`    | GET                   |
| `/payroll/pay-runs/:id/emp201-export` | `/payroll/:id/emp201-export` | GET                   |
| `/payroll/pay-runs/:id/gl-export`     | `/payroll/:id/gl-export`     | GET                   |
| `/payroll/pay-runs/:id/payslips/zip`  | `/payroll/:id/payslips/zip`  | GET                   |
| `/payroll/pay-runs/:id/adjustments`   | `/payroll/:id/adjustments`   | GET / POST / DELETE   |

### 2.4 Payslips

| Flutter (Wrong)         | Backend (Correct) | Method     |
| ----------------------- | ----------------- | ---------- |
| `/payroll/payslips`     | `/payslips`       | GET (list) |
| `/payroll/payslips/:id` | `/payslips/:id`   | GET        |

### 2.5 Leave

| Flutter (Wrong)               | Backend (Correct) | Method               |
| ----------------------------- | ----------------- | -------------------- |
| `/payroll/leave-requests`     | `/leave`          | GET / POST           |
| `/payroll/leave-requests/:id` | `/leave/:id`      | GET / PATCH / DELETE |
| `/payroll/leave-balances`     | `/leave/balances` | GET                  |
| `/payroll/leave-types`        | `/leave/types`    | GET                  |

### 2.6 Attendance

| Flutter (Wrong)       | Backend (Correct)     | Method     |
| --------------------- | --------------------- | ---------- |
| `/payroll/attendance` | `/attendance/records` | GET        |
| `/payroll/shifts`     | `/attendance/shifts`  | GET / POST |

### 2.7 Other Modules

| Flutter (Wrong)                  | Backend (Correct)      | Method     |
| -------------------------------- | ---------------------- | ---------- |
| `/payroll/audit-log`             | `/audit`               | GET        |
| `/payroll/benefit-contributions` | `/benefits/enrolments` | GET / POST |

---

## 3. Farm Pay Plugin Routes

> These routes **DO EXIST** on the backend. Flutter farm screens just need to call the correct URLs.
> All routes are under `/api/v1/payroll/*` (inside the payroll router).

### 3.1 Seasons (Crop Cycles)

| Method   | Path                   | Permission    | Body                                                           |
| -------- | ---------------------- | ------------- | -------------------------------------------------------------- |
| `GET`    | `/payroll/seasons`     | `farm:view`   | —                                                              |
| `POST`   | `/payroll/seasons`     | `farm:manage` | `{name, description?, cropType?, startDate, endDate, status?}` |
| `PATCH`  | `/payroll/seasons/:id` | `farm:manage` | Any of the above fields                                        |
| `DELETE` | `/payroll/seasons/:id` | `farm:manage` | — (soft-delete → status: cancelled)                            |

**Response shape:**

```json
{
  "data": [
    {
      "id": 1,
      "name": "Harvest 2026",
      "cropType": "maize",
      "startDate": "2026-03-01",
      "endDate": "2026-06-30",
      "status": "active"
    }
  ]
}
```

### 3.2 Task Rates (Piecework Rates)

| Method  | Path                      | Permission    | Body                                                  |
| ------- | ------------------------- | ------------- | ----------------------------------------------------- |
| `GET`   | `/payroll/task-rates`     | `farm:view`   | —                                                     |
| `POST`  | `/payroll/task-rates`     | `farm:manage` | `{name, description?, unit?, ratePerUnit, minUnits?}` |
| `PATCH` | `/payroll/task-rates/:id` | `farm:manage` | Any of the above + `isActive`                         |

**Response shape:**

```json
{
  "data": [
    {
      "id": 1,
      "name": "Picking (kg)",
      "unit": "kg",
      "ratePerUnit": 2.5,
      "minUnits": 50,
      "isActive": true
    }
  ]
}
```

### 3.3 Bonus Rules

| Method  | Path                       | Permission    | Body                                                                    |
| ------- | -------------------------- | ------------- | ----------------------------------------------------------------------- |
| `GET`   | `/payroll/bonus-rules`     | `farm:view`   | —                                                                       |
| `POST`  | `/payroll/bonus-rules`     | `farm:manage` | `{name, description?, triggerType?, threshold, bonusType?, bonusValue}` |
| `PATCH` | `/payroll/bonus-rules/:id` | `farm:manage` | Any of the above + `isActive`                                           |

**`triggerType` values:** `units_above`  
**`bonusType` values:** `fixed`, `percentage`

### 3.4 Worker Advances

| Method  | Path                            | Permission                                 | Notes               |
| ------- | ------------------------------- | ------------------------------------------ | ------------------- |
| `GET`   | `/payroll/advances`             | Employee sees own; `farm:approve` sees all | —                   |
| `POST`  | `/payroll/advances`             | Authenticated employee                     | `{amount, reason?}` |
| `PATCH` | `/payroll/advances/:id/approve` | `farm:approve`                             | Body: `{}`          |
| `PATCH` | `/payroll/advances/:id/reject`  | `farm:approve`                             | Body: `{reason?}`   |
| `PATCH` | `/payroll/advances/:id/cancel`  | Owner or `farm:approve`                    | Body: `{}`          |

### 3.5 Cash Payments

| Method | Path                     | Permission    | Body                                              |
| ------ | ------------------------ | ------------- | ------------------------------------------------- |
| `GET`  | `/payroll/cash-payments` | `farm:view`   | —                                                 |
| `POST` | `/payroll/cash-payments` | `farm:manage` | `{employeeId, amount, description?, paymentDate}` |

### 3.6 Farm Pay Run

| Method | Path                        | Permission     | Notes                                  |
| ------ | --------------------------- | -------------- | -------------------------------------- |
| `GET`  | `/payroll/:id/farm-pay-run` | `payroll:view` | Returns linked `plg_farm_pay_runs` row |
| `POST` | `/payroll/farm-run`         | `farm:manage`  | Trigger a farm-specific payroll run    |

---

## 4. Backend Routes Still Missing

Flutter has data models and screens for these features but **no backend routes exist yet**. These must be built before the corresponding Flutter screens can function.

| Priority      | Flutter Feature        | Expected Backend Route                         | Flutter Model File         |
| ------------- | ---------------------- | ---------------------------------------------- | -------------------------- |
| 🔴 **High**   | Pay Structures         | `GET/POST /payroll/pay-structures`             | `pay_structure.dart`       |
| 🔴 **High**   | Pay Structure detail   | `GET/PUT/DELETE /payroll/pay-structures/:id`   | `pay_structure.dart`       |
| 🔴 **High**   | Employment Contracts   | `GET/POST /payroll/contracts`                  | `employment_contract.dart` |
| 🔴 **High**   | Contract detail        | `GET/PUT/DELETE /payroll/contracts/:id`        | `employment_contract.dart` |
| 🔴 **High**   | Deduction Rules        | `GET/POST /payroll/deductions`                 | `deduction_rule.dart`      |
| 🔴 **High**   | Employer Config        | `GET /payroll/employer-config`                 | `employer_config.dart`     |
| 🔴 **High**   | Employer Config update | `PUT /payroll/employer-config`                 | `employer_config.dart`     |
| 🟡 **Medium** | Garnishee Orders       | `GET/POST /payroll/garnishee-orders`           | `garnishee_order.dart`     |
| 🟡 **Medium** | Garnishee Order detail | `GET/PUT/DELETE /payroll/garnishee-orders/:id` | `garnishee_order.dart`     |
| 🟡 **Medium** | Compliance Alerts      | `GET /payroll/compliance-alerts`               | `compliance_alert.dart`    |
| 🟡 **Medium** | Payment Transactions   | `GET /payroll/transactions`                    | `payment_transaction.dart` |
| 🟡 **Medium** | Incident Records       | `GET/POST /payroll/incidents`                  | `incident_record.dart`     |
| 🟡 **Medium** | Communication Logs     | `GET/POST /payroll/communications`             | `communication_log.dart`   |
| 🟡 **Medium** | Worker Disputes        | `GET/POST /payroll/worker-disputes`            | `worker_dispute.dart`      |
| 🟢 **Low**    | Task Assignments       | `GET/POST /payroll/task-assignments`           | `task_assignment.dart`     |
| 🟢 **Low**    | Piecework Logs         | `GET/POST /payroll/piecework`                  | `piecework_log.dart`       |

---

## 5. Flutter AuthUser Model Mapping

```dart
// Current AuthUser fields → What they should map to from backend user object

AuthUser.id              ← json['id']                     ✅ exists
AuthUser.email           ← json['email']                  ✅ exists
AuthUser.firstName       ← json['name'].split(' ').first  ⚠️  backend sends full name
AuthUser.lastName        ← json['name'].split(' ').last   ⚠️  backend sends full name
AuthUser.role            ← json['role']                   ✅ exists
AuthUser.mfaEnabled      ← json['mfa_enabled']            ⚠️  snake_case
AuthUser.farmName        ← NOT IN BACKEND RESPONSE        ❌ remove or fetch separately
AuthUser.farmOwnerId     ← use json['company_id']         ⚠️  rename/remap
AuthUser.subscriptionPlan  ← NOT IN BACKEND               ❌ derive from features[]
AuthUser.subscriptionStatus ← json['subscription_status'] ⚠️  snake_case
AuthUser.activatedModules   ← json['features']            ⚠️  rename
AuthUser.phone           ← NOT in JWT payload             ❌ fetch from /employees profile
AuthUser.jobTitle        ← NOT in JWT payload             ❌ fetch from /employees profile
```

---

## 6. Registration Wizard

### Current Flutter Flow (Wrong)

Flutter `RegistrationScreen` collects farmer-specific data and calls `POST /auth/register` with:

```json
{
  "firstName": "Jane",
  "lastName": "Farmer",
  "email": "jane@farm.co.za",
  "password": "...",
  "phone": "...",
  "farmName": "Green Acres",
  "country": "ZA",
  "province": "WC",
  "subscriptionPlan": "starter",
  "activatedModules": ["payroll", "farm_pay"]
}
```

### Backend Routes Available

```
POST /auth/register          → Creates basic user account: { name, email, password }
POST /auth/tenant-signup     → Creates company + assigns owner: { company_name, country, ... }
```

### What Flutter Must Do

1. **Step 1:** Call `POST /auth/register` with `{ name: firstName + ' ' + lastName, email, password }`
2. **Step 2:** Call `POST /auth/tenant-signup` with `{ company_name: farmName, country, province, ... }`

---

## 7. Action Plan

### Phase 1 — Fix Flutter (No backend changes needed)

- [ ] **`auth_remote_data_source.dart`**
  - Change `data['accessToken']` → `data['access_token']`
  - Remove `data['refreshToken']` read — rely on cookie (Dio `CookieJar`)
  - Remove separate `GET /auth/me` call after login — use `data['user']` from login response
  - Fix MFA: `{token, tempToken}` → `{challenge_token, totp_code}`
  - Fix SSO: `/auth/social` → `/auth/microsoft`
  - Remove `/farm/team`, `/farm/staff` calls → use `/employees`, `/users`

- [ ] **`api_client.dart`** (401 interceptor)
  - Remove refresh token from request body — cookie sent automatically
  - Add `Dio` with `CookieManager(CookieJar())` to handle `Set-Cookie`

- [ ] **`auth_user.dart`**
  - Map `json['name']` → split to `firstName` / `lastName`
  - Map `json['features']` → `activatedModules`
  - Map `json['subscription_status']` → `subscriptionStatus`
  - Map `json['company_id']` → retain as `companyId` (rename `farmOwnerId`)
  - Remove `farmName` from JWT-sourced fields

- [ ] **`payroll_remote_data_source.dart`**
  - Strip `/payroll/` prefix from: employees, pay-groups, payslips, leave, attendance, audit, benefits
  - Fix `/payroll/pay-runs` → `/payroll` (list) and `/payroll/run` (create)
  - Fix `/payroll/pay-runs/:id/*` → `/payroll/:id/*`

- [ ] **Farm Pay screens**
  - Wire seasons screen → `GET/POST /payroll/seasons`
  - Wire task-rates screen → `GET/POST /payroll/task-rates`
  - Wire advances screen → `GET/POST /payroll/advances`
  - Wire bonus-rules screen → `GET/POST /payroll/bonus-rules`
  - Wire cash-payments screen → `GET/POST /payroll/cash-payments`

- [ ] **Registration wizard**
  - Split into two calls: `/auth/register` then `/auth/tenant-signup`

### Phase 2 — Build Missing Backend Routes

Build the 16 routes listed in [Section 4](#4-backend-routes-still-missing) in priority order. Flutter models are already ready. Each route follows the same tenant-scoped pattern: `where: { company_id: req.companyId }`.

---

## Appendix: Backend App.js Mount Points

```
/auth                → auth router
/employees           → employees router
/payroll             → payroll router (runs + farm pay plugin)
/payroll-groups      → payroll-groups router
/payslips            → payslips router
/leave               → leave router
/attendance          → attendance router
/self-service        → self-service router
/benefits            → benefits router
/audit               → audit router
/users               → users router
/departments         → departments router
/positions           → positions router
```
