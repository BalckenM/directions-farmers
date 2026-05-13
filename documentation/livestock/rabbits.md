# Rabbit Management Design

## Overview

Rabbit farming is a high-return, low-input enterprise well-suited to smallholder and peri-urban farmers. Rabbits reproduce rapidly (up to 8 litters per year), are efficient feed converters, produce quality meat and fiber, and require minimal space. The management system must handle both **colony housing** and **cage housing** systems.

---

## Production Systems

| System | Description |
|---|---|
| **Cage (Individual)** | Does in individual cages — standard commercial practice |
| **Colony** | Group housing in a communal run — backyard/alternative system |
| **Outdoor Enclosure** | Semi-intensive with pasture access |

---

## South African Rabbit Farming Context

Rabbit farming in South Africa is a growing **food security and income-generation opportunity**, particularly for:
- Peri-urban and township households (backyard production)
- Smallholder farmers on land reform farms
- Women-led farming cooperatives (SEDA and NARYSEC programme beneficiaries)

**SA Rabbit Industry:**
- No official statistics but an estimated 250 000+ rabbits farmed commercially and semi-commercially
- Growing demand for rabbit meat in health-conscious urban markets (Cape Town, Johannesburg)
- Rabbit leather and fiber (Angora rabbit) remain niche
- **SA Rabbit Breeders Association (SARBA)** — promotes breed standards and best practices

**SA-Specific Challenges:**
- **Rabbit Haemorrhagic Disease (RHD/RHDV2)** — highly contagious viral disease; kills quickly; biosecurity critical
- **Coccidiosis** — most common cause of rabbit mortality in SA; triggered by stress, overcrowding, contaminated feed/water
- **Fly strike** — common in humid coastal areas; especially breech area
- **Heat stress** — SA summer temperatures can be lethal to rabbits (> 35°C); alert system for temperature thresholds

**Market channels in SA:**
- Butchery direct sales (Cape Town, Johannesburg specialty markets)
- Online marketplace (Bidorbuy, Facebook Marketplace)
- Restaurant supply (hospitality industry)
- No major formal abattoir chain specifically for rabbits — most processed on-farm or at small abattoirs

---

## Breeds Catalogue

| Category | Breeds |
|---|---|
| Meat | New Zealand White, Californian, Flemish Giant, Rex, Champagne d'Argent |
| Fiber (Angora) | English Angora, French Angora, Giant Angora, Satin Angora |
| Dual (Meat + Fur) | Rex (plush fur + meat), Satin |
| Pet/Show | Holland Lop, Dutch, Mini Rex, Lionhead |
| Indigenous | African bush rabbit variants |

---

## Rabbit-Specific Registration Fields

| Field | Type | Notes |
|---|---|---|
| `cage_id` | String | Physical cage or colony location |
| `breed` | Enum | From breeds catalogue |
| `purpose` | Enum | `Meat` / `Fiber` / `Dual` / `Breeding` |
| `tattoo_id` | String | Left ear = tattoo ID (standard) |
| `color_pattern` | String | Fur description |
| `total_litters_produced` | Int | Lifetime count |
| `total_kits_born` | Int | Lifetime production |
| `total_kits_weaned` | Int | Lifetime |
| `average_litter_size` | Double | Calculated from history |
| `last_kindling_date` | Date | Most recent kindle |
| `fiber_clip_weight_g` | Double | Most recent Angora clip |
| `fiber_clip_date` | Date | For Angora breeds |

---

## 1. Doe (Female) Reproductive Management

### 1.1 Mating Records

| Field | Notes |
|---|---|
| `mating_date` | Doe taken to buck's cage (rabbits cannot be left together) |
| `buck_id` | Sire |
| `mating_confirmed` | Boolean — observed tie/fall-off |
| `second_mating_date` | 8–12 hours after first (increases litter size) |
| `expected_kindling_date` | Calculated: mating date + 31 days |
| `pregnancy_check_date` | Palpation check at day 12–14 |
| `pregnancy_result` | Confirmed / Not Pregnant / Uncertain |

### 1.2 Nesting Box Records

- Provide nesting box at day 27–28 of gestation
- Nest box check date
- Nest quality: Good / Pulled hair / No nest (needs assistance)
- Doe condition pre-kindling

### 1.3 Kindling (Birth) Records

| Field | Notes |
|---|---|
| `doe_id` | |
| `buck_id` | |
| `kindling_date` | |
| `kits_born_alive` | |
| `kits_born_dead` | |
| `average_kit_weight_g` | Target: > 50 g |
| `doe_behavior` | Normal / Neglecting kits / Eating kits |
| `fostering_required` | Transfer kits to surrogate doe |
| `notes` | |

### 1.4 Litter Management

- **Day 1–3:** Count kits daily, remove dead, ensure warmth
- **Day 10:** Eyes open — note litter size
- **Day 14:** First venture from nest box
- **Day 21:** Start nibbling solid food
- **Day 28–35:** Weaning — separate kits from doe
- **Day 35–42:** Weaning (some systems)

Record:
- Litter ID
- Daily survival count
- Weaning date
- Number weaned
- Average weaning weight (target: > 500 g at 28 days)

### 1.5 Doe Performance Metrics

| KPI | Formula | Target |
|---|---|---|
| Litters per year | farrowings per year | 6–8 litters |
| Kits born alive / litter | average born alive | > 8 kits |
| Pre-weaning mortality | (born alive - weaned) / born alive × 100 | < 15% |
| Kits weaned / litter | average weaned | > 7 kits |
| Weaning weight | average kit weight | > 500 g (28 days) |
| Doe productivity index | (kits weaned per year / feed consumed) | Higher = better |
| Interval breeding | Days from weaning to remating | < 14 days |

---

## 2. Grow-Out (Fryers/Weaners to Market)

| Stage | Age | Weight |
|---|---|---|
| Weaning | 28–35 days | 500–700 g |
| Young fryer | 8 weeks | 1.2–1.5 kg |
| Market weight | 10–12 weeks | 2.0–2.5 kg (NZW) |

**Fryer batch management:**
- Batch ID (litter ID + weaning date)
- Entry weight, entry count
- Weekly weighing
- Feed type (pellets: 16–18% protein)
- Daily feed consumption per batch
- Mortality with cause
- Market weight and sale date

**Fryer KPIs:**

| KPI | Target |
|---|---|
| ADG (weaning to market) | > 30 g/day |
| FCR | < 3.5:1 |
| Mortality (post-weaning) | < 5% |
| Days to market weight | 70–90 days from weaning |

---

## 3. Angora Fiber Management

| Field | Notes |
|---|---|
| `clip_date` | Shearing every 90 days (4× per year) |
| `clip_weight_g` | Target: 300–500 g/animal/clip |
| `fiber_grade` | 1 (finest) – 5 |
| `contamination` | Presence of hay, feces, mats |
| `price_per_kg` | |
| `notes` | |

**Annual fiber yield target:** 1,000–1,500 g per animal (English Angora).

---

## 4. Disease Management

### 4.1 Critical Diseases

| Disease | Alert | Action |
|---|---|---|
| **Rabbit Hemorrhagic Disease (RHD / RHDV2)** | 🔴 EMERGENCY | **Notifiable**, vaccine if available |
| **Myxomatosis** | 🔴 HIGH | No treatment — cull and biosecurity |
| **Pasteurellosis (Snuffles)** | 🟡 MEDIUM | Antibiotic treatment; chronic carriers cull |
| **Coccidiosis** | 🟡 MEDIUM | Medicated water, hygiene |
| **Encephalitozoon cuniculi (E. cuniculi)** | 🟡 MEDIUM | Neurological — treatment with fenbendazole |
| **GI Stasis** | 🟡 MEDIUM | Gut motility drugs, fluids |
| **Sore Hocks** | 🟢 LOW | Bedding improvement, treatment |

### 4.2 Vaccination Schedule

| Vaccine | Timing |
|---|---|
| RHDV1 + RHDV2 | Annual (where available) |
| Myxomatosis | Annual (where available) |

---

## 5. Cage & Colony Hygiene Records

- Cage cleaning date and method per cage ID
- Disinfectant product used
- Litter/bedding change records
- Fly control measures
- Water line flushing records

---

## 6. Screen Design

```
Rabbit Module Dashboard
├── Total does / bucks / kits / fryers
├── Does due to kindle (next 14 days)
├── Does ready to remate (weaned > 7 days)
├── Fryer batch FCR trend
└── Disease alerts

Doe List → Status cards (gestating / lactating / available to mate)
  └── Doe Profile
      ├── Reproductive history: litter records, kits born/weaned
      ├── KPI card: litters/year, kits weaned/year
      ├── Health events
      └── Fiber records (Angora only)

Fryer Batches
  ├── Batch list with age, count, ADG
  └── Batch detail: weight chart, FCR, mortality, expected market date
```
