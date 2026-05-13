# Cattle Management Design — South Africa

## Overview

Cattle are South Africa's most economically significant livestock species — 13.8 million head, contributing R30+ billion annually to the agricultural economy. They must be managed as **two fundamentally distinct enterprises** — Beef and Dairy — even when on the same farm. A Bonsmara stud farmer requires completely different KPIs, screens, and alerts than a Holstein dairy farmer in KZN.

**South African Beef Industry Context:**
- Bonsmara (developed at Mara Research Station, 1937) dominates commercial beef — accounts for ~35% of all SA beef cattle registrations
- Nguni is the most numerically significant indigenous breed — well adapted to harsh conditions, tick-resistant, critical for communal and emerging farmers
- Afrikaner, Drakensberger, Tuli are important indigenous breeds for harsh environments
- Feedlots concentrated in North West, Limpopo, and Free State provinces
- Key auction houses: NTK (Limpopo), BKB (E. Cape/W. Cape), Agri-Auction (Gauteng)
- Beef price benchmark: R67–72/kg A3 carcass (2025/2026)

**South African Dairy Industry Context:**
- ~500 000 milking cows; concentrated in KZN, Western Cape, Free State
- Holstein-Friesian dominates (60%+); Jersey important for butter fat
- Raw milk price: R5.80–7.20/litre (cooperative rate, 2025/2026)
- Key buyers: Clover, Parmalat, Lancewood, Pioneer Foods

---

## Breeds Catalogue — SA Priority

| Category | SA-Primary Breeds | Notes |
|---|---|---|
| **Beef — Indigenous** | Bonsmara, Nguni, Afrikaner, Drakensberger, Tuli, Boran | SA-developed; hardy, tick-resistant |
| **Beef — Exotic** | Simmental, Brahman, Hereford, Angus, Charolais | Crossbreeding common |
| **Dairy** | Holstein-Friesian, Jersey, Ayrshire, Guernsey | Holstein dominates |
| **Dual-Purpose** | Dexler, Shorthorn, Fleckvieh | Smaller operations |
| **Draft/Indigenous** | Zebu, Tswana | Communal farming |

**SA Studbook:** Bonsmara, Nguni, Afrikaner, Drakensberger, Tuli all have active SA Studbook programmes. Performance recording through SA Studbook is mandatory for stud breeders.

---

## 1. Beef Cattle Management

### 1.1 Animal Registration (Beef-Specific Fields)

| Field | Type | Notes |
|---|---|---|
| `tagNumber` | String | Official ear tag — must comply with Animal ID Act 6/2002 |
| `rfidNumber` | String? | ISO 11784/11785 RFID; linked to RMIS from Nov 2025 |
| `brandNumber` | String | Fire brand or freeze brand — legally required for cattle in SA |
| `brandPosition` | String | e.g., "Left rib, T7" — as per brand registration |
| `earmarkDesc` | String? | Notarial earmark description — Animal ID Act requirement |
| `studBookNumber` | String? | SA Studbook registration (stud animals) |
| `rmisAnimalId` | String? | RMIS national traceability ID |
| `breed` | Enum | From SA breed catalogue |
| `frameScore` | Int (1–9) | Body frame size |
| `purpose` | Enum | `Breeding` / `Feedlot` / `Pasture` / `Stud` |
| `targetWeightKg` | Double | Market/slaughter target |
| `birthWeightKg` | Double | Recorded at birth |
| `weaningWeightKg` | Double | 205-day adjusted weaning weight |
| `yearlingWeightKg` | Double | 365-day adjusted weight |
| `carcassGrade` | String? | SA SAMEX grade if slaughtered |
| `feedlotEntryDate` | Date? | Feedlot entry date |
| `feedlotEntryWeightKg` | Double? | |
| `fmdZone` | FmdZoneEnum | `ProtectionZone` / `SurveillanceZone` / `FreeZone` |
| `brucellaTested` | Boolean | Statutory for herd sales |
| `brucellaTestDate` | Date? | |

### 1.2 Key Beef KPIs — SA Benchmarks

| KPI | Formula | SA Benchmark |
|---|---|---|
| Average Daily Gain (ADG) | (current_weight - entry_weight) / days | > 1.2 kg/day (feedlot); > 0.5 kg/day (veld) |
| Feed Conversion Ratio (FCR) | feed_consumed_kg / weight_gained_kg | < 7:1 (feedlot) |
| Calf Crop % | calves weaned / cows exposed × 100 | > 85% (commercial); > 75% (veld) |
| 205-day Weaning Weight | adjusted weaning weight | Bonsmara: 205 kg; Nguni: 165 kg |
| Conception Rate | pregnant / exposed × 100 | > 90% |
| Days to Market | days from weaning to slaughter weight | < 300 days (feedlot) |
| Dressing % | carcass_weight / live_weight × 100 | > 56% (commercial); Nguni > 53% |

### 1.3 Beef-Specific Events

- **Branding** — brand type (fire/freeze), date, body position — legally required; photo mandatory
- **Earmarking** — notarial description recorded; photo
- **Castration** — date, method (surgical/band/chemical), age
- **Dehorning** — date, method, healing notes; welfare record
- **Weaning** — date, weaning weight (adjust to 205-day), transfer to weaner group
- **Feedlot entry/exit** — weights, condition score, ADG calculation, destination
- **RMIS movement registration** — auto-submit to RMIS API when animal moves between farms

### 1.4 SA Disease Alerts (Beef)

| Disease | SA Status | Alert Action |
|---|---|---|
| **Foot and Mouth Disease (FMD)** | Notifiable — endemic in border zones | **Quarantine herd; report to DAFF immediately (012 319 7000)** |
| **Lumpy Skin Disease** | Emerging; 2023 KZN outbreak | Vaccinate; restrict movement; notify vet |
| **Bovine Respiratory Disease (BRD)** | Feedlot risk | Isolate; treat; monitor pen |
| **Tick-borne: Redwater (Babesiosis)** | Endemic in bushveld zones | Treat; review dipping schedule |
| **Tick-borne: Anaplasmosis (Galgesiekte)** | Endemic; older animals at risk | Blood smear; treat |
| **Tick-borne: East Coast Fever** | Mpumalanga/KZN border risk | **Notifiable; contact state vet** |
| **Blackleg/Black Quarter** | Clostridial; vaccinate-preventable | Vaccination review; casualty record |
| **Brucellosis** | Statutory testing for sales | Testing records; herd blood test |

### 1.5 SA Beef Vaccination Schedule (Pre-loaded Template)

| Vaccine | Frequency | Stage | SA Notes |
|---|---|---|---|
| Clostridial (7-in-1) | Annual + booster at weaning | All ages | Standard SA requirement |
| FMD | Bi-annual | All cattle in FMD zones | Compulsory in Limpopo/Mpumalanga border |
| Lumpy Skin Disease (LSD) | Annual | All cattle | Priority in KZN, Eastern Cape |
| Brucellosis (RB51/S19) | Once | Heifers 4–8 months | Government scheme; batch record mandatory |
| BVD / IBR | Annual | Breeding herd | Important for AI programmes |
| Tick Vaccine (Bayovac) | Per protocol | Endemic tick areas | Supplement dipping programme |

---

## 2. Dairy Cattle Management

### 2.1 SA Dairy Context

South Africa has ~500 000 milking cows. Commercial dairy is highly concentrated — top 2 000 producers supply ~85% of milk. Emerging dairy farmers are a growing government-supported segment (CASP and REDS programmes).

**SA Milk Payment System (MPS):** Milk is paid based on fat % and protein % — not just volume. The MPS score determines the farmer's milk price per litre. App must track fat and protein % and calculate estimated MPS score.

### 2.2 Dairy-Specific Registration Fields

| Field | Type | Notes |
|---|---|---|
| `lactationNumber` | Int | Current parity (Lactation 1 = first calver) |
| `calvingDate` | Date | Most recent calving |
| `dryOffDate` | Date | When dried off |
| `expectedCalvingDate` | Date | Next calving prediction |
| `day305MilkYieldKg` | Double | Standard 305-day lactation yield |
| `peakMilkYieldLitres` | Double | Highest recorded daily yield |
| `peakYieldDay` | Int | DIM (Day In Milk) at peak |
| `somaticCellCountLast` | Int | Most recent SCC (cells/mL) |
| `milkingSystem` | Enum | `Hand` / `Bucket` / `Pipeline` / `Parlour` / `Rotary` |

### 2.3 SA Dairy KPIs

| KPI | Formula | SA Commercial Target |
|---|---|---|
| Litres/cow/day | total yield / milking herd | > 22L (Holstein); > 14L (Jersey) |
| 305-day yield | cumulative lactation | > 8 000L (Holstein commercial) |
| Somatic Cell Count | direct reading | < 200 000 cells/mL (SANS standard) |
| Calving Interval | days between consecutive calvings | < 365 days |
| Conception Rate (AI) | pregnancies / inseminations | > 55% (fresh semen) |
| In-Calf Rate | % pregnant by 100 DIM | > 70% |
| Fat % | per session test | Holstein: 3.6–4.0% |
| Protein % | per session test | Holstein: 3.0–3.4% |

**SANS 1315 Milk Quality Standard:**
- Grade A milk: SCC < 400 000; bacteria < 100 000/mL
- App alerts when SCC approaches grade boundary

### 2.4 Mastitis Management

- Quarter tracking (LF / RF / LH / RH)
- California Mastitis Test (CMT) score (0 / + / ++ / +++)
- Treatment protocol log with **withdrawal period** tracking
- Milk withholding: milk from treated quarters **must not** enter the bulk tank during withdrawal
- Alert: "WITHDRAWAL ACTIVE — do not add to bulk tank until [date]"
- Chronic cow flag: SCC > 200 000 for 3+ consecutive monthly recordings → cull recommendation

---

## 3. Shared Cattle Features

### 3.1 Body Condition Score (BCS)

- Scale: 1 (emaciated) to 9 (obese) — USDA standard
- Log BCS at key lifecycle events: calving, dry-off, mid-gestation, sale
- SA target BCS at calving: 3.5 (beef), 3.0–3.5 (dairy)
- **Alert:** BCS drops > 1.0 unit in 30 days → nutrition investigation required

### 3.2 SA-Specific Parasite Control

**Tick Management (critical in SA bushveld, coastal, and lowveld zones):**
- Dipping schedule: communal dip register (legally required in many provinces)
- Spray / pour-on / injectable / acaricide ear tags — record product, AI, withdrawal period
- Tick species mapping: Boophilus (redwater risk), Amblyomma (ECF/heartwater risk), Hyalomma (sweating sickness)
- Alert: missed dipping event (statutory dipping requirements under Animal Diseases Act)

**FWPV (Footbath) for foot problems:**
- Zinc sulfate 10% footbath records
- Lameness scoring per animal

### 3.3 Movement Permits & RMIS

Every cattle movement between farms, to abattoir, or to auction requires:
1. **RMIS registration** (mandatory from November 2025) — app submits to RMIS API
2. **B313 Movement Permit** — pre-fill and generate PDF from animal records
3. **FMD Zone compliance check** — block movement from protection zone without veterinary health certificate

### 3.4 Livestock Theft Prevention

- Photo documentation: brand (close-up), both ears (earmark), RFID chip position
- GPS timestamp on all photo evidence
- SAPS stock theft report template: pre-fill with farm details, animal count, brand/tag description
- Emergency contacts: Provincial Stock Theft Units quick-dial
  - Eastern Cape: 046 645 9760
  - Free State: 051 507 3011
  - KZN: 033 355 8600
  - Limpopo: 015 290 6300
  - North West: 018 381 9300

### 3.5 Cattle Screen Flows

```
Cattle List → Filter: All / Beef / Dairy / Breeding / Feedlot / Stud
  └── Animal Card: tag, breed, sex, age, weight, BCS, health status chip
      └── Animal Profile
          ├── Overview: photo, tag, brand, RFID, FMD zone badge, BCS
          ├── Compliance: brand photo, earmark, RMIS ID, studbook number
          ├── Health: vaccinations, treatments, tick dipping, withdrawal periods
          ├── Reproduction: mating, pregnancy checks, calving records, offspring
          ├── Weight: growth chart with SA breed benchmark overlay, ADG trend
          ├── Milk (dairy only): lactation curve, SCC trend, MPS score
          ├── Financial: purchase cost, estimated current value, sale record
          └── Events: full chronological timeline
```

### 3.6 Cattle Dashboard Widgets

- Total herd: M/F/Calves/Weaners breakdown
- FMD zone compliance status badge
- Cows due for calving (next 30 days)
- Overdue vaccinations count
- Animals in withdrawal period (dairy: milk withholding alert)
- Current herd SCC average (dairy)
- RMIS sync status (pending submissions count)
- Dipping schedule compliance (days since last dip vs required interval)

