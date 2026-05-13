# Apiculture (Bee) Management Design

## Overview

Beekeeping is a unique enterprise compared to all other livestock. Bees are managed at the **hive (colony) level**, not individually. A single hive contains 20,000–80,000 bees, and the "animal" being managed is effectively the superorganism — the entire colony.

Successful bee management requires:
- Regular hive inspections (every 7–14 days in active season)
- Monitoring colony strength and population
- Queen health tracking
- Varroa mite management (the #1 global bee pest)
- Honey production planning and harvest recording
- Seasonal management adjustments

---

## South African Beekeeping Context

South Africa has **12 000+ registered beekeepers** and an estimated 750 000 registered hives (2024). The industry spans commercial honey production, pollination services, and hobbyist beekeeping.

**SA Bee Species — Critical Distinction:**

| Species | Distribution | Characteristics |
|---|---|---|
| **Cape Honeybee** (*Apis mellifera capensis*) | Western Cape (south of Hex River Mountains) | Unique — workers can lay diploid female eggs (thelytokous parthenogenesis); produces the "Cape Bee Phenomenon" in other subspecies hives |
| **African Honeybee** (*Apis mellifera scutellata*) | Rest of SA | More defensive; better adapted to heat and drought; excellent honey producer |
| **Hybrid** | Transition zones | Intermediate characteristics |

**⚠️ Cape Bee Warning:** Introducing Cape bees (capensis) into African bee (scutellata) hives causes "social parasitism" — capensis workers invade, lay eggs, and collapse the colony. The app must:
- Require beekeepers to record their dominant bee species/subspecies
- Warn when moving hives between Cape and non-Cape zones
- Flag this risk when logging hive combinations

**SA Honey Industry:**
- Annual production: ~2 000 tonnes honey; export market growing
- Fynbos honey (Western Cape) commands premium prices: R80–120/kg producer price
- Macadamia and citrus pollination services: R400–800 per hive per season
- **South African Bee Industry Organisation (SABIO)** regulates and promotes the industry
- **SA Honey Bee Act:** Bees are not officially regulated as livestock under SA Animal ID Act, but health records are increasingly required for pollination contracts

**SA Varroa Status:**
- Varroa destructor arrived in SA in 1997 — now widespread outside the Western Cape (capensis bees are naturally resistant to Varroa)
- Western Cape beekeepers moving hives to other provinces risk introducing Varroa into capensis populations
- Treatment options in SA: Oxalic acid (approved), Amitraz strips (Apistan), Formic acid

---

## Apiary Registration

An **apiary** is a physical location where hives are kept. One farm can have multiple apiaries (home farm, forest site, seasonal migration location).

| Field | Type | Notes |
|---|---|---|
| `apiary_id` | String | Auto-generated |
| `apiary_name` | String | "Home Farm", "Forest Site A" |
| `location_gps` | LatLng | GPS coordinates |
| `forage_description` | String | Surrounding flora (important for honey type) |
| `access_notes` | String | Vehicle access, distance from farm |
| `total_hives` | Int | Count of hives at this apiary |
| `water_source_nearby` | Boolean | Bees need water close to hive |

---

## Hive Registration Fields

| Field | Type | Notes |
|---|---|---|
| `hive_id` | String | Unique hive number (painted on lid) |
| `apiary_id` | String | Which apiary this hive belongs to |
| `hive_type` | Enum | `Langstroth` / `Dadant` / `Top Bar` / `Log Hive` / `Warre` |
| `origin` | Enum | `Swarm caught` / `Package bees` / `Split from existing` / `Purchased nucleus` |
| `installation_date` | Date | When colony was established |
| `bee_species_race` | String | Apis mellifera (African, Carniolan, Italian, etc.) |
| `queen_age_years` | Double | Approximate queen age |
| `queen_marked` | Boolean | Colored paint-dot marking |
| `queen_color_year` | String | Color code (BYWRG standard) |
| `hive_status` | Enum | `Active` / `Swarm risk` / `Queenless` / `Dead-out` / `Migrating` |

---

## 1. Hive Inspection Records

The core event in apiculture — inspect every 7–14 days in season.

| Field | Type | Notes |
|---|---|---|
| `inspection_date` | Date | |
| `hive_id` | String | |
| `inspector` | String | |
| `weather_conditions` | String | Sunny / Cloudy / Windy |
| `time_of_day` | String | Mid-morning best (most foragers out) |
| `colony_temperament` | Enum | `Calm` / `Moderate` / `Defensive` / `Aggressive` |
| `bee_population_frames` | Int | Number of frames covered with bees (1–10+) |
| `brood_frames` | Int | Frames containing brood |
| `brood_pattern` | Enum | `Solid` / `Spotty` / `Poor` (disease indicator) |
| `queen_seen` | Boolean | |
| `queen_condition` | Enum | `Healthy` / `Failing` / `Not seen` |
| `eggs_seen` | Boolean | Presence of eggs confirms recent queen activity |
| `honey_stores_frames` | Int | Frames of capped honey |
| `pollen_stores` | Enum | `Abundant` / `Adequate` / `Low` |
| `swarm_cells_present` | Boolean | 🚨 Swarm cells = swarm imminent |
| `supersedure_cells` | Boolean | Colony replacing queen naturally |
| `disease_signs` | String | Notes on any signs |
| `action_taken` | String | What was done |
| `next_inspection_date` | Date | |

### 1.1 Inspection Alerts

- **Swarm cells present** → Alert: "Hive [ID] has swarm cells. Immediate action required to prevent swarm loss."
- **No eggs, no queen** → Alert: "Hive [ID] appears queenless. Investigate immediately."
- **Spotty brood pattern** → Prompt to record disease investigation
- **Low honey stores** → Prompt to consider supplemental feeding

---

## 2. Colony Strength Assessment

Colony strength is scored using a standardized scale:

| Score | Description | Action |
|---|---|---|
| 1–2 | Very weak — < 3 frames bees | Consider combining with another weak colony |
| 3–4 | Weak — building up | Supplement feed, reduce entrance, monitor |
| 5–6 | Moderate — normal activity | Normal management |
| 7–8 | Strong — good foraging population | Prepare for honey flow or add supers |
| 9–10 | Very strong — at risk of swarming | Add space, split if needed |

---

## 3. Varroa Mite Management

**Varroa destructor** is the most destructive bee pest globally. Every beekeeper must actively monitor and treat. Without treatment, a colony will collapse within 1–3 years.

### 3.1 Varroa Counting Methods

| Method | How | When |
|---|---|---|
| Alcohol Wash | Wash 300 bees in alcohol, count mites | Every 30 days |
| Sugar Roll | Roll 300 bees in icing sugar, count | Gentler alternative |
| Sticky Board | Place sticky board under hive 24h, count daily drop | Monitoring only |

### 3.2 Varroa Count Record

| Field | Notes |
|---|---|
| `count_date` | |
| `hive_id` | |
| `method` | Alcohol Wash / Sugar Roll / Sticky Board |
| `mites_counted` | |
| `bees_sampled` | Usually 300 |
| `infestation_rate_pct` | (mites / bees) × 100 |
| `treatment_threshold` | 3% = treat in brood season; 2% = treat pre-winter |

**Alert thresholds:**
- Infestation > 2% in summer → Recommend treatment
- Infestation > 3% → **Urgent treatment required**
- Infestation > 5% → **Emergency treatment + hive may be lost**

### 3.3 Varroa Treatment Records

| Field | Notes |
|---|---|
| `treatment_date` | |
| `treatment_product` | Oxalic acid (dribble/sublimation/strips), Amitraz, Thymol, Formic acid |
| `method` | Sublimation / Dribble / Vapor / Strips |
| `broodless_colony` | Boolean — some treatments only work without brood |
| `dose` | |
| `application_count` | Some treatments require repeat application |
| `post_count_date` | Recount 30 days after treatment |
| `post_count_result` | Treatment efficacy |
| `honey_on_hive` | Boolean — critical: some treatments CANNOT be applied when honey supers on |

**Treatment rotation:** App tracks which treatments were used and suggests rotation to prevent mite resistance.

---

## 4. Queen Management

### 4.1 Queen Events

| Event | Fields |
|---|---|
| **Queen replacement** | Old queen removed, new queen introduced, introduction date, source (purchased/raised/natural) |
| **Re-queening** | Planned replacement before queen fails, reason, new queen ID |
| **Emergency queen cell** | Natural supersedure observed, expected hatch date |
| **Queen introduction** | New queen placed in cage, release date (3 days), acceptance confirmed |
| **Splitting** | Hive split to prevent swarm, both halves tracked |

### 4.2 Queen Source Records

| Field | Notes |
|---|---|
| `queen_source` | Purchased / Raised by farmer / Natural (wild caught swarm) |
| `breeder_name` | If purchased |
| `queen_line_genetics` | Carniolan / Italian / African hybrid / Local |
| `queen_price` | |
| `queen_introduction_date` | |
| `acceptance_confirmed` | Boolean |

---

## 5. Honey Production & Harvesting

### 5.1 Super (Honey Box) Management

- Record when honey supers are added to hive (start of nectar flow)
- Record when supers are removed for extraction
- One super can hold 15–30 kg of honey when fully capped

### 5.2 Honey Extraction Record

| Field | Notes |
|---|---|
| `extraction_date` | |
| `hive_ids_harvested` | Which hives were harvested |
| `frames_extracted` | Number of frames |
| `honey_weight_kg` | After extraction and straining |
| `honey_type` | Floral source (monofloral or wildflower) — determined by forage |
| `moisture_pct` | Must be < 20% for shelf stability |
| `colour_grade` | Water white / Extra light amber / Light amber / Amber |
| `price_per_kg` | |
| `sold_to` | Buyer name |
| `storage_notes` | |

### 5.3 Honey KPIs

| KPI | Target |
|---|---|
| Honey per hive per year | 15–30 kg (temperate), 30–80 kg (tropical) |
| Moisture content | < 20% |
| Frames per super | 8–10 frames |
| Harvest date (seasonal) | After major nectar flow ends |

---

## 6. Seasonal Management Calendar

| Season | Key Activities |
|---|---|
| **Spring** | First inspection, population assessment, add space, swarm prevention |
| **Summer** | Add supers, monitor varroa, record honey flow |
| **Autumn** | Harvest honey, varroa treatment (broodless period ideal), winter prep |
| **Winter** | Minimal inspections, check ventilation, monitor stores via heft |

App feature: Seasonal task reminders based on hemisphere setting (Northern/Southern) and local climate zone.

---

## 7. Other Products

| Product | Record |
|---|---|
| Beeswax | kg harvested, use (cosmetics/candles/foundation), price |
| Pollen | kg collected, dry weight, price |
| Propolis | g collected, price |
| Royal Jelly | g collected, price |
| Bee venom | Collected for therapy/pharmaceutical, volume, price |

---

## 8. Screen Design

```
Apiculture Dashboard
├── Apiary map (GPS pins for each apiary)
├── Hive status overview: Active / Queenless / Swarm risk / Dead-out
├── Varroa alert: hives above treatment threshold
├── Inspection overdue list (> 14 days without inspection)
└── Harvest season status: supers on / honey ready

Apiary List → Map view + List view
  └── Apiary Detail: hive cards, weather, forage notes

Hive List → Filter: All / Swarm risk / Queenless / Active
  └── Hive Profile
      ├── Overview: strength score, last inspection, queen status
      ├── Inspections: chronological log with strength chart
      ├── Varroa: count history, treatment log, resistance tracker
      ├── Queen: history of queens in this hive
      ├── Harvest: honey records, production chart
      └── Events timeline

Add Inspection → Multi-field form with guided prompts
```
