# 4Directions Farm — Master Planning Document

## Vision & Mission

> **"Give every South African farmer — from a smallholder with 20 goats to a commercial enterprise running 5 000 head — the same enterprise-grade livestock intelligence that was previously only available to large agribusinesses."**

This is a **holistic, offline-first farm management platform** purpose-built for South African agriculture. It is not a generic record-keeping app — it is a decision-support system that brings regulatory compliance, veterinary intelligence, market access, traceability, and financial insight directly into the farmer's pocket.

**The platform must:**
- Work fully **offline** — load shedding and rural coverage gaps make intermittent connectivity the norm, not the exception
- Be **compliant by design** — Animal Identification Act 6/2002, Animal Diseases Act 35/1984, Meat Safety Act 40/2000, and the 2025/2026 RMIS traceability mandate
- Be **simple enough** for a first-generation smartphone user yet **deep enough** for a commercial agronomist
- Be **modular** — a wool farmer does not see dairy features; a poultry operation does not see beef records
- Speak **South African farming language** — local breeds, local diseases, local markets, ZAR currency, metric units
- Be **API-ready from day one** — RMIS traceability API integration, SwiftVEE market feeds, government e-vet services

---

## Why This Application Exists — The South African Farming Reality

### Industry Scale
South Africa's agricultural sector contributes approximately **2.8% of GDP** (R90–110 billion annually), with livestock accounting for **42% of total agricultural output**. The primary livestock sectors:

| Sector | Scale | Key Facts |
|---|---|---|
| Beef Cattle | ~13.8 million head | 3rd largest in Africa; Bonsmara and Nguni dominate commercial |
| Sheep | ~22 million head | 2nd largest sheep flock in Africa; Eastern Cape is the heartland |
| Goats | ~6.5 million head | Boer Goat is a world-leading meat breed |
| Dairy | ~500 000 milking cows | Concentrated in KZN, Western Cape, Free State |
| Pigs | ~1.6 million | Concentrated commercial operations |
| Poultry | ~225 million birds | Largest agricultural sub-sector by value |
| Angora Goats | ~1 million | SA produces 50%+ of world's mohair |
| Merino Sheep | ~12 million | Eastern Cape; significant wool export industry |

### The Problem We Solve

**1. Regulatory compliance burden is increasing.** The RMIS (Red Meat Industry Traceability System) API launched November 2025 as a mandatory livestock movement registration platform. The FMD Voluntary Vaccination Scheme was gazetted May 2026, requiring vaccination records for cattle in 18 affected districts. Most farmers manage compliance through paper files, WhatsApp photos, and Excel spreadsheets.

**2. Livestock theft costs the industry R800M+ per year.** Eastern Cape alone reported R400M in losses, with only 18% of theft incidents formally reported. Proper RFID/ear-tag records, GPS timestamps, and movement audit trails are the first line of defence.

**3. Information asymmetry destroys farm profitability.** Commercial farmers with dedicated agronomists earn 3–5× more per animal than smallholder farmers managing by memory. The gap is information, not effort.

**4. Rural connectivity cannot be assumed.** Eskom load shedding (up to 12 hours/day in 2023–2024), weak LTE coverage in Limpopo, Northern Cape, and Eastern Cape districts, and high data costs (ZAR 0.29/MB prepaid) make cloud-only solutions unusable for the majority of SA farmers.

**5. The market opportunity is underserved.** Existing tools (AgriData, AgroPlan) are web-first, expensive (R800+/month), and English-only — excluding the 60% of SA livestock producers who are smallholders or emerging farmers.

---

## Target Market

### Tier 1 — Commercial Farm Operators (Primary Revenue)
- Farm size: 200–5 000+ animals
- Tech comfort: moderate to high
- Willingness to pay: R299–R799/month
- Needs: Full compliance suite, RMIS integration, multi-user roles, financial reporting, market price feeds
- Example: Bonsmara stud farm in Limpopo, Merino wool enterprise in Graaff-Reinet, feedlot operation in Free State

### Tier 2 — Smallholder & Emerging Farmers (Volume / Impact)
- Farm size: 5–200 animals
- Tech comfort: low to moderate (WhatsApp-native)
- Willingness to pay: R0–R99/month (freemium model)
- Needs: Simple record-keeping, vaccination reminders, theft prevention records, basic growth tracking
- Example: Communal goat farmer in Limpopo, backyard poultry producer in KZN, emerging beef farmer on land reform farm

### Tier 3 — Agribusiness Service Providers (B2B Channel)
- Veterinarians, AI technicians, extension officers, agri-cooperatives (BKB, NFO)
- Needs: Multi-farm dashboards, client farm access, bulk reporting tools
- Revenue model: Platform licensing fee per managed farm

---

## Application Domains

| # | Domain | Phase | Priority |
|---|---|---|---|
| 1 | **Livestock Management** | Phase 1 — Current | Critical |
| 2 | **Traceability & Compliance** | Phase 1 — Current | Critical |
| 3 | **Financial Management** | Phase 2 | High |
| 4 | **Feed & Inventory** | Phase 2 | High |
| 5 | **Market Access & Pricing** | Phase 2 | High |
| 6 | **Crop & Field Management** | Phase 3 | Medium |
| 7 | **Labour & Task Management** | Phase 4 | Medium |
| 8 | **Weather & Environment** | Phase 4 | Medium |
| 9 | **Analytics & Reporting** | Ongoing | High |
| 10 | **Farm Asset Management** | Phase 5 | Low-Medium |

---

## Phase 1 — Livestock Management (Current Focus)

### Supported Livestock Types

| Species | SA Relevance | Primary Breeds |
|---|---|---|
| **Cattle (Beef)** | 13.8M head; R30B+ industry | Bonsmara, Nguni, Afrikaner, Simmental, Brahman, Hereford |
| **Cattle (Dairy)** | 500K milking cows | Holstein-Friesian, Jersey, Ayrshire |
| **Sheep (Wool)** | 12M Merino; R1.5B wool exports | Merino, Dohne Merino, Rambouillet |
| **Sheep (Meat)** | 10M+; key smallholder species | Dorper, White Dorper, Damara, Blackhead Persian |
| **Goats (Meat)** | Boer Goat is a world breed | Boer Goat, Kalahari Red, Savanna |
| **Goats (Fiber)** | SA = 50%+ world mohair | Angora Goat (Port Elizabeth / E. Cape hub) |
| **Pigs** | 1.6M; commercial concentrated | Large White, Landrace, Duroc, Pietrain |
| **Poultry** | Largest ag sector by value | Ross 308 Broiler, ISA Brown Layer, Potchefstroom Koekoek |
| **Horses** | 120K+ working and sport | Boerperd, Quarter Horse, Thoroughbred |
| **Rabbits** | Growing urban/peri-urban | New Zealand White, Californian |
| **Aquaculture** | R1.2B industry; growing | Tilapia, Trout (Western Cape), Abalone, Shrimp |
| **Bees** | 12 000+ beekeepers | Cape Honeybee (*Apis mellifera capensis*), African Honeybee |

---

## Feature Specification — Livestock Management

### 1. Animal Registry

Each animal record stores a **base model** plus **species-specific extension fields**.

**Base Animal Model:**
```
Animal {
  id:               UUID
  farmId:           UUID
  tagNumber:        String       // Official ear tag number
  rfidNumber:       String?      // ISO 11784/11785 RFID transponder
  name:             String?      // Optional name for dairy cows, horses
  species:          SpeciesEnum
  breed:            String       // From SA breed registry
  sex:              SexEnum      // Male / Female / Castrated
  dob:              Date?
  estimatedAge:     AgeRange?    // When DOB unknown
  originType:       OriginEnum   // BornOnFarm / Purchased / Donated
  purchaseDate:     Date?
  purchasePrice:    Double?      // ZAR
  purchasedFrom:    String?
  damId:            UUID?        // Mother linkage
  sireId:           UUID?        // Father linkage
  groupId:          UUID?
  currentStatus:    StatusEnum   // Active / Sold / Deceased / Culled / Transferred
  photoPath:        String?      // Local path (offline-first)
  notes:            String?
  createdAt:        DateTime
  updatedAt:        DateTime
  syncedAt:         DateTime?    // Last cloud sync
}
```

**SA-Specific Mandatory Fields:**
```
AnimalSACompliance {
  animalId:         UUID
  brandNumber:      String?      // Animal Identification Act 6/2002 — fire or freeze brand
  brandPosition:    String?      // e.g., "Left rib, T7"
  earmarkDesc:      String?      // Official earmark description (notarial)
  studBookNumber:   String?      // SA Studbook registration number
  fmdZone:          FmdZoneEnum? // FMD-controlled area zone (affects movement permits)
  rmisAnimalId:     String?      // RMIS national traceability ID (post Nov 2025)
  brucellaTested:   Boolean      // Statutory for herd sales
  brucellaTestDate: Date?
  importPermitNo:   String?      // If imported
}
```

### 2. Health & Veterinary Records

**HealthEvent model:**
```
HealthEvent {
  id:               UUID
  animalId:         UUID         // OR groupId for batch events
  groupId:          UUID?
  eventType:        HealthEventType
  date:             Date
  nextDueDate:      Date?
  vetId:            UUID?
  performedBy:      String       // Farmer / Farmworker / Vet
  diagnosis:        String?
  symptoms:         List<String>
  drug:             String?
  drugBatchNo:      String?
  dosage:           String?
  withdrawalDays:   Int?         // Withdrawal period in days
  withdrawalEnd:    Date?        // Calculated: date + withdrawalDays
  cost:             Double?      // ZAR
  outcome:          OutcomeEnum?
  notes:            String?
  photoPath:        String?
  isSyncedToRmis:   Boolean      // For notifiable disease events
}
```

**SA Vaccination Schedule Templates (pre-loaded per species):**

| Vaccine | Species | Frequency | SA-Specific Notes |
|---|---|---|---|
| FMD (Foot and Mouth) | Cattle | Bi-annual (FMD zones) | Compulsory in Mpumalanga, Limpopo, KZN border zones; record for RMIS |
| Brucellosis (RB51) | Cattle heifers | Once, 4–8 months | Government vaccination scheme; record vaccine batch |
| Lumpy Skin Disease | Cattle | Annual | Emerging threat; 2023 outbreak in KZN, Eastern Cape |
| BVD / IBR | Cattle (breeding) | Annual | Important for stud and AI programmes |
| Clostridial (7-in-1) | Cattle, Sheep, Goats | Annual + booster | Bloat, blackleg, pulpy kidney |
| Orf (Contagious Ecthyma) | Sheep, Goats | Annual | Especially important for Angora goats |
| PPR (Peste des Petits Ruminants) | Sheep, Goats | Per outbreak zone | Notifiable — report to DAFF |
| Pasteurella | Sheep, Goats | Annual | Pneumonia prevention |
| Swine Fever (ASF) | Pigs | Ongoing vigilance | No vaccine; biosecurity protocol mandatory |
| Newcastle Disease | Poultry | Monthly (LaSota) | Critical for smallholder flocks; mass mortality risk |

**SA Notifiable Diseases (mandatory reporting to DAFF):**
- Foot and Mouth Disease (FMD)
- African Swine Fever (ASF)
- Avian Influenza (HPAI)
- Bovine Spongiform Encephalopathy (BSE)
- Contagious Bovine Pleuropneumonia (CBPP)
- Rinderpest (eradicated but remains notifiable)
- Peste des Petits Ruminants (PPR)
- Sheep and Goat Pox

App behaviour: When any notifiable disease event is logged, immediately show a mandatory reporting prompt with DAFF contact number (012 319 7000) and generate a pre-filled incident report PDF.

### 3. Weight & Growth Tracking

Records:
```
WeightRecord {
  id, animalId, weightKg, date, recordedBy,
  bodyConditionScore: Int?,   // 1–9 (cattle), 1–5 (sheep/goats)
  notes, photoPath
}
```

**SA Breed Benchmarks (pre-loaded):**

| Breed | Weaning Target | Mature Weight |
|---|---|---|
| Bonsmara Bull | 200 kg (205-day adj) | 700–900 kg |
| Nguni Bull | 160 kg | 450–550 kg |
| Dorper Ram | 40 kg (90-day) | 90–130 kg |
| Boer Goat Buck | 25 kg (90-day) | 110–135 kg |
| SA Merino Ram | 45 kg (120-day) | 70–90 kg |
| Large White Boar | 30 kg (8 weeks) | 300–450 kg |

### 4. Breeding & Reproduction

```
BreedingEvent {
  id, animalId (dam), sireId?, aiStrainCode?,
  eventType: BreedingEventType,   // Mating / AI / PregnancyCheck / Birth / Wean
  date, outcome, notes,
  expectedBirthDate: Date?,
  kidsLambsPigletsBorn: Int?,
  bornAlive: Int?,
  bornDead: Int?,
  birthType: BirthTypeEnum?,
  offspringIds: List<UUID>
}
```

**SA Studbook Integration:**
- Bonsmara, Nguni, Dohne Merino, Boer Goat, Angora all have SA Studbook programmes
- Store `studBookNumber` per registered animal
- Future: Direct SA Studbook API submission for performance recorded animals

### 5. Production Records

**Milk:**
```
MilkRecord {
  id, animalId, date, session (AM/PM/Eve),
  yieldLitres, fatPct?, proteinPct?,
  somaticCellCount?, conductivity?,
  bulkTankContribution: Boolean,
  notes
}
```

**Wool/Mohair (SA-critical):**
```
WoolRecord {
  id, animalId (or groupId for mob shearing), shearingDate,
  greasyFleecWeightKg, skirtedWeightKg?,
  woolMicron, stapleLength_mm, stapleStrength_nktex?,
  vegetableMatterPct?, yieldPct?,
  colorGrade,           // AA / A / B / C
  woolBuyer,            // BKB, Agri-Best, Cape Wools SA, etc.
  pricePerKg_zar?,
  baleNumber?,
  certificateRef?       // Cape Wools SA TEAM certification
}
```

**Eggs:**
```
EggRecord {
  id, groupId (flock), date,
  totalEggs, brokenEggs, gradeA, gradeB,
  hatchingEggs?,        // For breeding flocks
  notes
}
```

### 6. Groups & Mob Management

```
AnimalGroup {
  id, farmId, name, species,
  purpose: GroupPurpose,    // Breeding / Feedlot / Weaner / Production / Quarantine
  locationDescription,
  paddockId: UUID?,
  createdAt, updatedAt
}
```

### 7. Alerts & Reminders Engine

Priority levels (with visual coding):
- **P1 — Critical (red):** Notifiable disease suspected, overdue withdrawal period, animal at-risk
- **P2 — Action Required (amber):** Vaccination overdue, pregnancy milestone, FAMACHA 4–5
- **P3 — Informational (blue):** Upcoming event in 7 days, growth milestone reached
- **P4 — Advisory (grey):** Market price movement, weather alert

---

## Traceability & Compliance Module

### RMIS Integration (November 2025 Mandate)

The Red Meat Industry Traceability System is now mandatory for all cattle and small stock movement registrations. The app must:

1. **Register animals** — Submit animal registration data to RMIS API (via sync when online)
2. **Log movements** — Record every farm-to-farm, farm-to-abattoir, farm-to-auction movement
3. **Generate Movement Permits** — Pre-fill B313 Livestock Movement Permit form
4. **Receive RMIS Animal IDs** — Store `rmisAnimalId` against each animal
5. **Offline queuing** — Queue all RMIS submissions for sync when connectivity resumes

```
MovementRecord {
  id, animalIds: List<UUID>,
  movementType: MovementType,  // FarmToFarm / FarmToAbattoir / FarmToAuction / Import / Export
  movementDate, fromFarmId, toFarmName, toFarmRegistrationNo,
  transporterName, vehicleRegNo, permitNumber,
  rmisSubmitted: Boolean, rmisSubmitDate?,
  veterinaryHealthCertRef?,
  notes
}
```

### Movement Permits (B313)

The app pre-fills the Department of Agriculture, Land Reform and Rural Development (DALRRD) Form B313:
- Seller details (farm registration, brand/earmark)
- Buyer details
- Animal count per species
- Ear tag / brand numbers
- Destination (farm, abattoir, auction)
- Veterinary health status declaration
- Transport details

Generate as PDF for print or digital sharing via WhatsApp.

### FMD Zone Compliance

South Africa has FMD-controlled areas primarily in the northern and eastern border regions:
- **Protection Zone:** Limpopo/Mpumalanga FMD border corridor — cattle and buffalo movement restricted
- **Surveillance Zone:** Buffer areas
- **Free Zone:** Most of SA

App features:
- GPS-detect or manually set farm FMD zone
- Block movement records that violate FMD zone restrictions (with explanation)
- Mandatory vaccination recording for animals in FMD zones
- Integration with FMD Voluntary Vaccination Scheme records (gazetted May 2026)

### Livestock Theft Prevention

With R800M+ lost to theft annually, this is a critical value-add:

1. **RFID + brand photo documentation** — Timestamped photographic record of brand, earmark, and RFID tag serves as legal evidence
2. **Theft report generation** — Pre-filled SAPS docket template (CAS number field)
3. **Movement anomaly alerts** — Flag if animals deregistered from RMIS at unexpected location
4. **Emergency contacts** — Quick-dial stock theft unit (per province), SAPS, Agri SA stock theft desk
5. **Offline animal census** — Always-available animal count with last-known GPS location of farm

---

## Financial Management Module (Phase 2)

### Core Financial Records

```
FinancialTransaction {
  id, farmId, date,
  type: TransactionType,    // Income / Expense / Transfer
  category: FinancialCategory,
  amount_zar: Double,
  linkedAnimalId?: UUID,
  linkedGroupId?: UUID,
  description, reference,
  payee_payer: String,
  notes
}
```

**Income Categories:** Livestock Sales, Milk Sales, Wool/Mohair Sales, Egg Sales, Stud Fees, Government Grants (CASP, REDS), Agri-Insurance Payouts

**Expense Categories:** Feed & Supplements, Veterinary & Medicines, Labour, Equipment, Fuel & Transport, Dipping & Spraying, Marketing & Auction Fees, Land Rental, Loan Repayments, Infrastructure

### SA Market Price Integration

**Key price sources to integrate:**
- **SAMEX (SA Meat Exchange):** Weekly cattle and small stock prices per abattoir
- **SwiftVEE Live Auction:** Real-time auction prices for SA's largest online livestock auction
- **BKB Wool Auctions:** Weekly wool price per micron (Port Elizabeth, Durban)
- **Cape Mohair Auction:** Bi-annual mohair auction prices (Port Elizabeth)
- **NAMC (National Agricultural Marketing Council):** Official price bulletins

**Price Benchmarks (2025/2026):**
| Product | Current Price | Unit |
|---|---|---|
| A3 Beef Carcass | R67–72 | per kg |
| Dorper Wethers | R1 800–2 400 | per head |
| Boer Goat (auction) | R1 500–3 500 | per head |
| Merino Wool (21 micron) | R120–145 | per kg clean |
| Mohair (Kid, <26 micron) | R320–380 | per kg |
| Raw Milk (commercial) | R5.80–7.20 | per litre |

### Profitability Per Enterprise

Calculate **gross margin per enterprise** (cattle/sheep/goats/poultry):
- Revenue: All sales from enterprise
- Variable costs: Feed, vet, medication, auction fees
- Gross Margin = Revenue - Variable Costs
- Per-head margin and per-kg margin views

---

## Market Access Module (Phase 2)

### Auction & Sales Integration

**Auction Houses:**
- SwiftVEE (online, nationwide) — API available
- BKB Auctioneers (Eastern Cape, Western Cape)
- Agri-Auction (Limpopo, Gauteng)
- NTK Veehandelsdienste (Limpopo, North West)
- NFO Veehandelsdienste (Free State, Northern Cape)

**Features:**
- Browse upcoming auction dates and venues near farm GPS
- Log animals nominated for auction with condition photos
- Record sale results back against animals
- Auto-generate RMIS movement record from sale

### Abattoir Direct Sales

**Major SA abattoirs by species:**
- Cattle: Rainbow Chicken (no — poultry), Beefcor (Gauteng), Joburg Fresh (Central), RCL Foods
- Sheep: Agri-Best, Abattoir Bethlehem, Roos-Senekal
- Pigs: RCL Foods (Wolmeransstad), Enterprise Foods

---

## Gap Analysis — Current vs Required

### Critical Gaps (Must Have for Market Launch)

| Gap | Impact | Effort |
|---|---|---|
| No Drift/SQLite schema implemented | App uses mock JSON — cannot persist real data | High |
| No RMIS API integration | Non-compliant with Nov 2025 mandate | High |
| No Movement Permit (B313) generation | Illegal animal movement without permit | Medium |
| No offline sync architecture | App breaks without connectivity | High |
| No user authentication backend | Cannot secure multi-user farm data | High |
| No push notifications backend | Vaccination reminders don't work offline | Medium |

### High Priority Gaps

| Gap | Impact | Effort |
|---|---|---|
| No RFID scanner integration (mobile_scanner) | Manual entry is error-prone; tag scanning not functional | Medium |
| No wool/mohair production records | Omits R1.5B export sector entirely | Medium |
| No movement record screen | Core compliance feature missing | Medium |
| No financial transaction recording | Cannot calculate farm profitability | High |
| No PDF export (Movement Permit, Reports) | Compliance requires paper/digital documents | Medium |
| No SA breed benchmarks in weight tracking | Generic targets don't apply to Bonsmara/Nguni/Dorper | Low |
| No FAMACHA scoring screen | Critical for sheep/goat parasite management | Low |

### Medium Priority Gaps

| Gap | Impact | Effort |
|---|---|---|
| No multi-language support (isiZulu, Afrikaans, Sesotho) | Excludes 60% of SA farmer base | High |
| No agri-cooperative integration (BKB, NFO) | Misses B2B channel | High |
| No weather integration | SA farmers need drought/frost alerts | Medium |
| No livestock theft report generator | Key differentiator for SA market | Low |
| No FMD zone map visualization | Compliance UX gap | Medium |
| No SA Studbook integration | Misses stud industry segment | High |

---

## Development Roadmap

### Sprint 1 — Foundation (4 weeks)
- Drift SQLite schema (all 10 core models)
- Repository pattern with local DataSource
- Mock → Local DB migration (keep mock for demo mode)
- Authentication (Supabase Auth — email, phone number)
- Farm setup wizard (species selection, province, FMD zone)

### Sprint 2 — Core Livestock CRUD (4 weeks)
- Animal registration with SA compliance fields (brand, RFID, earmark)
- Group management
- Weight records with SA breed benchmarks
- QR/RFID scanner integration (mobile_scanner)
- Photo capture for animals

### Sprint 3 — Health & Events (3 weeks)
- Health event logging with SA vaccination templates
- Notifiable disease reporting prompt
- FAMACHA scoring screen for sheep/goats
- Withdrawal period tracking with calendar alerts
- push notification setup (flutter_local_notifications)

### Sprint 4 — Compliance & Traceability (4 weeks)
- Movement record screen
- B313 movement permit PDF generation
- RMIS API integration (online sync)
- Offline queue system for RMIS submissions
- FMD zone compliance checks

### Sprint 5 — Production & Breeding (3 weeks)
- Wool/mohair shearing records
- Milk production with SCC tracking
- Egg production records
- Breeding event screens
- Kidding/lambing/calving workflow

### Sprint 6 — Financial & Market (4 weeks)
- Basic income/expense recording
- Profitability per enterprise
- SwiftVEE price feed integration
- SAMEX price bulletin display
- Sales record linkage to animal history

---

## Technology Stack

| Layer | Technology | Status |
|---|---|---|
| Framework | Flutter 3.11.5+ | ✅ Implemented |
| State Management | Riverpod 3.3.1 | ✅ Implemented |
| Navigation | GoRouter 17.2.3 | ✅ Implemented |
| Local Database | Drift 2.23.1 (SQLite) | ⚠️ Dependency added, schema pending |
| HTTP Client | Dio 5.8.0 | ⚠️ Dependency added, not integrated |
| Charts | fl_chart 1.2.0 | ✅ Used in InsightsScreen |
| RFID/QR Scanning | mobile_scanner 7.0.1 | ⚠️ Dependency added, not integrated |
| Notifications | flutter_local_notifications | ⚠️ Dependency added, not integrated |
| Photo Capture | image_picker 1.1.2 | ⚠️ Dependency added, not integrated |
| Auth | Supabase Auth (planned) | ❌ Not started |
| Backend API | Supabase (planned) | ❌ Not started |
| RMIS Integration | DALRRD RMIS API | ❌ Not started |
| PDF Generation | pdf package (to add) | ❌ Not started |
| Offline Sync | Custom + Drift | ❌ Not started |

---

## Role-Based Access Control

| Role | Permissions |
|---|---|
| **Owner** | Full access: all livestock data, financial records, user management, farm settings, API integrations |
| **Manager / Agronomist** | All livestock records, health events, production, breeding, movement permits — no financial reports |
| **Farmworker** | Log events (feeding, weight, health check-ins), view assigned animals — no edit/delete existing records |
| **Veterinarian** | View all health records for linked farm, add diagnosis and treatment records — read-only for other modules |
| **Extension Officer** | Read-only access to all records for advisory purposes — no write permissions |
| **Auditor** | Read-only full access including financial records for compliance audit |

---

## Offline Architecture

### Sync Strategy
```
User action
  → Write to Drift local DB immediately (optimistic UI)
  → Add to sync queue (pending_syncs table)
  → Background isolate polls connectivity
  → When online: flush sync queue to Supabase / RMIS API
  → Handle conflicts: server timestamp wins for records modified on multiple devices
```

### Data Prioritisation for Offline
1. **Always offline:** Animal registry, health events, weight records, production records
2. **Sync on open:** Market prices, RMIS status updates, push notification payloads
3. **Online only:** PDF generation (optional), SA Studbook lookups, real-time auction prices

### Storage Estimates
- 1 000 animals × 2 years data ≈ 15 MB local SQLite
- Photos: compressed to 200 KB each; 3 per animal = 600 MB for 1 000 animals
- Strategy: Thumbnail cached locally; full resolution on cloud storage (Supabase Storage)

---

## Monetisation

### Free Tier
- Up to 20 animals
- Basic record-keeping (health events, weights, breeding)
- No compliance features, no market prices
- Community support only

### Starter — R99/month (R990/year)
- Up to 200 animals
- Full livestock records
- SA vaccination templates
- Basic movement records
- Email support

### Professional — R299/month (R2 990/year)
- Unlimited animals
- RMIS integration
- Movement permit PDF generation
- Financial tracking
- Market price feeds (SwiftVEE, SAMEX)
- Multi-user (up to 3)
- Wool/Mohair records

### Enterprise — R799/month (R7 990/year)
- All Professional features
- Multi-farm management (up to 10 farms)
- SA Studbook integration
- Custom reporting and PDF export
- API access for agri-cooperative integration
- Unlimited users
- Dedicated support

### B2B — Custom pricing
- Agri-cooperative branded deployment
- Extension officer multi-farm dashboard
- Government programme reporting tools

---

## Folder Structure (Current Implementation)

```
mobile_app/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── app_colors.dart
│   │   │   ├── app_typography.dart
│   │   │   ├── app_spacing.dart
│   │   │   ├── app_radius.dart
│   │   │   └── app_shadows.dart
│   │   ├── router/
│   │   │   ├── app_router.dart        ← GoRouter + 5-branch shell (✅ redesigned)
│   │   │   └── app_routes.dart        ← Route constants (✅ updated)
│   │   ├── utils/
│   │   │   ├── app_extensions.dart
│   │   │   ├── date_utils.dart
│   │   │   ├── validators.dart
│   │   │   └── connectivity_service.dart
│   │   ├── constants/
│   │   │   ├── app_constants.dart
│   │   │   └── livestock_constants.dart
│   │   └── errors/
│   │       ├── app_exception.dart
│   │       └── failure.dart
│   ├── shared/
│   │   ├── widgets/
│   │   │   ├── farm_scaffold.dart     ✅
│   │   │   ├── farm_app_bar.dart      ✅
│   │   │   ├── stat_card.dart         ✅
│   │   │   ├── section_header.dart    ✅
│   │   │   ├── chart_card.dart        ✅
│   │   │   ├── empty_state.dart       ✅
│   │   │   ├── loading_shimmer.dart   ✅
│   │   │   └── [25+ additional widgets]
│   │   ├── models/
│   │   │   ├── farm.dart
│   │   │   └── pagination_meta.dart
│   │   └── data/
│   │       ├── mock_data_source.dart
│   │       └── api_response.dart
│   └── features/
│       ├── auth/
│       │   ├── screens/
│       │   │   ├── splash_screen.dart  ✅
│       │   │   ├── login_screen.dart   ✅
│       │   │   └── onboarding_screen.dart ✅
│       │   └── providers/
│       │       └── auth_provider.dart  ✅
│       ├── dashboard/                 ← "Command" screen (✅ redesigned)
│       ├── livestock/                 ← "Herd" screen (✅ redesigned)
│       ├── record/                    ← NEW: unified events+production (✅ created)
│       ├── insights/                  ← NEW: analytics screen (✅ created)
│       ├── reports/
│       ├── events/                    ← Sub-screens (health, weight, breeding)
│       ├── production/                ← Sub-screens (milk, eggs)
│       └── settings/                  ← "Farm" screen (✅ redesigned)
├── data/
│   └── mock/
│       └── api/                       ← 14 JSON mock files
└── documentation/
    ├── planning.md                    ← This file
    ├── design_system.md
    └── livestock/                     ← Per-species design documents
```

---

## Individual Livestock Design Documents

Detailed species-specific design in `documentation/livestock/`:
- [cattle.md](livestock/cattle.md) — Beef (Bonsmara, Nguni, Afrikaner) & Dairy cattle
- [goats.md](livestock/goats.md) — Boer Goat (meat), Angora (mohair), dairy goats
- [sheep.md](livestock/sheep.md) — Merino (wool), Dorper (meat), indigenous breeds
- [pigs.md](livestock/pigs.md) — Commercial pigs, biosecurity (ASF threat)
- [poultry.md](livestock/poultry.md) — Broilers, layers, indigenous breeds (Potchefstroom Koekoek)
- [horses.md](livestock/horses.md) — Boerperd, working horses, donkeys
- [rabbits.md](livestock/rabbits.md) — Meat and fur rabbit farming
- [aquaculture.md](livestock/aquaculture.md) — Tilapia, trout, abalone (SA context)
- [bees.md](livestock/bees.md) — Cape Honeybee, honey production, pollination services

---

_Document version 3.0 — Updated with South African industry research, RMIS compliance, FMD scheme (May 2026), and full gap analysis. Previous version 2.0 archived._
