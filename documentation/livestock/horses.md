# Horse & Equine Management Design

## Overview

Horses require some of the most detailed individual animal records of any livestock species. Unlike cattle or poultry, each horse has a long working life (20–30 years), a unique identity, and requires a comprehensive portfolio of:
- Regular farriery (hoof care every 6–8 weeks)
- Dental care (floating teeth every 1–2 years)
- Structured deworming programs
- Training logs and competition history
- Breeding records (stallion/mare management)

The app must serve both **working horses** (farm draft, riding) and **performance horses** (racing, showjumping, endurance, polo).

---

## South African Horse Industry Context

South Africa has approximately **120 000 horses** across four distinct sectors:

| Sector | Key Details |
|---|---|
| **Racing** | SA is among the top 10 racing nations globally; Kenilworth, Turffontein, Greyville are main tracks; Thoroughbred Society of SA (TBSA) administers studbook |
| **Sport (Showjumping, Dressage, Endurance)** | SA Equestrian Federation (SAEF) governs; competitive sport horses need detailed health, competition, and vaccination records |
| **Boerperd (Working/Farm)** | SA's indigenous breed; Boerperd Breeders Society; widely used on farms in Free State, Limpopo, North West for mustering, rounding up cattle |
| **Donkeys** | ~120 000 donkeys; critical for smallholder transport and draught power in Limpopo, Eastern Cape, North West; SPCA welfare programmes |

**SA-Specific Priorities:**
- **African Horse Sickness (AHS)** — endemic in SA; notifiable disease; **annual vaccination mandatory in AHS-controlled areas**; SA is the only country where AHS vaccine is commercially available
- AHS zones: Infected zone (Limpopo, Mpumalanga, KZN coastal) and Protection/Surveillance zones
- AHS vaccination record is required for horse movement certificates
- **Equine Influenza:** Annual vaccination required for competition horses (SAEF rules)
- **Equine Herpesvirus (EHV-1, EHV-4):** Bi-annual vaccination recommended for performance horses

---

## Species & Types Covered

| Type | Primary Use |
|---|---|
| Thoroughbred | Racing |
| Warmblood (Hanoverian, KWPN, etc.) | Sport (dressage, showjumping) |
| Quarter Horse | Rodeo, ranch work, racing |
| Arabian | Endurance, racing, showing |
| Draft / Coldblood | Farm work, pulling |
| Pony (Shetland, Welsh, etc.) | Riding, children's sport |
| Miniature Horse | Companion, therapy |
| **Donkey** | Draft work, transport, companion |
| **Mule** | Draft work |
| **Zebra** | Conservation breeding |

---

## Horse-Specific Registration Fields

| Field | Type | Notes |
|---|---|---|
| `stable_name` | String | Barn name |
| `registered_name` | String | Studbook registered name |
| `studbook` | String | Jockey Club, SANEF, KWPN, etc. |
| `passport_number` | String | Equine passport/ID |
| `microchip_number` | String | 15-digit ISO microchip |
| `brand` | String | Freeze brand or hot brand |
| `color` | String | Bay, Grey, Chestnut, Black, Roan, Pinto |
| `markings` | String | White socks, blaze, star, etc. |
| `discipline` | Enum | Racing / Dressage / Showjumping / Endurance / Ranch / Draft / Companion |
| `height_hands` | Double | Measured in hands (hh) |
| `height_cm` | Double | |
| `weight_kg` | Double | Updated at each vet visit or weigh tape |
| `body_condition_score` | Int (1–9) | Henneke BCS scale |
| `workload_level` | Enum | `Idle` / `Light` / `Moderate` / `Heavy` / `Race Training` |
| `insurance_policy` | String | Policy number |
| `insurance_value` | Double | Insured value |

---

## 1. Farriery Records

Hoof health is critical — a lame horse cannot work. Every 6–8 weeks minimum.

| Field | Notes |
|---|---|
| `farrier_date` | |
| `farrier_name` | |
| `service_type` | `Trim only` / `Shoe front` / `Shoe all round` / `Reset` / `Remedial` |
| `shoe_type` | Steel / Aluminium / Barefoot / Specialist |
| `hoof_condition` | Normal / Cracked / Thrush / White Line Disease / Laminitis |
| `per_hoof_notes` | LF / RF / LH / RH condition |
| `next_due_date` | Auto-calculated: farrier_date + 6 weeks |
| `cost` | |

**App alert:** Notify 1 week before next farriery due date.

---

## 2. Dental Records

Horses develop sharp enamel points and hooks requiring regular floating (rasping) to prevent pain and weight loss.

| Field | Notes |
|---|---|
| `dental_date` | |
| `vet_or_dentist` | Practitioner name |
| `procedure` | Floating / Extraction / Wolf tooth removal / Check only |
| `condition_notes` | Sharp points, hooks, incisors, mouth grade |
| `sedation_used` | Boolean — sedation required |
| `next_due_date` | Auto-calculated: typically + 12 months (younger horses + 6 months) |

---

## 3. Deworming (Anthelmintic) Program

Horses require rotational deworming or fecal egg count (FEC)-based targeted treatment.

| Field | Notes |
|---|---|
| `treatment_date` | |
| `product` | Ivermectin / Moxidectin / Pyrantel / Fenbendazole |
| `active_ingredient` | For rotation tracking |
| `dosage` | Based on body weight |
| `body_weight_at_dosing_kg` | Underdosing causes resistance |
| `fec_result` | Fecal egg count pre-treatment (eggs per gram) |
| `fec_post_result` | 14 days post-treatment |
| `efficacy_pct` | Calculated |
| `next_due_date` | Based on season and resistance strategy |

**Resistance monitoring:** If FEC reduction < 95% after treatment → alert possible anthelmintic resistance.

---

## 4. Health Records

### 4.1 Standard Health Events (same as base Animal model)
- Vaccinations
- Veterinary visits
- Laboratory results
- Injuries and treatments

### 4.2 Equine-Specific Health Events

| Event Type | Key Fields |
|---|---|
| Colic episode | Type (gas/impaction/displacement), treatment, outcome |
| Laminitis | Severity score (Obel grade 1–4), trigger (diet/grass/illness) |
| Lameness | Grade (0–5 AAEP scale), limb affected, diagnosis |
| Eye ulcer/injury | Eye affected, treatment |
| Skin condition | Rain rot, ringworm, summer eczema |
| Respiratory | Heaves/RAO, bacterial, viral |

### 4.3 Vaccination Schedule (Horses)

| Vaccine | Frequency | Notes |
|---|---|---|
| Tetanus | Annual | Critical — all horses |
| African Horse Sickness (AHS) | Annual (endemic areas) | **Notifiable disease** |
| Equine Influenza | 6-monthly (competition horses) | |
| Equine Herpesvirus (EHV 1+4) | 6-monthly | Especially pregnant mares |
| Strangles | Annual (endemic areas) | Intranasal vaccine |
| Equine Viral Arteritis (EVA) | As required | Especially breeding stallions |
| Rabies | Annual (endemic areas) | |

---

## 5. Breeding Records

### 5.1 Mare Records

| Field | Notes |
|---|---|
| `heat_date` | Date of observed estrus |
| `breeding_date` | Service date |
| `breeding_method` | `Natural Cover` / `AI Fresh` / `AI Frozen` / `ET (Embryo Transfer)` |
| `stallion_id` | On-farm stallion or external |
| `stud_name` | External stud farm name |
| `ai_dose_id` | Semen dose batch number |
| `pregnancy_check_date` | Ultrasound at 14–16 days post-service |
| `pregnancy_result` | Positive / Negative / Twin (reduce) |
| `expected_foaling_date` | Calculated: service date + 340 days |
| `foaling_date` | Actual |
| `foal_sex` | |
| `foal_weight_kg` | |
| `foal_color` | |
| `placenta_passed_time` | Critical — retained placenta = emergency |

### 5.2 Foal Record

- Born from dam + sire link
- Colostrum intake within 2 hours — critical immune transfer
- Passive transfer test (IgG) at 18–24 hours
- Foal heat check (dam's first heat 7–10 days post-foaling)
- Growth measurements: weight, height
- Weaning at 4–6 months

### 5.3 Stallion Records

- Breeding soundness examination (BSE) records
- Semen collection logs (if AI or commercial)
- Motility, morphology, concentration results
- Breeding season records: mares covered, conception rate

---

## 6. Training & Competition Records

### 6.1 Training Log

| Field | Notes |
|---|---|
| `training_date` | |
| `duration_minutes` | |
| `exercise_type` | Lunge / Ride / Jump / Trail / Rest day |
| `intensity` | Walk / Trot / Canter / Gallop / Competition simulation |
| `trainer_name` | |
| `notes` | Notes on performance, attitude, fitness |

### 6.2 Competition Record

| Field | Notes |
|---|---|
| `event_name` | Show/race name |
| `event_date` | |
| `event_type` | Racing / Dressage / Showjumping / Endurance / Polo |
| `class_entered` | |
| `placing` | 1st / 2nd / 3rd / etc. |
| `score_or_time` | As applicable |
| `prize_money` | |
| `notes` | |

---

## 7. Equipment & Tack Records

- Saddle fit records (horses' backs change shape with fitness)
- Blanket/rug inventory per horse
- Equipment service/replacement dates

---

## 8. Screen Design

```
Equine Module Dashboard
├── Total horses (by type/discipline)
├── Farriery overdue alerts
├── Dental overdue alerts
├── Vaccination due (next 30 days)
├── Mares: foaling due / pregnancy status
└── Competition schedule (next 30 days)

Horse List → Filter by: All / Horses / Donkeys / Stallions / Mares / Geldings / Foals
  └── Horse Profile
      ├── Overview: photo, height, breed, discipline, insured value
      ├── Health: vaccination, treatments, dental, deworming
      ├── Farriery: hoof care history, shoe type, next due
      ├── Breeding: heat records, foaling history, foal list
      ├── Training: log, fitness level
      ├── Competition: results timeline
      └── Events timeline
```
