# Sheep Management Design — South Africa

## Overview

South Africa has approximately **22 million sheep** — the second largest flock in Africa — making sheep the nation's most numerous livestock species and one of its most important agricultural export earners through wool. The industry operates across three fundamentally different production systems:

1. **Wool Production** — Merino dominant; Eastern Cape karoo heartland; R1.5B+ annual exports
2. **Meat Production** — Dorper dominant; arid and semi-arid regions; key smallholder species
3. **Hair Sheep / Indigenous** — Damara, Blackhead Persian, Van Rooy; communal farming; no shearing required

**South African Sheep Industry Context:**
- **Merino Wool:** ~12 million Merino sheep; Eastern Cape (Graaff-Reinet, Middelburg, Cradock, Nieu-Bethesda) is the heartland; Cape Wools SA administers the TEAM certification programme
- **Dorper:** A SA-developed breed (1930s, Carnarvon Research Station) combining the Dorset Horn and Blackhead Persian; now the most farmed meat sheep breed in Africa
- **Wool exports:** SA exports ~40 million kg of greasy wool annually; China and India are primary markets; SA Merino wool is internationally recognised for consistent micron and staple quality
- **Meat sheep:** Dorper/White Dorper dominate commercial meat; Blackhead Persian and Damara are critical communal farming breeds
- **Key auction houses:** BKB (Eastern Cape, Western Cape), NFO (Free State), NTK (Limpopo), Agri-Auction
- **Wool auctions:** Cape Wools SA (Port Elizabeth weekly), Agri-Best, Nedwool
- **Benchmark prices (2025/2026):** Merino wool 21 micron — R120–145/kg clean; Dorper weaner — R1 800–2 400/head

---

## Breeds Catalogue — SA Priority

| Category | SA-Primary Breeds | Notes |
|---|---|---|
| **Fine Wool** | Merino (SA Merino, SAMFA registered), Dohne Merino | Eastern Cape heartland; export quality |
| **Medium Wool** | Corriedale, Polwarth, SA Mutton Merino | Dual-purpose wool+meat |
| **Meat** | Dorper, White Dorper | SA-developed; world-leading meat breed |
| **Hair (no wool)** | Damara, Blackhead Persian, Van Rooy | Heat-tolerant; communal farming |
| **Indigenous** | Nguni, Swazi, Pedi, Tswana, Zulu | Hardy; communal |
| **Dairy** | East Friesian, Lacaune, Awassi | Niche market |

**SA Studbook:** SA Merino (SAMFA), Dohne Merino, Dorper, White Dorper, Damara all have active SA Studbook programmes.

---

## Sheep-Specific Registration Fields

| Field | Type | Notes |
|---|---|---|
| `tagNumber` | String | Official ear tag — Animal ID Act 6/2002 |
| `rfidNumber` | String? | ISO RFID; RMIS linked |
| `brandNumber` | String? | Mostly for ram flocks and stud animals |
| `studBookNumber` | String? | SA Studbook registration |
| `rmisAnimalId` | String? | RMIS national ID |
| `breed` | Enum | SA breed catalogue |
| `purpose` | Enum | `Wool` / `Meat` / `Hair` / `Dairy` / `Dual` |
| `fleeceType` | Enum | `Fine` / `Medium` / `Coarse` / `Hair` |
| `woolMicron` | Double? | Fiber diameter — quality prime metric |
| `dagScore` | Int (0–5) | Fecal soiling score (breech) |
| `dagScoreDate` | Date | Last dag assessment |
| `lastShearingDate` | Date? | Wool/dual-purpose breeds |
| `lastShearingWeightKg` | Double? | |
| `scrapeGenotype` | String? | ARR/ARR, ARR/ARQ, etc. — scrapie programme |
| `footrotHistory` | Boolean | Flag for known footrot history |
| `mobId` | String? | Mob/paddock assignment |
| `fmdZone` | FmdZoneEnum | SA FMD zone |

---

## 1. Wool Sheep Management (Merino / Dohne Merino)

### 1.1 SA Wool Industry Context

- Merino sheep are shorn **once per year** in most SA systems (some twice-yearly programmes)
- **TEAM certification** (Cape Wools SA) — Testing, Evaluation and Management programme; certified wool clips fetch premium prices
- Wool is classified by: micron, staple length, staple strength, vegetable matter, yield, colour
- **SA Wool Growers Association (SAWGA)** represents commercial wool producers
- **Wool pricing:** Merino 17–18µ (superfine): R180–220/kg; 19–21µ (fine): R120–145/kg; 22–25µ (medium): R90–110/kg

### 1.2 Shearing Records

| Field | Type | Notes |
|---|---|---|
| `shearingDate` | Date | |
| `greasyfleecweightKg` | Double | Total raw fleece weight |
| `skirtedWeightKg` | Double | After skirting (remove belly/dag wool) |
| `woolMicron` | Double | **Prime quality metric** — average fiber diameter |
| `stapleLength_mm` | Double | Target 70–100mm (Merino) |
| `stapleStrength_nktex` | Double | Break strength; > 35 N/ktex = strong |
| `colorGrade` | String | AA / A / B / C |
| `vegetableMatterPct` | Double | VM % — major quality discount |
| `yieldPct` | Double | Clean wool % (after scouring) |
| `teamCertRef` | String? | Cape Wools SA TEAM certificate number |
| `woolBuyer` | String | BKB, Cape Wools SA, Agri-Best, Nedwool, etc. |
| `pricePerKg_zar` | Double? | Realised clean price |
| `baleNumber` | String? | Auction/sale bale tracking |

### 1.3 SA Wool KPIs

| KPI | SA Merino Target |
|---|---|
| Annual greasy fleece weight | 4.5–6.5 kg |
| Wool micron | 17–21 µm (fine–medium fine); < 17µm (ultrafine premium) |
| Staple length | 70–100 mm |
| Vegetable matter | < 2.0% |
| Staple strength | > 35 N/ktex |
| Yield % | > 65% |
| TEAM score | A or above |

### 1.4 Wool Shearing Schedule Alert

- Shearing date auto-alert: 21 days prior based on recorded last shearing + ~365 days
- Pre-shearing: Alert for pre-shearing dip / lice treatment (withholding period must clear before shearing)
- Post-shearing: Alert for post-shearing drenching window

---

## 2. Meat Sheep Management (Dorper / White Dorper)

### 2.1 SA Dorper Context

The Dorper is a SA-developed breed (1930s) — one of the most commercially successful sheep breeds ever developed. Key characteristics:
- **Shedding breed** — no shearing required; hair/wool coat sheds naturally
- Highly adapted to arid and semi-arid conditions (Karoo, Northern Cape, Free State)
- Fast growth rate; excellent carcass conformation
- **Dorper Society of SA (DSSA)** administers Studbook

### 2.2 SA Growth Targets

| Stage | Age | Dorper Target | White Dorper |
|---|---|---|---|
| Birth | 0 | 4–6 kg | 3.5–5.5 kg |
| 42 days | 6 weeks | 16–20 kg | 15–18 kg |
| Weaning | 90 days | 26–32 kg | 24–28 kg |
| Market | 4–5 months | 38–48 kg | 35–45 kg |
| Mature ram | 4 years | 110–140 kg | 90–120 kg |
| Mature ewe | 4 years | 65–85 kg | 55–70 kg |

### 2.3 Meat Sheep KPIs — SA Benchmarks

| KPI | Formula | SA Benchmark |
|---|---|---|
| Lambing % | lambs weaned / ewes joined × 100 | > 120% (Dorper) |
| Birth weight | average birth weight | > 4 kg (Dorper) |
| 90-day Weaning Weight | | > 26 kg (Dorper) |
| ADG (birth to weaning) | | > 280 g/day (Dorper) |
| Pre-weaning mortality | | < 8% |
| Conception Rate | | > 90% (1 ram : 35 ewes) |

### 2.4 Lambing Records

| Field | Notes |
|---|---|
| `eweId` | Dam |
| `ramId` / `aiCode` | Sire |
| `lambingDate` | |
| `lambsAlive`, `lambsDead`, `lambsStillborn` | |
| `birthType` | Single / Twin / Triplet |
| For each lamb: `sex`, `birthWeightKg`, `lambTag` | Tag immediately at birth |
| `lambingEase` | Easy / Assisted / Difficult |
| `fosteringRequired` | Boolean — orphan management |

---

## 3. SA Parasite Management (Critical)

### 3.1 FAMACHA Scoring (Worm Burden — Haemonchus)

FAMACHA is critical for SA sheep management — *Haemonchus contortus* (Barber's Pole Worm) is the primary killer of sheep in summer rainfall regions. **Drench resistance is widespread.**

Same 1–5 conjunctiva scoring system as goats (see [goats.md](goats.md)):
- **Score 4–5:** Treat immediately → P1 alert
- **Herd-level alert:** > 20% of mob scoring 4–5 → pasture contamination signal; mob movement required

**SA Drench Resistance Status:**
- Benzimidazoles (BZ): Near-universal resistance in most SA farms
- Levamisole: Resistance increasing (especially Eastern Cape, KZN)
- Macrocyclic Lactones (ML): Resistance emerging
- **Five-point check approach recommended:** Targeted Selective Treatment (TST) based on FAMACHA, dag score, BCS, nasal discharge, jaw oedema

### 3.2 Dag Score (Breech Soiling) — SA Flystrike Risk

| Score | Description | Action |
|---|---|---|
| 0 | Clean, dry | Normal |
| 1 | Slight staining | Monitor |
| 2 | Moist soiling | Monitor; consider crutching |
| 3 | Fresh feces on wool | **Crutch within 48 hours** |
| 4 | Flystrike risk zone | **Crutch immediately + preventive treatment** |
| 5 | Active flystrike | **Emergency treatment; isolate** |

**SA flystrike risk calendar:**
- High risk: October–April (warm, humid periods)
- Critical zones: Eastern Cape coastal, KZN Midlands, Western Cape valleys

### 3.3 SA Anthelmintic (Drench) Rotation

| Field | Notes |
|---|---|
| `drenchDate` | |
| `productName` | e.g., "Closantel", "Panacur", "Ivermectin", "Zolvix" |
| `activeClass` | BZ / LEV / ML / Combination / Monepantel / Derquantel |
| `dosage` | mL/kg; emphasise correct weigh-and-dose |
| `withdrawalDays` | Meat withdrawal period |
| `preDrenchFec` | Eggs per gram (FEC) |
| `postDrenchFec` | 14 days post-treatment |
| `efficacyPct` | Alert if < 95% |

**App rule:** Never recommend the same drench class twice consecutively. Alert if farmer selects same class as previous treatment.

---

## 4. Flystrike Management (SA High Priority)

Flystrike (blowfly strike / myiasis) is a life-threatening welfare emergency. SA conditions (warm, humid periods) make this a seasonal priority.

### 4.1 Flystrike Event Record

| Field | Notes |
|---|---|
| `eventDate` | Record immediately — flystrike advances in hours |
| `animalId` | |
| `affectedArea` | Breech / Body / Poll / Feet / Wound |
| `severity` | Grade 1 (superficial) / 2 (subcutaneous) / 3 (deep tissue) |
| `treatmentUsed` | Product name, active ingredient |
| `woundPhoto` | Photo evidence |
| `outcome` | Recovered / Died / Euthanised |

**Prevention Calendar:**
- Pre-season jetting (late September): Alert at September 1st
- Crutching before high-risk season: Alert 21 days before high-risk period
- Preventive chemical treatment (Magnum, Extinosad): Record + set next treatment date

---

## 5. Footrot Management (SA Merino Priority)

Footrot (*Dichelobacter nodosus*) is highly contagious and a major cause of lameness and production loss in Merino mobs.

- Affected feet: LF / RF / LH / RH
- Severity score: 0 (normal) to 5 (severe interdigital necrosis)
- Zinc sulfate 10% footbath: Record date, solution concentration, flock treated
- Antibiotic treatment records: drug, dose, withdrawal period
- Footvax vaccination records
- Quarantine: Flag mob for restricted movement
- Cull recommendation: Chronic carriers (score 3+ in 3 consecutive treatments)

---

## 6. Mob / Paddock Management (SA Veld Management)

Sheep in commercial SA operations are managed in **mobs**, not individually:
- Mob name and paddock location
- Mob composition: ewes / lambs / wethers / rams / ewe lambs
- **Rotational grazing** records — essential for karoo veld management
  - Mob move date, from paddock, to paddock
  - Rest period (allow veld recovery — typically 30–90 days in karoo)
- Mob-level events: FAMACHA assessment, dag scoring, weighing, drenching, dipping
- Paddock carrying capacity (DSE — Dry Sheep Equivalent) tracking

---

## 7. SA-Specific Events

| Event | Notes |
|---|---|
| **Lamb marking** | Eartagging, earmarking, castration, tail docking — record day, method, complications |
| **Crutching** | Breech clipping to prevent flystrike — 2–3x per year; record date, contractor |
| **Jetting** | Preventive flystrike spray — record product, coverage, date |
| **Dipping** | Communal dip records (statutory requirement in some areas); tick, lice, itch mite |
| **Shearing** | Full shearing record (see §1.2); record shearer, shearing shed |
| **TEAM sampling** | Cape Wools SA wool testing — record test date, certificate ref |
| **Marketing / Sale** | Auction, abattoir direct, or private treaty — link to RMIS movement record |

---

## 8. Screen Design

```
Sheep Module
├── Dashboard
│   ├── Mob summary: total mobs, total head, mob composition
│   ├── FAMACHA alerts: high-risk count, overdue assessments
│   ├── Dag/flystrike alerts: dag score > 2 mob count
│   ├── Ewes due to lamb (next 30 days)
│   └── Shearing countdown (wool breeds)
│
├── Sheep List → Filter: All / Mobs / Ewes / Rams / Lambs / Wethers / Wool / Meat
│   └── Animal/Mob Card: tag, breed, mob, dag score badge, FAMACHA badge
│       └── Sheep Profile
│           ├── Overview: photo, tag, mob, FMD zone, studbook badge
│           ├── Compliance: brand, earmark, RMIS ID
│           ├── Health: FAMACHA history, drenching, dipping, footrot, vaccination
│           ├── Fleece (wool breeds): shearing history, micron trend, TEAM certs
│           ├── Reproduction: joining records, lambing, offspring
│           ├── Weight: growth chart with SA breed benchmark
│           └── Events: full chronological timeline
│
└── Mob Actions (batch operations — critical for sheep)
    ├── Log FAMACHA Assessment (all animals in mob)
    ├── Log Dag Score Assessment (mob)
    ├── Record Drench (mob)
    ├── Record Crutching / Jetting (mob)
    ├── Record Shearing (mob — creates WoolRecord per animal or mob aggregate)
    └── Move Mob (paddock to paddock; record for rotational grazing)
```
