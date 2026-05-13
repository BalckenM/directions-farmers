# Aquaculture Management Design

## Overview

Aquaculture (fish and prawn farming) is the fastest-growing food production sector globally. Unlike terrestrial livestock, fish live in a managed water environment where **water quality is the single most critical management variable** — poor water quality kills entire populations in hours.

The app must monitor and alert on water quality parameters in near-real-time, manage stocking density, track feed conversion, and record harvest data. It must support both **pond culture** and **tank/recirculating aquaculture systems (RAS)**.

---

## South African Aquaculture Context

South Africa's aquaculture sector is worth approximately **R1.2 billion annually** (2024) — small relative to global production but growing at 8–12% per year. Key SA species and operations:

| Species | Location | Scale |
|---|---|---|
| **Rainbow Trout** | Western Cape (Villiersdorp, Ceres, Hex River Valley), Eastern Cape highlands | ~3 000 tonnes/year; Cape Nature permits required |
| **Tilapia** (Nile & Mozambique) | Limpopo, North West, Mpumalanga (warm-water ponds) | Growing; Mozambique Tilapia is indigenous to SA |
| **Abalone** (*Haliotis midae*) | Western Cape (Hermanus, Gansbaai, Betty's Bay) | ~2 500 tonnes/year; world-class quality; poaching is critical threat |
| **Oysters** | Western Cape (Knysna, Saldanha Bay, Langebaan) | Established industry |
| **Mussels** | Western Cape (Saldanha Bay) | R60M+ industry |
| **Shrimp** | Emerging (KZN coast, Limpopo) | Pilot operations |

**SA Regulatory Framework:**
- Department of Environment, Forestry and Fisheries (DEFF): Aquaculture permits under Marine Living Resources Act (MLRA)
- **Aquaculture Development and Enhancement Programme (ADEP):** Government support for emerging aquaculture farmers
- Water use licences (DWS): Required for pond/dam operations
- **Environmental Impact Assessment:** Required for new aquaculture operations > certain scale

**SA-Specific Challenges:**
- Abalone poaching — Operation Phakisa marine resource protection; record legal stock with permits
- Water rights in drought-prone SA — water quality records critical for compliance
- Load shedding threatens aeration systems — UPS/generator backup is a compliance requirement for fish health

---

## Species Supported

| Category | Species |
|---|---|
| Warm-water Fish | Tilapia (Nile, Blue, Mozambique), Catfish (African, Channel), Carp, Milkfish |
| Cold/Coolwater Fish | Trout (Rainbow, Brown), Salmon, Char |
| Marine Fish | Sea Bass, Sea Bream, Red Snapper |
| Crustaceans | Freshwater Prawns, Tiger Prawns, Crayfish |
| Molluscs | Oysters, Mussels, Clams |
| Amphibians | Frogs (where farmed) |

---

## System Types

| System | Description |
|---|---|
| **Earthen Ponds** | Dug ponds, often semi-intensive |
| **Concrete / Lined Ponds** | Higher control, easy drain-down |
| **Cages (Net Cages)** | Floating cages in dams/rivers/sea |
| **Tanks (RAS)** | Recirculating system — highest intensity |
| **Raceways** | Flow-through channels — for trout |
| **Pen Culture** | Large fenced sections in natural water bodies |

---

## Pond / Tank Registration Fields

| Field | Type | Notes |
|---|---|---|
| `unit_id` | String | Pond or tank identifier |
| `unit_type` | Enum | `Earthen Pond` / `Lined Pond` / `Cage` / `Tank` / `Raceway` |
| `area_m2` | Double | Surface area |
| `volume_m3` | Double | Water volume |
| `depth_m` | Double | Average depth |
| `water_source` | String | Borehole / River / Rain / Mains |
| `aeration_system` | String | Paddle wheel / Air stone / Diffuser / None |
| `last_limed_date` | Date | pH management |
| `last_drain_cleaned_date` | Date | Biosecurity |

---

## 1. Stocking Records

When fish are stocked into a pond/tank:

| Field | Notes |
|---|---|
| `stocking_date` | |
| `species` | |
| `strain_source` | Hatchery or wild caught |
| `initial_count` | |
| `initial_avg_weight_g` | |
| `stocking_density` | fish per m³ |
| `batch_id` | Auto-generated |
| `expected_harvest_date` | Estimated based on target weight |
| `target_harvest_weight_g` | Species-specific market weight |

**Stocking density guidelines:**
- Tilapia (pond): 1–3 fish/m²
- Catfish (pond): 10–20 fish/m²
- Tilapia (RAS): 30–60 kg/m³
- Trout (raceway): 30–50 kg/m³

---

## 2. Water Quality Management

### 2.1 Daily Water Quality Records

This is the most critical data in aquaculture. Record at least twice daily (morning + afternoon):

| Parameter | Unit | Optimal Range (Tilapia) | Alert Threshold |
|---|---|---|---|
| `temperature` | °C | 25–30°C | < 20°C or > 35°C |
| `dissolved_oxygen` (DO) | mg/L | 5–8 mg/L | < 4 mg/L = ALERT, < 2 mg/L = EMERGENCY |
| `ph` | pH units | 6.5–8.5 | < 6.0 or > 9.5 |
| `ammonia_total` | mg/L | < 0.5 mg/L | > 1.0 mg/L |
| `unionized_ammonia` (NH₃) | mg/L | < 0.02 mg/L | > 0.05 mg/L |
| `nitrite` (NO₂) | mg/L | < 0.1 mg/L | > 0.5 mg/L |
| `nitrate` (NO₃) | mg/L | < 50 mg/L | > 100 mg/L |
| `turbidity` | NTU | 30–60 NTU | > 150 NTU |
| `salinity` | ppt | 0–5 (freshwater) | Species dependent |
| `secchi_depth` | cm | 25–40 cm | < 15 cm (algae bloom) |

### 2.2 Water Quality Alerts

- **DO < 4 mg/L** → Immediate aeration alert — push notification + in-app banner
- **DO < 2 mg/L** → EMERGENCY — fish will die within hours
- **Ammonia > 1 mg/L** → Start emergency water exchange
- **pH > 9.5** → Algae bloom or over-liming — reduce feeding, emergency aeration
- **Secchi depth < 15 cm** → Heavy algal bloom — reduce feeding, consider lime application

### 2.3 Corrective Actions Log

When alert triggered, prompt farmer to log action taken:
- Water exchange (% exchanged, time taken)
- Emergency aeration activated
- Feeding rate reduced
- Lime application (dose per ha)
- Alum treatment (algae control)

---

## 3. Feeding Management

### 3.1 Daily Feed Records

| Field | Notes |
|---|---|
| `feeding_date` | |
| `pond_id` | |
| `feed_type` | Floating pellets / Sinking pellets / Dough ball / Fermented feed |
| `feed_size_mm` | Pellet size (must match fish size) |
| `protein_pct` | Feed protein percentage |
| `amount_fed_kg` | |
| `feeding_rate_pct` | % of estimated biomass fed (typically 2–5%) |
| `estimated_biomass_kg` | |
| `fish_response` | Vigorous / Moderate / Poor (health indicator) |

### 3.2 Feed Conversion Ratio

FCR = Total feed consumed (kg) / Total weight gain (kg)

| Species | Target FCR |
|---|---|
| Tilapia | 1.2–1.8 |
| Catfish | 1.5–2.0 |
| Rainbow Trout | 1.0–1.4 |
| Channel Catfish | 1.8–2.5 |
| Salmon | 1.1–1.4 |

---

## 4. Growth Sampling Records

Every 2–4 weeks, a random sample of 20–50 fish is caught and weighed:

| Field | Notes |
|---|---|
| `sample_date` | |
| `pond_id` | |
| `sample_count` | Number of fish weighed |
| `average_weight_g` | |
| `min_weight_g` | Smallest fish in sample |
| `max_weight_g` | Largest fish in sample |
| `uniformity_pct` | % within ±10% of average |
| `estimated_total_biomass_kg` | avg weight × estimated total count |
| `notes` | Signs of disease, injuries, behavior |

**KPIs from growth sampling:**

| KPI | Formula | Target |
|---|---|---|
| ADG (Average Daily Gain) | (current avg - prev avg) / days | Species specific |
| SGR (Specific Growth Rate) | (ln(W2) - ln(W1)) / days × 100 | > 1.5% body weight/day (tilapia) |
| Survival Rate | estimated count / stocked count × 100 | > 90% |
| FCR | feed fed / weight gain | < 1.8 (tilapia) |

---

## 5. Disease & Treatment Records

### 5.1 Common Fish Diseases

| Disease | Indicator | Action |
|---|---|---|
| Columnaris (Bacterial) | Gray patches, fraying fins | Potassium permanganate bath |
| Ich (White Spot) | White salt-like spots | Temperature increase, salt treatment |
| Aeromonas (Bacterial) | Hemorrhagic ulcers | Antibiotic treatment |
| Saprolegnia (Fungal) | White cotton-like growth | Salt bath, antifungal |
| Trematodes (Flukes) | Flashing behavior, rapid breathing | Formalin/praziquantel bath |
| Tilapia Lake Virus (TiLV) | 🔴 EMERGENCY | **Notifiable** — quarantine, no treatment |

### 5.2 Treatment Records

| Field | Notes |
|---|---|
| `treatment_date` | |
| `pond_id` | |
| `diagnosis` | Observed symptoms |
| `treatment_type` | `Bath treatment` / `Medicated feed` / `Water additive` |
| `chemical_product` | |
| `dose_mg_per_liter` | |
| `duration_hours` | Bath duration |
| `withholding_period_days` | No harvest during this period |
| `outcome` | Improved / No change / Mortality increase |

---

## 6. Harvest Records

| Field | Notes |
|---|---|
| `harvest_date` | |
| `pond_id` | |
| `harvest_type` | `Partial` / `Full drain-down` |
| `fish_harvested_count` | |
| `total_harvest_weight_kg` | |
| `average_harvest_weight_g` | |
| `grade_A_pct` | Premium size (%); size grading |
| `buyer_name` | |
| `price_per_kg` | |
| `total_revenue` | |
| `notes` | Losses during harvest |

---

## 7. Screen Design

```
Aquaculture Dashboard
├── Pond/Tank overview: species, age (days since stocking), biomass estimate
├── 🚨 Water quality alerts (DO, ammonia, pH) — live status
├── Harvest ready: ponds near target weight
└── Feeding schedule today

Pond/Tank List
  └── Pond Detail
      ├── Water Quality: real-time readings log, trend charts, alert history
      ├── Stocking info: batch, density, days since stocking
      ├── Growth: sampling records, ADG/SGR chart
      ├── Feeding: daily log, FCR chart
      ├── Disease: treatment log, withholding status
      └── Harvest record

Water Quality Log
  └── Add Reading: multi-parameter form with color-coded risk indicators
```
