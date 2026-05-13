# Goat Module — Full Feature Plan, Mock Data & Design

_Based on `documentation/livestock/goats.md` and consistent with the poultry module architecture._

---

## 1. Core Design Decisions

### Individual Animal Model (vs. poultry batch model)

Goats are **individually identified and tracked** — unlike poultry which is managed as a batch
of anonymous birds. Every goat has a tag number, a date of birth, a sire/dam, a breeding history,
and a multi-year lifecycle. The data model therefore centres on `GoatAnimal` (one record per goat)
grouped into herds, rather than on a flock/batch entity.

| Concept | Poultry equivalent | Goat equivalent |
|---|---|---|
| Primary entity | `PoultryFlock` (batch) | `GoatAnimal` (individual) |
| Grouping | House / pen (`houseId`) | Herd (`herdId`) |
| Count tracking | `currentCount` on batch | Count computed from animal list |
| Lifecycle | 42 days (broiler) to 60 weeks (layer) | 2–8 years |
| Production types | broiler / layer / duck / turkey / quail | meat / dairy / fiber / breeding / communal |

### Production Types (SA context)
| Code | Description | Key Breeds |
|---|---|---|
| `meat` | Commercial and communal slaughter | Boer, Kalahari Red, Savanna, Indigenous Veld |
| `dairy` | Milk for processing or household | Saanen, Toggenburg, British Alpine |
| `fiber` | Mohair/Angora commercial production | Angora |
| `breeding` | Stud animals (bucks & does) | Boer, Savanna, Kalahari Red studs |
| `communal` | Smallholder / rural mixed system | Indigenous Veld, mixed |

### Animal Sexes
`doe` · `buck` · `kid_female` · `kid_male` · `wether` (castrated male)

### Animal Statuses
`active` · `sold` · `slaughtered` · `deceased` · `culled` · `dry` (dairy — not lactating)

---

## 2. Module File Structure

```
lib/features/goat/
├── data/
│   ├── goat_data_source.dart          # Abstract interface (11 methods)
│   ├── goat_mock_data_source.dart     # In-memory mock implementation
│   ├── goat_remote_data_source.dart   # Stub (all UnimplementedError)
│   └── goat_repository.dart           # AppConstants.useMockData switch
├── models/
│   ├── goat_animal.dart               # GoatAnimal + type-specific nested classes
│   └── goat_records.dart              # All supporting record/event models
├── providers/
│   └── goat_providers.dart            # All Riverpod providers
└── screens/
    ├── goat_screen.dart               # Herd list / analytics hub (entry point)
    ├── goat_detail_screen.dart        # Individual animal — 5 tabs
    ├── add_goat_screen.dart           # Register new animal
    ├── edit_goat_screen.dart          # Edit animal identity / metadata
    ├── add_kid_screen.dart            # Register newborn kid (linked to dam)
    ├── kidding_screen.dart            # Kidding event log per doe
    ├── breeding_screen.dart           # Mating / service records per animal
    ├── pregnancy_check_screen.dart    # Pregnancy confirmation records
    ├── milk_records_screen.dart       # Daily milk yield (dairy only)
    ├── shearing_screen.dart           # Mohair shearing records (Angora only)
    ├── weight_records_screen.dart     # Periodic liveweight records
    ├── health_events_screen.dart      # Disease / health events per animal
    ├── vaccination_screen.dart        # Vaccination schedule per animal
    ├── add_medication_screen.dart     # Log medication / deworming treatment
    ├── body_condition_screen.dart     # BCS (Body Condition Score) log
    ├── goat_financials_screen.dart    # Financial summary per animal or herd
    ├── goat_reports_screen.dart       # Herd performance report
    ├── sales_screen.dart              # Animal sale records
    ├── inventory_screen.dart          # Feed, medicine, drenching supply stock
    ├── pasture_screen.dart            # Grazing camp / veld rotation log
    └── cross_herd_comparison_screen.dart  # Side-by-side herd analytics
```

---

## 3. Models

### 3.1 `GoatAnimal` (core — `goat_animal.dart`)

```
id                    String     — unique identifier (goat-001 …)
farmId                String
tagNumber             String     — official ear tag / tattoo / RFID
name                  String?    — optional pet name
breed                 String     — Boer / Kalahari Red / Savanna / Angora / Saanen / Toggenburg / Indigenous Veld / Mixed
productionType        String     — meat / dairy / fiber / breeding / communal
sex                   String     — doe / buck / kid_female / kid_male / wether
status                String     — active / sold / slaughtered / deceased / culled / dry
herdId                String     — groups animals (herd-a … herd-f)
dateOfBirth           String     — ISO 8601
damId                 String?    — tag/id of mother
sireId                String?    — tag/id of father
purchaseDate          String?
purchasePrice         double?
currentWeightKg       double?
targetWeightKg        double?    — slaughter/sale target
bodyConditionScore    double?    — BCS 1-5 scale
isPregnant            bool
expectedKiddingDate   String?    — derived from last mating + 150d
lastKiddingDate       String?
totalKidsRaised       int?
isLactating           bool       — dairy/communal does
dryOffDate            String?    — dairy
currentMilkLitrePd    double?    — dairy: current daily average
lactationNumber       int?       — dairy: which lactation cycle
lastShearingDate      String?    — Angora
lastDewormingDate     String?
famachaScore          int?       — 1-5 FAMACHA eye score (parasite load indicator)
registrationNumber    String?    — stud book number
notes                 String?
createdAt             String?
updatedAt             String?
```

**Type-specific nested classes:**

```
MeatSpecific
  adgGPerDay            double?   — average daily gain (g/day)
  targetSlaughterAgeMonths  int?
  dressingPct           double?   — carcass yield %

DairySpecific
  peakMilkLitrePd       double?
  totalMilkThisLactation double?
  dryMatterIntakeKgPd   double?
  milkFatPct            double?
  milkProteinPct        double?
  projectedDryOffDate   String?

FiberSpecific
  avgFleeceMassKg       double?   — last shearing yield
  stapleLength          double?   — mm
  micronRating          double?   — fiber fineness (µm) — lower = finer = better price
  colorGrade            String?   — White / ABK (brown/black)
  lastMohairPricePerKg  double?

BreederSpecific
  studBookNumber        String?
  registeredBreeder     bool
  breedingFee           double?   — per service (bucks)
  doesServedCount       int?      — bucks: total does mated this season
  kidRatio              double?   — kids per doe per year
```

---

### 3.2 Supporting Records (`goat_records.dart`)

| Class | Key fields | Notes |
|---|---|---|
| `WeightRecord` | id, animalId, date, weightKg, bodyConditionScore, notes | Periodic liveweight |
| `MatingRecord` | id, doeId, buckId, serviceDate, serviceMethod, expectedKiddingDate, outcome | outcome: pregnant / empty / uncertain |
| `PregnancyCheck` | id, animalId, date, method, result, expectedKiddingDate, daysPregnant | method: visual / ultrasound |
| `KiddingEvent` | id, damId, kiddingDate, totalKidsBorn, kidsAliveBorn, kidsStillborn, birthWeights, kidIds, assisted, complications, notes | Links to new GoatAnimal records for each kid |
| `DailyMilkRecord` | id, animalId, date, morningLitres, eveningLitres, totalLitres, lactationDay, notes | Dairy only |
| `ShearingRecord` | id, animalId, shearingDate, fleeceWeightKg, stapleLength, micron, colorGrade, pricePerKg, totalRevenue, notes | Angora only |
| `GoatHealthEvent` | id, animalId, date, condition, severity, treatment, vet, outcome, notes | same severity scale as poultry |
| `GoatMedicationLog` | id, animalId, date, drug, dose, route, reason, withdrawalDays, administeredBy, notes | route: oral / injection / topical |
| `GoatVaccination` | id, animalId, vaccineName, dueDate, givenDate, batchNumber, nextDueDate, administeredBy | |
| `BodyConditionRecord` | id, animalId, date, score, notes | BCS 1.0–5.0 (0.5 increments) |
| `GoatSaleRecord` | id, animalId, saleDate, buyerName, saleWeightKg, pricePerKg, totalRevenue, invoiceRef, notes | |
| `GoatFeedRecord` | id, herdId, date, feedType, quantityKg, costPerKg, notes | Herd-level supplement feed |
| `PastureRecord` | id, herdId, campId, entryDate, exitDate, estimatedHa, veldCondition, notes | Grazing camp rotation |
| `FamachaRecord` | id, animalId, date, score, actionTaken, notes | SA parasite management tool |

---

## 4. Abstract Data Source Interface

```dart
abstract class GoatDataSource {
  Future<List<GoatAnimal>>       getAnimals();
  Future<List<WeightRecord>>     getWeightRecords();
  Future<List<MatingRecord>>     getMatingRecords();
  Future<List<KiddingEvent>>     getKiddingEvents();
  Future<List<DailyMilkRecord>>  getMilkRecords();
  Future<List<ShearingRecord>>   getShearingRecords();
  Future<List<GoatHealthEvent>>  getHealthEvents();
  Future<List<GoatMedicationLog>> getMedicationLogs();
  Future<List<GoatVaccination>>  getVaccinations();
  Future<List<GoatSaleRecord>>   getSaleRecords();
  Future<List<GoatFeedRecord>>   getFeedRecords();
}
```

---

## 5. Mock Data Plan

### 5.1 Herds (6 herds — map to `herdId`)

| herdId | Name | Production Type | Location |
|---|---|---|---|
| herd-a | Boer Commercial Herd | meat | Limpopo farm block |
| herd-b | Kalahari Red Herd | meat | Northern Cape veld |
| herd-c | Angora Fiber Herd | fiber | Eastern Cape |
| herd-d | Saanen Dairy Unit | dairy | Western Cape |
| herd-e | Communal Mixed Herd | communal | KwaZulu-Natal |
| herd-f | Savanna Breeding Stud | breeding | Free State |

---

### 5.2 Animals (14 animals — rich cross-section of breeds / sexes / statuses)

| id | Tag | Name | Breed | Sex | Production | Herd | Status | DoB | Weight |
|---|---|---|---|---|---|---|---|---|---|
| goat-001 | SA-B001 | Bella | Boer | doe | meat | herd-a | active | 2022-03-15 | 68 kg |
| goat-002 | SA-B002 | Titan | Boer | buck | breeding | herd-a | active | 2020-08-01 | 105 kg |
| goat-003 | SA-K001 | Rooiland | Kalahari Red | doe | meat | herd-b | active | 2021-11-20 | 58 kg |
| goat-004 | EC-A001 | Silky | Angora | doe | fiber | herd-c | active | 2022-01-10 | 42 kg |
| goat-005 | EC-A002 | Fleece | Angora | buck | fiber | herd-c | active | 2020-06-05 | 55 kg |
| goat-006 | WC-S001 | Millie | Saanen | doe | dairy | herd-d | active (lactating) | 2021-09-12 | 62 kg |
| goat-007 | WC-T001 | Tessa | Toggenburg | doe | dairy | herd-d | dry | 2022-02-28 | 55 kg |
| goat-008 | KZN-IV01 | Ntombi | Indigenous Veld | doe | communal | herd-e | active | 2020-05-17 | 38 kg |
| goat-009 | FS-SV01 | Granite | Savanna | doe | breeding | herd-f | active | 2021-07-04 | 72 kg |
| goat-010 | SA-B003 | Pip | Boer | kid_female | meat | herd-a | active | 2024-02-10 | 18 kg |
| goat-011 | SA-B004 | Lena | Boer | doe | meat | herd-a | sold | 2020-01-25 | — |
| goat-012 | WC-S002 | Pearl | Saanen | doe | dairy | herd-d | active (lactating) | 2020-11-30 | 65 kg |
| goat-013 | EC-A003 | Curl | Angora | doe | fiber | herd-c | active | 2023-03-18 | 38 kg |
| goat-014 | SA-K002 | Blitz | Kalahari Red | buck | meat | herd-b | active | 2021-04-09 | 92 kg |

---

### 5.3 Weight Records (8 records across multiple animals)

- goat-001: 2024-01-15 → 66.5 kg, BCS 3.5
- goat-001: 2024-03-01 → 68.0 kg, BCS 3.5 (post-kidding recovery)
- goat-006: 2024-01-10 → 61.0 kg, BCS 3.0 (mid-lactation)
- goat-006: 2024-03-05 → 62.0 kg, BCS 3.5
- goat-010: 2024-02-10 → 4.2 kg (birth weight)
- goat-010: 2024-03-15 → 18.0 kg (5-week weight)
- goat-004: 2024-01-20 → 41.5 kg, BCS 3.0 (pre-shearing)
- goat-008: 2024-02-28 → 38.0 kg, BCS 2.5

---

### 5.4 Mating Records (4 records)

- goat-001 × goat-002: 2023-09-15, natural mating, outcome: pregnant, expected kidding: 2024-02-12
- goat-003 × goat-014: 2023-10-01, natural mating, outcome: pregnant, expected kidding: 2024-02-28
- goat-009 × goat-002 (buck loan): 2023-08-20, natural mating, outcome: pregnant, expected kidding: 2024-01-17
- goat-007 × stud buck (external): 2024-03-10, AI, outcome: uncertain (pending check)

---

### 5.5 Kidding Events (3 events)

- goat-001: 2024-02-10, 2 kids born, 2 alive (goat-010 = kid_female 4.2 kg, unnamed kid_male 4.0 kg), no complications
- goat-009: 2024-01-17, 1 kid born, 1 alive, birth weight 3.8 kg, assisted (malposition)
- goat-003: 2024-03-02, triplets born, 2 alive 1 stillborn, birth weights 3.5 / 3.3 / — kg

---

### 5.6 Daily Milk Records (7 records — dairy does)

- goat-006 (Millie, Saanen): lactation day 65
  - 2024-03-01: AM 1.8 L / PM 1.6 L = 3.4 L
  - 2024-03-02: AM 1.9 L / PM 1.7 L = 3.6 L
  - 2024-03-03: AM 1.8 L / PM 1.5 L = 3.3 L
- goat-012 (Pearl, Saanen): lactation day 112
  - 2024-03-01: AM 2.1 L / PM 1.9 L = 4.0 L
  - 2024-03-02: AM 2.0 L / PM 1.8 L = 3.8 L
  - 2024-03-03: AM 2.2 L / PM 2.0 L = 4.2 L
  - 2024-03-04: AM 2.1 L / PM 1.9 L = 4.0 L

---

### 5.7 Shearing Records (3 records — Angora)

- goat-004 (Silky): 2023-08-12 → 2.4 kg fleece, staple 90 mm, micron 26.5, white, R 280/kg = R 672
- goat-005 (Fleece): 2023-08-12 → 3.1 kg fleece, staple 95 mm, micron 28.0, white, R 280/kg = R 868
- goat-013 (Curl): 2023-08-12 → 1.8 kg fleece, staple 80 mm, micron 27.0, white, R 280/kg = R 504

---

### 5.8 Health Events (6 events)

- goat-001: 2024-01-20, mastitis (mild), penicillin treatment, resolved
- goat-008: 2024-02-05, internal parasites (high FAMACHA 4), drench + isolation, monitoring
- goat-010: 2024-02-12, navel ill (day 2 after birth), iodine + antibiotics, resolved
- goat-003: 2024-02-28, pregnancy toxaemia (late pregnancy), propylene glycol + glucose, recovered
- goat-006: 2024-03-01, foot rot (mild), zinc sulphate foot bath, improving
- goat-004: 2024-01-05, Angora kid cold stress post-shearing, blanket + shelter, resolved

---

### 5.9 Vaccination Records (8 records — spread across multiple animals)

- goat-001: Pulpy Kidney (Enterotoxaemia) given 2024-01-10, due 2024-07-10
- goat-001: Orf (Contagious Ecthyma) given 2023-11-15, due 2024-11-15
- goat-006: Pulpy Kidney given 2024-01-10, due 2024-07-10
- goat-006: CAE (Caprine Arthritis Encephalitis) test — negative 2024-01-08
- goat-008: Pulpy Kidney given 2024-02-01, due 2024-08-01
- goat-003: Pulpy Kidney given 2024-01-15, due 2024-07-15
- goat-010: Pulpy Kidney (first dose) given 2024-03-01, booster due 2024-03-22
- goat-004: Pasteurella given 2023-10-20, due 2024-04-20 ← OVERDUE alert trigger

---

### 5.10 Medication Logs (5 records)

- goat-001: 2024-01-20, Penicillin G, 2 mL IM, mastitis, 7-day withdrawal, by farm worker
- goat-008: 2024-02-05, Closantel (Supaverm), 8 mL oral drench, parasites, 30-day withdrawal
- goat-010: 2024-02-12, Penicillin G, 0.5 mL IM, navel ill, 7-day withdrawal
- goat-003: 2024-02-28, Propylene glycol, 60 mL oral, pregnancy toxaemia, no withdrawal
- goat-006: 2024-03-01, Zinc sulphate 10% solution, topical foot bath, foot rot, no withdrawal

---

### 5.11 Sale Records (2 records)

- goat-011 (Lena): 2024-01-05, buyer: Mogashoa Abattoir, 54 kg LW, R 42/kg = R 2,268, invoice #INV-0043
- Two unnamed male kids from goat-001's 2024 kidding: 2024-03-15 (weaned), buyer: local market, avg 22 kg, R 38/kg = R 836 each

---

### 5.12 Feed Records (4 records — herd-level supplement)

- herd-a: 2024-03-01, Lucerne hay, 50 kg, R 4.20/kg — late pregnancy supplement
- herd-d: 2024-03-01, Dairy concentrate, 80 kg, R 8.50/kg — lactating does
- herd-c: 2024-02-01, Sheep & Goat lick mineral, 25 kg, R 14.00/kg
- herd-e: 2024-02-15, Maize meal, 40 kg, R 5.80/kg — winter supplement

---

## 6. Screens — Detail Design

### 6.1 `goat_screen.dart` — Herd Hub

**Analytics strip (4 KPIs):**
- Total Animals (active count)
- Does Pregnant (isPregnant = true)
- Lactating Does (isLactating = true)
- Avg BCS (average body condition score)

**Alerts / banners:**
- Kidding due soon (expectedKiddingDate within 10 days)
- Vaccination overdue (nextDueDate < today)
- FAMACHA score ≥ 4 (needs deworming)
- Shearing due (lastShearingDate > 6 months ago, Angora only)

**Filter modes:** All · Active · Sold/Slaughtered
**Toolbar buttons:** Cross-Herd Comparison · Add Animal (role-gated)

**Animal card KPIs:**
- Tag number + name
- Breed chip + Herd chip
- Sex icon + Production type chip
- Status badge (Pregnant / Lactating / Dry / Active)
- Weight · BCS · Age

---

### 6.2 `goat_detail_screen.dart` — Individual Animal (5 tabs)

| Tab | Content |
|---|---|
| **Overview** | Identity (tag, breed, sex, DOB, age), current weight, BCS, production type, herd, dam/sire links; computed KPIs; alerts |
| **Health** | Health events timeline, vaccination schedule, medication logs, FAMACHA scores, deworming history |
| **Breeding** | Mating records, pregnancy checks, kidding events, kids table (with links to kids' profiles) |
| **Production** | _Dairy_: milk record chart + daily log table; _Fiber_: shearing history + mohair revenue; _Meat_: weight gain chart + ADG; _Communal_: mixed |
| **Finance** | Cost vs revenue per animal: purchase cost, feed allocated, meds, vet, sale/cull value, margin |

---

### 6.3 `kidding_screen.dart`

Per doe: list of all kidding events with expandable cards showing:
- Date, number of kids born/alive/stillborn
- Birth weights
- Links to kid profiles
- Complications notes
- FAB: "Record Kidding"

---

### 6.4 `breeding_screen.dart`

Per doe: mating records + pregnancy check outcomes
- Mating date, buck used, expected kidding date
- Outcome status chip (Pregnant / Empty / Uncertain)
- FAB: "Add Mating Record"

---

### 6.5 `milk_records_screen.dart` (dairy only)

- Daily milk entry (AM + PM)
- Line chart: lactation curve (days in milk vs L/day)
- Total litres this lactation + projected revenue at current price
- Lactation number indicator

---

### 6.6 `shearing_screen.dart` (Angora only)

- Per animal shearing history
- Table: date / fleece kg / staple mm / micron / colour / price / revenue
- Cumulative mohair revenue
- Shearing interval alert
- FAB: "Record Shearing"

---

### 6.7 `goat_reports_screen.dart`

Herd picker → report with sections:
- Herd summary (count by sex, status, production type)
- Reproductive performance (kidding %, kids per doe, kid survival)
- Weight performance (avg current weight, ADG, BCS distribution)
- Health summary (disease events count, deworming frequency)
- Financial summary (feed cost, vet cost, revenue, margin per animal)
- Dairy section (if dairy herd): total litres, avg daily yield, revenue
- Fiber section (if Angora herd): total kg mohair, avg micron, revenue

---

## 7. Providers Design

```dart
// Core animals
final _mockAnimalsProvider          — FutureProvider<List<GoatAnimal>>
final addedAnimalsProvider          — NotifierProvider (in-session new animals)
final animalsProvider               — Provider.autoDispose (mock + added + overrides)
final animalDetailProvider          — Provider.autoDispose.family<GoatAnimal?, String>

// Per-animal records (all .family<…, String> — keyed by animalId)
final animalWeightRecordsProvider
final animalMatingRecordsProvider
final animalKiddingEventsProvider
final animalMilkRecordsProvider
final animalShearingRecordsProvider
final animalHealthEventsProvider
final animalMedicationLogsProvider
final animalVaccinationsProvider
final animalSaleRecordsProvider

// Herd-level
final herdFeedRecordsProvider       — family keyed by herdId
final herdAnimalsProvider           — family keyed by herdId

// Alert providers
final kiddingDueSoonProvider        — animals with expectedKiddingDate within 10 days
final vaccinationOverdueProvider    — vaccinations where nextDueDate < today
final famachaAlertProvider          — animals with famachaScore >= 4
final shearingDueProvider           — Angora animals where lastShearingDate > 6 months

// In-session write notifiers
final newWeightRecordProvider       — NotifierProvider<Map<String, List<WeightRecord>>>
final newMilkRecordProvider         — NotifierProvider<Map<String, List<DailyMilkRecord>>>
final newKiddingEventProvider       — NotifierProvider<…>
final animalStatusOverrideProvider  — NotifierProvider<Map<String, String>>
final animalEditProvider            — NotifierProvider<Map<String, Map<String,dynamic>>>
```

---

## 8. Business Rules / Smart Alerts

| Rule | Logic | Where shown |
|---|---|---|
| Kidding due | `expectedKiddingDate` within 10 days of today | Banner on goat_screen, alert badge on detail |
| Vaccination overdue | `nextDueDate` < today | Banner on goat_screen, Health tab badge |
| Deworming due | `lastDewormingDate` > 60 days OR FAMACHA ≥ 4 | Health tab alert card |
| Shearing due | `lastShearingDate` > 180 days, Angora only | Banner on goat_screen |
| Low BCS | `bodyConditionScore` < 2.0 | Alert on Overview tab |
| Dry cow alert | dairy doe, `dryOffDate` within 7 days | Production tab alert |
| Kid colostrum | newborn (age < 12h) with no milk record | Kidding screen reminder |

---

## 9. Routing (AppRoutes additions)

```dart
// Goat module
static const goats              = '/goats';
static goatDetail(String id)    = '/goats/$id';
static addGoat()                = '/goats/add';
static editGoat(String id)      = '/goats/$id/edit';
static goatHealth(String id)    = '/goats/$id/health';
static goatBreeding(String id)  = '/goats/$id/breeding';
static goatKidding(String id)   = '/goats/$id/kidding';
static addKid(String damId)     = '/goats/$damId/add-kid';
static goatMilk(String id)      = '/goats/$id/milk';
static goatShearing(String id)  = '/goats/$id/shearing';
static goatWeights(String id)   = '/goats/$id/weights';
static goatFinancials(String id) = '/goats/$id/financials';
static goatReports()            = '/goats/reports';
static goatInventory()          = '/goats/inventory';
static goatPasture()            = '/goats/pasture';
static crossHerdComparison()    = '/goats/compare';
static addGoatMedication(String id) = '/goats/$id/add-medication';
```

---

## 10. RBAC Gates (consistent with poultry pattern)

| Action | Required permission |
|---|---|
| Add animal | `canAddAnimal` (vet / manager / owner) |
| Edit animal | `canEditAnimal` |
| Record kidding | `canAddAnimal` |
| View financials | `canEditFinancials` |
| Record medication | `canManageHealth` |
| Administer vaccination | `canManageHealth` |

---

## 11. Consistent Design Tokens

| Element | Goat module colour |
|---|---|
| Primary accent | `AppColors.goatColor` — warm amber/brown (#795548) |
| Container background | `AppColors.goatColorContainer` |
| Analytics strip | goatColorContainer background |
| Status chips | Same pattern as poultry (active=green, sold=blue, culled=orange, deceased=red) |
| Production type chips | Color-coded per type (meat=orange, dairy=teal, fiber=purple, breeding=indigo, communal=brown) |

---

## 12. Implementation Order (Recommended Sprint Sequence)

1. **Models** — `goat_animal.dart` + `goat_records.dart`
2. **Data layer** — abstract source → mock → remote stub → repository
3. **Providers** — core animals + all record providers + alert providers
4. **`goat_screen.dart`** — list + analytics strip + banners
5. **`goat_detail_screen.dart`** — 5-tab overview (Overview + Health first)
6. **`add_goat_screen.dart`** + **`edit_goat_screen.dart`**
7. **Breeding workflow** — `breeding_screen` + `kidding_screen` + `pregnancy_check_screen` + `add_kid_screen`
8. **Production screens** — `milk_records_screen` (dairy) + `shearing_screen` (Angora) + `weight_records_screen`
9. **Health workflow** — `health_events_screen` + `vaccination_screen` + `add_medication_screen` + `body_condition_screen`
10. **Financial & reports** — `goat_financials_screen` + `goat_reports_screen` + `sales_screen`
11. **Supporting** — `inventory_screen` + `pasture_screen` + `cross_herd_comparison_screen`
12. **Tests** — models, repository, providers (mirror poultry test structure)

---

## 13. Test File Structure

```
test/goat/
├── models/
│   ├── goat_animal_test.dart       — computed getters, type-specific fields
│   └── goat_records_test.dart      — all record model factories
├── data/
│   └── goat_repository_test.dart   — mock data integrity (counts, required fields)
└── providers/
    └── goat_providers_test.dart    — alert providers, filter logic
```

---
