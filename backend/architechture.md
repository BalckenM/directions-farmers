# 4DFarmer API — Backend Project Structure

## Stack

| Concern         | Choice                                            |
| --------------- | ------------------------------------------------- |
| Runtime         | Node.js 20 LTS                                    |
| Language        | TypeScript 5.x (strict mode)                      |
| Framework       | Express 5                                         |
| ORM             | Drizzle ORM (`drizzle-orm/mysql2`)                |
| Database        | MySQL 8.0                                         |
| Auth            | Jose 6 (JWT HS256) + bcryptjs                     |
| Validation      | Zod 4                                             |
| Rate limiting   | express-rate-limit (in-memory, per IP)            |
| Cache           | lru-cache (in-memory, TTL-based)                  |
| Background jobs | node-cron + DB-backed job table                   |
| Email           | nodemailer + SMTP (Gmail / custom domain)         |
| Logging         | Pino                                              |
| Testing         | Vitest + Supertest                                |
| Deployment      | Firebase App Hosting (Cloud Run, containerized)   |
| CI/CD           | GitHub Actions → Docker build → `firebase deploy` |

---

## Response Envelope Contracts

**Standard modules** (auth, goat, cattle, poultry, crop, financial, events, livestock, production, record, traceability, settings, insights, advisor, disease, weather, dashboard):

```
GET  list  → { "data": [...], "meta": { "page": n, "limit": n, "total": n } }
GET  one   → { "data": { ... } }
POST       → { "data": { ... } }           HTTP 201
PUT/PATCH  → { "data": { ... } }
DELETE     → HTTP 204 no body
Error      → { "error": { "code": "string", "message": "string" } }
```

**Payroll module** (Flutter `PayrollRemoteDataSource` expects raw arrays — breaking this contract causes app crash):

```
GET list → [...]                           raw JSON array, NO envelope
POST     → { ... }                         raw JSON object
PUT      → { ... }                         raw JSON object
```

---

## Module-Based Folder Convention

Complex domain modules (goat, cattle, poultry, crop, payroll) are organised into **subfolders by module name** under each architectural layer. Each subfolder contains one file per sub-domain concern, plus a barrel re-export file:

```
src/
├── controllers/{module}/
│   ├── {module}.controller.ts    ← barrel re-export aggregating all sub-controllers
│   ├── animals.controller.ts     ← one file per sub-domain
│   ├── health.controller.ts
│   └── ...
├── services/{module}/
│   ├── {module}.service.ts       ← barrel re-export / facade
│   ├── animals.service.ts
│   └── ...
├── repositories/{module}/
│   ├── {module}.repo.ts          ← barrel re-export
│   ├── animals.repo.ts
│   └── ...
├── routes/{module}/
│   └── index.ts                  ← registers all sub-routes for the module
└── validators/{module}/
    └── {module}.validator.ts     ← all Zod schemas for the module
```

Simpler modules (financial, events, production, etc.) remain as single files per layer (e.g. `financial.controller.ts`, `financial.service.ts`).

---

## Project Root

```
4dfarmer-api/
├── package.json
├── tsconfig.json
├── .env.example
├── .env                                   ← gitignored
├── .gitignore
├── Dockerfile                             ← multi-stage: build (tsc) → runtime (node:20-alpine)
├── .dockerignore                          ← excludes node_modules, src/, .env, test files
├── apphosting.yaml                        ← Firebase App Hosting config (runConfig, env vars)
├── drizzle.config.ts                      ← dialect: mysql, schema: src/db/schema
├── vitest.config.ts
├── nodemon.json                           ← dev only
│
├── .github/
│   └── workflows/
│       └── deploy.yml                     ← lint → test → docker build → firebase deploy
│
├── src/
│   ├── index.ts                           ← process bootstrap: load env, connect DB, start server
│   ├── app.ts                             ← Express app factory: register middleware + router
│   │
│   ├── config/
│   │   ├── env.ts                         ← Zod-validated process.env; throws on startup if invalid
│   │   └── database.ts                    ← mysql2 pool + Drizzle instance; exported as `db`
│
│   ├── db/
│   │   ├── migrate.ts                     ← programmatic migration runner
│   │   │                                    calls migrate() from drizzle-orm/mysql2/migrator
│   │   │                                    reads migrations/ folder; drizzle tracks applied files
│   │   │                                    in __drizzle_migrations table; run on every deploy
│   │   │                                    `npm run db:migrate`
│   │   │
│   │   ├── seed.ts                        ← incremental seed runner
│   │   │                                    imports ordered registry from seeds/index.ts
│   │   │                                    checks seed_history table before each seed
│   │   │                                    runs only seeds not yet recorded; inserts row on success
│   │   │                                    safe to call on every deploy: skips already-run seeds
│   │   │                                    `npm run db:seed`
│   │   │
│   │   ├── migrations/                    ← ALL FILES AUTO-GENERATED by `drizzle-kit generate`
│   │   │   │                                NEVER hand-edit; each schema change appends one new file
│   │   │   │                                applied in ascending numeric order; idempotent via journal
│   │   │   │
│   │   │   ├── meta/                      ← drizzle-kit internal tracking (commit to git)
│   │   │   │   ├── _journal.json          ← records every generated migration + checksum
│   │   │   │   └── <hash>_snapshot.json  ← full schema snapshot per migration (auto-generated)
│   │   │   │
│   │   │   ├── 0000_init_auth.sql         ← farm_owners, farm_staff, tokens tables
│   │   │   ├── 0001_init_subscription.sql ← subscription_plans, modules, plan_module_access,
│   │   │   │                                 farm_subscriptions, farm_module_activations
│   │   │   ├── 0002_init_goat.sql         ← all goat_* tables
│   │   │   ├── 0003_init_cattle.sql       ← all cattle_* tables
│   │   │   ├── 0004_init_poultry.sql      ← all poultry_* tables
│   │   │   ├── 0005_init_crop.sql         ← all crop_* tables
│   │   │   ├── 0006_init_payroll.sql      ← all payroll_* tables + payroll_piecework_logs
│   │   │   ├── 0007_init_farm.sql         ← farm_paddocks, farm_settings
│   │   │   ├── 0008_init_financial.sql    ← financial_transactions
│   │   │   ├── 0009_init_events.sql       ← farm_health_events, farm_weight_records,
│   │   │   │                                 farm_breeding_events
│   │   │   ├── 0010_init_production.sql   ← production_milk_records, production_egg_records,
│   │   │   │                                 production_wool_records
│   │   │   ├── 0011_init_traceability.sql ← movement_records
│   │   │   ├── 0012_init_record.sql       ← feed_logs
│   │   │   ├── 0013_init_audit.sql        ← audit_logs, seed_history
│   │   │   └── 0014_add_livestock.sql     ← livestock_groups
│   │   │                                    (future: 0015_add_<feature>.sql per schema change)
│   │   │
│   │   ├── seeds/                         ← INCREMENTAL, IDEMPOTENT reference data
│   │   │   │                                each file uses INSERT ... ON DUPLICATE KEY UPDATE
│   │   │   │                                new reference data = new numbered file; never edit old ones
│   │   │   │                                seed runner records each file name in seed_history on success
│   │   │   │
│   │   │   ├── index.ts                   ← ordered registry
│   │   │   │                                export const seeds: SeedEntry[] = [
│   │   │   │                                  { name: '001_subscription_plans', run: import('./001_...') }
│   │   │   │                                  { name: '002_modules',            run: import('./002_...') }
│   │   │   │                                  { name: '003_plan_module_access', run: import('./003_...') }
│   │   │   │                                ]  ← append new entries here when adding seed files
│   │   │   │
│   │   │   ├── 001_subscription_plans.seed.ts  ← upsert starter / growth / enterprise plan rows
│   │   │   │                                      INSERT ... ON DUPLICATE KEY UPDATE label, price, ...
│   │   │   ├── 002_modules.seed.ts             ← upsert cattle/goat/poultry/crop/payroll/...
│   │   │   │                                      INSERT ... ON DUPLICATE KEY UPDATE label, description
│   │   │   └── 003_plan_module_access.seed.ts  ← upsert which modules each plan includes
│   │   │                                          INSERT IGNORE INTO plan_module_access ...
│   │   │                                          (future: add 004_*.seed.ts; append to index.ts)
│   │   │
│   │   └── schema/
│   │       ├── index.ts                   ← barrel re-export of all schema files
│   │       ├── auth.schema.ts             ← farm_owners, farm_staff, refresh_tokens,
│   │       │                                 email_verification_tokens,
│   │       │                                 password_reset_tokens, staff_invite_tokens
│   │       ├── subscription.schema.ts     ← subscription_plans, modules,
│   │       │                                 plan_module_access, farm_subscriptions,
│   │       │                                 farm_module_activations
│   │       ├── audit.schema.ts            ← audit_logs, seed_history
│   │       ├── goat.schema.ts             ← goat_animals, goat_weight_records,
│   │       │                                 goat_mating_records, goat_pregnancy_checks,
│   │       │                                 goat_kidding_events, goat_daily_milk,
│   │       │                                 goat_shearing_records, goat_health_events,
│   │       │                                 goat_medication_logs, goat_vaccinations,
│   │       │                                 goat_sale_records, goat_feed_records,
│   │       │                                 goat_pasture_records, goat_famacha_records,
│   │       │                                 goat_bcs_records
│   │       ├── cattle.schema.ts           ← cattle_animals, cattle_weight_records,
│   │       │                                 cattle_breeding_records, cattle_pregnancy_checks,
│   │       │                                 cattle_calving_events, cattle_daily_milk,
│   │       │                                 cattle_health_events, cattle_medication_logs,
│   │       │                                 cattle_vaccinations, cattle_sale_records,
│   │       │                                 cattle_feed_records, cattle_pasture_records,
│   │       │                                 cattle_bcs_records, cattle_dipping_records
│   │       ├── poultry.schema.ts          ← poultry_flocks, poultry_daily_records,
│   │       │                                 poultry_vaccination_schedules, poultry_feed_phases,
│   │       │                                 poultry_harvest_records, poultry_medication_logs,
│   │       │                                 poultry_disease_events, poultry_environment_readings,
│   │       │                                 poultry_inventory, poultry_egg_sales,
│   │       │                                 poultry_chick_sales
│   │       ├── crop.schema.ts             ← crop_categories, crops, crop_fields,
│   │       │                                 crop_seasons, crop_planting_plans, crop_tasks,
│   │       │                                 crop_pest_observations, crop_spray_records,
│   │       │                                 crop_expenses, crop_harvest_records,
│   │       │                                 crop_sales, crop_calendar_events,
│   │       │                                 crop_advisory_content
│   │       ├── payroll.schema.ts          ← payroll_employees, payroll_contracts,
│   │       │                                 payroll_pay_groups, payroll_pay_structures,
│   │       │                                 payroll_pay_runs, payroll_payslips,
│   │       │                                 payroll_deduction_rules, payroll_garnishee_orders,
│   │       │                                 payroll_leave_types, payroll_leave_balances,
│   │       │                                 payroll_leave_requests, payroll_transactions,
│   │       │                                 payroll_compliance_alerts, payroll_audit_log,
│   │       │                                 payroll_incidents, payroll_communications,
│   │       │                                 payroll_piecework_logs
│   │       ├── farm.schema.ts             ← farm_paddocks, farm_settings
│   │       ├── financial.schema.ts        ← financial_transactions
│   │       ├── livestock.schema.ts        ← livestock_groups (cross-species view support)
│   │       ├── events.schema.ts           ← farm_health_events, farm_weight_records,
│   │       │                                 farm_breeding_events (cross-species event log)
│   │       ├── production.schema.ts       ← production_milk_records, production_egg_records,
│   │       │                                 production_wool_records
│   │       ├── traceability.schema.ts     ← movement_records
│   │       └── record.schema.ts           ← feed_logs
│   │
│   ├── middleware/
│   │   ├── auth.middleware.ts             ← verifies JWT; attaches req.auth
│   │   │                                    { sub, subType, farmOwnerId, modules[], role }
│   │   ├── module-guard.middleware.ts     ← factory: requireModule('goat') checks req.auth.modules
│   │   ├── rate-limiter.middleware.ts     ← express-rate-limit token-bucket per IP
│   │   ├── validate.middleware.ts         ← factory: validate({ body, query, params } ZodSchemas)
│   │   ├── audit.middleware.ts            ← writes audit_logs row after mutating requests
│   │   └── error-handler.middleware.ts   ← catches all thrown errors; formats error envelope
│   │
│   ├── lib/
│   │   ├── jwt.ts                         ← signAccessToken(), signRefreshToken(), verifyToken()
│   │   ├── password.ts                    ← hashPassword(), comparePassword()
│   │   ├── token-store.ts                 ← storeRefreshToken(), findRefreshToken(),
│   │   │                                    revokeRefreshToken(), revokeAllForSubject()
│   │   ├── response.ts                    ← ok(), okList(), created(), noContent(), apiError()
│   │   ├── pagination.ts                  ← parsePagination(query), buildMeta()
│   │
│   ├── validators/
│   │   ├── auth.validator.ts              ← RegisterSchema, LoginSchema, RefreshSchema,
│   │   │                                    ForgotPasswordSchema, ResetPasswordSchema,
│   │   │                                    AcceptInviteSchema, InviteStaffSchema
│   │   ├── goat/
│   │   │   └── goat.validator.ts          ← GoatSchema, WeightSchema, MatingSchema,
│   │   │                                    PregnancyCheckSchema, KiddingSchema, MilkSchema,
│   │   │                                    ShearingSchema, HealthEventSchema, MedicationSchema,
│   │   │                                    VaccinationSchema, SaleSchema, FeedSchema,
│   │   │                                    PastureSchema, FamachaSchema, BCSSchema
│   │   ├── cattle/
│   │   │   └── cattle.validator.ts        ← CattleSchema, BreedingSchema, CalvingSchema,
│   │   │                                    DippingSchema + shared shapes from goat
│   │   ├── poultry/
│   │   │   └── poultry.validator.ts       ← FlockSchema, DailyRecordSchema, VaccinationScheduleSchema,
│   │   │                                    FeedPhaseSchema, HarvestSchema, MedicationLogSchema,
│   │   │                                    DiseaseEventSchema, EnvironmentReadingSchema,
│   │   │                                    InventorySchema, EggSaleSchema, ChickSaleSchema
│   │   ├── crop/
│   │   │   └── crop.validator.ts          ← CategorySchema, CropSchema, FieldSchema, SeasonSchema,
│   │   │                                    PlantingPlanSchema, TaskSchema, PestObservationSchema,
│   │   │                                    SprayRecordSchema, ExpenseSchema, HarvestRecordSchema,
│   │   │                                    SaleSchema, CalendarEventSchema
│   │   ├── payroll/
│   │   │   └── payroll.validator.ts       ← EmployeeSchema, ContractSchema, PayGroupSchema,
│   │   │                                    PayStructureSchema, PayRunCalculateSchema,
│   │   │                                    DeductionSchema, GarnisheeSchema,
│   │   │                                    LeaveRequestSchema, TerminationSchema,
│   │   │                                    VoidContractSchema, RejectLeaveSchema,
│   │   │                                    ResolveAlertSchema, PieceworkDeleteSchema,
│   │   │                                    IncidentSchema, CommunicationSchema
│   │   ├── events.validator.ts            ← HealthEventSchema, WeightRecordSchema, BreedingEventSchema
│   │   ├── farm.validator.ts              ← InviteStaffSchema, UpdateStaffSchema
│   │   ├── financial.validator.ts         ← FinancialTransactionSchema
│   │   ├── livestock.validator.ts         ← GroupSchema
│   │   ├── production.validator.ts        ← MilkSchema, EggSchema, WoolSchema
│   │   ├── record.validator.ts            ← FeedLogSchema
│   │   ├── traceability.validator.ts      ← MovementSchema
│   │   └── common.validator.ts            ← IdParamSchema, PaginationSchema, UUIDSchema
│   │
│   ├── repositories/
│   │   ├── auth.repo.ts                   ← findById, findByEmail, create, update,
│   │   │                                    updatePassword, updateMfa (owners + staff + tokens)
│   │   ├── subscription.repo.ts           ← findByFarmOwner, getActivatedModules,
│   │   │                                    activateModule, deactivateModule,
│   │   │                                    updatePlan, findAllPlans
│   │   ├── goat/                          ← split by concern; each file handles one sub-domain
│   │   │   ├── goat.repo.ts              ← barrel re-export of all goat repos
│   │   │   ├── _projections.ts            ← shared column projection helpers
│   │   │   ├── animals.repo.ts            ← animals CRUD; all queries filter by farmOwnerId
│   │   │   ├── weight.repo.ts             ← weight records
│   │   │   ├── mating.repo.ts             ← mating records
│   │   │   ├── pregnancy.repo.ts          ← pregnancy checks
│   │   │   ├── kidding.repo.ts            ← kidding events
│   │   │   ├── milk.repo.ts               ← daily milk records
│   │   │   ├── shearing.repo.ts           ← shearing records
│   │   │   ├── health.repo.ts             ← health events
│   │   │   ├── medications.repo.ts        ← medication logs
│   │   │   ├── vaccinations.repo.ts       ← vaccination records
│   │   │   ├── sales.repo.ts              ← sale records
│   │   │   ├── feed.repo.ts               ← feed records
│   │   │   ├── pasture.repo.ts            ← pasture assignments
│   │   │   ├── famacha.repo.ts            ← FAMACHA scores
│   │   │   └── bcs.repo.ts               ← body condition scores
│   │   ├── cattle/                        ← same pattern as goat/
│   │   │   ├── cattle.repo.ts            ← barrel re-export
│   │   │   ├── _projections.ts            ← shared column projections
│   │   │   ├── animals.repo.ts            ← animals CRUD
│   │   │   ├── weight.repo.ts             ← weight records
│   │   │   ├── breeding.repo.ts           ← breeding records
│   │   │   ├── pregnancy.repo.ts          ← pregnancy checks
│   │   │   ├── calving.repo.ts            ← calving events
│   │   │   ├── milk.repo.ts               ← daily milk records
│   │   │   ├── health.repo.ts             ← health events
│   │   │   ├── medications.repo.ts        ← medication logs
│   │   │   ├── vaccinations.repo.ts       ← vaccination records
│   │   │   ├── sales.repo.ts              ← sale records
│   │   │   ├── feed.repo.ts               ← feed records
│   │   │   ├── pasture.repo.ts            ← pasture assignments
│   │   │   ├── bcs.repo.ts               ← body condition scores
│   │   │   └── dipping.repo.ts           ← dipping records (cattle-specific)
│   │   ├── poultry/                       ← split by sub-domain
│   │   │   ├── poultry.repo.ts           ← barrel re-export
│   │   │   ├── flocks.repo.ts             ← flock CRUD
│   │   │   ├── daily-records.repo.ts      ← daily production records
│   │   │   ├── vaccinations.repo.ts       ← vaccination schedules
│   │   │   └── harvest.repo.ts            ← harvest records
│   │   ├── crop/                          ← split by sub-domain
│   │   │   ├── crop.repo.ts              ← barrel re-export
│   │   │   ├── fields.repo.ts             ← field CRUD
│   │   │   ├── planting-plans.repo.ts     ← planting plan CRUD
│   │   │   ├── tasks.repo.ts              ← task CRUD
│   │   │   ├── spray-records.repo.ts      ← spray/chemical application records
│   │   │   └── harvest.repo.ts            ← harvest records
│   │   ├── payroll/                       ← split by concern
│   │   │   ├── payroll.repo.ts           ← barrel re-export
│   │   │   ├── employees.repo.ts          ← employee CRUD
│   │   │   ├── contracts.repo.ts          ← contract CRUD
│   │   │   ├── contracts-flat.repo.ts     ← denormalized contract view
│   │   │   ├── pay-groups.repo.ts         ← pay group CRUD
│   │   │   ├── pay-structures.repo.ts     ← pay structure CRUD
│   │   │   ├── pay-runs.repo.ts           ← pay run lifecycle
│   │   │   ├── payslips.repo.ts           ← payslip storage/retrieval
│   │   │   ├── deductions.repo.ts         ← deduction rules + garnishee orders
│   │   │   ├── leave.repo.ts              ← leave types + balances
│   │   │   ├── leave-requests.repo.ts     ← leave request CRUD + approval
│   │   │   ├── leave-balances.repo.ts     ← leave balance queries
│   │   │   ├── transactions.repo.ts       ← payroll transaction log
│   │   │   ├── compliance.repo.ts         ← compliance alerts
│   │   │   ├── audit.repo.ts             ← payroll audit log
│   │   │   ├── communications.repo.ts     ← staff communications
│   │   │   └── piecework.repo.ts         ← piecework task logs
│   │   ├── farm.repo.ts                   ← getPaddocks, updatePaddock, getSettings
│   │   ├── financial.repo.ts              ← list, create, findById
│   │   ├── livestock.repo.ts              ← getAnimals(species), getGroups — queries goat/cattle
│   │   ├── events.repo.ts                ← getHealthEvents, getWeightRecords, getBreedingEvents
│   │   │                                    — fan-out across goat/cattle tables
│   │   ├── production.repo.ts            ← getMilk, getEggs, getWool — fan-out
│   │   ├── record.repo.ts                ← getFeedLogs, addFeedLog
│   │   ├── traceability.repo.ts           ← getMovements, addMovement
│   │   └── dashboard.repo.ts             ← aggregation query for summary counts
│   │
│   ├── services/
│   │   ├── auth.service.ts                ← register, login, refresh, logout, acceptInvite,
│   │   │                                    forgotPassword, resetPassword, inviteStaff
│   │   ├── subscription.service.ts        ← getplan, upgrade, checkModuleAccess,
│   │   │                                    enforcePlanLimits (livestock/field/user caps)
│   │   ├── email.service.ts               ← sendVerification, sendPasswordReset,
│   │   │                                    sendStaffInvite, sendPayslip
│   │   ├── dashboard.service.ts           ← aggregates summary from all modules
│   │   ├── goat/                          ← split by sub-domain; goat.service.ts re-exports
│   │   │   ├── goat.service.ts           ← barrel re-export / facade
│   │   │   ├── animals.service.ts         ← business rules: plan limits, cascade deletes
│   │   │   ├── weight.service.ts          ← weight record business logic
│   │   │   ├── mating.service.ts          ← mating record logic
│   │   │   ├── pregnancy.service.ts       ← pregnancy check logic
│   │   │   ├── kidding.service.ts         ← kidding event logic
│   │   │   ├── milk.service.ts            ← daily milk logic
│   │   │   ├── shearing.service.ts        ← shearing record logic
│   │   │   ├── health.service.ts          ← health event logic
│   │   │   ├── medications.service.ts     ← medication log logic
│   │   │   ├── vaccinations.service.ts    ← vaccination logic
│   │   │   ├── sales.service.ts           ← sale record logic
│   │   │   ├── feed.service.ts            ← feed record logic
│   │   │   ├── pasture.service.ts         ← pasture exit validation
│   │   │   ├── famacha.service.ts         ← FAMACHA score logic
│   │   │   └── bcs.service.ts            ← body condition score logic
│   │   ├── cattle/                        ← same pattern as goat + dipping
│   │   │   ├── cattle.service.ts         ← barrel re-export / facade
│   │   │   ├── animals.service.ts         ← business rules: plan limits, cascade deletes
│   │   │   ├── weight.service.ts          ← weight record logic
│   │   │   ├── breeding.service.ts        ← breeding record logic
│   │   │   ├── pregnancy.service.ts       ← pregnancy check logic
│   │   │   ├── calving.service.ts         ← calving event logic
│   │   │   ├── milk.service.ts            ← daily milk logic
│   │   │   ├── health.service.ts          ← health event logic
│   │   │   ├── medications.service.ts     ← medication log logic
│   │   │   ├── vaccinations.service.ts    ← vaccination logic
│   │   │   ├── sales.service.ts           ← sale record logic
│   │   │   ├── feed.service.ts            ← feed record logic
│   │   │   ├── pasture.service.ts         ← pasture management
│   │   │   ├── bcs.service.ts            ← body condition score logic
│   │   │   └── dipping.service.ts        ← dipping interval enforcement
│   │   ├── poultry/                       ← split by sub-domain
│   │   │   ├── poultry.service.ts        ← barrel re-export / facade
│   │   │   ├── flocks.service.ts          ← flock state machine, CRUD rules
│   │   │   ├── daily-records.service.ts   ← daily record logic
│   │   │   ├── vaccinations.service.ts    ← vaccination schedule logic
│   │   │   └── harvest.service.ts         ← harvest record logic
│   │   ├── crop/                          ← split by sub-domain
│   │   │   ├── crop.service.ts           ← barrel re-export / facade
│   │   │   ├── fields.service.ts          ← field CRUD logic
│   │   │   ├── planting-plans.service.ts  ← season/plan overlap checks
│   │   │   ├── tasks.service.ts           ← task scheduling logic
│   │   │   ├── spray-records.service.ts   ← spray record logic
│   │   │   └── harvest.service.ts         ← harvest record logic
│   │   ├── payroll/                       ← split by concern
│   │   │   ├── payroll.service.ts        ← barrel re-export / facade
│   │   │   ├── employees.service.ts       ← employee lifecycle, termination
│   │   │   ├── contracts.service.ts       ← contract management
│   │   │   ├── contracts-flat.service.ts  ← denormalized contract view
│   │   │   ├── pay-groups.service.ts      ← pay group logic
│   │   │   ├── pay-structures.service.ts  ← wage type definitions
│   │   │   ├── pay-runs.service.ts        ← pay-run calculation engine
│   │   │   ├── payslips.service.ts        ← payslip generation + PDF
│   │   │   ├── deductions.service.ts      ← deduction rule evaluation
│   │   │   ├── leave.service.ts           ← leave balance deduction, approval flow
│   │   │   ├── leave-balances.service.ts  ← leave balance queries
│   │   │   ├── compliance.service.ts      ← compliance rule evaluation, alert creation
│   │   │   ├── audit.service.ts          ← payroll audit log queries
│   │   │   └── communications.service.ts  ← staff communication dispatch
│   │   ├── farm.service.ts               ← team management, paddock management
│   │   ├── financial.service.ts           ← transaction categorisation
│   │   ├── events.service.ts              ← cross-species event aggregation
│   │   ├── livestock.service.ts           ← fan-out across repositories by species
│   │   ├── production.service.ts          ← production record aggregation
│   │   ├── record.service.ts             ← feed log management
│   │   ├── traceability.service.ts        ← movement record logic
│   │   ├── weather.service.ts             ← proxies 3rd-party weather API; caches 15 min
│   │   ├── insights.service.ts            ← market price aggregation
│   │   ├── advisor.service.ts             ← proxies LLM/AI API
│   │   └── disease.service.ts             ← proxies image-classification API
│   │
│   ├── controllers/                       ← grouped by module name into subfolders
│   │   ├── auth.controller.ts
│   │   ├── farm.controller.ts
│   │   ├── dashboard.controller.ts
│   │   ├── goat/                          ← one controller per sub-domain
│   │   │   ├── goat.controller.ts        ← barrel re-export aggregating all sub-controllers
│   │   │   ├── animals.controller.ts      ← list, create, getOne, update, remove
│   │   │   ├── weight.controller.ts       ← listWeights, addWeight, removeWeight
│   │   │   ├── mating.controller.ts       ← listMatings, addMating, updateMating
│   │   │   ├── pregnancy.controller.ts    ← listPregnancyChecks, addPregnancyCheck
│   │   │   ├── kidding.controller.ts      ← listKidding, addKidding
│   │   │   ├── milk.controller.ts         ← listMilk, addMilk, removeMilk
│   │   │   ├── shearing.controller.ts     ← listShearing, addShearing
│   │   │   ├── health.controller.ts       ← listHealth, addHealth, updateHealth
│   │   │   ├── medications.controller.ts  ← listMedications, addMedication
│   │   │   ├── vaccinations.controller.ts ← listVaccinations, addVaccination, markGiven
│   │   │   ├── sales.controller.ts        ← listSales, addSale, updateSale, removeSale
│   │   │   ├── feed.controller.ts         ← listFeed, addFeed, removeFeed
│   │   │   ├── pasture.controller.ts      ← listPastures, addPasture, exitPasture
│   │   │   ├── famacha.controller.ts      ← listFamacha, addFamacha
│   │   │   └── bcs.controller.ts         ← listBcs, addBcs
│   │   ├── cattle/                        ← same per-concern split as goat + dipping
│   │   │   ├── cattle.controller.ts      ← barrel re-export
│   │   │   ├── animals.controller.ts      ← list, create, getOne, update, remove
│   │   │   ├── weight.controller.ts       ← listWeights, addWeight, removeWeight
│   │   │   ├── breeding.controller.ts     ← listBreeding, addBreeding, updateBreeding
│   │   │   ├── pregnancy.controller.ts    ← listPregnancyChecks, addPregnancyCheck
│   │   │   ├── calving.controller.ts      ← listCalving, addCalving
│   │   │   ├── milk.controller.ts         ← listMilk, addMilk, removeMilk
│   │   │   ├── health.controller.ts       ← listHealth, addHealth, updateHealth
│   │   │   ├── medications.controller.ts  ← listMedications, addMedication
│   │   │   ├── vaccinations.controller.ts ← listVaccinations, addVaccination, markGiven
│   │   │   ├── sales.controller.ts        ← listSales, addSale, updateSale, removeSale
│   │   │   ├── feed.controller.ts         ← listFeed, addFeed, removeFeed
│   │   │   ├── pasture.controller.ts      ← listPastures, addPasture, exitPasture
│   │   │   ├── bcs.controller.ts         ← listBcs, addBcs
│   │   │   └── dipping.controller.ts     ← listDipping, addDipping
│   │   ├── poultry/                       ← split by resource type
│   │   │   ├── poultry.controller.ts     ← barrel re-export
│   │   │   ├── flocks.controller.ts       ← listFlocks, createFlock, getFlock, updateFlock, deleteFlock
│   │   │   ├── daily-records.controller.ts← listDailyRecords, addDailyRecord
│   │   │   ├── vaccinations.controller.ts ← listVaccinationSchedules, addVaccinationSchedule
│   │   │   └── harvest.controller.ts      ← listHarvestRecords, addHarvestRecord
│   │   ├── crop/                          ← split by resource type
│   │   │   ├── crop.controller.ts        ← barrel re-export
│   │   │   ├── fields.controller.ts       ← listFields, addField, updateField, deleteField
│   │   │   ├── planting-plans.controller.ts← listPlantingPlans, addPlan, updatePlan, deletePlan
│   │   │   ├── tasks.controller.ts        ← listTasks, addTask, updateTask, deleteTask
│   │   │   ├── spray-records.controller.ts← listSprayRecords, addSpray, updateSpray, deleteSpray
│   │   │   └── harvest.controller.ts      ← listHarvestRecords, addHarvest, updateHarvest, deleteHarvest
│   │   ├── payroll/                       ← one controller per payroll concern
│   │   │   ├── payroll.controller.ts     ← barrel re-export
│   │   │   ├── employees.controller.ts    ← listEmployees, createEmployee, getEmployee, updateEmployee, terminate
│   │   │   ├── contracts.controller.ts    ← listContracts, createContract, updateContract, voidContract
│   │   │   ├── contracts-flat.controller.ts← denormalized contract view handlers
│   │   │   ├── pay-groups.controller.ts   ← listPayGroups, createPayGroup, updatePayGroup, deactivate
│   │   │   ├── pay-structures.controller.ts← listPayStructures, create, update
│   │   │   ├── pay-runs.controller.ts     ← listPayRuns, calculate, approve, disburse
│   │   │   ├── payslips.controller.ts     ← listPayslips, downloadPdf
│   │   │   ├── deductions.controller.ts   ← listDeductions, create, update, deactivate
│   │   │   ├── leave.controller.ts        ← listLeaveRequests, create, approve, reject, cancel, delete
│   │   │   ├── leave-balances.controller.ts← listLeaveBalances, listLeaveTypes
│   │   │   ├── compliance.controller.ts   ← listAlerts, resolveAlert
│   │   │   ├── audit.controller.ts       ← getAuditLog, listIncidents, createIncident
│   │   │   └── communications.controller.ts← listCommunications, createCommunication
│   │   ├── financial.controller.ts
│   │   ├── weather.controller.ts
│   │   ├── livestock.controller.ts
│   │   ├── events.controller.ts
│   │   ├── production.controller.ts
│   │   ├── record.controller.ts
│   │   ├── traceability.controller.ts
│   │   ├── settings.controller.ts
│   │   ├── insights.controller.ts
│   │   ├── advisor.controller.ts
│   │   └── disease.controller.ts
│   │
│   ├── routes/
│   │   ├── index.ts                       ← mounts all routers under /v1
│   │   ├── auth.routes.ts
│   │   ├── farm.routes.ts
│   │   ├── dashboard.routes.ts
│   │   ├── goat/
│   │   │   └── index.ts                  ← registers all /goats/* sub-routes
│   │   ├── cattle/
│   │   │   └── index.ts                  ← registers all /cattle/* sub-routes
│   │   ├── poultry/
│   │   │   └── index.ts                  ← registers all /poultry/* sub-routes
│   │   ├── crop/
│   │   │   └── index.ts                  ← registers all /crop/* sub-routes
│   │   ├── payroll/                       ← split into sub-route files
│   │   │   ├── index.ts                  ← mounts all /payroll/* sub-routers
│   │   │   ├── employees.routes.ts        ← /payroll/employees, /payroll/contracts
│   │   │   ├── pay-runs.routes.ts         ← /payroll/pay-groups, pay-structures, pay-runs, payslips
│   │   │   ├── leave.routes.ts            ← /payroll/leave-types, leave-balances, leave-requests
│   │   │   ├── compliance.routes.ts       ← /payroll/compliance-alerts, audit-log, incidents
│   │   │   └── communications.routes.ts   ← /payroll/communications, piecework
│   │   ├── financial.routes.ts
│   │   ├── weather.routes.ts
│   │   ├── livestock.routes.ts
│   │   ├── events.routes.ts
│   │   ├── production.routes.ts
│   │   ├── record.routes.ts
│   │   ├── traceability.routes.ts
│   │   ├── settings.routes.ts
│   │   ├── insights.routes.ts
│   │   ├── advisor.routes.ts
│   │   └── disease.routes.ts
│   │
│   ├── jobs/
│   │   ├── scheduler.ts                   ← node-cron schedules: payroll reminders, leave expiry
│   │   └── workers/
│   │       ├── email.worker.ts            ← sends email via nodemailer SMTP
│   │       ├── pdf.worker.ts              ← generates payslip PDF buffer; stores in payroll_payslips.pdf_data (MEDIUMBLOB)
│   │       ├── notify.worker.ts           ← dispatches push notification jobs
│   │       └── sync.worker.ts             ← background data sync tasks
│   │
│   └── types/
│       ├── express.d.ts                   ← augments Request: req.auth, req.farmOwnerId
│       └── api.types.ts                   ← AuthPayload, PaginatedResponse<T>, ApiError
│
└── tests/
    ├── setup.ts                           ← test DB setup, global teardown
    ├── auth/
    │   └── auth.service.test.ts           ← auth service unit tests
    ├── goat/
    │   └── goat.service.test.ts           ← goat service unit tests
    └── lib/
        └── pagination.test.ts             ← pagination helper unit tests
```

---

## Route Registry — `/v1`

### Auth — no `requireAuth` unless noted

| Method | Path                  | Auth | Module | Handler                        |
| ------ | --------------------- | ---- | ------ | ------------------------------ |
| POST   | /auth/register        | —    | —      | auth.controller.register       |
| POST   | /auth/login           | —    | —      | auth.controller.login          |
| POST   | /auth/refresh         | —    | —      | auth.controller.refresh        |
| POST   | /auth/logout          | ✓    | —      | auth.controller.logout         |
| GET    | /auth/me              | ✓    | —      | auth.controller.me             |
| POST   | /auth/forgot-password | —    | —      | auth.controller.forgotPassword |
| POST   | /auth/reset-password  | —    | —      | auth.controller.resetPassword  |
| GET    | /auth/verify-email    | —    | —      | auth.controller.verifyEmail    |
| POST   | /auth/accept-invite   | —    | —      | auth.controller.acceptInvite   |

### Farm

| Method | Path                    | Auth | Module | Handler                         |
| ------ | ----------------------- | ---- | ------ | ------------------------------- |
| GET    | /farm/team/:farmOwnerId | ✓    | —      | farm.controller.getTeam         |
| POST   | /farm/staff             | ✓    | —      | farm.controller.inviteStaff     |
| PUT    | /farm/staff/:id         | ✓    | —      | farm.controller.updateStaff     |
| DELETE | /farm/staff/:id         | ✓    | —      | farm.controller.deactivateStaff |

### Dashboard

| Method | Path               | Auth | Module | Handler                         |
| ------ | ------------------ | ---- | ------ | ------------------------------- |
| GET    | /dashboard/summary | ✓    | —      | dashboard.controller.getSummary |

### Goat — `requireModule('goat')`

| Method | Path                          | Handler                                         |
| ------ | ----------------------------- | ----------------------------------------------- |
| GET    | /goats                        | goat/animals.controller.list                    |
| POST   | /goats                        | goat/animals.controller.create                  |
| GET    | /goats/:id                    | goat/animals.controller.getOne                  |
| PUT    | /goats/:id                    | goat/animals.controller.update                  |
| DELETE | /goats/:id                    | goat/animals.controller.remove                  |
| GET    | /goats/weights                | goat/weight.controller.listWeights              |
| POST   | /goats/weights                | goat/weight.controller.addWeight                |
| DELETE | /goats/weights/:id            | goat/weight.controller.removeWeight             |
| GET    | /goats/matings                | goat/mating.controller.listMatings              |
| POST   | /goats/matings                | goat/mating.controller.addMating                |
| PUT    | /goats/matings/:id            | goat/mating.controller.updateMating             |
| GET    | /goats/pregnancy-checks       | goat/pregnancy.controller.listPregnancyChecks   |
| POST   | /goats/pregnancy-checks       | goat/pregnancy.controller.addPregnancyCheck     |
| GET    | /goats/kidding                | goat/kidding.controller.listKidding             |
| POST   | /goats/kidding                | goat/kidding.controller.addKidding              |
| GET    | /goats/milk                   | goat/milk.controller.listMilk                   |
| POST   | /goats/milk                   | goat/milk.controller.addMilk                    |
| DELETE | /goats/milk/:id               | goat/milk.controller.removeMilk                 |
| GET    | /goats/shearing               | goat/shearing.controller.listShearing           |
| POST   | /goats/shearing               | goat/shearing.controller.addShearing            |
| GET    | /goats/health                 | goat/health.controller.listHealth               |
| POST   | /goats/health                 | goat/health.controller.addHealth                |
| PUT    | /goats/health/:id             | goat/health.controller.updateHealth             |
| GET    | /goats/medications            | goat/medications.controller.listMedications     |
| POST   | /goats/medications            | goat/medications.controller.addMedication       |
| GET    | /goats/vaccinations           | goat/vaccinations.controller.listVaccinations   |
| POST   | /goats/vaccinations           | goat/vaccinations.controller.addVaccination     |
| PATCH  | /goats/vaccinations/:id/given | goat/vaccinations.controller.markVaccinationGiven |
| GET    | /goats/sales                  | goat/sales.controller.listSales                 |
| POST   | /goats/sales                  | goat/sales.controller.addSale                   |
| PUT    | /goats/sales/:id              | goat/sales.controller.updateSale                |
| DELETE | /goats/sales/:id              | goat/sales.controller.removeSale                |
| GET    | /goats/feed                   | goat/feed.controller.listFeed                   |
| POST   | /goats/feed                   | goat/feed.controller.addFeed                    |
| DELETE | /goats/feed/:id               | goat/feed.controller.removeFeed                 |
| GET    | /goats/pastures               | goat/pasture.controller.listPastures            |
| POST   | /goats/pastures               | goat/pasture.controller.addPasture              |
| PATCH  | /goats/pastures/:id/exit      | goat/pasture.controller.exitPasture             |
| GET    | /goats/famacha                | goat/famacha.controller.listFamacha             |
| POST   | /goats/famacha                | goat/famacha.controller.addFamacha              |
| GET    | /goats/bcs                    | goat/bcs.controller.listBcs                     |
| POST   | /goats/bcs                    | goat/bcs.controller.addBcs                      |

### Cattle — `requireModule('cattle')`

| Method | Path                           | Handler                                           |
| ------ | ------------------------------ | ------------------------------------------------- |
| GET    | /cattle                        | cattle/animals.controller.list                    |
| POST   | /cattle                        | cattle/animals.controller.create                  |
| GET    | /cattle/:id                    | cattle/animals.controller.getOne                  |
| PUT    | /cattle/:id                    | cattle/animals.controller.update                  |
| DELETE | /cattle/:id                    | cattle/animals.controller.remove                  |
| GET    | /cattle/weights                | cattle/weight.controller.listWeights              |
| POST   | /cattle/weights                | cattle/weight.controller.addWeight                |
| DELETE | /cattle/weights/:id            | cattle/weight.controller.removeWeight             |
| GET    | /cattle/breeding               | cattle/breeding.controller.listBreeding           |
| POST   | /cattle/breeding               | cattle/breeding.controller.addBreeding            |
| PUT    | /cattle/breeding/:id           | cattle/breeding.controller.updateBreeding         |
| GET    | /cattle/pregnancy-checks       | cattle/pregnancy.controller.listPregnancyChecks   |
| POST   | /cattle/pregnancy-checks       | cattle/pregnancy.controller.addPregnancyCheck     |
| GET    | /cattle/calving                | cattle/calving.controller.listCalving             |
| POST   | /cattle/calving                | cattle/calving.controller.addCalving              |
| GET    | /cattle/milk                   | cattle/milk.controller.listMilk                   |
| POST   | /cattle/milk                   | cattle/milk.controller.addMilk                    |
| DELETE | /cattle/milk/:id               | cattle/milk.controller.removeMilk                 |
| GET    | /cattle/health                 | cattle/health.controller.listHealth               |
| POST   | /cattle/health                 | cattle/health.controller.addHealth                |
| PUT    | /cattle/health/:id             | cattle/health.controller.updateHealth             |
| GET    | /cattle/medications            | cattle/medications.controller.listMedications     |
| POST   | /cattle/medications            | cattle/medications.controller.addMedication       |
| GET    | /cattle/vaccinations           | cattle/vaccinations.controller.listVaccinations   |
| POST   | /cattle/vaccinations           | cattle/vaccinations.controller.addVaccination     |
| PATCH  | /cattle/vaccinations/:id/given | cattle/vaccinations.controller.markVaccinationGiven |
| GET    | /cattle/sales                  | cattle/sales.controller.listSales                 |
| POST   | /cattle/sales                  | cattle/sales.controller.addSale                   |
| PUT    | /cattle/sales/:id              | cattle/sales.controller.updateSale                |
| DELETE | /cattle/sales/:id              | cattle/sales.controller.removeSale                |
| GET    | /cattle/feed                   | cattle/feed.controller.listFeed                   |
| POST   | /cattle/feed                   | cattle/feed.controller.addFeed                    |
| DELETE | /cattle/feed/:id               | cattle/feed.controller.removeFeed                 |
| GET    | /cattle/pastures               | cattle/pasture.controller.listPastures            |
| POST   | /cattle/pastures               | cattle/pasture.controller.addPasture              |
| PATCH  | /cattle/pastures/:id/exit      | cattle/pasture.controller.exitPasture             |
| GET    | /cattle/bcs                    | cattle/bcs.controller.listBcs                     |
| POST   | /cattle/bcs                    | cattle/bcs.controller.addBcs                      |
| GET    | /cattle/dipping                | cattle/dipping.controller.listDipping             |
| POST   | /cattle/dipping                | cattle/dipping.controller.addDipping              |

### Poultry — `requireModule('poultry')`

| Method | Path                           | Handler                                              |
| ------ | ------------------------------ | ---------------------------------------------------- |
| GET    | /poultry/flocks                | poultry/flocks.controller.listFlocks                 |
| POST   | /poultry/flocks                | poultry/flocks.controller.createFlock                |
| GET    | /poultry/flocks/:id            | poultry/flocks.controller.getFlock                   |
| PUT    | /poultry/flocks/:id            | poultry/flocks.controller.updateFlock                |
| DELETE | /poultry/flocks/:id            | poultry/flocks.controller.deleteFlock                |
| GET    | /poultry/daily-records         | poultry/daily-records.controller.listDailyRecords    |
| POST   | /poultry/daily-records         | poultry/daily-records.controller.addDailyRecord      |
| GET    | /poultry/vaccination-schedules | poultry/vaccinations.controller.listVaccinationSchedules |
| POST   | /poultry/vaccination-schedules | poultry/vaccinations.controller.addVaccinationSchedule   |
| GET    | /poultry/feed-phases           | poultry/flocks.controller.listFeedPhases             |
| POST   | /poultry/feed-phases           | poultry/flocks.controller.addFeedPhase               |
| GET    | /poultry/harvest-records       | poultry/harvest.controller.listHarvestRecords        |
| POST   | /poultry/harvest-records       | poultry/harvest.controller.addHarvestRecord          |
| GET    | /poultry/medication-logs       | poultry/flocks.controller.listMedicationLogs         |
| POST   | /poultry/medication-logs       | poultry/flocks.controller.addMedicationLog           |
| GET    | /poultry/disease-events        | poultry/flocks.controller.listDiseaseEvents          |
| POST   | /poultry/disease-events        | poultry/flocks.controller.addDiseaseEvent            |
| GET    | /poultry/environment-readings  | poultry/flocks.controller.listEnvironmentReadings    |
| POST   | /poultry/environment-readings  | poultry/flocks.controller.addEnvironmentReading      |
| GET    | /poultry/inventory-items       | poultry/flocks.controller.listInventory              |
| POST   | /poultry/inventory-items       | poultry/flocks.controller.addInventoryItem           |
| GET    | /poultry/egg-sales             | poultry/flocks.controller.listEggSales               |
| POST   | /poultry/egg-sales             | poultry/flocks.controller.addEggSale                 |
| GET    | /poultry/chick-sales           | poultry/flocks.controller.listChickSales             |
| POST   | /poultry/chick-sales           | poultry/flocks.controller.addChickSale               |

### Crop — `requireModule('crop')`

| Method | Path                           | Handler                                               |
| ------ | ------------------------------ | ----------------------------------------------------- |
| GET    | /crop/categories               | crop/crops.controller.listCategories                  |
| GET    | /crop/crops                    | crop/crops.controller.listCrops                       |
| GET    | /crop/fields                   | crop/fields.controller.listFields                     |
| POST   | /crop/fields                   | crop/fields.controller.addField                       |
| PUT    | /crop/fields/:id               | crop/fields.controller.updateField                    |
| DELETE | /crop/fields/:id               | crop/fields.controller.deleteField                    |
| GET    | /crop/seasons                  | crop/seasons.controller.listSeasons                   |
| POST   | /crop/seasons                  | crop/seasons.controller.addSeason                     |
| PUT    | /crop/seasons/:id              | crop/seasons.controller.updateSeason                  |
| DELETE | /crop/seasons/:id              | crop/seasons.controller.deleteSeason                  |
| GET    | /crop/planting-plans           | crop/planting-plans.controller.listPlantingPlans      |
| POST   | /crop/planting-plans           | crop/planting-plans.controller.addPlantingPlan        |
| PUT    | /crop/planting-plans/:id       | crop/planting-plans.controller.updatePlantingPlan     |
| DELETE | /crop/planting-plans/:id       | crop/planting-plans.controller.deletePlantingPlan     |
| GET    | /crop/tasks                    | crop/tasks.controller.listTasks                       |
| POST   | /crop/tasks                    | crop/tasks.controller.addTask                         |
| PUT    | /crop/tasks/:id                | crop/tasks.controller.updateTask                      |
| DELETE | /crop/tasks/:id                | crop/tasks.controller.deleteTask                      |
| GET    | /crop/pest-observations        | crop/pest-observations.controller.listPestObservations|
| POST   | /crop/pest-observations        | crop/pest-observations.controller.addPestObservation  |
| PUT    | /crop/pest-observations/:id    | crop/pest-observations.controller.updatePestObservation|
| DELETE | /crop/pest-observations/:id    | crop/pest-observations.controller.deletePestObservation|
| GET    | /crop/spray-records            | crop/spray-records.controller.listSprayRecords        |
| POST   | /crop/spray-records            | crop/spray-records.controller.addSprayRecord          |
| PUT    | /crop/spray-records/:id        | crop/spray-records.controller.updateSprayRecord       |
| DELETE | /crop/spray-records/:id        | crop/spray-records.controller.deleteSprayRecord       |
| GET    | /crop/expenses                 | crop/expenses.controller.listExpenses                 |
| POST   | /crop/expenses                 | crop/expenses.controller.addExpense                   |
| PUT    | /crop/expenses/:id             | crop/expenses.controller.updateExpense                |
| DELETE | /crop/expenses/:id             | crop/expenses.controller.deleteExpense                |
| GET    | /crop/harvest-records          | crop/harvest.controller.listHarvestRecords            |
| POST   | /crop/harvest-records          | crop/harvest.controller.addHarvestRecord              |
| PUT    | /crop/harvest-records/:id      | crop/harvest.controller.updateHarvestRecord           |
| DELETE | /crop/harvest-records/:id      | crop/harvest.controller.deleteHarvestRecord           |
| GET    | /crop/calendar-events          | crop/calendar-events.controller.listCalendarEvents    |
| POST   | /crop/calendar-events          | crop/calendar-events.controller.addCalendarEvent      |
| PUT    | /crop/calendar-events/:id      | crop/calendar-events.controller.updateCalendarEvent   |
| DELETE | /crop/calendar-events/:id      | crop/calendar-events.controller.deleteCalendarEvent   |
| GET    | /crop/sales                    | crop/sales.controller.listSales                       |
| POST   | /crop/sales                    | crop/sales.controller.addSale                         |
| PUT    | /crop/sales/:id                | crop/sales.controller.updateSale                      |
| DELETE | /crop/sales/:id                | crop/sales.controller.deleteSale                      |
| GET    | /crop/advisory-content         | crop/advisory.controller.getAdvisoryContent           |

### Payroll — `requireModule('payroll')` — RAW array/object responses (no envelope)

| Method | Path                                   | Handler                                            |
| ------ | -------------------------------------- | -------------------------------------------------- |
| GET    | /payroll/employees                     | payroll/employees.controller.listEmployees         |
| POST   | /payroll/employees                     | payroll/employees.controller.createEmployee        |
| GET    | /payroll/employees/:id                 | payroll/employees.controller.getEmployee           |
| PUT    | /payroll/employees/:id                 | payroll/employees.controller.updateEmployee        |
| PATCH  | /payroll/employees/:id/terminate       | payroll/employees.controller.terminateEmployee     |
| GET    | /payroll/contracts                     | payroll/contracts.controller.listContracts         |
| POST   | /payroll/contracts                     | payroll/contracts.controller.createContract        |
| PUT    | /payroll/contracts/:id                 | payroll/contracts.controller.updateContract        |
| PATCH  | /payroll/contracts/:id/void            | payroll/contracts.controller.voidContract          |
| GET    | /payroll/pay-groups                    | payroll/pay-groups.controller.listPayGroups        |
| POST   | /payroll/pay-groups                    | payroll/pay-groups.controller.createPayGroup       |
| PUT    | /payroll/pay-groups/:id                | payroll/pay-groups.controller.updatePayGroup       |
| PATCH  | /payroll/pay-groups/:id/deactivate     | payroll/pay-groups.controller.deactivatePayGroup   |
| GET    | /payroll/pay-structures                | payroll/pay-structures.controller.listPayStructures |
| POST   | /payroll/pay-structures                | payroll/pay-structures.controller.createPayStructure|
| PUT    | /payroll/pay-structures/:id            | payroll/pay-structures.controller.updatePayStructure|
| GET    | /payroll/pay-runs                      | payroll/pay-runs.controller.listPayRuns            |
| POST   | /payroll/pay-runs/calculate            | payroll/pay-runs.controller.calculatePayRun        |
| PATCH  | /payroll/pay-runs/:id/approve          | payroll/pay-runs.controller.approvePayRun          |
| PATCH  | /payroll/pay-runs/:id/disburse         | payroll/pay-runs.controller.disbursePayRun         |
| GET    | /payroll/payslips                      | payroll/payslips.controller.listPayslips           |
| GET    | /payroll/payslips/:id/pdf              | payroll/payslips.controller.downloadPayslipPdf     |
| GET    | /payroll/deductions                    | payroll/deductions.controller.listDeductions       |
| POST   | /payroll/deductions                    | payroll/deductions.controller.createDeduction      |
| PUT    | /payroll/deductions/:id                | payroll/deductions.controller.updateDeduction      |
| PATCH  | /payroll/deductions/:id/deactivate     | payroll/deductions.controller.deactivateDeduction  |
| GET    | /payroll/garnishee-orders              | payroll/deductions.controller.listGarnishees       |
| POST   | /payroll/garnishee-orders              | payroll/deductions.controller.createGarnishee      |
| PUT    | /payroll/garnishee-orders/:id          | payroll/deductions.controller.updateGarnishee      |
| GET    | /payroll/shifts                        | payroll/shifts.controller.listShifts               |
| POST   | /payroll/shifts                        | payroll/shifts.controller.createShift              |
| PUT    | /payroll/shifts/:id                    | payroll/shifts.controller.updateShift              |
| DELETE | /payroll/shifts/:id                    | payroll/shifts.controller.deleteShift              |
| GET    | /payroll/task-assignments              | payroll/task-assignments.controller.listTaskAssignments |
| POST   | /payroll/task-assignments              | payroll/task-assignments.controller.createTaskAssignment|
| PUT    | /payroll/task-assignments/:id          | payroll/task-assignments.controller.updateTaskAssignment|
| DELETE | /payroll/task-assignments/:id          | payroll/task-assignments.controller.deleteTaskAssignment|
| GET    | /payroll/attendance                    | payroll/attendance.controller.listAttendanceRecords|
| POST   | /payroll/attendance                    | payroll/attendance.controller.createAttendanceRecord|
| PUT    | /payroll/attendance/:id                | payroll/attendance.controller.updateAttendanceRecord|
| GET    | /payroll/piecework                     | payroll/piecework.controller.listPieceworkLogs     |
| POST   | /payroll/piecework                     | payroll/piecework.controller.createPieceworkLog    |
| DELETE | /payroll/piecework/:id                 | payroll/piecework.controller.deletePieceworkLog    |
| GET    | /payroll/employer-config               | payroll/employer-config.controller.getEmployerConfig|
| PUT    | /payroll/employer-config               | payroll/employer-config.controller.updateEmployerConfig|
| GET    | /payroll/leave-types                   | payroll/leave-balances.controller.listLeaveTypes   |
| GET    | /payroll/leave-balances                | payroll/leave-balances.controller.listLeaveBalances|
| GET    | /payroll/leave-requests                | payroll/leave.controller.listLeaveRequests         |
| POST   | /payroll/leave-requests                | payroll/leave.controller.createLeaveRequest        |
| DELETE | /payroll/leave-requests/:id            | payroll/leave.controller.deleteLeaveRequest        |
| PATCH  | /payroll/leave-requests/:id/approve    | payroll/leave.controller.approveLeaveRequest       |
| PATCH  | /payroll/leave-requests/:id/reject     | payroll/leave.controller.rejectLeaveRequest        |
| PATCH  | /payroll/leave-requests/:id/cancel     | payroll/leave.controller.cancelLeaveRequest        |
| GET    | /payroll/transactions                  | payroll/audit.controller.listTransactions          |
| GET    | /payroll/compliance-alerts             | payroll/compliance.controller.listComplianceAlerts |
| PATCH  | /payroll/compliance-alerts/:id/resolve | payroll/compliance.controller.resolveAlert         |
| GET    | /payroll/audit-log                     | payroll/audit.controller.getAuditLog               |
| GET    | /payroll/incidents                     | payroll/audit.controller.listIncidents             |
| POST   | /payroll/incidents                     | payroll/audit.controller.createIncident            |
| PUT    | /payroll/incidents/:id                 | payroll/audit.controller.updateIncident            |
| PATCH  | /payroll/incidents/:id/deactivate      | payroll/audit.controller.deactivateIncident        |
| GET    | /payroll/communications                | payroll/communications.controller.listCommunications |
| POST   | /payroll/communications                | payroll/communications.controller.createCommunication|
| POST   | /payroll/communications/send           | payroll/communications.controller.sendCommunication  |

### Other Modules — all `requireAuth`

| Method | Path                    | Module | Handler                               |
| ------ | ----------------------- | ------ | ------------------------------------- |
| GET    | /weather/current        | —      | weather.controller.getCurrent         |
| GET    | /weather/forecast       | —      | weather.controller.getForecast        |
| GET    | /weather/alerts         | —      | weather.controller.getAlerts          |
| GET    | /financial/transactions | —      | financial.controller.listTransactions |
| POST   | /financial/transactions | —      | financial.controller.addTransaction   |
| GET    | /events/health          | —      | events.controller.listHealthEvents    |
| POST   | /events/health          | —      | events.controller.addHealthEvent      |
| GET    | /events/weights         | —      | events.controller.listWeightRecords   |
| POST   | /events/weights         | —      | events.controller.addWeightRecord     |
| GET    | /events/breeding        | —      | events.controller.listBreedingEvents  |
| POST   | /events/breeding        | —      | events.controller.addBreedingEvent    |
| GET    | /livestock/animals      | —      | livestock.controller.getAnimals       |
| GET    | /livestock/groups       | —      | livestock.controller.getGroups        |
| GET    | /production/milk        | —      | production.controller.listMilk        |
| POST   | /production/milk        | —      | production.controller.addMilk         |
| GET    | /production/eggs        | —      | production.controller.listEggs        |
| POST   | /production/eggs        | —      | production.controller.addEggs         |
| GET    | /production/wool        | —      | production.controller.listWool        |
| POST   | /production/wool        | —      | production.controller.addWool         |
| GET    | /record/feed-logs       | —      | record.controller.listFeedLogs        |
| POST   | /record/feed-logs       | —      | record.controller.addFeedLog          |
| GET    | /traceability/movements | —      | traceability.controller.listMovements |
| POST   | /traceability/movements | —      | traceability.controller.addMovement   |
| GET    | /settings/paddocks      | —      | settings.controller.getPaddocks       |
| GET    | /insights/market-prices | —      | insights.controller.getMarketPrices   |
| POST   | /advisor/advice         | —      | advisor.controller.getAdvice          |
| GET    | /advisor/briefing       | —      | advisor.controller.getDailyBriefing   |
| GET    | /disease/library        | —      | disease.controller.getLibrary         |
| POST   | /disease/detect         | —      | disease.controller.detect             |

---

## Middleware Execution Order

```
Request
  └─ rateLimiter.middleware          ← express-rate-limit (in-memory, per IP)
       └─ express.json()             ← body parser
            └─ auth.middleware       ← verify JWT → req.auth
                 └─ moduleGuard      ← requireModule() factory (route-level)
                      └─ validate    ← Zod safeParse (route-level)
                           └─ controller
                                └─ service → repository → Drizzle → MySQL
                                     └─ response helpers
                 └─ error-handler.middleware  ← catches all thrown errors
```

---

## Multi-Tenancy Rules

- Every domain table has `farm_owner_id UUID NOT NULL`
- JWT payload: `{ sub, subType: 'owner'|'staff', farmId, modules[], role }`
- `auth.middleware` computes `req.auth.farmOwnerId`:
  - `subType === 'owner'` → `farmOwnerId = sub`
  - `subType === 'staff'` → `farmOwnerId = farmId`
- Every repository method receives `farmOwnerId` as first argument
- No repository query may omit the `farmOwnerId` WHERE clause

---

## Security Standards

### OWASP Top 10 (2021) Mitigations

| #   | Risk                      | Mitigation in this project                                                                                                                                                                                                                             |
| --- | ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| A01 | Broken Access Control     | `farmOwnerId` WHERE clause enforced in every repository query; `requireModule()` gate on every domain route; staff `role` checked before mutating operations                                                                                           |
| A02 | Cryptographic Failures    | Passwords hashed with `bcryptjs` (cost ≥ 12); JWTs signed HS256 with 32-char+ secret; TLS enforced at MySQL host (no plaintext DB traffic); `.env` gitignored                                                                                          |
| A03 | Injection                 | Drizzle ORM uses parameterized queries exclusively — raw SQL strings are forbidden; all input validated with Zod `safeParse` before reaching any service or repository                                                                                 |
| A04 | Insecure Design           | Subscription plan enforces livestock/field/user caps in `subscription.service.ts`; module activation checked at route level, not just UI; audit trail written on every mutating request                                                                |
| A05 | Security Misconfiguration | `helmet()` sets all security headers (CSP, HSTS, X-Frame-Options, etc.); CORS restricted to `APP_URL` origin; `config/env.ts` throws at startup if any required env var is missing or malformed                                                        |
| A06 | Vulnerable Components     | `npm audit --audit-level=high` runs in CI; devDependencies excluded from production build; lock file committed                                                                                                                                         |
| A07 | Auth Failures             | bcryptjs cost ≥ 12 for all passwords; access tokens TTL 15 min; refresh token rotation on every `/auth/refresh` call (old token revoked immediately); `express-rate-limit` applied to all `/auth/*` routes (stricter window than global)               |
| A08 | Data Integrity Failures   | JWT signature verified on every request in `auth.middleware`; `config/env.ts` Zod-validates all startup config                                                                                                                                         |
| A09 | Logging & Monitoring      | Pino logs every request/response (method, path, status, duration); `audit.middleware` writes `audit_logs` row (actor, action, table, row_id, before/after) for all POST/PUT/PATCH/DELETE; logs never include passwords, tokens, or full request bodies |
| A10 | SSRF                      | Weather/advisor/disease integrations call only fixed, config-supplied URLs — no user-controlled URL parameters                                                                                                                                         |

---

### Authentication Security Rules

| Rule               | Implementation                                                                                                 |
| ------------------ | -------------------------------------------------------------------------------------------------------------- |
| Password hashing   | `bcryptjs.hash(password, 12)` — minimum cost factor 12                                                         |
| Access token TTL   | 900 s (15 min) — `ACCESS_TOKEN_TTL` env var                                                                    |
| Refresh token TTL  | 2 592 000 s (30 days) — `REFRESH_TOKEN_TTL` env var                                                            |
| Refresh rotation   | On every `/auth/refresh`: verify old token → issue new pair → revoke old refresh token row immediately         |
| Token revocation   | `refresh_tokens` table; `auth.middleware` rejects any token whose `jti` is revoked                             |
| Email verification | `farm_owners.email_verified` must be `true` before login succeeds                                              |
| Staff invite flow  | One-time `staff_invite_tokens` row (expires 72 h); consumed and deleted on `/auth/accept-invite`               |
| Password reset     | One-time `password_reset_tokens` row (expires 1 h); Argon-safe comparison via `jose` to prevent timing attacks |
| Logout             | Deletes all refresh token rows for the subject (`revokeAllForSubject`)                                         |

---

### Input Validation Rules

- Every route **must** use `validate({ body?, query?, params? })` middleware with a Zod schema
- Schemas use `.strict()` on body objects — unknown keys are rejected (no mass-assignment)
- UUID path params validated with `UUIDSchema` (rejects non-UUID strings before repo call)
- Pagination query params validated with `PaginationSchema` (capped at `limit ≤ 100`)

---

### HTTP Security Headers (via `helmet()`)

| Header                      | Value                                       |
| --------------------------- | ------------------------------------------- |
| `Content-Security-Policy`   | `default-src 'none'` (API — no HTML served) |
| `Strict-Transport-Security` | `max-age=31536000; includeSubDomains`       |
| `X-Content-Type-Options`    | `nosniff`                                   |
| `X-Frame-Options`           | `DENY`                                      |
| `Referrer-Policy`           | `no-referrer`                               |
| `X-Powered-By`              | removed                                     |

---

### CORS Policy

```ts
// app.ts
app.use(
  cors({
    origin: env.APP_URL, // single allowed origin — no wildcard in production
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE"],
    allowedHeaders: ["Content-Type", "Authorization"],
    credentials: true,
    maxAge: 86400, // preflight cached 24 h
  }),
);
```

---

### Rate Limiting Rules

| Route group                            | Window | Max requests |
| -------------------------------------- | ------ | ------------ |
| `/auth/login`, `/auth/forgot-password` | 15 min | 10 per IP    |
| `/auth/*` (all other)                  | 15 min | 30 per IP    |
| All other routes                       | 1 min  | 120 per IP   |

Implemented in `rate-limiter.middleware.ts` using `express-rate-limit` (in-memory token-bucket). Returns `429` with `Retry-After` header.

---

### Secrets & Environment Rules

- `.env` is gitignored — **never committed**
- `.env.example` contains only key names and safe placeholder values — no real secrets
- `config/env.ts` validates all env vars with Zod at process startup — server refuses to start with missing/malformed config
- `JWT_SECRET` minimum 32 characters enforced by Zod `.min(32)`
- Database credentials travel only in `DATABASE_URL` — never logged

---

### Audit Logging Rules

`audit.middleware` fires after every successful `POST`, `PUT`, `PATCH`, `DELETE`:

```ts
{
  actor_id:    req.auth.sub,
  actor_type:  req.auth.subType,   // 'owner' | 'staff'
  farm_owner_id: req.auth.farmOwnerId,
  action:      'CREATE' | 'UPDATE' | 'DELETE',
  table_name:  string,             // derived from route metadata
  row_id:      uuid,               // from response body or params
  before:      Record | null,      // fetched pre-mutation for UPDATE/DELETE
  after:       Record | null,      // from response for CREATE/UPDATE
  ip:          string,
  user_agent:  string,
  created_at:  timestamp,
}
```

Audit log rows are **never deleted** — no DELETE route exists on `audit_logs`.

---

## Environment Variables — `.env.example`

```
# Database
DATABASE_URL=mysql://user:pass@host:3306/4dfarmer?ssl=true

# Auth
JWT_SECRET=                        # min 32 chars, HS256
ACCESS_TOKEN_TTL=900               # seconds (15 min)
REFRESH_TOKEN_TTL=2592000          # seconds (30 days)

# Email (SMTP)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=
SMTP_PASS=                         # Gmail app password or SMTP credentials
EMAIL_FROM=noreply@4dfarmer.app

# App
APP_URL=https://api.4dfarmer.app
PORT=3000
NODE_ENV=production

# 3rd-party integrations
WEATHER_API_KEY=
ADVISOR_API_KEY=
DISEASE_API_KEY=
```

---

## npm Package List — `package.json`

### dependencies

```
express
@types/express
cors
@types/cors
helmet
compression
@types/compression
pino
pino-http
pino-pretty
jose
bcryptjs
@types/bcryptjs
zod
drizzle-orm
mysql2
express-rate-limit
@types/express-rate-limit
lru-cache
node-cron
@types/node-cron
nodemailer
@types/nodemailer
pdfkit
@types/pdfkit
uuid
@types/uuid
```

### devDependencies

```
typescript
tsx
ts-node
nodemon
drizzle-kit
vitest
@vitest/coverage-v8
supertest
@types/supertest
eslint
@typescript-eslint/parser
@typescript-eslint/eslint-plugin
prettier
```

---

## Flutter Integration Contract

The Flutter app switches from mock to real HTTP with a single flag in `lib/core/constants/app_constants.dart`:

```
AppConstants.useMockData = false   ← flips ALL modules to real HTTP
```

No UI, provider, repository, or model code changes. Only the `*_remote_data_source.dart` files are activated. Every backend endpoint must return JSON that exactly matches the shape the mock data source returns — the mock is the contract.

### Response Envelope — Payroll Exception

`PayrollRemoteDataSource` calls `_dio.get<List<dynamic>>(path)` — Dio parses the response body directly as a JSON array. The backend **must not** wrap payroll GET list responses in `{ "data": [...] }`. All other modules use the standard envelope.

---

## Drizzle Config — `drizzle.config.ts`

```
dialect:    mysql
schema:     src/db/schema/index.ts
out:        src/db/migrations
dbCredentials.url:  process.env.DATABASE_URL
```

---

## CI/CD & Deployment

### Pipeline — GitHub Actions (`deploy.yml`)

```
push to main
  └─ lint (eslint src/)
       └─ test (vitest run)
            └─ build (tsc → dist/)
                 └─ docker build --tag 4dfarmer-api .
                      └─ firebase deploy --only hosting:api
                           └─ post-deploy: db:migrate + db:seed
                                (tsx src/db/migrate.ts && tsx src/db/seed.ts)
```

Migrations and seeds run as a **deploy hook** inside the container after every successful deploy — never manually in production.

---

### Dockerfile — Multi-Stage

```dockerfile
# Stage 1: build
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build          # tsc → dist/

# Stage 2: runtime
FROM node:20-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production
COPY package*.json ./
RUN npm ci --omit=dev      # production deps only
COPY --from=build /app/dist ./dist
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

- `src/`, `tests/`, `.env`, `*.test.ts` are excluded via `.dockerignore`
- No shell, no dev tools, no source maps in the runtime image

---

### `apphosting.yaml` — Firebase App Hosting Config

```yaml
runConfig:
  minInstances: 1
  maxInstances: 10
  concurrency: 80
  cpu: 1
  memoryMiB: 512

env:
  - variable: NODE_ENV
    value: production
  - variable: DATABASE_URL
    secret: DATABASE_URL # stored in Firebase Secret Manager
  - variable: JWT_SECRET
    secret: JWT_SECRET
  - variable: SMTP_USER
    secret: SMTP_USER
  - variable: SMTP_PASS
    secret: SMTP_PASS
```

All secrets are stored in **Firebase Secret Manager** — never in `apphosting.yaml` values or environment variable files.

---

### Environment Secrets — CI Rules

- GitHub Actions secrets: `FIREBASE_SERVICE_ACCOUNT`, `DATABASE_URL`, and all app secrets
- `.env` is **never committed** and **never baked into the Docker image**
- Runtime env vars are injected by Firebase App Hosting from Secret Manager at container start
- `config/env.ts` Zod validation still runs at boot — rejects misconfigured containers before serving traffic

---

## Build & Scripts

| Command                 | Purpose                                                                      |
| ----------------------- | ---------------------------------------------------------------------------- |
| `npm run dev`           | nodemon + tsx watch (local only)                                             |
| `npm run build`         | tsc → dist/                                                                  |
| `npm start`             | node dist/index.js ← container `CMD`                                         |
| `npm run db:generate`   | drizzle-kit generate → appends new SQL to migrations/                        |
| `npm run db:migrate`    | tsx src/db/migrate.ts → applies all unapplied migrations                     |
| `npm run db:seed`       | tsx src/db/seed.ts → runs only un-applied seeds                              |
| `npm run db:studio`     | drizzle-kit studio                                                           |
| `npm test`              | vitest run                                                                   |
| `npm run test:coverage` | vitest run --coverage                                                        |
| `npm run lint`          | eslint src/                                                                  |
| `docker build`          | builds multi-stage image (build stage compiles TS, runtime stage runs dist/) |
| `firebase deploy`       | pushes container to Firebase App Hosting (Cloud Run)                         |
