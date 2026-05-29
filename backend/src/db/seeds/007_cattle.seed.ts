import { sql } from "drizzle-orm";
import { db } from "../../config/database";

/**
 * Seed 007: cattle_animals and all related records.
 *
 * All data mirrors cattle_mock_data_source.dart exactly:
 *   18 animals (Nguni×6, Bonsmara×4, Holstein×5, Jersey×3)
 *   with weight, breeding, pregnancy, calving, milk, health,
 *   medication, vaccination, sale, feed, pasture, BCS and dipping records.
 *
 * Columns added by migration 0014 are populated where the Dart model
 * provides a value.  BeefSpecific / DairySpecific sub-objects are stored
 * as JSON in the `specific_data` column.
 */
const now = "2024-01-01 00:00:00";

export async function runCattleSeed(): Promise<void> {
  // ── Animals ──────────────────────────────────────────────────────────────
  const animals: Array<{
    id: string;
    tag_id: string;
    name: string;
    breed: string;
    sex: string;
    date_of_birth: string | null;
    status: string;
    notes: string | null;
    production_type: string | null;
    herd_id: string | null;
    current_weight_kg: number | null;
    target_weight_kg: number | null;
    body_condition_score: number | null;
    is_pregnant: boolean;
    expected_calving_date: string | null;
    last_calving_date: string | null;
    total_calves_raised: number;
    is_lactating: boolean;
    current_milk_litre_pd: number | null;
    lactation_number: number;
    brucella_tested: boolean;
    brucella_test_date: string | null;
    fmd_zone: string | null;
    registration_number: string | null;
    brand_number: string | null;
    brand_position: string | null;
    dam_id: string | null;
    specific_data: string | null;
  }> = [
    // ── Nguni ×6 ──────────────────────────────────────────────────────────
    {
      id: "CA001",
      tag_id: "CA001",
      name: "Thandi",
      breed: "Nguni",
      sex: "cow",
      date_of_birth: "2020-03-14",
      status: "active",
      notes: null,
      production_type: "beef",
      herd_id: "herd-nguni",
      current_weight_kg: null,
      target_weight_kg: null,
      body_condition_score: 3.5,
      is_pregnant: true,
      expected_calving_date: "2026-08-15",
      last_calving_date: "2025-08-20",
      total_calves_raised: 2,
      is_lactating: false,
      current_milk_litre_pd: null,
      lactation_number: 0,
      brucella_tested: true,
      brucella_test_date: "2025-04-10",
      fmd_zone: "free",
      registration_number: null,
      brand_number: null,
      brand_position: null,
      dam_id: null,
      specific_data: JSON.stringify({ averageDailyGainKg: 0.58 }),
    },
    {
      id: "CA002",
      tag_id: "CA002",
      name: "Sbu",
      breed: "Nguni",
      sex: "bull",
      date_of_birth: "2019-06-02",
      status: "active",
      notes: null,
      production_type: "beef",
      herd_id: "herd-nguni",
      current_weight_kg: 620,
      target_weight_kg: null,
      body_condition_score: 4.0,
      is_pregnant: false,
      expected_calving_date: null,
      last_calving_date: null,
      total_calves_raised: 0,
      is_lactating: false,
      current_milk_litre_pd: null,
      lactation_number: 0,
      brucella_tested: false,
      brucella_test_date: null,
      fmd_zone: "zone1",
      registration_number: "NGU-2019-002",
      brand_number: "SB22",
      brand_position: "left rib",
      dam_id: null,
      specific_data: null,
    },
    {
      id: "CA003",
      tag_id: "CA003",
      name: "Langa",
      breed: "Nguni",
      sex: "heifer",
      date_of_birth: "2023-09-11",
      status: "active",
      notes: null,
      production_type: "beef",
      herd_id: "herd-nguni",
      current_weight_kg: 280,
      target_weight_kg: null,
      body_condition_score: 3.0,
      is_pregnant: false,
      expected_calving_date: null,
      last_calving_date: null,
      total_calves_raised: 0,
      is_lactating: false,
      current_milk_litre_pd: null,
      lactation_number: 0,
      brucella_tested: true,
      brucella_test_date: "2026-01-15",
      fmd_zone: "free",
      registration_number: null,
      brand_number: null,
      brand_position: null,
      dam_id: null,
      specific_data: null,
    },
    {
      id: "CA004",
      tag_id: "CA004",
      name: "Nandi",
      breed: "Nguni",
      sex: "cow",
      date_of_birth: "2021-01-28",
      status: "active",
      notes: null,
      production_type: "beef",
      herd_id: "herd-nguni",
      current_weight_kg: null,
      target_weight_kg: null,
      body_condition_score: 3.5,
      is_pregnant: true,
      expected_calving_date: "2026-09-02",
      last_calving_date: "2025-09-05",
      total_calves_raised: 1,
      is_lactating: false,
      current_milk_litre_pd: null,
      lactation_number: 0,
      brucella_tested: false,
      brucella_test_date: null,
      fmd_zone: "free",
      registration_number: null,
      brand_number: null,
      brand_position: null,
      dam_id: null,
      specific_data: null,
    },
    {
      id: "CA005",
      tag_id: "CA005",
      name: "Mfan",
      breed: "Nguni",
      sex: "steer",
      date_of_birth: "2023-04-17",
      status: "active",
      notes: null,
      production_type: "beef",
      herd_id: "herd-nguni",
      current_weight_kg: 310,
      target_weight_kg: 420,
      body_condition_score: 3.5,
      is_pregnant: false,
      expected_calving_date: null,
      last_calving_date: null,
      total_calves_raised: 0,
      is_lactating: false,
      current_milk_litre_pd: null,
      lactation_number: 0,
      brucella_tested: false,
      brucella_test_date: null,
      fmd_zone: "free",
      registration_number: null,
      brand_number: null,
      brand_position: null,
      dam_id: null,
      specific_data: JSON.stringify({ averageDailyGainKg: 0.62 }),
    },
    {
      id: "CA006",
      tag_id: "CA006",
      name: "Busi",
      breed: "Nguni",
      sex: "calf_female",
      date_of_birth: "2026-02-10",
      status: "active",
      notes: null,
      production_type: "beef",
      herd_id: "herd-nguni",
      current_weight_kg: 78,
      target_weight_kg: null,
      body_condition_score: 3.0,
      is_pregnant: false,
      expected_calving_date: null,
      last_calving_date: null,
      total_calves_raised: 0,
      is_lactating: false,
      current_milk_litre_pd: null,
      lactation_number: 0,
      brucella_tested: false,
      brucella_test_date: null,
      fmd_zone: "free",
      registration_number: null,
      brand_number: null,
      brand_position: null,
      dam_id: "CA001",
      specific_data: null,
    },
    // ── Bonsmara ×4 ───────────────────────────────────────────────────────
    {
      id: "CA007",
      tag_id: "CA007",
      name: "Koos",
      breed: "Bonsmara",
      sex: "bull",
      date_of_birth: "2018-11-05",
      status: "active",
      notes: null,
      production_type: "beef",
      herd_id: "herd-bonsmara",
      current_weight_kg: 780,
      target_weight_kg: null,
      body_condition_score: 4.5,
      is_pregnant: false,
      expected_calving_date: null,
      last_calving_date: null,
      total_calves_raised: 0,
      is_lactating: false,
      current_milk_litre_pd: null,
      lactation_number: 0,
      brucella_tested: false,
      brucella_test_date: null,
      fmd_zone: "free",
      registration_number: "BNS-2018-007",
      brand_number: "KV07",
      brand_position: "right hip",
      dam_id: null,
      specific_data: JSON.stringify({
        averageDailyGainKg: 0.81,
        feedConversionRatio: 6.2,
      }),
    },
    {
      id: "CA008",
      tag_id: "CA008",
      name: "Petra",
      breed: "Bonsmara",
      sex: "cow",
      date_of_birth: "2019-07-22",
      status: "active",
      notes: null,
      production_type: "beef",
      herd_id: "herd-bonsmara",
      current_weight_kg: 490,
      target_weight_kg: null,
      body_condition_score: 3.5,
      is_pregnant: false,
      expected_calving_date: null,
      last_calving_date: "2025-06-12",
      total_calves_raised: 3,
      is_lactating: false,
      current_milk_litre_pd: null,
      lactation_number: 0,
      brucella_tested: true,
      brucella_test_date: "2025-04-10",
      fmd_zone: "free",
      registration_number: null,
      brand_number: null,
      brand_position: null,
      dam_id: null,
      specific_data: null,
    },
    {
      id: "CA009",
      tag_id: "CA009",
      name: "Steyn",
      breed: "Bonsmara",
      sex: "steer",
      date_of_birth: "2023-02-14",
      status: "active",
      notes: null,
      production_type: "beef",
      herd_id: "herd-bonsmara",
      current_weight_kg: 375,
      target_weight_kg: 480,
      body_condition_score: 4.0,
      is_pregnant: false,
      expected_calving_date: null,
      last_calving_date: null,
      total_calves_raised: 0,
      is_lactating: false,
      current_milk_litre_pd: null,
      lactation_number: 0,
      brucella_tested: false,
      brucella_test_date: null,
      fmd_zone: "free",
      registration_number: null,
      brand_number: null,
      brand_position: null,
      dam_id: null,
      specific_data: JSON.stringify({
        averageDailyGainKg: 0.78,
        feedlotPenId: "B1",
      }),
    },
    {
      id: "CA010",
      tag_id: "CA010",
      name: "Riaan",
      breed: "Bonsmara",
      sex: "heifer",
      date_of_birth: "2023-05-30",
      status: "active",
      notes: null,
      production_type: "beef",
      herd_id: "herd-bonsmara",
      current_weight_kg: 305,
      target_weight_kg: 380,
      body_condition_score: 3.5,
      is_pregnant: false,
      expected_calving_date: null,
      last_calving_date: null,
      total_calves_raised: 0,
      is_lactating: false,
      current_milk_litre_pd: null,
      lactation_number: 0,
      brucella_tested: false,
      brucella_test_date: null,
      fmd_zone: "free",
      registration_number: null,
      brand_number: null,
      brand_position: null,
      dam_id: null,
      specific_data: null,
    },
    // ── Holstein ×5 ───────────────────────────────────────────────────────
    {
      id: "CA011",
      tag_id: "CA011",
      name: "Daisy",
      breed: "Holstein",
      sex: "cow",
      date_of_birth: "2020-05-18",
      status: "active",
      notes: null,
      production_type: "dairy",
      herd_id: "herd-dairy",
      current_weight_kg: null,
      target_weight_kg: null,
      body_condition_score: 3.0,
      is_pregnant: false,
      expected_calving_date: null,
      last_calving_date: null,
      total_calves_raised: 0,
      is_lactating: true,
      current_milk_litre_pd: 28.0,
      lactation_number: 3,
      brucella_tested: true,
      brucella_test_date: "2026-01-20",
      fmd_zone: "free",
      registration_number: null,
      brand_number: null,
      brand_position: null,
      dam_id: null,
      specific_data: JSON.stringify({
        somaticCellCount: 180000,
        butterfatPct: 3.8,
        proteinPct: 3.2,
        milkingSchedule: "twice",
        totalMilkThisLactation: 4200,
        peakMilkLitrePd: 34.0,
      }),
    },
    {
      id: "CA012",
      tag_id: "CA012",
      name: "Flora",
      breed: "Holstein",
      sex: "cow",
      date_of_birth: "2018-08-03",
      status: "active",
      notes: null,
      production_type: "dairy",
      herd_id: "herd-dairy",
      current_weight_kg: null,
      target_weight_kg: null,
      body_condition_score: 3.5,
      is_pregnant: false,
      expected_calving_date: null,
      last_calving_date: null,
      total_calves_raised: 0,
      is_lactating: true,
      current_milk_litre_pd: 32.0,
      lactation_number: 5,
      brucella_tested: true,
      brucella_test_date: "2026-01-20",
      fmd_zone: "free",
      registration_number: null,
      brand_number: null,
      brand_position: null,
      dam_id: null,
      specific_data: JSON.stringify({
        somaticCellCount: 95000,
        butterfatPct: 3.9,
        proteinPct: 3.3,
        milkingSchedule: "twice",
        totalMilkThisLactation: 5800,
        peakMilkLitrePd: 38.0,
      }),
    },
    {
      id: "CA013",
      tag_id: "CA013",
      name: "Bella",
      breed: "Holstein",
      sex: "cow",
      date_of_birth: "2021-12-09",
      status: "active",
      notes: null,
      production_type: "dairy",
      herd_id: "herd-dairy",
      current_weight_kg: null,
      target_weight_kg: null,
      body_condition_score: 3.5,
      is_pregnant: true,
      expected_calving_date: "2026-10-20",
      last_calving_date: null,
      total_calves_raised: 0,
      is_lactating: false,
      current_milk_litre_pd: null,
      lactation_number: 2,
      brucella_tested: true,
      brucella_test_date: "2025-11-05",
      fmd_zone: "free",
      registration_number: null,
      brand_number: null,
      brand_position: null,
      dam_id: null,
      specific_data: null,
    },
    {
      id: "CA014",
      tag_id: "CA014",
      name: "Hanna",
      breed: "Holstein",
      sex: "cow",
      date_of_birth: "2019-04-25",
      status: "active",
      notes: "Elevated SCC — monitor closely",
      production_type: "dairy",
      herd_id: "herd-dairy",
      current_weight_kg: null,
      target_weight_kg: null,
      body_condition_score: 2.5,
      is_pregnant: false,
      expected_calving_date: null,
      last_calving_date: null,
      total_calves_raised: 0,
      is_lactating: true,
      current_milk_litre_pd: 25.0,
      lactation_number: 4,
      brucella_tested: false,
      brucella_test_date: null,
      fmd_zone: "free",
      registration_number: null,
      brand_number: null,
      brand_position: null,
      dam_id: null,
      specific_data: JSON.stringify({
        somaticCellCount: 250000,
        butterfatPct: 3.6,
        proteinPct: 3.1,
        milkingSchedule: "twice",
        totalMilkThisLactation: 3100,
        peakMilkLitrePd: 30.0,
      }),
    },
    {
      id: "CA015",
      tag_id: "CA015",
      name: "Tops",
      breed: "Holstein",
      sex: "bull",
      date_of_birth: "2021-02-01",
      status: "active",
      notes: null,
      production_type: "dairy",
      herd_id: "herd-dairy",
      current_weight_kg: 850,
      target_weight_kg: null,
      body_condition_score: 4.0,
      is_pregnant: false,
      expected_calving_date: null,
      last_calving_date: null,
      total_calves_raised: 0,
      is_lactating: false,
      current_milk_litre_pd: null,
      lactation_number: 0,
      brucella_tested: false,
      brucella_test_date: null,
      fmd_zone: "free",
      registration_number: "HOL-2021-015",
      brand_number: null,
      brand_position: null,
      dam_id: null,
      specific_data: null,
    },
    // ── Jersey ×3 ─────────────────────────────────────────────────────────
    {
      id: "CA016",
      tag_id: "CA016",
      name: "Suzie",
      breed: "Jersey",
      sex: "cow",
      date_of_birth: "2020-10-14",
      status: "active",
      notes: null,
      production_type: "dairy",
      herd_id: "herd-dairy",
      current_weight_kg: null,
      target_weight_kg: null,
      body_condition_score: 3.5,
      is_pregnant: false,
      expected_calving_date: null,
      last_calving_date: null,
      total_calves_raised: 0,
      is_lactating: true,
      current_milk_litre_pd: 18.0,
      lactation_number: 3,
      brucella_tested: true,
      brucella_test_date: "2026-01-20",
      fmd_zone: "free",
      registration_number: null,
      brand_number: null,
      brand_position: null,
      dam_id: null,
      specific_data: JSON.stringify({
        somaticCellCount: 120000,
        butterfatPct: 5.1,
        proteinPct: 3.8,
        milkingSchedule: "twice",
        totalMilkThisLactation: 2800,
        peakMilkLitrePd: 22.0,
      }),
    },
    {
      id: "CA017",
      tag_id: "CA017",
      name: "Marla",
      breed: "Jersey",
      sex: "cow",
      date_of_birth: "2021-07-08",
      status: "active",
      notes: null,
      production_type: "dairy",
      herd_id: "herd-dairy",
      current_weight_kg: null,
      target_weight_kg: null,
      body_condition_score: 3.5,
      is_pregnant: true,
      expected_calving_date: "2026-09-28",
      last_calving_date: null,
      total_calves_raised: 0,
      is_lactating: false,
      current_milk_litre_pd: null,
      lactation_number: 2,
      brucella_tested: true,
      brucella_test_date: "2025-11-05",
      fmd_zone: "free",
      registration_number: null,
      brand_number: null,
      brand_position: null,
      dam_id: null,
      specific_data: null,
    },
    {
      id: "CA018",
      tag_id: "CA018",
      name: "Ginger",
      breed: "Jersey",
      sex: "heifer",
      date_of_birth: "2024-01-22",
      status: "active",
      notes: null,
      production_type: "dairy",
      herd_id: "herd-dairy",
      current_weight_kg: null,
      target_weight_kg: null,
      body_condition_score: 3.0,
      is_pregnant: false,
      expected_calving_date: null,
      last_calving_date: null,
      total_calves_raised: 0,
      is_lactating: false,
      current_milk_litre_pd: null,
      lactation_number: 0,
      brucella_tested: false,
      brucella_test_date: null,
      fmd_zone: "free",
      registration_number: null,
      brand_number: null,
      brand_position: null,
      dam_id: null,
      specific_data: null,
    },
  ];

  for (const a of animals) {
    await db.execute(sql`
      INSERT INTO cattle_animals
        (id, farm_owner_id, tag_id, name, breed, sex, date_of_birth, status, notes,
         production_type, herd_id, current_weight_kg, target_weight_kg,
         body_condition_score, is_pregnant, expected_calving_date, last_calving_date,
         total_calves_raised, is_lactating, current_milk_litre_pd, lactation_number,
         brucella_tested, brucella_test_date, fmd_zone, registration_number,
         brand_number, brand_position, dam_id, specific_data, created_at, updated_at)
      VALUES
        (${a.id}, 'farm-001', ${a.tag_id}, ${a.name}, ${a.breed}, ${a.sex},
         ${a.date_of_birth}, ${a.status}, ${a.notes},
         ${a.production_type}, ${a.herd_id}, ${a.current_weight_kg}, ${a.target_weight_kg},
         ${a.body_condition_score}, ${a.is_pregnant}, ${a.expected_calving_date},
         ${a.last_calving_date}, ${a.total_calves_raised}, ${a.is_lactating},
         ${a.current_milk_litre_pd}, ${a.lactation_number}, ${a.brucella_tested},
         ${a.brucella_test_date}, ${a.fmd_zone}, ${a.registration_number},
         ${a.brand_number}, ${a.brand_position}, ${a.dam_id}, ${a.specific_data},
         ${now}, ${now})
      ON DUPLICATE KEY UPDATE
        tag_id = VALUES(tag_id), name = VALUES(name), breed = VALUES(breed),
        sex = VALUES(sex), date_of_birth = VALUES(date_of_birth),
        status = VALUES(status), notes = VALUES(notes),
        production_type = VALUES(production_type), herd_id = VALUES(herd_id),
        current_weight_kg = VALUES(current_weight_kg),
        target_weight_kg = VALUES(target_weight_kg),
        body_condition_score = VALUES(body_condition_score),
        is_pregnant = VALUES(is_pregnant),
        expected_calving_date = VALUES(expected_calving_date),
        last_calving_date = VALUES(last_calving_date),
        total_calves_raised = VALUES(total_calves_raised),
        is_lactating = VALUES(is_lactating),
        current_milk_litre_pd = VALUES(current_milk_litre_pd),
        lactation_number = VALUES(lactation_number),
        brucella_tested = VALUES(brucella_tested),
        brucella_test_date = VALUES(brucella_test_date),
        fmd_zone = VALUES(fmd_zone),
        registration_number = VALUES(registration_number),
        brand_number = VALUES(brand_number),
        brand_position = VALUES(brand_position),
        dam_id = VALUES(dam_id),
        specific_data = VALUES(specific_data),
        updated_at = VALUES(updated_at)
    `);
  }
  console.log(`cattle_animals seeded (${animals.length} animals)`);

  // ── Weight records ─────────────────────────────────────────────────────
  const weightRecords = [
    {
      id: "WR001",
      cattle_id: "CA001",
      weight_kg: 410,
      recorded_at: "2026-03-01",
      notes: "BCS 3.5",
    },
    {
      id: "WR002",
      cattle_id: "CA002",
      weight_kg: 620,
      recorded_at: "2026-03-01",
      notes: null,
    },
    {
      id: "WR003",
      cattle_id: "CA005",
      weight_kg: 310,
      recorded_at: "2026-03-01",
      notes: "BCS 3.5",
    },
    {
      id: "WR004",
      cattle_id: "CA009",
      weight_kg: 375,
      recorded_at: "2026-03-15",
      notes: "BCS 4.0",
    },
    {
      id: "WR005",
      cattle_id: "CA010",
      weight_kg: 305,
      recorded_at: "2026-03-15",
      notes: "BCS 3.5",
    },
    {
      id: "WR006",
      cattle_id: "CA005",
      weight_kg: 285,
      recorded_at: "2026-01-15",
      notes: null,
    },
    {
      id: "WR007",
      cattle_id: "CA009",
      weight_kg: 340,
      recorded_at: "2026-01-20",
      notes: null,
    },
    {
      id: "WR008",
      cattle_id: "CA007",
      weight_kg: 780,
      recorded_at: "2026-02-10",
      notes: null,
    },
  ];
  for (const w of weightRecords) {
    await db.execute(sql`
      INSERT INTO cattle_weight_records (id, farm_owner_id, cattle_id, weight_kg, recorded_at, notes, created_at)
      VALUES (${w.id}, 'farm-001', ${w.cattle_id}, ${w.weight_kg}, ${w.recorded_at}, ${w.notes}, ${now})
      ON DUPLICATE KEY UPDATE weight_kg = VALUES(weight_kg), notes = VALUES(notes)
    `);
  }
  console.log(`cattle_weight_records seeded (${weightRecords.length})`);

  // ── BCS records ────────────────────────────────────────────────────────
  const bcsRecords = [
    {
      id: "BC001",
      cattle_id: "CA001",
      score: 3.5,
      record_date: "2026-03-01",
      notes: "Assessed by Farm manager",
    },
    {
      id: "BC002",
      cattle_id: "CA011",
      score: 3.0,
      record_date: "2026-03-01",
      notes: "Assessed by Farm manager",
    },
    {
      id: "BC003",
      cattle_id: "CA014",
      score: 2.5,
      record_date: "2026-03-01",
      notes: "Below target — increase energy supplementation",
    },
    {
      id: "BC004",
      cattle_id: "CA016",
      score: 3.5,
      record_date: "2026-03-01",
      notes: "Assessed by Farm manager",
    },
    {
      id: "BC005",
      cattle_id: "CA007",
      score: 4.5,
      record_date: "2026-02-15",
      notes: null,
    },
  ];
  for (const b of bcsRecords) {
    await db.execute(sql`
      INSERT INTO cattle_bcs_records (id, farm_owner_id, cattle_id, score, record_date, notes, created_at)
      VALUES (${b.id}, 'farm-001', ${b.cattle_id}, ${b.score}, ${b.record_date}, ${b.notes}, ${now})
      ON DUPLICATE KEY UPDATE score = VALUES(score), notes = VALUES(notes)
    `);
  }
  console.log(`cattle_bcs_records seeded (${bcsRecords.length})`);

  // ── Breeding records ───────────────────────────────────────────────────
  const breedingRecords = [
    {
      id: "BR001",
      cow_id: "CA001",
      bull_id: "CA002",
      breeding_date: "2025-11-01",
      method: "natural",
      notes: "outcome:confirmed_pregnant expectedCalving:2026-08-15",
    },
    {
      id: "BR002",
      cow_id: "CA004",
      bull_id: "CA002",
      breeding_date: "2025-11-18",
      method: "natural",
      notes: "outcome:confirmed_pregnant expectedCalving:2026-09-02",
    },
    {
      id: "BR003",
      cow_id: "CA013",
      bull_id: "CA015",
      breeding_date: "2026-01-10",
      method: "ai",
      notes:
        "semenSource:Topline Genetics technician:J. Botha outcome:confirmed_pregnant expectedCalving:2026-10-20",
    },
    {
      id: "BR004",
      cow_id: "CA017",
      bull_id: "CA015",
      breeding_date: "2025-12-28",
      method: "natural",
      notes: "outcome:confirmed_pregnant expectedCalving:2026-09-28",
    },
  ];
  for (const br of breedingRecords) {
    await db.execute(sql`
      INSERT INTO cattle_breeding_records (id, farm_owner_id, cow_id, bull_id, breeding_date, method, notes, created_at)
      VALUES (${br.id}, 'farm-001', ${br.cow_id}, ${br.bull_id}, ${br.breeding_date}, ${br.method}, ${br.notes}, ${now})
      ON DUPLICATE KEY UPDATE method = VALUES(method), notes = VALUES(notes)
    `);
  }
  console.log(`cattle_breeding_records seeded (${breedingRecords.length})`);

  // ── Pregnancy checks ───────────────────────────────────────────────────
  const pregnancyChecks = [
    {
      id: "PC001",
      cattle_id: "CA001",
      check_date: "2025-12-10",
      result: "pregnant",
      expected_calving_date: "2026-08-15",
      notes: "method:rectal daysPregnant:40 checkedBy:Dr. Mokoena",
    },
    {
      id: "PC002",
      cattle_id: "CA004",
      check_date: "2025-12-15",
      result: "pregnant",
      expected_calving_date: "2026-09-02",
      notes: "method:ultrasound daysPregnant:28 checkedBy:Dr. Mokoena",
    },
    {
      id: "PC003",
      cattle_id: "CA013",
      check_date: "2026-02-05",
      result: "pregnant",
      expected_calving_date: "2026-10-20",
      notes: "method:ultrasound daysPregnant:26 checkedBy:Dr. Van Rooyen",
    },
    {
      id: "PC004",
      cattle_id: "CA017",
      check_date: "2026-01-25",
      result: "pregnant",
      expected_calving_date: "2026-09-28",
      notes: "method:rectal daysPregnant:29 checkedBy:Dr. Van Rooyen",
    },
  ];
  for (const pc of pregnancyChecks) {
    await db.execute(sql`
      INSERT INTO cattle_pregnancy_checks (id, farm_owner_id, cattle_id, check_date, result, expected_calving_date, notes, created_at)
      VALUES (${pc.id}, 'farm-001', ${pc.cattle_id}, ${pc.check_date}, ${pc.result}, ${pc.expected_calving_date}, ${pc.notes}, ${now})
      ON DUPLICATE KEY UPDATE result = VALUES(result), expected_calving_date = VALUES(expected_calving_date), notes = VALUES(notes)
    `);
  }
  console.log(`cattle_pregnancy_checks seeded (${pregnancyChecks.length})`);

  // ── Calving events ─────────────────────────────────────────────────────
  const calvingEvents = [
    {
      id: "CE001",
      cow_id: "CA001",
      calving_date: "2025-08-20",
      calves_alive: 1,
      calves_dead: 0,
      notes:
        "calvingEase:easy calfId:CA006 calfSex:calf_female calfWeightKg:28.5",
    },
    {
      id: "CE002",
      cow_id: "CA008",
      calving_date: "2025-06-12",
      calves_alive: 1,
      calves_dead: 0,
      notes: "calvingEase:easy calfSex:calf_male calfWeightKg:32.0",
    },
    {
      id: "CE003",
      cow_id: "CA004",
      calving_date: "2025-09-05",
      calves_alive: 1,
      calves_dead: 0,
      notes:
        "calvingEase:assisted calfSex:calf_female calfWeightKg:26.0 complications:Dystocia — manual correction required",
    },
  ];
  for (const ce of calvingEvents) {
    await db.execute(sql`
      INSERT INTO cattle_calving_events (id, farm_owner_id, cow_id, calving_date, calves_alive, calves_dead, notes, created_at)
      VALUES (${ce.id}, 'farm-001', ${ce.cow_id}, ${ce.calving_date}, ${ce.calves_alive}, ${ce.calves_dead}, ${ce.notes}, ${now})
      ON DUPLICATE KEY UPDATE calves_alive = VALUES(calves_alive), calves_dead = VALUES(calves_dead), notes = VALUES(notes)
    `);
  }
  console.log(`cattle_calving_events seeded (${calvingEvents.length})`);

  // ── Daily milk records ─────────────────────────────────────────────────
  const milkRecords = [
    {
      id: "MR001",
      cattle_id: "CA011",
      record_date: "2026-03-15",
      morning_litres: 14.5,
      evening_litres: 13.5,
      total_litres: 28.0,
      notes: "lactationDay:180",
    },
    {
      id: "MR002",
      cattle_id: "CA012",
      record_date: "2026-03-15",
      morning_litres: 16.5,
      evening_litres: 15.5,
      total_litres: 32.0,
      notes: "lactationDay:155",
    },
    {
      id: "MR003",
      cattle_id: "CA014",
      record_date: "2026-03-15",
      morning_litres: 12.5,
      evening_litres: 12.5,
      total_litres: 25.0,
      notes: "lactationDay:200 qualityFlag:elevated_scc",
    },
    {
      id: "MR004",
      cattle_id: "CA016",
      record_date: "2026-03-15",
      morning_litres: 9.5,
      evening_litres: 8.5,
      total_litres: 18.0,
      notes: "lactationDay:165",
    },
    {
      id: "MR005",
      cattle_id: "CA011",
      record_date: "2026-03-14",
      morning_litres: 14.0,
      evening_litres: 14.0,
      total_litres: 28.0,
      notes: "lactationDay:179",
    },
    {
      id: "MR006",
      cattle_id: "CA012",
      record_date: "2026-03-14",
      morning_litres: 16.0,
      evening_litres: 16.0,
      total_litres: 32.0,
      notes: "lactationDay:154",
    },
    {
      id: "MR007",
      cattle_id: "CA016",
      record_date: "2026-03-14",
      morning_litres: 9.0,
      evening_litres: 9.0,
      total_litres: 18.0,
      notes: "lactationDay:164",
    },
  ];
  for (const m of milkRecords) {
    await db.execute(sql`
      INSERT INTO cattle_daily_milk (id, farm_owner_id, cattle_id, record_date, morning_litres, evening_litres, total_litres, created_at)
      VALUES (${m.id}, 'farm-001', ${m.cattle_id}, ${m.record_date}, ${m.morning_litres}, ${m.evening_litres}, ${m.total_litres}, ${now})
      ON DUPLICATE KEY UPDATE morning_litres = VALUES(morning_litres), evening_litres = VALUES(evening_litres), total_litres = VALUES(total_litres)
    `);
  }
  console.log(`cattle_daily_milk seeded (${milkRecords.length})`);

  // ── Health events ──────────────────────────────────────────────────────
  const healthEvents = [
    {
      id: "HE001",
      cattle_id: "CA014",
      event_date: "2026-02-20",
      event_type: "illness",
      diagnosis: "Subclinical mastitis",
      treatment: null,
      outcome: "Responding to treatment",
      notes:
        "severity:moderate treatedBy:Farm manager isNotifiable:false Right rear quarter affected. Teat dipping increased.",
    },
    {
      id: "HE002",
      cattle_id: "CA003",
      event_date: "2026-01-05",
      event_type: "injury",
      diagnosis: "Barbed wire laceration — left shoulder",
      treatment: null,
      outcome: "Healed",
      notes: "severity:mild treatedBy:Farm manager",
    },
    {
      id: "HE003",
      cattle_id: "CA009",
      event_date: "2026-03-01",
      event_type: "observation",
      diagnosis: "Suspected lumpy skin disease",
      treatment: null,
      outcome: null,
      notes:
        "severity:moderate treatedBy:Dr. Mokoena isNotifiable:true Notifiable disease — reported to AHT. Pending lab confirmation.",
    },
  ];
  for (const h of healthEvents) {
    await db.execute(sql`
      INSERT INTO cattle_health_events (id, farm_owner_id, cattle_id, event_date, event_type, diagnosis, treatment, outcome, notes, created_at)
      VALUES (${h.id}, 'farm-001', ${h.cattle_id}, ${h.event_date}, ${h.event_type}, ${h.diagnosis}, ${h.treatment}, ${h.outcome}, ${h.notes}, ${now})
      ON DUPLICATE KEY UPDATE diagnosis = VALUES(diagnosis), outcome = VALUES(outcome), notes = VALUES(notes)
    `);
  }
  console.log(`cattle_health_events seeded (${healthEvents.length})`);

  // ── Medication logs ────────────────────────────────────────────────────
  const medicationLogs = [
    {
      id: "ML001",
      cattle_id: "CA014",
      administered_at: "2026-02-20",
      medication_name: "Penicillin G",
      dosage: "3000mg injection",
      administered_by: "Dr. Van Rooyen",
      notes:
        "route:injection withdrawalDaysMeat:6 withdrawalDaysMilk:4 vetApproved:true",
    },
    {
      id: "ML002",
      cattle_id: "CA003",
      administered_at: "2026-01-05",
      medication_name: "Terramycin spray",
      dosage: "50mg topical",
      administered_by: "Farm manager",
      notes: "route:topical vetApproved:false",
    },
    {
      id: "ML003",
      cattle_id: "CA009",
      administered_at: "2026-03-01",
      medication_name: "Neethling vaccine",
      dosage: "5mg injection",
      administered_by: "Dr. Mokoena",
      notes: "route:injection withdrawalDaysMeat:21 vetApproved:true",
    },
  ];
  for (const ml of medicationLogs) {
    await db.execute(sql`
      INSERT INTO cattle_medication_logs (id, farm_owner_id, cattle_id, medication_name, dosage, administered_at, administered_by, notes, created_at)
      VALUES (${ml.id}, 'farm-001', ${ml.cattle_id}, ${ml.medication_name}, ${ml.dosage}, ${ml.administered_at}, ${ml.administered_by}, ${ml.notes}, ${now})
      ON DUPLICATE KEY UPDATE medication_name = VALUES(medication_name), dosage = VALUES(dosage), notes = VALUES(notes)
    `);
  }
  console.log(`cattle_medication_logs seeded (${medicationLogs.length})`);

  // ── Vaccinations ───────────────────────────────────────────────────────
  // vaccination_date = givenDate if present, else dueDate
  const vaccinations = [
    {
      id: "VC001",
      cattle_id: "CA001",
      vaccine_name: "Brucella S19",
      vaccination_date: "2026-04-01",
      next_due_date: null,
      batch_number: null,
      notes: "route:injection administeredBy:Dr. Mokoena",
    },
    {
      id: "VC002",
      cattle_id: "CA002",
      vaccine_name: "Blackleg (Clostridial)",
      vaccination_date: "2026-05-14",
      next_due_date: "2027-05-14",
      batch_number: "CLO-2026-A",
      notes: "route:injection",
    },
    {
      id: "VC003",
      cattle_id: "CA011",
      vaccine_name: "BVD + IBR combo",
      vaccination_date: "2026-03-02",
      next_due_date: "2027-03-02",
      batch_number: "BVD-2026-B",
      notes: "route:injection administeredBy:Dr. Van Rooyen",
    },
    {
      id: "VC004",
      cattle_id: "CA009",
      vaccine_name: "Lumpy Skin Disease",
      vaccination_date: "2026-02-01",
      next_due_date: null,
      batch_number: null,
      notes: null,
    },
    {
      id: "VC005",
      cattle_id: "CA016",
      vaccine_name: "Rift Valley Fever",
      vaccination_date: "2026-06-01",
      next_due_date: null,
      batch_number: null,
      notes: "route:injection",
    },
  ];
  for (const v of vaccinations) {
    await db.execute(sql`
      INSERT INTO cattle_vaccinations (id, farm_owner_id, cattle_id, vaccine_name, vaccination_date, next_due_date, batch_number, notes, created_at)
      VALUES (${v.id}, 'farm-001', ${v.cattle_id}, ${v.vaccine_name}, ${v.vaccination_date}, ${v.next_due_date}, ${v.batch_number}, ${v.notes}, ${now})
      ON DUPLICATE KEY UPDATE vaccine_name = VALUES(vaccine_name), vaccination_date = VALUES(vaccination_date), next_due_date = VALUES(next_due_date), batch_number = VALUES(batch_number), notes = VALUES(notes)
    `);
  }
  console.log(`cattle_vaccinations seeded (${vaccinations.length})`);

  // ── Sale records ───────────────────────────────────────────────────────
  await db.execute(sql`
    INSERT INTO cattle_sale_records (id, farm_owner_id, cattle_id, sale_date, buyer_name, sale_price, notes, created_at)
    VALUES ('SR001', 'farm-001', 'CA005', '2025-11-10', 'Langkloof Feedlot', 11165.00, 'saleWeightKg:290 pricePerKg:38.50 transportCost:650 permitNumber:MP-LK-2025-0441', ${now})
    ON DUPLICATE KEY UPDATE buyer_name = VALUES(buyer_name), sale_price = VALUES(sale_price), notes = VALUES(notes)
  `);
  console.log("cattle_sale_records seeded (1)");

  // ── Feed records ───────────────────────────────────────────────────────
  const feedRecords = [
    {
      id: "FR001",
      cattle_id: "CA009",
      feed_date: "2026-03-15",
      feed_type: "TMR (total mixed ration)",
      quantity_kg: 12.5,
      notes: "costPerKg:3.20 feedlotPenId:B1 rationName:Finisher ration",
    },
    {
      id: "FR002",
      cattle_id: "CA011",
      feed_date: "2026-03-15",
      feed_type: "Dairy concentrate",
      quantity_kg: 8.0,
      notes: "costPerKg:5.80",
    },
    {
      id: "FR003",
      cattle_id: "CA012",
      feed_date: "2026-03-15",
      feed_type: "Dairy concentrate",
      quantity_kg: 9.5,
      notes: "costPerKg:5.80",
    },
    {
      id: "FR004",
      cattle_id: "CA016",
      feed_date: "2026-03-15",
      feed_type: "Dairy concentrate",
      quantity_kg: 6.0,
      notes: "costPerKg:5.80",
    },
  ];
  for (const f of feedRecords) {
    await db.execute(sql`
      INSERT INTO cattle_feed_records (id, farm_owner_id, cattle_id, feed_type, quantity_kg, feed_date, notes, created_at)
      VALUES (${f.id}, 'farm-001', ${f.cattle_id}, ${f.feed_type}, ${f.quantity_kg}, ${f.feed_date}, ${f.notes}, ${now})
      ON DUPLICATE KEY UPDATE feed_type = VALUES(feed_type), quantity_kg = VALUES(quantity_kg), notes = VALUES(notes)
    `);
  }
  console.log(`cattle_feed_records seeded (${feedRecords.length})`);

  // ── Pasture records ────────────────────────────────────────────────────
  const pastureRecords = [
    {
      id: "PR001",
      pasture_name: "Camp A",
      move_date: "2026-02-01",
      notes: "herdId:herd-nguni estimatedHa:45.0 veldCondition:good",
    },
    {
      id: "PR002",
      pasture_name: "Camp C",
      move_date: "2026-01-15",
      notes: "herdId:herd-bonsmara estimatedHa:30.0 veldCondition:fair",
    },
    {
      id: "PR003",
      pasture_name: "Camp B",
      move_date: "2025-11-01",
      notes:
        "herdId:herd-nguni estimatedHa:40.0 veldCondition:good exitDate:2026-01-31",
    },
  ];
  for (const p of pastureRecords) {
    await db.execute(sql`
      INSERT INTO cattle_pasture_records (id, farm_owner_id, pasture_name, move_date, notes, created_at)
      VALUES (${p.id}, 'farm-001', ${p.pasture_name}, ${p.move_date}, ${p.notes}, ${now})
      ON DUPLICATE KEY UPDATE pasture_name = VALUES(pasture_name), move_date = VALUES(move_date), notes = VALUES(notes)
    `);
  }
  console.log(`cattle_pasture_records seeded (${pastureRecords.length})`);

  // ── Dipping records ────────────────────────────────────────────────────
  // DB table is herd-level (no cattle_id); animalId stored in notes
  const dippingRecords = [
    {
      id: "DR001",
      dipping_date: "2026-02-15",
      chemical: "Triatix (Amitraz)",
      concentration: "0.025%",
      number_of_cattle: 1,
      notes: "animalId:CA001 method:spray nextDueDays:14 vetApproved:false",
    },
    {
      id: "DR002",
      dipping_date: "2026-02-15",
      chemical: "Triatix (Amitraz)",
      concentration: "0.025%",
      number_of_cattle: 1,
      notes: "animalId:CA002 method:spray nextDueDays:14",
    },
    {
      id: "DR003",
      dipping_date: "2026-03-01",
      chemical: "Deadline (Cypermethrin)",
      concentration: "0.05%",
      number_of_cattle: 1,
      notes:
        "animalId:CA009 method:plunge nextDueDays:21 vetApproved:true Feedlot protocol — mandatory 21-day interval",
    },
  ];
  for (const d of dippingRecords) {
    await db.execute(sql`
      INSERT INTO cattle_dipping_records (id, farm_owner_id, dipping_date, chemical, concentration, number_of_cattle, notes, created_at)
      VALUES (${d.id}, 'farm-001', ${d.dipping_date}, ${d.chemical}, ${d.concentration}, ${d.number_of_cattle}, ${d.notes}, ${now})
      ON DUPLICATE KEY UPDATE chemical = VALUES(chemical), concentration = VALUES(concentration), notes = VALUES(notes)
    `);
  }
  console.log(`cattle_dipping_records seeded (${dippingRecords.length})`);
}
