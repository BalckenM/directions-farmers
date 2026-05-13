# Pig Management Design

## Overview

Pig farming is an intensive, fast-cycling enterprise with tightly managed reproduction (farrowing), strict biosecurity requirements, and precise feed conversion economics. Unlike cattle or sheep, pigs must be managed through defined production stages from birth to slaughter. The primary economic metric — **PSY (Pigs per Sow per Year)** — drives all management decisions.

**Critical difference from other livestock:** Pig health events have the potential to become national biosecurity emergencies (African Swine Fever, Foot and Mouth) requiring immediate alert systems.

---

## South African Pig Industry Context

- **~1.6 million pigs** nationally; heavily concentrated commercial operations
- Commercial pig farming concentrated in: North West (Wolmeransstad area), Limpopo, Western Cape, Gauteng
- Major processors: RCL Foods (Rainbow Chicken subsidiary), Enterprise Foods, Eskort, Joburg Fresh
- **African Swine Fever (ASF)** is the existential biosecurity threat — no vaccine exists; outbreaks have decimated the industry in Limpopo (2012, 2019) and remain an ongoing risk from neighbouring countries (Zimbabwe, Mozambique, Botswana)
- ASF is **legally notifiable** under Animal Diseases Act 35/1984 — failure to report carries criminal penalties
- Pig prices (2025/2026): R22–27/kg live weight; R38–45/kg pork retail

### SA ASF Biosecurity Alert System

The app must have an **ASF Emergency Protocol** that triggers when any of these symptoms are recorded in a group:
- Sudden high mortality (> 3% in 24 hours)
- High fever (> 41°C) in multiple animals
- Bleeding from nose/eyes/skin hemorrhages
- Sudden appetite loss in > 20% of group

**When triggered:** Full-screen alert with mandatory DAFF reporting prompt, farm quarantine checklist, and contact numbers:
- DAFF Animal Health Emergency: 012 319 7000
- DALRRD State Vet (provincial)
- Nearest government veterinarian

---

## Production System Types

| System | Description |
|---|---|
| **Farrow-to-Finish** | Full cycle from breeding to slaughter weight |
| **Farrow-to-Wean** | Produce weaned piglets for sale |
| **Weaner Production** | Purchase weaners, grow to grower stage |
| **Finisher Only** | Purchase growers, finish to slaughter weight |
| **Village/Backyard** | Low-input extensive system |

---

## Breeds Catalogue

| Category | Breeds |
|---|---|
| Commercial | Large White, Landrace, Duroc, Pietrain |
| Indigenous | African/Chinese local breeds, Vietnamese Potbelly |
| Crosses | F1 (LW × Landrace), Terminal cross (× Duroc) |

---

## Pig Production Stages

```
Gilt → Breeding (Service) → Gestation (114 days) → Farrowing → Piglets (Suckling)
    → Weaning (21–28 days) → Weaners → Growers (25–60 kg) → Finishers (60+ kg) → Slaughter
```

The app tracks each pig through these stages with automatic status changes based on events logged.

---

## Sow Management

### 2.1 Sow Registration Fields

| Field | Type | Notes |
|---|---|---|
| `sow_tag` | String | Ear tag number |
| `breed` | Enum | |
| `parity` | Int | How many times she has farrowed |
| `date_of_birth` | Date | |
| `gilts_status` | Enum | `Gilt` (never farrowed) / `Sow` |
| `current_stage` | Enum | `Dry` / `Gestation` / `Lactating` / `Weaned` |
| `days_to_service` | Int | Auto-calculated |
| `total_pigs_born` | Int | Lifetime production |
| `total_pigs_weaned` | Int | Lifetime production |
| `backfat_mm` | Double | Body condition indicator (P2 point) |
| `wean_to_service_days` | Int | Days from weaning to next mating |

### 2.2 Sow Reproductive Cycle

```
Farrowing → Suckling (21–28 days) → Weaning → Estrus (3–5 days after weaning) 
→ Service → Gestation (114 days) → Farrowing
```

**Key interval targets:**
- Wean-to-service interval: < 7 days
- Services per conception: < 1.5
- Farrowing rate: > 90%

### 2.3 Service/Mating Records

| Field | Notes |
|---|---|
| `service_date` | First service date |
| `second_service_date` | Repeat service 12–24h later |
| `boar_id` or `ai_dose_id` | Natural or AI |
| `service_method` | `Natural` / `AI` |
| `notes` | |
| `expected_farrowing_date` | Auto-calculated: service date + 114 days |

### 2.4 Pregnancy Confirmation

- Ultrasound scan date and result (30 days post-service)
- If "not pregnant" → back to service queue
- If confirmed pregnant → track gestation progress
- Move sow to farrowing crate 5–7 days before expected farrowing date

---

## Farrowing Records

This is the most critical event in the pig production cycle.

### 3.1 Farrowing Event

| Field | Type | Notes |
|---|---|---|
| `sow_id` | String | Dam |
| `farrowing_date` | Date | |
| `farrowing_ease` | Enum | Normal / Assisted / Difficult |
| `total_born` | Int | Including mummies |
| `born_alive` | Int | |
| `born_dead` | Int | Stillbirths |
| `mummified` | Int | |
| `average_birth_weight_kg` | Double | Target: > 1.3 kg |
| `piglets_cross_fostered` | Int | Moved to/from other sows |
| `sow_condition` | Enum | Good / Thin / Mastitis / MMA |
| `nurse_sow_used` | Boolean | |
| `notes` | String | |

### 3.2 MMA Syndrome Alert

**MMA (Mastitis-Metritis-Agalactia)** is a critical post-farrowing condition:
- Signs: fever > 39.5°C, reduced milk, piglets crying/wasting
- Alert triggered: sow temperature logged > 39.5°C within 48h post-farrowing
- App logs treatment protocol and monitors recovery

---

## Litter Management

### 4.1 Per-Litter Records

- Litter tag/batch number
- Individual piglet tags (if ear-notched or tagged)
- Daily weight checks (first 7 days — mortality risk period)
- Pre-weaning mortality tracking with cause (crushing, starvation, chilling, disease)
- Iron injection records (3 days old)
- Teeth clipping records
- Tail docking records (if practiced)
- Castration records (males, if market requires)

### 4.2 Weaning Record

| Field | Notes |
|---|---|
| `litter_id` | |
| `weaning_date` | |
| `weaning_age_days` | Target: 21–28 days |
| `number_weaned` | Alive at weaning |
| `average_weaning_weight_kg` | Target: > 5.5 kg at 21 days |
| `pre_weaning_mortality` | born alive - number weaned |
| `pre_weaning_mortality_pct` | calculated |

---

## Grow-Out Phase (Weaners → Growers → Finishers)

Pigs in grow-out are managed as **batches** (groups), not individually in most systems.

### 5.1 Batch Record

| Field | Notes |
|---|---|
| `batch_id` | Auto-generated batch reference |
| `entry_date` | When batch entered this phase |
| `entry_count` | Number of pigs |
| `entry_weight_avg_kg` | Average entry weight |
| `feed_type` | Diet formulation |
| `pen_id` | Physical location |

### 5.2 Batch Events

- **Weekly weighing** — record average batch weight
- **Mortality** — count and cause per week
- **Feed consumption** — daily/weekly totals
- **Disease treatments** — batch medication events
- **Slaughter/sale** — exit event with weights and prices

### 5.3 Grow-Out KPIs

| KPI | Formula | Target |
|---|---|---|
| ADG (Average Daily Gain) | (exit weight - entry weight) / days | > 750 g/day (commercial) |
| FCR (Feed Conversion Ratio) | feed consumed / weight gained | < 2.8:1 |
| Mortality Rate | died / entered × 100 | < 3% |
| Days to Market | days from weaning to slaughter | 140–160 days |
| Slaughter Weight | live weight at slaughter | 95–110 kg |
| Backfat P2 | mm at P2 point | < 12 mm |

---

## Key Pig KPIs (Whole Farm Level)

| KPI | Formula | Target |
|---|---|---|
| PSY (Pigs per Sow per Year) | (pigs weaned per litter × farrowings per year) | > 24 pigs |
| Farrowing Rate | sows farrowed / sows served × 100 | > 88% |
| Litter Size Born Alive | average across all litters | > 11 |
| Pre-weaning Mortality | % | < 12% |
| Wean-to-Service Interval | days | < 7 days |
| NPD (Non-Productive Days) | days per sow per year not pregnant or lactating | < 30 days |

---

## Disease Management & Biosecurity Alerts

### Critical Diseases

| Disease | Alert Level | Action |
|---|---|---|
| **African Swine Fever (ASF)** | 🔴 EMERGENCY | Immediate isolation, notify authorities — **notifiable disease** |
| **Foot and Mouth Disease** | 🔴 EMERGENCY | Herd lockdown — **notifiable disease** |
| **Porcine Reproductive & Respiratory Syndrome (PRRS)** | 🔴 HIGH | Test, vaccinate, biosecurity review |
| **Classical Swine Fever (CSF)** | 🔴 HIGH | Notifiable, quarantine |
| **Swine Influenza** | 🟡 MEDIUM | Treatment, monitor biosecurity |
| **Porcine Circovirus (PCV2)** | 🟡 MEDIUM | Vaccination, reduce stressors |
| **E. coli Scours** | 🟡 MEDIUM | Oral rehydration, antibiotic treatment |
| **Enzootic Pneumonia** | 🟡 MEDIUM | Reduce ammonia, ventilation check |

### Biosecurity Checklist (App Feature)

- Visitor log (all-in-all-out strict)
- Vehicle disinfection records
- Feed source tracking
- Mortality disposal records (rendering, burial log)
- Pest control records (rodent bait stations)
- Farm perimeter fence inspection log

---

## Vaccination Schedule Template

| Vaccine | Target | Timing |
|---|---|---|
| CSF (where endemic) | All pigs | Per national schedule |
| Mycoplasma hyopneumoniae | Piglets | 3 weeks + 5 weeks |
| PCV2 | Piglets | 3 weeks |
| E. coli | Sows | 5 weeks pre-farrowing (× 2) |
| PRRS | All breeding stock | Per veterinary protocol |
| Erysipelas | Sows/Gilts | 3 weeks pre-farrowing |
| Parvo/PPV | Gilts | Before first service |

---

## Screen Design

```
Pig Module Dashboard
├── Sow board: breeding / gestation / farrowing / lactating / weaned counts
├── Farrowing due list (next 14 days)
├── Sows to service (weaned > 5 days ago)
├── Batch grow-out progress (FCR trend, ADG chart)
└── 🚨 ASF/disease alert status

Sow Module
  ├── Sow List → breeding status cards
  └── Sow Profile: reproductive history, parity, PSY contribution

Farrowing
  └── Log farrowing event → litter details → individual piglet tracking

Grow-Out
  ├── Batch List
  ├── Batch Detail: weight trend, FCR chart, mortality log
  └── Slaughter Planning: pigs near market weight
```
