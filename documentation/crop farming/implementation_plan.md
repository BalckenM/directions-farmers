# Crop Farming Module — Implementation Plan
**AgriFlow SA | 4Directions Mobile App**
**Date:** 2026-05-10 | **Phase:** MVP (Release 1)

---

## 1. Overview

This plan translates the AgriFlow SA PRD (`mainplan.md`) into a concrete, file-by-file implementation plan for the Flutter app. It follows the **exact same architectural pattern** as the existing livestock module:

```
lib/features/<feature>/
  models/          ← Dart model classes (immutable, fromJson/toJson)
  data/            ← Repository wrapping MockDataSource
  providers/       ← Riverpod providers
  screens/         ← UI screens organized by sub-feature
```

Mock data lives in `data/mock/api/crop/` and is registered in `pubspec.yaml`.

---

## 2. Scope — MVP Modules to Implement

Based on PRD Section 2.1 MVP Features, these 10 functional modules are in scope:

| Module | PRD Ref | Description |
|--------|---------|-------------|
| Crop Catalog | B | Categories + crop library with SA crop data |
| Farm & Field Setup | A | Fields/plots under existing farms |
| Seasonal Planner | C | Season creation, crop-per-field assignment |
| Planting Calendar | D | Auto-generated activity timeline per field/crop |
| Tasks & Operations | E | Task creation, assignment, completion tracking |
| Weather Alerts | F | Location-based alerts, frost/heat/rain warnings |
| Pest & Disease Logging | H | Scouting logs, spray records, basic guidance |
| Expense & Input Tracking | J+M | Input purchases, categorized costs per field |
| Harvest Logging | L | Yield capture, expected vs actual comparison |
| Advisory & Knowledge Hub | N | Localized SA crop guides, weekly tips |
| Profitability Basics | M | Sales recording, gross margin calculator |

---

## 3. Mock Data Files

All files live under `data/mock/api/crop/` and must be registered in `pubspec.yaml`.

### 3.1 Files to Create

```
data/mock/api/crop/
  crop_categories.json       ← 8–10 SA crop categories
  crops.json                 ← 30–40 SA crops with full agronomic data
  fields.json                ← 6–8 sample fields under existing farms
  seasons.json               ← 4–6 active/past seasons
  planting_plans.json        ← 6–8 field-crop-season plans
  calendar_events.json       ← 20–30 scheduled activities
  tasks.json                 ← 15–20 farm tasks
  weather_alerts.json        ← 8–10 sample alerts
  pest_observations.json     ← 10–12 pest/disease scouting records
  spray_records.json         ← 6–8 spray application records
  expenses.json              ← 15–20 expense entries
  harvest_records.json       ← 8–10 harvest records
  sales.json                 ← 6–8 sales transactions
  advisory_content.json      ← 15–20 advisory articles
```

### 3.2 Key JSON Schema Sketches

**crop_categories.json**
```json
{
  "status": "success",
  "data": [
    {
      "id": "cat-001",
      "name": "Grains & Cereals",
      "icon": "grain",
      "color": "#F59E0B",
      "crop_count": 8,
      "description": "Maize, wheat, sorghum, sunflower and other field crops"
    }
  ]
}
```

**crops.json**
```json
{
  "status": "success",
  "data": [
    {
      "id": "crop-001",
      "category_id": "cat-001",
      "name": "Maize (White)",
      "scientific_name": "Zea mays",
      "local_names": {"zu": "Ummbila", "af": "Mielies", "nso": "Mmidi"},
      "maturity_days_min": 110,
      "maturity_days_max": 130,
      "planting_months": [10, 11, 12],
      "harvest_months": [3, 4, 5],
      "water_requirement": "medium",
      "rainfall_mm_min": 450,
      "rainfall_mm_max": 800,
      "suitable_provinces": ["Limpopo", "Mpumalanga", "Free State", "North West"],
      "soil_types": ["loam", "clay_loam", "sandy_loam"],
      "farm_type": ["dryland", "irrigated"],
      "temperature_min_c": 10,
      "temperature_max_c": 35,
      "expected_yield_dryland_t_ha": 3.5,
      "expected_yield_irrigated_t_ha": 8.0,
      "market_use": ["food", "animal_feed", "export"],
      "common_pests": ["Fall Armyworm", "Stalk Borer", "Aphids"],
      "common_diseases": ["Grey Leaf Spot", "Northern Corn Leaf Blight"],
      "fertilizer_n_kg_ha": 120,
      "fertilizer_p_kg_ha": 35,
      "fertilizer_k_kg_ha": 20
    }
  ]
}
```

**fields.json**
```json
{
  "status": "success",
  "data": [
    {
      "id": "field-001",
      "farm_id": "farm-001",
      "name": "North Block A",
      "size_hectares": 45.5,
      "soil_type": "clay_loam",
      "irrigation_type": "dryland",
      "prior_crop_id": "crop-001",
      "gps_center": {"lat": -23.4120, "lng": 29.8450},
      "notes": "Previously maize, good yield history"
    }
  ]
}
```

**seasons.json**
```json
{
  "status": "success",
  "data": [
    {
      "id": "season-001",
      "farm_id": "farm-001",
      "name": "Summer 2024/2025",
      "season_type": "summer",
      "start_date": "2024-10-01",
      "end_date": "2025-05-31",
      "status": "active",
      "notes": ""
    }
  ]
}
```

**planting_plans.json**
```json
{
  "status": "success",
  "data": [
    {
      "id": "plan-001",
      "field_id": "field-001",
      "season_id": "season-001",
      "crop_id": "crop-001",
      "planned_planting_date": "2024-11-15",
      "planned_harvest_date": "2025-04-01",
      "target_yield_t_ha": 4.0,
      "status": "active",
      "created_at": "2024-10-10T08:00:00Z"
    }
  ]
}
```

**calendar_events.json**
```json
{
  "status": "success",
  "data": [
    {
      "id": "event-001",
      "plan_id": "plan-001",
      "field_id": "field-001",
      "activity_type": "planting",
      "title": "Plant Maize — North Block A",
      "scheduled_date": "2024-11-15",
      "completed_date": null,
      "status": "pending",
      "notes": "",
      "reminder_days_before": 3
    }
  ]
}
```
Activity types: `land_prep`, `input_purchase`, `planting`, `germination_check`, `fertilizer_application`, `weeding`, `irrigation`, `scouting`, `spraying`, `harvest`, `post_harvest`.

**tasks.json**
```json
{
  "status": "success",
  "data": [
    {
      "id": "task-001",
      "farm_id": "farm-001",
      "field_id": "field-001",
      "plan_id": "plan-001",
      "title": "Apply basal fertilizer",
      "description": "Apply LAN 28% at 200 kg/ha at planting",
      "due_date": "2024-11-15",
      "priority": "high",
      "status": "pending",
      "assigned_to": "worker-001",
      "created_at": "2024-11-01T08:00:00Z",
      "completed_at": null
    }
  ]
}
```
Status values: `pending`, `in_progress`, `completed`, `delayed`.

**weather_alerts.json**
```json
{
  "status": "success",
  "data": [
    {
      "id": "weather-001",
      "farm_id": "farm-001",
      "alert_type": "frost_warning",
      "severity": "high",
      "title": "Frost Warning — Tonight",
      "message": "Temperatures expected to drop below 2°C. Cover sensitive seedlings.",
      "issued_at": "2025-06-12T14:00:00Z",
      "valid_until": "2025-06-13T08:00:00Z",
      "action_required": true,
      "crop_ids_affected": ["crop-005"]
    }
  ]
}
```
Alert types: `frost_warning`, `heat_stress`, `rain_forecast`, `drought_warning`, `spray_suitable`, `spray_unsuitable`, `planting_opportunity`.

**pest_observations.json**
```json
{
  "status": "success",
  "data": [
    {
      "id": "pest-001",
      "plan_id": "plan-001",
      "field_id": "field-001",
      "observed_date": "2025-01-10",
      "pest_name": "Fall Armyworm",
      "category": "pest",
      "severity": "moderate",
      "description": "Leaf damage visible on ~15% of plants in eastern corner",
      "image_url": null,
      "recommended_action": "Apply registered pesticide. Scout weekly.",
      "follow_up_date": "2025-01-17",
      "status": "open"
    }
  ]
}
```

**expenses.json**
```json
{
  "status": "success",
  "data": [
    {
      "id": "exp-001",
      "farm_id": "farm-001",
      "field_id": "field-001",
      "plan_id": "plan-001",
      "category": "fertilizer",
      "description": "LAN 28% — 2 ton",
      "amount_zar": 8400.00,
      "date": "2024-11-10",
      "supplier": "Agri SA",
      "quantity": 2000,
      "unit": "kg"
    }
  ]
}
```
Categories: `seed`, `fertilizer`, `chemical`, `fuel`, `labor`, `machinery`, `irrigation`, `transport`, `other`.

**harvest_records.json**
```json
{
  "status": "success",
  "data": [
    {
      "id": "harvest-001",
      "plan_id": "plan-001",
      "field_id": "field-001",
      "harvest_date": "2025-04-05",
      "crop_id": "crop-001",
      "actual_yield_tons": 185.0,
      "area_harvested_ha": 45.5,
      "yield_t_ha": 4.07,
      "quality_grade": "A",
      "moisture_percent": 12.5,
      "storage_location": "Main Silo",
      "losses_tons": 3.2,
      "loss_reason": "Wind damage",
      "notes": ""
    }
  ]
}
```

**sales.json**
```json
{
  "status": "success",
  "data": [
    {
      "id": "sale-001",
      "harvest_id": "harvest-001",
      "farm_id": "farm-001",
      "crop_id": "crop-001",
      "sale_date": "2025-04-20",
      "quantity_tons": 180.0,
      "price_per_ton_zar": 3850.00,
      "total_amount_zar": 693000.00,
      "buyer": "Grain SA Co-op",
      "payment_status": "paid"
    }
  ]
}
```

**advisory_content.json**
```json
{
  "status": "success",
  "data": [
    {
      "id": "adv-001",
      "category": "crop_tip",
      "crop_id": "crop-001",
      "province": null,
      "title": "Managing Fall Armyworm in Maize",
      "summary": "Early scouting and correct spray timing are key.",
      "body": "Fall Armyworm (Spodoptera frugiperda) is one of the most destructive pests of maize in South Africa...",
      "tags": ["pest", "maize", "scouting"],
      "language": "en",
      "published_at": "2025-01-01T00:00:00Z"
    }
  ]
}
```

---

## 4. Feature Directory Structure

```
lib/features/crop/
├── models/
│   ├── crop_category.dart
│   ├── crop.dart
│   ├── crop_field.dart          (named CropField to avoid conflict with Flutter Field)
│   ├── season.dart
│   ├── planting_plan.dart
│   ├── calendar_event.dart
│   ├── crop_task.dart
│   ├── weather_alert.dart
│   ├── pest_observation.dart
│   ├── spray_record.dart
│   ├── crop_expense.dart
│   ├── harvest_record.dart
│   ├── crop_sale.dart
│   └── advisory_content.dart
├── data/
│   └── crop_repository.dart
├── providers/
│   └── crop_providers.dart
└── screens/
    ├── crop_hub_screen.dart          ← Entry point, mirrors LivestockHubScreen
    ├── catalog/
    │   ├── crop_catalog_screen.dart
    │   └── crop_detail_screen.dart
    ├── fields/
    │   ├── field_list_screen.dart
    │   ├── field_detail_screen.dart
    │   └── add_edit_field_screen.dart
    ├── season/
    │   ├── season_planner_screen.dart
    │   └── add_season_screen.dart
    ├── calendar/
    │   └── planting_calendar_screen.dart
    ├── tasks/
    │   ├── task_list_screen.dart
    │   ├── task_detail_screen.dart
    │   └── add_edit_task_screen.dart
    ├── weather/
    │   └── weather_dashboard_screen.dart
    ├── pests/
    │   ├── pest_log_screen.dart
    │   └── add_pest_observation_screen.dart
    ├── expenses/
    │   ├── expense_tracker_screen.dart
    │   └── add_expense_screen.dart
    ├── harvest/
    │   ├── harvest_log_screen.dart
    │   └── add_harvest_screen.dart
    ├── profitability/
    │   └── profitability_screen.dart
    └── advisory/
        ├── advisory_hub_screen.dart
        └── advisory_detail_screen.dart
```

**Total: 21 screens, 14 models, 1 repository, 1 providers file.**

---

## 5. Model Definitions

### 5.1 CropCategory (`crop_category.dart`)
```dart
class CropCategory {
  final String id;
  final String name;
  final String icon;
  final String color;       // hex string
  final int cropCount;
  final String description;
}
```

### 5.2 Crop (`crop.dart`)
```dart
class Crop {
  final String id;
  final String categoryId;
  final String name;
  final String? scientificName;
  final Map<String, String> localNames;        // {"zu": "...", "af": "..."}
  final int maturityDaysMin;
  final int maturityDaysMax;
  final List<int> plantingMonths;             // 1–12
  final List<int> harvestMonths;
  final String waterRequirement;             // low / medium / high
  final int rainfallMmMin;
  final int rainfallMmMax;
  final List<String> suitableProvinces;
  final List<String> soilTypes;
  final List<String> farmType;               // dryland / irrigated
  final double temperatureMinC;
  final double temperatureMaxC;
  final double? expectedYieldDrylandTHa;
  final double? expectedYieldIrrigatedTHa;
  final List<String> marketUse;
  final List<String> commonPests;
  final List<String> commonDiseases;
  final double? fertilizerNKgHa;
  final double? fertilizerPKgHa;
  final double? fertilizerKKgHa;
}
```

### 5.3 CropField (`crop_field.dart`)
```dart
class CropField {
  final String id;
  final String farmId;
  final String name;
  final double sizeHectares;
  final String soilType;
  final String irrigationType;       // dryland / irrigated / mixed
  final String? priorCropId;
  final ({double lat, double lng})? gpsCenter;
  final String? notes;
}
```

### 5.4 Season (`season.dart`)
```dart
class Season {
  final String id;
  final String farmId;
  final String name;
  final String seasonType;           // summer / winter / year_round
  final DateTime startDate;
  final DateTime endDate;
  final String status;               // planned / active / completed
  final String? notes;
}
```

### 5.5 PlantingPlan (`planting_plan.dart`)
```dart
class PlantingPlan {
  final String id;
  final String fieldId;
  final String seasonId;
  final String cropId;
  final DateTime? plannedPlantingDate;
  final DateTime? plannedHarvestDate;
  final double? targetYieldTHa;
  final String status;               // planned / active / completed / cancelled
  final DateTime createdAt;
}
```

### 5.6 CalendarEvent (`calendar_event.dart`)
```dart
enum CalendarActivityType {
  landPrep, inputPurchase, planting, germinationCheck,
  fertilizerApplication, weeding, irrigation, scouting,
  spraying, harvest, postHarvest,
}

class CalendarEvent {
  final String id;
  final String planId;
  final String fieldId;
  final CalendarActivityType activityType;
  final String title;
  final DateTime scheduledDate;
  final DateTime? completedDate;
  final String status;               // pending / completed / overdue / skipped
  final String? notes;
  final int reminderDaysBefore;
}
```

### 5.7 CropTask (`crop_task.dart`)
```dart
enum TaskPriority { low, medium, high, urgent }
enum TaskStatus { pending, inProgress, completed, delayed }

class CropTask {
  final String id;
  final String farmId;
  final String? fieldId;
  final String? planId;
  final String title;
  final String? description;
  final DateTime dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final String? assignedTo;
  final DateTime createdAt;
  final DateTime? completedAt;
}
```

### 5.8 WeatherAlert (`weather_alert.dart`)
```dart
enum WeatherAlertType {
  frostWarning, heatStress, rainForecast, droughtWarning,
  spraySuitable, sprayUnsuitable, plantingOpportunity,
}

class WeatherAlert {
  final String id;
  final String farmId;
  final WeatherAlertType alertType;
  final String severity;             // low / medium / high / critical
  final String title;
  final String message;
  final DateTime issuedAt;
  final DateTime validUntil;
  final bool actionRequired;
  final List<String> cropIdsAffected;
}
```

### 5.9 PestObservation (`pest_observation.dart`)
```dart
class PestObservation {
  final String id;
  final String? planId;
  final String fieldId;
  final DateTime observedDate;
  final String pestName;
  final String category;             // pest / disease / weed
  final String severity;             // low / moderate / high / critical
  final String? description;
  final String? imageUrl;
  final String? recommendedAction;
  final DateTime? followUpDate;
  final String status;               // open / treated / resolved
}
```

### 5.10 SprayRecord (`spray_record.dart`)
```dart
class SprayRecord {
  final String id;
  final String? pestObservationId;
  final String fieldId;
  final DateTime sprayDate;
  final String productName;
  final double dosagePerHa;
  final double areaSprayedHa;
  final String? applicatorName;
  final int withholdingDays;
  final DateTime reEntryDate;
  final String? outcome;
}
```

### 5.11 CropExpense (`crop_expense.dart`)
```dart
enum ExpenseCategory {
  seed, fertilizer, chemical, fuel, labor,
  machinery, irrigation, transport, other,
}

class CropExpense {
  final String id;
  final String farmId;
  final String? fieldId;
  final String? planId;
  final ExpenseCategory category;
  final String description;
  final double amountZar;
  final DateTime date;
  final String? supplier;
  final double? quantity;
  final String? unit;
}
```

### 5.12 HarvestRecord (`harvest_record.dart`)
```dart
class HarvestRecord {
  final String id;
  final String planId;
  final String fieldId;
  final String cropId;
  final DateTime harvestDate;
  final double actualYieldTons;
  final double areaHarvestedHa;
  final double yieldTHa;
  final String? qualityGrade;
  final double? moisturePercent;
  final String? storageLocation;
  final double? lossesTons;
  final String? lossReason;
  final String? notes;
}
```

### 5.13 CropSale (`crop_sale.dart`)
```dart
class CropSale {
  final String id;
  final String? harvestId;
  final String farmId;
  final String cropId;
  final DateTime saleDate;
  final double quantityTons;
  final double pricePerTonZar;
  final double totalAmountZar;
  final String? buyer;
  final String paymentStatus;        // pending / paid / partial
}
```

### 5.14 AdvisoryContent (`advisory_content.dart`)
```dart
class AdvisoryContent {
  final String id;
  final String category;             // crop_tip / pest_guide / climate_advice / market_insight
  final String? cropId;
  final String? province;
  final String title;
  final String summary;
  final String body;
  final List<String> tags;
  final String language;
  final DateTime publishedAt;
}
```

---

## 6. Repository (`crop_repository.dart`)

Single repository with methods for each entity. Follows the same pattern as `LivestockRepository`:

```dart
class CropRepository {
  CropRepository(this._source);
  final MockDataSource _source;

  // Catalog
  Future<List<CropCategory>> getCropCategories();
  Future<List<Crop>> getCrops({String? categoryId, String? province});
  Future<Crop?> getCropById(String id);

  // Fields
  Future<List<CropField>> getFields({String? farmId});
  Future<CropField?> getFieldById(String id);

  // Seasons
  Future<List<Season>> getSeasons({String? farmId});

  // Planting Plans
  Future<List<PlantingPlan>> getPlantingPlans({String? fieldId, String? seasonId});
  Future<PlantingPlan?> getPlanById(String id);

  // Calendar
  Future<List<CalendarEvent>> getCalendarEvents({String? planId, String? fieldId});

  // Tasks
  Future<List<CropTask>> getTasks({String? farmId, String? fieldId, TaskStatus? status});

  // Weather
  Future<List<WeatherAlert>> getWeatherAlerts({String? farmId});

  // Pests
  Future<List<PestObservation>> getPestObservations({String? fieldId});
  Future<List<SprayRecord>> getSprayRecords({String? fieldId});

  // Expenses
  Future<List<CropExpense>> getExpenses({String? farmId, String? fieldId, String? planId});

  // Harvest
  Future<List<HarvestRecord>> getHarvestRecords({String? fieldId});

  // Sales
  Future<List<CropSale>> getSales({String? farmId});

  // Advisory
  Future<List<AdvisoryContent>> getAdvisoryContent({String? cropId, String? province});
}
```

`MockDataSource` must be extended with crop getter methods matching the pattern of existing methods (e.g. `getCropCategories()`, `getCrops()`, etc.).

---

## 7. Riverpod Providers (`crop_providers.dart`)

```dart
// Repository provider
final cropRepositoryProvider = Provider<CropRepository>(...);

// Catalog
final cropCategoriesProvider = FutureProvider<List<CropCategory>>(...);
final cropsProvider = FutureProvider.family<List<Crop>, String?>(...); // param: categoryId
final cropByIdProvider = FutureProvider.family<Crop?, String>(...);

// Fields
final cropFieldsProvider = FutureProvider.family<List<CropField>, String?>(...); // param: farmId
final cropFieldByIdProvider = FutureProvider.family<CropField?, String>(...);

// Seasons
final seasonsProvider = FutureProvider.family<List<Season>, String?>(...);

// Planting Plans
final plantingPlansProvider = FutureProvider.family<List<PlantingPlan>, String?>(...);

// Calendar Events
final calendarEventsProvider = FutureProvider.family<List<CalendarEvent>, String?>(...);

// Tasks
final cropTasksProvider = FutureProvider.family<List<CropTask>, String?>(...);
final overdueCropTasksProvider = Provider<AsyncValue<List<CropTask>>>(...);

// Weather
final weatherAlertsProvider = FutureProvider.family<List<WeatherAlert>, String?>(...);

// Pests
final pestObservationsProvider = FutureProvider.family<List<PestObservation>, String?>(...);

// Expenses
final cropExpensesProvider = FutureProvider.family<List<CropExpense>, String?>(...);
final totalExpensesProvider = Provider<AsyncValue<double>>(...);  // computed

// Harvest
final harvestRecordsProvider = FutureProvider.family<List<HarvestRecord>, String?>(...);

// Sales
final cropSalesProvider = FutureProvider.family<List<CropSale>, String?>(...);
final totalRevenueProvider = Provider<AsyncValue<double>>(...);  // computed

// Advisory
final advisoryContentProvider = FutureProvider.family<List<AdvisoryContent>, String?>(...);

// Profitability (computed from expenses + sales)
final grossMarginProvider = Provider<AsyncValue<Map<String, double>>>(...);
```

---

## 8. Routes to Add (`app_routes.dart`)

```dart
// ── Crop Farming ──────────────────────────────────────────────────────────────
static const String crop = '/crop';
static const String cropCatalog = '/crop/catalog';
static String cropDetailPath(String cropId) => '/crop/catalog/$cropId';
static const String cropFields = '/crop/fields';
static String cropFieldDetailPath(String fieldId) => '/crop/fields/$fieldId';
static const String addCropField = '/crop/fields/add';
static String editCropFieldPath(String fieldId) => '/crop/fields/$fieldId/edit';
static const String cropSeasons = '/crop/seasons';
static const String addCropSeason = '/crop/seasons/add';
static const String cropCalendar = '/crop/calendar';
static const String cropTasks = '/crop/tasks';
static String cropTaskDetailPath(String taskId) => '/crop/tasks/$taskId';
static const String addCropTask = '/crop/tasks/add';
static const String cropWeather = '/crop/weather';
static const String cropPests = '/crop/pests';
static const String addPestObservation = '/crop/pests/add';
static const String cropExpenses = '/crop/expenses';
static const String addCropExpense = '/crop/expenses/add';
static const String cropHarvest = '/crop/harvest';
static const String addCropHarvest = '/crop/harvest/add';
static const String cropProfitability = '/crop/profitability';
static const String cropAdvisory = '/crop/advisory';
static String cropAdvisoryDetailPath(String articleId) => '/crop/advisory/$articleId';
```

The GoRouter shell must include `/crop` as a top-level route with sub-routes nested inside. Follow the existing poultry/aquaculture route registration pattern in `app_router.dart`.

---

## 9. Navigation Integration

### 9.1 Bottom Navigation
Add **Crop** tab to the shell scaffold (or use a dedicated entry from the dashboard/drawer). If bottom nav is already at capacity, access via:
- Dashboard quick-action card labelled "Crop Farming"
- `FarmDrawer` — add "Crop Farming" nav item below Livestock

### 9.2 FarmDrawer Update
Add entry in `FarmDrawer`:
```dart
DrawerItem(
  icon: Icons.eco_outlined,
  label: 'Crop Farming',
  route: AppRoutes.crop,
),
```

### 9.3 Dashboard Quick-Action
Add a `QuickActionCard` on the dashboard pointing to `AppRoutes.crop`.

---

## 10. App Constants Update (`app_constants.dart`)

Add mock path constants:
```dart
// ── Crop Farming ──────────────────────────────────────────────────────────────
static const String mockCropCategoriesPath = '$mockBasePath/crop/crop_categories.json';
static const String mockCropsPath           = '$mockBasePath/crop/crops.json';
static const String mockCropFieldsPath      = '$mockBasePath/crop/fields.json';
static const String mockSeasonsPath         = '$mockBasePath/crop/seasons.json';
static const String mockPlantingPlansPath   = '$mockBasePath/crop/planting_plans.json';
static const String mockCalendarEventsPath  = '$mockBasePath/crop/calendar_events.json';
static const String mockCropTasksPath       = '$mockBasePath/crop/tasks.json';
static const String mockWeatherAlertsPath   = '$mockBasePath/crop/weather_alerts.json';
static const String mockPestObsPath         = '$mockBasePath/crop/pest_observations.json';
static const String mockSprayRecordsPath    = '$mockBasePath/crop/spray_records.json';
static const String mockCropExpensesPath    = '$mockBasePath/crop/expenses.json';
static const String mockCropHarvestPath     = '$mockBasePath/crop/harvest_records.json';
static const String mockCropSalesPath       = '$mockBasePath/crop/sales.json';
static const String mockAdvisoryContentPath = '$mockBasePath/crop/advisory_content.json';
```

---

## 11. pubspec.yaml Asset Registration

Add under the `assets:` section:
```yaml
# Crop Farming mock data
- data/mock/api/crop/crop_categories.json
- data/mock/api/crop/crops.json
- data/mock/api/crop/fields.json
- data/mock/api/crop/seasons.json
- data/mock/api/crop/planting_plans.json
- data/mock/api/crop/calendar_events.json
- data/mock/api/crop/tasks.json
- data/mock/api/crop/weather_alerts.json
- data/mock/api/crop/pest_observations.json
- data/mock/api/crop/spray_records.json
- data/mock/api/crop/expenses.json
- data/mock/api/crop/harvest_records.json
- data/mock/api/crop/sales.json
- data/mock/api/crop/advisory_content.json
```

---

## 12. Screen-by-Screen Specification

### 12.1 CropHubScreen (`/crop`)
**Purpose:** Entry point for all crop farming features. Mirrors `LivestockHubScreen` pattern.

**Sections:**
- Header: active season name + farm selector chip
- KPI row: Active Fields | Active Seasons | Open Tasks | Overdue Alerts
- Quick Actions grid (2×4): Fields, Catalog, Calendar, Tasks, Weather, Pests, Expenses, Harvest
- Recent Alerts banner (WeatherAlerts with `actionRequired: true`)
- Upcoming Tasks list (next 3 tasks by due date)
- Advisory Tip card (latest advisory article)

### 12.2 CropCatalogScreen (`/crop/catalog`)
**Purpose:** Browse crop categories and filter crops by province/season.

**Layout:**
- Filter chips: Province | Season | Water requirement | Farm type
- Category horizontal scroll (icon + name cards)
- Crop list (card per crop: name, maturity days, yield range, season months indicator)

### 12.3 CropDetailScreen (`/crop/catalog/:cropId`)
**Purpose:** Full crop profile with SA agronomic data.

**Sections:**
- Header: crop name, category, local names
- Planting window calendar (month indicators highlighted)
- Key stats row: Maturity | Water | Yield range
- Suitable provinces chips
- Soil & temperature requirements
- Common pests & diseases (tappable list → Advisory)
- Fertilizer guide (N/P/K)

### 12.4 FieldListScreen (`/crop/fields`)
**Purpose:** All fields under the selected farm.

**Layout:**
- Farm selector at top (re-use existing farm context)
- Field cards: name, size (ha), soil type, irrigation, current plan status badge
- FAB: Add field

### 12.5 FieldDetailScreen (`/crop/fields/:fieldId`)
**Purpose:** Field profile + linked planting plans.

**Sections:**
- Field info card (size, soil, irrigation, GPS)
- Active season plan card (crop, planting date, stage progress bar)
- Calendar Events tab (upcoming activities for this field)
- Tasks tab (open tasks for this field)
- Pest Log tab (observations for this field)
- History tab (past seasons/harvests)

### 12.6 AddEditFieldScreen (`/crop/fields/add`, `.../edit`)
**Purpose:** Create or edit a field.

**Fields:** Name, size (ha), soil type (dropdown), irrigation type (dropdown), GPS (optional), notes, prior crop (crop picker).

### 12.7 SeasonPlannerScreen (`/crop/seasons`)
**Purpose:** List of seasons with status and field coverage.

**Layout:**
- Season cards: name, date range, status badge, fields count, crops count
- Per-season expand: field → crop assignments
- FAB: New season

### 12.8 AddSeasonScreen (`/crop/seasons/add`)
**Purpose:** Create a new season and assign crops to fields.

**Flow:**
1. Season name + type + date range
2. Select fields to include
3. For each field: pick crop → system shows recommended planting window
4. Confirm → creates Season + PlantingPlan records + auto-generates CalendarEvents

### 12.9 PlantingCalendarScreen (`/crop/calendar`)
**Purpose:** Monthly/weekly view of all scheduled activities.

**Layout:**
- Month/week toggle tabs
- Calendar grid with activity dots colour-coded by type
- Day tap → activity list for that day
- Filter: Field | Crop | Activity type
- Each event card: activity type icon, field name, status chip, "Mark done" action

### 12.10 TaskListScreen (`/crop/tasks`)
**Purpose:** All farm crop tasks with status and priority.

**Layout:**
- Filter tabs: All | Pending | Overdue | Completed
- Task cards: title, due date, priority badge, field name, assigned to
- Overdue tasks highlighted in error colour
- FAB: Add task

### 12.11 TaskDetailScreen (`/crop/tasks/:taskId`)
**Purpose:** Full task details and status update.

**Sections:**
- Title, description, linked field, linked plan, due date
- Status selector (pending → in progress → completed)
- Priority badge
- Assignment info
- Notes field
- Mark Complete button

### 12.12 AddEditTaskScreen (`/crop/tasks/add`, `.../edit`)
**Purpose:** Create or edit a task.

**Fields:** Title, description, linked field (optional), due date, priority, assignee (optional), notes.

### 12.13 WeatherDashboardScreen (`/crop/weather`)
**Purpose:** Farm-location weather summary + farming alerts.

**Sections:**
- Current conditions card (temperature, humidity, wind — mock static data)
- 7-day forecast mini cards
- Active Alerts list (from weather_alerts.json) grouped by severity
- Spray suitability indicator
- Frost risk calendar (days with frost warning flagged)

### 12.14 PestLogScreen (`/crop/pests`)
**Purpose:** All pest/disease/weed observations across fields.

**Layout:**
- Filter: Field | Category (pest/disease/weed) | Severity | Status
- Observation cards: pest name, field, date, severity chip, status chip
- FAB: Log observation

### 12.15 AddPestObservationScreen (`/crop/pests/add`)
**Purpose:** Log a new pest or disease sighting.

**Fields:** Field (picker), date, pest/disease name (searchable dropdown), category, severity slider, description, photo upload (UI only — no actual upload in mock), recommended action (auto-filled from crop data), follow-up date, spray record option.

### 12.16 ExpenseTrackerScreen (`/crop/expenses`)
**Purpose:** All crop-related expenses with category breakdown.

**Layout:**
- Summary row: Total spent | Top category
- Donut chart by category (using fl_chart or simple custom paint)
- Expense list sorted by date
- Filter: Field | Category | Date range
- FAB: Add expense

### 12.17 AddExpenseScreen (`/crop/expenses/add`)
**Purpose:** Log an expense.

**Fields:** Category (dropdown), description, amount (ZAR), date, field (optional), supplier, quantity + unit (optional).

### 12.18 HarvestLogScreen (`/crop/harvest`)
**Purpose:** All harvest records with yield comparison.

**Layout:**
- Summary: Total harvested (tons) | Average yield (t/ha) | vs planned
- Harvest cards: field, crop, date, actual vs planned yield bar
- FAB: Log harvest

### 12.19 AddHarvestScreen (`/crop/harvest/add`)
**Purpose:** Record a harvest.

**Fields:** Field (picker — pre-fills plan data), harvest date, actual yield (tons), area harvested (ha), quality grade, moisture %, storage location, losses (tons), loss reason, notes.

### 12.20 ProfitabilityScreen (`/crop/profitability`)
**Purpose:** Per-field and per-crop profitability summary.

**Sections:**
- Season selector chip
- KPI row: Total Revenue | Total Costs | Gross Margin | Margin %
- Field profitability table (field | crop | revenue | cost | margin)
- Cost breakdown bar chart by category
- Best/worst performing field highlight cards
- "Log Sale" FAB → triggers add sale bottom sheet

### 12.21 AdvisoryHubScreen (`/crop/advisory`)
**Purpose:** Localized guides, tips, and best-practice articles.

**Layout:**
- Category filter tabs: All | Crop Tips | Pest Guides | Climate | Market
- Crop filter chip
- Article cards: title, summary, tags, date
- Search bar

### 12.22 AdvisoryDetailScreen (`/crop/advisory/:articleId`)
**Purpose:** Full article view.

**Layout:** Title, tags, published date, rich body text, related articles section.

---

## 13. Implementation Sequence

Build in this order to ensure each step is independently runnable and testable:

### Step 1 — Foundation (Data Layer)
1. Create all 14 mock JSON files with realistic SA data
2. Register all assets in `pubspec.yaml`
3. Add all mock path constants to `AppConstants`
4. Extend `MockDataSource` with 14 new getter methods
5. Create all 14 model classes with `fromJson` / `toJson`
6. Create `CropRepository` with all query methods
7. Create `crop_providers.dart` with all Riverpod providers
8. Add all crop routes to `AppRoutes`
9. Register routes in `app_router.dart`

### Step 2 — Entry Point & Navigation
10. `CropHubScreen` — entry point with KPIs, quick actions, alerts, tasks
11. Wire drawer entry + dashboard quick-action card

### Step 3 — Catalog
12. `CropCatalogScreen` — category + crop browsing
13. `CropDetailScreen` — full crop profile

### Step 4 — Fields
14. `FieldListScreen`
15. `FieldDetailScreen`
16. `AddEditFieldScreen`

### Step 5 — Season & Calendar
17. `SeasonPlannerScreen`
18. `AddSeasonScreen` (with auto-calendar-event generation logic)
19. `PlantingCalendarScreen`

### Step 6 — Tasks
20. `TaskListScreen`
21. `TaskDetailScreen`
22. `AddEditTaskScreen`

### Step 7 — Monitoring
23. `WeatherDashboardScreen`
24. `PestLogScreen`
25. `AddPestObservationScreen`

### Step 8 — Financials
26. `ExpenseTrackerScreen`
27. `AddExpenseScreen`
28. `HarvestLogScreen`
29. `AddHarvestScreen`
30. `ProfitabilityScreen` (depends on expenses + harvest + sales)

### Step 9 — Advisory
31. `AdvisoryHubScreen`
32. `AdvisoryDetailScreen`

---

## 14. SA Crop Data Reference (for Mock JSON Population)

### Crop Categories to Include
| ID | Name | Key Crops |
|----|------|-----------|
| cat-001 | Grains & Cereals | Maize (white/yellow), Wheat, Sorghum, Sunflower, Soybean |
| cat-002 | Vegetables | Tomato, Onion, Potato, Cabbage, Spinach, Butternut, Sweet Pepper |
| cat-003 | Fruit | Mango, Avocado, Citrus (Navel, Valencia), Banana, Table Grape |
| cat-004 | Root Crops | Cassava, Sweet Potato, Groundnut |
| cat-005 | Legumes | Dry Beans, Cowpea, Chickpea |
| cat-006 | Fodder & Cover Crops | Lucerne, Oats, Rye, Vetch |
| cat-007 | Industrial Crops | Cotton, Sugarcane, Tobacco |
| cat-008 | Indigenous Crops | Amadumbe (Taro), Cowpea leaves, Morogo |

### Province Planting Windows (SA Summer Rainfall Region)
- **Limpopo / Mpumalanga:** Maize Oct–Nov; Tomato Aug–Sep (irrigated year-round)
- **Free State / North West:** Maize Nov–Dec; Sunflower Nov–Jan
- **KwaZulu-Natal:** Maize Oct–Dec; Sugar Nov–Mar
- **Western Cape:** Wheat Apr–Jun (winter); Deciduous fruit Aug–Sep

---

## 15. Design Consistency Rules

Follow existing `AppColors`, `AppSpacing`, `AppRadius`, and `AppTypography` throughout:
- Use `FarmScaffold` as base for all crop screens
- Use `SectionHeader` widget for section labels
- Use `LoadingShimmer` while `AsyncValue` is loading
- Crop module accent color: `Color(0xFF16A34A)` (green-600) — map to a named `AppColors.cropGreen`
- Card elevation: follow existing `AppRadius.cardRadius`
- Avoid new utility widgets — reuse existing `shared/widgets/`

---

## 16. Files Modified in Existing Codebase

| File | Change |
|------|--------|
| `lib/core/constants/app_constants.dart` | +14 mock path constants |
| `lib/core/router/app_routes.dart` | +24 crop route constants |
| `lib/core/router/app_router.dart` | Register crop shell + sub-routes |
| `lib/shared/data/mock_data_source.dart` | +14 getter methods |
| `lib/shared/widgets/farm_drawer.dart` | Add Crop Farming nav item |
| `lib/features/dashboard/screens/dashboard_screen.dart` | Add Crop quick-action card |
| `pubspec.yaml` | +14 asset registrations |

---

## 17. Out of Scope for MVP

Per PRD Section 2.1 MVP Exclusions:
- Soil & fertility module (Phase 2)
- Irrigation scheduling (Phase 2)
- Full inventory management (Phase 2)
- Labor payroll and machinery management (Phase 2)
- Satellite/drone imagery (Phase 3)
- AI crop recommendations (Phase 3)
- Offline sync (Phase 1 basic stubs only — full Drift wiring in Phase 2)
- Multilingual UI (content data has `local_names` ready; UI strings English-only for now)

---

## 18. Definition of Done (MVP)

- [ ] All 14 mock JSON files created and populated with realistic SA data
- [ ] All 14 models compile with `fromJson` / `toJson`
- [ ] All providers return data from mock source without errors
- [ ] All 21 screens navigate without crashes
- [ ] CropHubScreen shows live KPIs from mock data
- [ ] Planting calendar renders events from `calendar_events.json`
- [ ] Task list shows overdue tasks highlighted
- [ ] Expense + harvest data feeds profitability calculation
- [ ] Advisory content loads and is filterable by crop
- [ ] Drawer entry navigates to `/crop`
- [ ] No broken imports; `flutter analyze` clean


Summary
Category	Status
Screens & navigation	✅ Complete
Read (GET) operations	✅ Complete
Add (POST) operations	✅ 9 of 13 entities
Edit (PUT) operations	❌ Only fields + tasks
Delete operations	❌ Repository only, no UI
Calendar event creation	❌ Not implemented
Data persistence	❌ In-memory only
Provider cache invalidation	❌ Missing
Agronomic intelligence	❌ Not built yet
Reports / exports	❌ Not built (packages available)
Notifications	❌ Not built (package available)
Offline / SQLite	❌ Not built (drift available)