# 4Directions Farm — Architecture Reference

---

## Layer Rules

- `screens/` depends on `providers/` only — never on `data/` or `models/` of another feature
- `providers/` depends on `data/` (repositories) and `models/` within the same feature, plus `shared/`
- `data/` (repositories) depends on `models/` within the same feature and `shared/data/`
- `core/` has no dependencies on `features/` or `shared/`
- `shared/` has no dependencies on `features/`
- Cross-feature data access goes through providers — never direct repository imports
- Models are immutable (`freezed`); all fields declared in the constructor
- Every provider lives in `features/{feature}/providers/` — no top-level global provider files except those in `core/providers/`

---

## Asset Rules

| Location | Purpose |
|---|---|
| `assets/icons/farm/` | Farm-domain SVG icons |
| `assets/icons/livestock/` | Species SVG icons |
| `pubspec.yaml flutter.assets` | Declares `assets/icons/farm/` and `assets/icons/livestock/` **only** |
| `data/mock/api/` | Legacy JSON fixtures — delete per feature as migration completes |
| Mock data (target pattern) | Typed Dart objects in `{feature}_mock_data_source.dart` — implements `{feature}_data_source.dart` |
| Real backend (target pattern) | `{feature}_remote_data_source.dart` — implements same interface; flip `AppConstants.useMockData` to switch |

---

## Data Layer Migration Plan

### Three States

| State | What it is | Status |
|---|---|---|
| **1 — Current (wrong)** | `MockDataSource` reads JSON via `rootBundle`; JSON bundled in app via `pubspec.yaml flutter.assets` | Active now — must be removed |
| **2 — Mock (correct)** | Each feature has `{feature}_mock_data_source.dart` with typed Dart objects; no JSON, no `rootBundle`, no async | Migration target |
| **3 — Real backend** | Each feature has `{feature}_remote_data_source.dart` using `Dio`; returns same typed models | Final production state |

### Repository Interface Pattern

Every feature repository must depend on an **abstract interface**, not a concrete source. The provider wires the implementation.

```
lib/features/{feature}/data/
├── {feature}_data_source.dart          — abstract interface: declares all method signatures
├── {feature}_mock_data_source.dart     — implements interface with hardcoded typed Dart objects
├── {feature}_remote_data_source.dart   — implements interface with Dio HTTP calls
└── {feature}_repository.dart          — takes data source via constructor; only touches the interface
```

The provider in `{feature}/providers/` reads `AppConstants.useMockData` (a `bool` const) and supplies the correct implementation. **No screen or provider code changes when switching to real backend — only the provider wiring changes.**

### Switch Mechanism

`lib/core/constants/app_constants.dart` owns the single flag:

```dart
static const bool useMockData = true;   // flip to false for real backend
```

The feature provider:

```dart
final repositoryProvider = Provider<LivestockRepository>((ref) {
  final source = AppConstants.useMockData
      ? LivestockMockDataSource()
      : LivestockRemoteDataSource(ref.watch(dioProvider));
  return LivestockRepository(source);
});
```

### Migration Steps Per Feature

1. Create `{feature}_data_source.dart` — abstract class with all method signatures
2. Create `{feature}_mock_data_source.dart` — implements interface; data is typed Dart objects (no JSON, no Future where avoidable)
3. Update `{feature}_repository.dart` — constructor takes `{Feature}DataSource` instead of `MockDataSource`
4. Update `{feature}_providers.dart` — wire `useMockData` flag
5. Delete JSON paths for this feature from `pubspec.yaml flutter.assets`
6. Create `{feature}_remote_data_source.dart` stub (throws `UnimplementedError`) — ready for backend team

### Feature Migration Status

| Feature | Interface | Mock source | Remote stub | pubspec cleaned |
|---|---|---|---|---|
| livestock | ✅ | ✅ | ✅ | ✅ |
| poultry | ✅ | ✅ | ✅ | ✅ |
| goat | ✅ | ✅ | ✅ | ✅ |
| pigs | ✅ | ✅ | ✅ | ✅ |
| aquaculture | ✅ | ✅ | ✅ | ✅ |
| apiculture | ✅ | ✅ | ✅ | ✅ |
| events | ✅ | ✅ | ✅ | ✅ |
| production | ✅ | ✅ | ✅ | ✅ |
| financial | ✅ | ✅ | ✅ | ✅ |
| traceability | ✅ | ✅ | ✅ | ✅ |
| record | ✅ | ✅ | ✅ | ✅ |
| dashboard | ✅ | ✅ | ✅ | ✅ |
| crop | ✅ | ✅ | ✅ | ✅ |
| settings | ✅ | ✅ | ✅ | ✅ |
| insights | ✅ | ✅ | ✅ | ✅ |
| cattle | ❌ | ❌ | ❌ | ❌ |
| payroll | ❌ | ❌ | ❌ | ✅ |

### Files to Delete Once All Features Are Migrated

- ~~`lib/shared/data/mock_data_source.dart`~~ **DELETED**
- `data/mock/api/` (entire folder) — JSON fixtures still present; safe to delete
- ~~All `data/mock/api/` entries in `pubspec.yaml flutter.assets`~~ **DONE**
- `AppConstants.mock*Path` constants in `app_constants.dart` — unreferenced; safe to delete

---

## Provider Naming

| Type | Naming pattern | Example |
|---|---|---|
| `FutureProvider` | `{noun}Provider` | `flocksProvider` |
| `NotifierProvider` | `{noun}Notifier` + `{noun}Provider` | `AddedFlocksNotifier`, `addedFlocksProvider` |
| `AsyncNotifierProvider` | `{noun}Notifier` + `{noun}Provider` | — |
| `Provider` (computed, private) | `_{noun}Provider` | `_mockFlocksProvider` |

---

## Project Root

```
mobile_app/
├── pubspec.yaml
├── analysis_options.yaml
├── run_dev.ps1
├── run_tests.bat
├── assets/
├── data/
├── documentation/
├── lib/
├── test/
├── android/
├── ios/
├── web/
├── linux/
├── macos/
└── windows/
```

---

## assets/

```
assets/
└── icons/
    ├── farm/
    │   ├── farm_house.svg
    │   ├── field.svg
    │   ├── finance.svg
    │   ├── task.svg
    │   ├── tractor.svg
    │   └── weather.svg
    └── livestock/
        ├── bee.svg
        ├── cattle.svg
        ├── fish.svg
        ├── goat.svg
        ├── horse.svg
        ├── pig.svg
        ├── poultry.svg
        ├── rabbit.svg
        └── sheep.svg
```

---

## data/ (legacy mock fixtures — pending migration to typed Dart objects)

```
data/
└── mock/
    ├── README.md
    └── api/
        ├── farms.json
        ├── users.json
        ├── apiculture/
        ├── aquaculture/
        ├── crop/
        ├── events/
        ├── farms/
        ├── financial/
        ├── livestock/
        ├── market/
        ├── pigs/
        ├── poultry/
        ├── production/
        ├── records/
        └── traceability/
```

---

## lib/

```
lib/
├── main.dart                          — ProviderScope bootstrap, observer registration
├── app.dart                           — MaterialApp.router, theme, go_router
│
├── core/
│   ├── auth/
│   │   └── user_role.dart             — UserRole enum
│   ├── constants/
│   │   ├── app_constants.dart         — mockBasePath, API base URLs, shared constants
│   │   └── livestock_constants.dart   — species lists, production type constants
│   ├── errors/
│   │   ├── app_exception.dart         — NetworkException, CacheException, AuthException
│   │   └── failure.dart               — Domain Failure types mapping from exceptions
│   ├── observers/
│   │   └── provider_logger_observer.dart
│   ├── providers/
│   │   ├── shared_preferences_provider.dart
│   │   └── theme_provider.dart
│   ├── router/
│   │   ├── app_router.dart            — GoRouter instance, redirect guards
│   │   └── app_routes.dart            — Route name constants
│   ├── services/
│   │   ├── notification_service.dart          — abstract interface
│   │   ├── notification_service_mobile.dart   — flutter_local_notifications implementation
│   │   └── notification_service_stub.dart     — no-op for web / desktop
│   ├── theme/
│   │   ├── app_colors.dart            — brand palette, species colours
│   │   ├── app_radius.dart
│   │   ├── app_shadows.dart
│   │   ├── app_spacing.dart
│   │   ├── app_theme.dart             — ThemeData light + dark
│   │   └── app_typography.dart        — Inter (body), Plus Jakarta Sans (display)
│   ├── utils/
│   │   ├── app_extensions.dart
│   │   ├── connectivity_service.dart
│   │   ├── farm_date_utils.dart
│   │   ├── logger.dart
│   │   ├── logger_file_io.dart        — native file logging
│   │   ├── logger_file_stub.dart      — web no-op
│   │   ├── number_utils.dart
│   │   └── validators.dart
│   └── widgets/
│       └── debug_console.dart
│
├── shared/
│   ├── data/
│   │   └── api_response.dart          — generic paginated API response wrapper
│   ├── models/
│   │   └── pagination_meta.dart
│   └── widgets/
│       ├── alert_banner.dart
│       ├── animal_list_tile.dart
│       ├── animal_search_bar.dart
│       ├── avatar_widget.dart
│       ├── bcs_indicator.dart
│       ├── chart_card.dart
│       ├── confirm_dialog.dart
│       ├── dag_score_selector.dart
│       ├── date_picker_field.dart
│       ├── empty_state.dart
│       ├── error_state.dart
│       ├── famacha_score_selector.dart
│       ├── farm_app_bar.dart
│       ├── farm_bottom_nav.dart
│       ├── farm_drawer.dart
│       ├── farm_dropdown.dart
│       ├── farm_scaffold.dart
│       ├── farm_text_field.dart
│       ├── fmd_zone_indicator.dart
│       ├── icon_action_button.dart
│       ├── info_sheet.dart
│       ├── kpi_row.dart
│       ├── loading_shimmer.dart
│       ├── movement_permit_card.dart
│       ├── notifiable_disease_prompt.dart
│       ├── offline_banner.dart
│       ├── offline_sync_indicator.dart
│       ├── paginated_list_view.dart
│       ├── primary_button.dart
│       ├── progress_bar.dart
│       ├── rfid_scan_button.dart
│       ├── secondary_button.dart
│       ├── section_header.dart
│       ├── species_card.dart
│       ├── stat_card.dart
│       ├── status_chip.dart
│       ├── tag_cloud.dart
│       └── withdrawal_countdown.dart
│
└── features/
    │
    ├── auth/
    │   ├── providers/
    │   │   └── auth_provider.dart
    │   └── screens/
    │       ├── splash_screen.dart
    │       ├── onboarding_screen.dart
    │       └── login_screen.dart
    │
    ├── dashboard/
    │   ├── data/
    │   │   └── dashboard_repository.dart
    │   ├── models/
    │   │   └── dashboard_summary.dart
    │   ├── providers/
    │   │   └── dashboard_providers.dart
    │   └── screens/
    │       └── dashboard_screen.dart
    │
    ├── livestock/
    │   ├── data/
    │   │   └── livestock_repository.dart
    │   ├── models/
    │   │   ├── animal.dart
    │   │   └── group.dart
    │   ├── providers/
    │   │   ├── groups_provider.dart
    │   │   ├── livestock_providers.dart
    │   │   └── local_animal_store.dart    — drift-backed offline store
    │   └── screens/
    │       ├── livestock_hub_screen.dart
    │       ├── livestock_screen.dart
    │       ├── species_list_screen.dart
    │       ├── animal_detail_screen.dart
    │       ├── add_edit_animal_screen.dart
    │       ├── groups_screen.dart
    │       ├── group_detail_screen.dart
    │       └── add_edit_group_screen.dart
    │
    ├── poultry/
    │   ├── data/
    │   │   └── poultry_repository.dart
    │   ├── models/
    │   │   ├── flock.dart
    │   │   ├── poultry_flock.dart         — mortalityPct: double (non-nullable); isHatchery getter
    │   │   ├── inventory_item.dart
    │   │   └── vaccination_reference.dart
    │   ├── providers/
    │   │   └── poultry_providers.dart     — addedFlocksProvider, flocksProvider, flockDetailProvider
    │   └── screens/
    │       ├── poultry_screen.dart
    │       ├── poultry_flock_picker_screen.dart
    │       ├── add_flock_screen.dart
    │       ├── edit_flock_screen.dart
    │       ├── flock_detail_screen.dart
    │       ├── flock_financial_screen.dart
    │       ├── add_daily_record_screen.dart
    │       ├── add_delivery_screen.dart
    │       ├── add_disease_event_screen.dart
    │       ├── add_medication_screen.dart
    │       ├── add_egg_sale_screen.dart
    │       ├── add_chick_sale_screen.dart
    │       ├── add_feed_phase_screen.dart
    │       ├── feed_phases_screen.dart
    │       ├── vaccination_hub_screen.dart
    │       ├── health_events_hub_screen.dart
    │       ├── biosecurity_log_screen.dart
    │       ├── house_allocation_screen.dart
    │       ├── inventory_screen.dart
    │       ├── invoice_screen.dart
    │       ├── litter_management_screen.dart
    │       ├── molt_management_screen.dart
    │       ├── harvest_record_screen.dart
    │       ├── breeder_records_screen.dart
    │       ├── cross_batch_comparison_screen.dart
    │       └── poultry_reports_screen.dart
    │
    ├── goat/
    │   ├── data/
    │   │   ├── goat_data_source.dart
    │   │   ├── goat_mock_data_source.dart
    │   │   ├── goat_remote_data_source.dart
    │   │   └── goat_repository.dart
    │   ├── models/
    │   │   ├── goat_animal.dart          — GoatAnimal + MeatSpecific / DairySpecific / FiberSpecific / BreederSpecific
    │   │   └── goat_records.dart         — WeightRecord, MatingRecord, KiddingEvent, DailyMilkRecord, ShearingRecord, GoatHealthEvent, GoatMedicationLog, GoatVaccination, BodyConditionRecord, GoatSaleRecord, GoatFeedRecord, PastureRecord, FamachaRecord
    │   ├── providers/
    │   │   └── goat_providers.dart
    │   └── screens/
    │       ├── goat_screen.dart
    │       ├── goat_detail_screen.dart
    │       ├── add_goat_screen.dart
    │       ├── edit_goat_screen.dart
    │       ├── add_kid_screen.dart
    │       ├── kidding_screen.dart
    │       ├── breeding_screen.dart
    │       ├── pregnancy_check_screen.dart
    │       ├── milk_records_screen.dart
    │       ├── shearing_screen.dart
    │       ├── weight_records_screen.dart
    │       ├── health_events_screen.dart
    │       ├── vaccination_screen.dart
    │       ├── add_medication_screen.dart
    │       ├── body_condition_screen.dart
    │       ├── goat_financials_screen.dart
    │       ├── goat_reports_screen.dart
    │       ├── sales_screen.dart
    │       ├── inventory_screen.dart
    │       ├── pasture_screen.dart
    │       └── cross_herd_comparison_screen.dart
    │    ├── cattle/
    │   ├── data/
    │   │   ├── cattle_data_source.dart
    │   │   ├── cattle_mock_data_source.dart
    │   │   ├── cattle_remote_data_source.dart
    │   │   └── cattle_repository.dart
    │   ├── models/
    │   │   ├── cattle_animal.dart
    │   │   └── cattle_records.dart
    │   ├── providers/
    │   │   └── cattle_providers.dart
    │   └── screens/
    │       ├── cattle_screen.dart
    │       ├── cattle_breed_screen.dart
    │       ├── cattle_detail_screen.dart
    │       ├── add_cattle_screen.dart
    │       ├── edit_cattle_screen.dart
    │       ├── add_calf_screen.dart
    │       ├── calving_screen.dart
    │       ├── breeding_screen.dart
    │       ├── pregnancy_check_screen.dart
    │       ├── milk_records_screen.dart
    │       ├── weight_records_screen.dart
    │       ├── health_events_screen.dart
    │       ├── vaccination_screen.dart
    │       ├── add_medication_screen.dart
    │       ├── body_condition_screen.dart
    │       ├── dipping_screen.dart
    │       ├── cattle_financials_screen.dart
    │       ├── cattle_reports_screen.dart
    │       ├── sales_screen.dart
    │       ├── inventory_screen.dart
    │       ├── pasture_screen.dart
    │       ├── feed_supplement_screen.dart
    │       └── cross_herd_comparison_screen.dart
    │    ├── pigs/
    │   ├── data/
    │   │   └── pigs_repository.dart
    │   ├── models/
    │   │   └── sow.dart
    │   ├── providers/
    │   │   └── pigs_providers.dart
    │   └── screens/
    │       ├── pigs_screen.dart
    │       └── sow_detail_screen.dart
    │
    ├── aquaculture/
    │   ├── data/
    │   │   └── aquaculture_repository.dart
    │   ├── models/
    │   │   ├── aquaculture_unit.dart
    │   │   └── water_quality_log.dart
    │   ├── providers/
    │   │   └── aquaculture_providers.dart
    │   └── screens/
    │       ├── aquaculture_screen.dart
    │       └── aquaculture_unit_detail_screen.dart
    │
    ├── apiculture/
    │   ├── data/
    │   │   └── apiculture_repository.dart
    │   ├── models/
    │   │   └── apiculture.dart
    │   ├── providers/
    │   │   └── apiculture_providers.dart
    │   └── screens/
    │       ├── apiculture_screen.dart
    │       └── hive_detail_screen.dart
    │
    ├── events/
    │   ├── data/
    │   │   └── events_repository.dart
    │   ├── models/
    │   │   ├── breeding_event.dart
    │   │   ├── health_event.dart
    │   │   └── weight_record.dart
    │   ├── providers/
    │   │   └── alerts_provider.dart
    │   └── screens/
    │       ├── events_screen.dart
    │       ├── alerts_screen.dart
    │       ├── health_events_screen.dart
    │       ├── add_health_event_screen.dart
    │       ├── breeding_events_screen.dart
    │       ├── add_breeding_event_screen.dart
    │       ├── weight_records_screen.dart
    │       └── add_weight_record_screen.dart
    │
    ├── production/
    │   ├── data/
    │   │   ├── production_data_source.dart
    │   │   ├── production_mock_data_source.dart
    │   │   ├── production_remote_data_source.dart
    │   │   └── production_repository.dart
    │   ├── models/
    │   │   ├── egg_record.dart
    │   │   ├── milk_record.dart
    │   │   └── wool_record.dart
    │   ├── providers/
    │   │   └── production_providers.dart
    │   └── screens/
    │       ├── production_screen.dart
    │       ├── egg_records_screen.dart
    │       ├── add_egg_record_screen.dart
    │       ├── milk_records_screen.dart
    │       ├── add_milk_record_screen.dart
    │       ├── wool_records_screen.dart
    │       └── add_wool_record_screen.dart
    │
    ├── financial/
    │   ├── data/
    │   │   ├── financial_data_source.dart
    │   │   ├── financial_mock_data_source.dart
    │   │   ├── financial_remote_data_source.dart
    │   │   └── financial_repository.dart
    │   ├── models/
    │   │   └── financial_transaction.dart
    │   ├── providers/
    │   │   └── financial_providers.dart
    │   └── screens/
    │       ├── financial_screen.dart
    │       └── add_financial_transaction_screen.dart
    │
    ├── traceability/
    │   ├── data/
    │   │   ├── traceability_data_source.dart
    │   │   ├── traceability_mock_data_source.dart
    │   │   ├── traceability_remote_data_source.dart
    │   │   └── traceability_repository.dart
    │   ├── models/
    │   │   └── movement_record.dart
    │   ├── providers/
    │   │   └── traceability_providers.dart
    │   └── screens/
    │       ├── movement_records_screen.dart
    │       └── add_movement_record_screen.dart
    │
    ├── record/
    │   ├── data/
    │   │   ├── record_data_source.dart
    │   │   ├── record_mock_data_source.dart
    │   │   ├── record_remote_data_source.dart
    │   │   └── record_repository.dart
    │   ├── models/
    │   │   └── feed_log.dart
    │   ├── providers/
    │   │   └── record_providers.dart
    │   └── screens/
    │       ├── record_screen.dart
    │       ├── feed_log_screen.dart
    │       └── add_feed_log_screen.dart
    │
    ├── reports/
    │   └── screens/
    │       └── reports_screen.dart
    │
    ├── insights/
    │   ├── data/
    │   │   ├── insights_data_source.dart
    │   │   ├── insights_mock_data_source.dart
    │   │   ├── insights_remote_data_source.dart
    │   │   └── insights_repository.dart
    │   ├── providers/
    │   │   └── insights_providers.dart
    │   └── screens/
    │       ├── insights_screen.dart
    │       └── market_prices_screen.dart
    │
    ├── settings/
    │   ├── data/
    │   │   ├── settings_data_source.dart
    │   │   ├── settings_mock_data_source.dart
    │   │   ├── settings_remote_data_source.dart
    │   │   └── settings_repository.dart
    │   ├── models/
    │   │   └── paddock.dart
    │   ├── providers/
    │   │   └── settings_providers.dart
    │   └── screens/
    │       ├── settings_screen.dart
    │       ├── farm_settings_screen.dart
    │       ├── account_settings_screen.dart
    │       ├── notification_settings_screen.dart
    │       ├── theme_settings_screen.dart
    │       └── paddocks_screen.dart
    │
    ├── crop/
        ├── data/
        │   └── crop_repository.dart
        ├── models/
        │   ├── advisory_content.dart
        │   ├── calendar_event.dart
        │   ├── crop.dart
        │   ├── crop_category.dart
        │   ├── crop_expense.dart
        │   ├── crop_field.dart
        │   ├── crop_sale.dart
        │   ├── crop_season.dart
        │   ├── crop_task.dart
        │   ├── harvest_record.dart
        │   ├── pest_observation.dart
        │   ├── planting_plan.dart
        │   ├── spray_record.dart
        │   └── weather_alert.dart
        ├── providers/
        │   └── crop_providers.dart
        ├── widgets/
        │   ├── crop_illustration.dart
        │   └── field_visualization.dart
        └── screens/
            ├── crop_hub_screen.dart
            ├── advisory/
            │   ├── advisory_hub_screen.dart
            │   └── advisory_detail_screen.dart
            ├── calendar/
            │   └── planting_calendar_screen.dart
            ├── catalog/
            │   ├── crop_catalog_screen.dart
            │   └── crop_detail_screen.dart
            ├── expenses/
            │   ├── expense_tracker_screen.dart
            │   └── add_expense_screen.dart
            ├── fields/
            │   ├── field_list_screen.dart
            │   ├── field_detail_screen.dart
            │   ├── add_edit_field_screen.dart
            │   ├── planted_crop_detail_screen.dart
            │   └── add_planting_plan_screen.dart
            ├── harvest/
            │   ├── harvest_log_screen.dart
            │   └── add_harvest_screen.dart
            ├── pests/
            │   ├── pest_log_screen.dart
            │   ├── add_pest_observation_screen.dart
            │   └── add_spray_record_screen.dart
            ├── profitability/
            │   └── profitability_screen.dart
            ├── sales/
            │   ├── sales_screen.dart
            │   └── add_sale_screen.dart
            ├── season/
            │   ├── season_planner_screen.dart
            │   └── add_season_screen.dart
            ├── tasks/
            │   ├── task_list_screen.dart
            │   ├── task_detail_screen.dart
            │   └── add_edit_task_screen.dart
            └── weather/
                └── weather_dashboard_screen.dart
    │
    └── payroll/
        ├── data/
        │   ├── payroll_data_source.dart          — abstract interface
        │   ├── payroll_mock_data_source.dart     — SA mock employees + pay runs
        │   ├── payroll_remote_data_source.dart   — Dio stub
        │   └── payroll_repository.dart
        ├── models/
        │   ├── payroll_employee.dart
        │   ├── employment_contract.dart
        │   ├── pay_group.dart
        │   ├── pay_structure.dart
        │   ├── shift.dart
        │   ├── attendance_record.dart
        │   ├── task_assignment.dart
        │   ├── piecework_log.dart
        │   ├── pay_run.dart
        │   ├── payslip.dart
        │   ├── deduction_rule.dart
        │   ├── leave_type.dart
        │   ├── leave_request.dart
        │   ├── leave_balance.dart
        │   ├── payment_transaction.dart
        │   ├── compliance_alert.dart
        │   ├── audit_log_entry.dart
        │   ├── incident_record.dart
        │   └── communication_log.dart
        ├── providers/
        │   └── payroll_providers.dart
        └── screens/
            ├── payroll_hub_screen.dart
            ├── employees/
            │   ├── employee_list_screen.dart
            │   ├── employee_detail_screen.dart
            │   ├── add_employee_screen.dart
            │   └── edit_employee_screen.dart
            ├── contracts/
            │   └── contract_detail_screen.dart
            ├── roster/
            │   └── roster_screen.dart
            ├── attendance/
            │   ├── attendance_screen.dart
            │   └── clock_in_screen.dart
            ├── pay_runs/
            │   ├── pay_run_list_screen.dart
            │   ├── pay_run_detail_screen.dart
            │   └── create_pay_run_screen.dart
            ├── payslips/
            │   ├── payslip_list_screen.dart
            │   └── payslip_detail_screen.dart
            ├── leave/
            │   ├── leave_dashboard_screen.dart
            │   ├── leave_request_screen.dart
            │   └── leave_approval_screen.dart
            ├── deductions/
            │   └── deductions_screen.dart
            ├── pay_groups/
            │   ├── pay_group_list_screen.dart
            │   └── pay_structure_list_screen.dart
            ├── compliance/
            │   └── compliance_screen.dart
            ├── disbursements/
            │   └── disbursements_screen.dart
            └── reports/
                └── payroll_reports_screen.dart
```

---

## test/

```
test/
├── widget_test.dart
├── poultry/
│   ├── data/
│   │   └── poultry_repository_test.dart
│   ├── models/
│   │   ├── flock_models_test.dart
│   │   └── poultry_flock_test.dart
│   └── providers/
│       └── poultry_providers_test.dart
├── goat/
│   ├── data/
│   │   └── goat_repository_test.dart
│   ├── models/
│   │   ├── goat_animal_test.dart
│   │   └── goat_records_test.dart
│   └── providers/
│       └── goat_providers_test.dart
├── cattle/
│   ├── data/
│   │   └── cattle_repository_test.dart
│   ├── models/
│   │   ├── cattle_animal_test.dart
│   │   └── cattle_records_test.dart
│   └── providers/
│       └── cattle_providers_test.dart
├── payroll/
│   ├── data/
│   │   └── payroll_repository_test.dart
│   ├── models/
│   │   └── payroll_employee_test.dart
│   └── providers/
│       └── payroll_providers_test.dart
└── routing/
    └── poultry_hub_routing_test.dart
```

---

## Feature Status

| Feature | data/ | providers/ | Screens |
|---|---|---|---|
| auth | — | auth_provider | 3 |
| dashboard | repository | providers | 1 |
| livestock | repository | 3 files | 8 |
| poultry | repository | providers | 25 |
| goat | repository + 3 source files | providers | 21 |
| cattle | repository + 3 source files | providers | 23 |
| pigs | repository | providers | 2 |
| aquaculture | repository | providers | 2 |
| apiculture | repository | providers | 2 |
| events | repository | alerts_provider | 8 |
| crop | repository | providers | 30 (nested) |
| production | repository + 3 source files | providers | 7 |
| financial | repository + 3 source files | providers | 2 |
| traceability | repository + 3 source files | providers | 2 |
| record | repository + 3 source files | providers | 3 |
| reports | uses multi-repo providers | — | 1 |
| insights | repository + 3 source files | providers | 2 |
| settings | repository + 3 source files | providers | 6 |
| payroll | ❌ not started | ❌ not started | 0 / 44 planned |

---

## Key Dependencies

| Package | Version | Role |
|---|---|---|
| flutter_riverpod | ^3.3.1 | All state management |
| go_router | ^17.2.3 | Declarative routing |
| dio | ^5.9.2 | HTTP client |
| drift + sqlite3_flutter_libs | ^2.33.0 | Local offline DB |
| freezed_annotation + json_serializable | — | Immutable models |
| google_fonts | ^8.1.0 | Inter + Plus Jakarta Sans |
| flutter_svg | ^2.3.0 | SVG icons |
| fl_chart | ^1.2.0 | Charts |
| flutter_local_notifications | ^21.0.0 | Reminders |
| mobile_scanner | ^7.2.0 | RFID / QR scanning |
| mocktail | ^1.0.5 | Test doubles |
