import { sql } from "drizzle-orm";
import { db } from "../../config/database";

/**
 * Seed 008: goat_animals and all related records.
 *
 * All data mirrors goat_mock_data_source.dart exactly:
 *   14 goats across 6 herds (Boer, Kalahari Red, Angora, Saanen, Communal, Savanna)
 *   with weight, mating, pregnancy, kidding, milk, shearing, health, medication,
 *   vaccination, sale, feed, pasture, FAMACHA and BCS records.
 *
 * farmId 'FARM-001' → normalised to 'farm-001' for the DB.
 * MeatSpecific / DairySpecific / FiberSpecific / BreederSpecific are stored as
 * JSON in the `specific_data` column added by migration 0015.
 */
const now = "2025-05-28 00:00:00";

export async function runGoatSeed(): Promise<void> {
  // ── Animals ──────────────────────────────────────────────────────────────
  type GoatRow = {
    id: string;
    tag_id: string;
    name: string | null;
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
    expected_kidding_date: string | null;
    last_kidding_date: string | null;
    total_kids_raised: number;
    is_lactating: boolean;
    current_milk_litre_pd: number | null;
    lactation_number: number;
    dry_off_date: string | null;
    last_shearing_date: string | null;
    last_deworming_date: string | null;
    famacha_score: number | null;
    registration_number: string | null;
    dam_id: string | null;
    specific_data: string | null;
  };

  const animals: GoatRow[] = [
    // ── Herd A — Boer Commercial (meat, Limpopo) ──────────────────────────
    {
      id: "goat-001",
      tag_id: "BC-001",
      name: "Bella",
      breed: "Boer",
      sex: "doe",
      date_of_birth: "2021-03-10",
      status: "active",
      notes: null,
      production_type: "meat",
      herd_id: "herd-a",
      current_weight_kg: 68.0,
      target_weight_kg: 72.0,
      body_condition_score: 3.5,
      is_pregnant: true,
      expected_kidding_date: "2025-06-15",
      last_kidding_date: "2024-06-20",
      total_kids_raised: 4,
      is_lactating: false,
      current_milk_litre_pd: null,
      lactation_number: 0,
      dry_off_date: null,
      last_shearing_date: null,
      last_deworming_date: "2025-01-10",
      famacha_score: 2,
      registration_number: null,
      dam_id: null,
      specific_data: JSON.stringify({
        meatSpecific: { adgGPerDay: 180.0, dressingPct: 48.0 },
      }),
    },
    {
      id: "goat-002",
      tag_id: "BC-002",
      name: "Daisy",
      breed: "Boer",
      sex: "doe",
      date_of_birth: "2021-05-22",
      status: "active",
      notes: null,
      production_type: "meat",
      herd_id: "herd-a",
      current_weight_kg: 64.5,
      target_weight_kg: 70.0,
      body_condition_score: 3.0,
      is_pregnant: false,
      expected_kidding_date: null,
      last_kidding_date: "2025-03-01",
      total_kids_raised: 5,
      is_lactating: true,
      current_milk_litre_pd: 1.2,
      lactation_number: 3,
      dry_off_date: null,
      last_shearing_date: null,
      last_deworming_date: "2025-02-15",
      famacha_score: 2,
      registration_number: null,
      dam_id: null,
      specific_data: null,
    },
    {
      id: "goat-003",
      tag_id: "BC-003",
      name: "Thor",
      breed: "Boer",
      sex: "buck",
      date_of_birth: "2020-08-14",
      status: "active",
      notes: null,
      production_type: "meat",
      herd_id: "herd-a",
      current_weight_kg: 112.0,
      target_weight_kg: 115.0,
      body_condition_score: 4.0,
      is_pregnant: false,
      expected_kidding_date: null,
      last_kidding_date: null,
      total_kids_raised: 0,
      is_lactating: false,
      current_milk_litre_pd: null,
      lactation_number: 0,
      dry_off_date: null,
      last_shearing_date: null,
      last_deworming_date: "2025-01-05",
      famacha_score: 1,
      registration_number: null,
      dam_id: null,
      specific_data: JSON.stringify({
        meatSpecific: { adgGPerDay: 220.0, dressingPct: 50.0 },
        breederSpecific: {
          registeredBreeder: true,
          studBookNumber: "SA-BOER-4412",
          doesServedCount: 32,
          kidRatio: 1.85,
          breedingFee: 850.0,
        },
      }),
    },
    // ── Herd B — Kalahari Red (meat, Northern Cape) ───────────────────────
    {
      id: "goat-004",
      tag_id: "KR-001",
      name: "Ruby",
      breed: "Kalahari Red",
      sex: "doe",
      date_of_birth: "2022-01-18",
      status: "active",
      notes: null,
      production_type: "meat",
      herd_id: "herd-b",
      current_weight_kg: 52.0,
      target_weight_kg: 58.0,
      body_condition_score: 3.0,
      is_pregnant: true,
      expected_kidding_date: "2025-06-25",
      last_kidding_date: "2024-07-05",
      total_kids_raised: 2,
      is_lactating: false,
      current_milk_litre_pd: null,
      lactation_number: 0,
      dry_off_date: null,
      last_shearing_date: null,
      last_deworming_date: "2024-12-20",
      famacha_score: 3,
      registration_number: null,
      dam_id: null,
      specific_data: null,
    },
    {
      id: "goat-005",
      tag_id: "KR-002",
      name: null,
      breed: "Kalahari Red",
      sex: "wether",
      date_of_birth: "2023-04-12",
      status: "active",
      notes: null,
      production_type: "meat",
      herd_id: "herd-b",
      current_weight_kg: 43.0,
      target_weight_kg: 50.0,
      body_condition_score: 3.5,
      is_pregnant: false,
      expected_kidding_date: null,
      last_kidding_date: null,
      total_kids_raised: 0,
      is_lactating: false,
      current_milk_litre_pd: null,
      lactation_number: 0,
      dry_off_date: null,
      last_shearing_date: null,
      last_deworming_date: "2025-02-01",
      famacha_score: 2,
      registration_number: null,
      dam_id: null,
      specific_data: JSON.stringify({
        meatSpecific: {
          adgGPerDay: 165.0,
          targetSlaughterAgeMonths: 18,
          dressingPct: 47.0,
        },
      }),
    },
    // ── Herd C — Angora Fiber (fiber, Eastern Cape) ───────────────────────
    {
      id: "goat-006",
      tag_id: "ANG-001",
      name: "Fluffy",
      breed: "Angora",
      sex: "doe",
      date_of_birth: "2020-09-30",
      status: "active",
      notes: null,
      production_type: "fiber",
      herd_id: "herd-c",
      current_weight_kg: 38.0,
      target_weight_kg: 40.0,
      body_condition_score: 3.5,
      is_pregnant: false,
      expected_kidding_date: null,
      last_kidding_date: null,
      total_kids_raised: 0,
      is_lactating: false,
      current_milk_litre_pd: null,
      lactation_number: 0,
      dry_off_date: null,
      last_shearing_date: "2024-09-05",
      last_deworming_date: "2025-01-20",
      famacha_score: 2,
      registration_number: null,
      dam_id: null,
      specific_data: JSON.stringify({
        fiberSpecific: {
          avgFleeceMassKg: 3.8,
          stapleLength: 115.0,
          micronRating: 28.5,
          colorGrade: "White",
          lastMohairPricePerKg: 420.0,
        },
      }),
    },
    {
      id: "goat-007",
      tag_id: "ANG-002",
      name: "Cloud",
      breed: "Angora",
      sex: "buck",
      date_of_birth: "2019-11-15",
      status: "active",
      notes: null,
      production_type: "fiber",
      herd_id: "herd-c",
      current_weight_kg: 55.0,
      target_weight_kg: 57.0,
      body_condition_score: 4.0,
      is_pregnant: false,
      expected_kidding_date: null,
      last_kidding_date: null,
      total_kids_raised: 0,
      is_lactating: false,
      current_milk_litre_pd: null,
      lactation_number: 0,
      dry_off_date: null,
      last_shearing_date: "2024-08-20",
      last_deworming_date: "2025-01-20",
      famacha_score: 1,
      registration_number: null,
      dam_id: null,
      specific_data: JSON.stringify({
        fiberSpecific: {
          avgFleeceMassKg: 4.5,
          stapleLength: 120.0,
          micronRating: 26.0,
          colorGrade: "White",
          lastMohairPricePerKg: 450.0,
        },
      }),
    },
    // ── Herd D — Saanen Dairy (dairy, Western Cape) ───────────────────────
    {
      id: "goat-008",
      tag_id: "SD-001",
      name: "Milka",
      breed: "Saanen",
      sex: "doe",
      date_of_birth: "2021-07-08",
      status: "active",
      notes: null,
      production_type: "dairy",
      herd_id: "herd-d",
      current_weight_kg: 62.0,
      target_weight_kg: 65.0,
      body_condition_score: 3.0,
      is_pregnant: false,
      expected_kidding_date: null,
      last_kidding_date: "2025-02-10",
      total_kids_raised: 6,
      is_lactating: true,
      current_milk_litre_pd: 3.8,
      lactation_number: 3,
      dry_off_date: null,
      last_shearing_date: null,
      last_deworming_date: "2025-01-15",
      famacha_score: 4,
      registration_number: null,
      dam_id: null,
      specific_data: JSON.stringify({
        dairySpecific: {
          peakMilkLitrePd: 4.5,
          totalMilkThisLactation: 285.0,
          milkFatPct: 3.9,
          milkProteinPct: 3.2,
          projectedDryOffDate: "2025-11-10",
        },
      }),
    },
    {
      id: "goat-009",
      tag_id: "SD-002",
      name: "Cream",
      breed: "Saanen",
      sex: "doe",
      date_of_birth: "2022-04-25",
      status: "active",
      notes: null,
      production_type: "dairy",
      herd_id: "herd-d",
      current_weight_kg: 58.0,
      target_weight_kg: 62.0,
      body_condition_score: 3.5,
      is_pregnant: true,
      expected_kidding_date: "2025-07-02",
      last_kidding_date: "2024-07-02",
      total_kids_raised: 2,
      is_lactating: false,
      current_milk_litre_pd: null,
      lactation_number: 0,
      dry_off_date: "2025-04-01",
      last_shearing_date: null,
      last_deworming_date: "2025-02-10",
      famacha_score: 2,
      registration_number: null,
      dam_id: null,
      specific_data: JSON.stringify({
        dairySpecific: {
          peakMilkLitrePd: 3.9,
          totalMilkThisLactation: 0.0,
          milkFatPct: 4.1,
          milkProteinPct: 3.3,
        },
      }),
    },
    // ── Herd E — Communal Mixed (KwaZulu-Natal) ───────────────────────────
    {
      id: "goat-010",
      tag_id: "CM-001",
      name: null,
      breed: "Indigenous/Nguni Cross",
      sex: "doe",
      date_of_birth: "2023-10-05",
      status: "active",
      notes: null,
      production_type: "communal",
      herd_id: "herd-e",
      current_weight_kg: 28.0,
      target_weight_kg: 40.0,
      body_condition_score: 3.0,
      is_pregnant: false,
      expected_kidding_date: null,
      last_kidding_date: null,
      total_kids_raised: 0,
      is_lactating: false,
      current_milk_litre_pd: null,
      lactation_number: 0,
      dry_off_date: null,
      last_shearing_date: null,
      last_deworming_date: "2025-01-30",
      famacha_score: 2,
      registration_number: null,
      dam_id: "goat-001",
      specific_data: null,
    },
    {
      id: "goat-011",
      tag_id: "CM-002",
      name: null,
      breed: "Nguni",
      sex: "buck",
      date_of_birth: "2020-06-17",
      status: "active",
      notes: null,
      production_type: "communal",
      herd_id: "herd-e",
      current_weight_kg: 48.0,
      target_weight_kg: null,
      body_condition_score: 3.0,
      is_pregnant: false,
      expected_kidding_date: null,
      last_kidding_date: null,
      total_kids_raised: 0,
      is_lactating: false,
      current_milk_litre_pd: null,
      lactation_number: 0,
      dry_off_date: null,
      last_shearing_date: null,
      last_deworming_date: "2024-12-10",
      famacha_score: 3,
      registration_number: null,
      dam_id: null,
      specific_data: null,
    },
    // ── Herd F — Savanna Breeding Stud (Free State) ───────────────────────
    {
      id: "goat-012",
      tag_id: "SB-001",
      name: "Atlas",
      breed: "Savanna",
      sex: "buck",
      date_of_birth: "2019-05-02",
      status: "active",
      notes: null,
      production_type: "breeding",
      herd_id: "herd-f",
      current_weight_kg: 108.0,
      target_weight_kg: 110.0,
      body_condition_score: 4.0,
      is_pregnant: false,
      expected_kidding_date: null,
      last_kidding_date: null,
      total_kids_raised: 0,
      is_lactating: false,
      current_milk_litre_pd: null,
      lactation_number: 0,
      dry_off_date: null,
      last_shearing_date: null,
      last_deworming_date: "2025-02-01",
      famacha_score: 1,
      registration_number: "SASBA-2019-0412",
      dam_id: null,
      specific_data: JSON.stringify({
        breederSpecific: {
          studBookNumber: "SASBA-2019-0412",
          registeredBreeder: true,
          doesServedCount: 45,
          kidRatio: 1.92,
          breedingFee: 1200.0,
        },
      }),
    },
    {
      id: "goat-013",
      tag_id: "SB-002",
      name: "Duchess",
      breed: "Savanna",
      sex: "doe",
      date_of_birth: "2020-10-12",
      status: "active",
      notes: null,
      production_type: "breeding",
      herd_id: "herd-f",
      current_weight_kg: 75.0,
      target_weight_kg: 78.0,
      body_condition_score: 3.5,
      is_pregnant: true,
      expected_kidding_date: "2025-06-28",
      last_kidding_date: "2024-06-28",
      total_kids_raised: 8,
      is_lactating: false,
      current_milk_litre_pd: null,
      lactation_number: 0,
      dry_off_date: null,
      last_shearing_date: null,
      last_deworming_date: "2025-01-25",
      famacha_score: 2,
      registration_number: "SASBA-2020-1122",
      dam_id: null,
      specific_data: JSON.stringify({
        breederSpecific: {
          studBookNumber: "SASBA-2020-1122",
          registeredBreeder: true,
          kidRatio: 1.95,
        },
      }),
    },
    {
      id: "goat-014",
      tag_id: "SB-003",
      name: "Prince",
      breed: "Boer × Savanna",
      sex: "buck",
      date_of_birth: "2022-02-28",
      status: "active",
      notes: null,
      production_type: "breeding",
      herd_id: "herd-f",
      current_weight_kg: 88.0,
      target_weight_kg: 95.0,
      body_condition_score: 3.5,
      is_pregnant: false,
      expected_kidding_date: null,
      last_kidding_date: null,
      total_kids_raised: 0,
      is_lactating: false,
      current_milk_litre_pd: null,
      lactation_number: 0,
      dry_off_date: null,
      last_shearing_date: null,
      last_deworming_date: "2025-02-10",
      famacha_score: 2,
      registration_number: null,
      dam_id: null,
      specific_data: JSON.stringify({
        meatSpecific: { adgGPerDay: 210.0, dressingPct: 49.0 },
        breederSpecific: {
          registeredBreeder: false,
          doesServedCount: 18,
          kidRatio: 1.78,
          breedingFee: 600.0,
        },
      }),
    },
  ];

  for (const a of animals) {
    await db.execute(sql`
      INSERT INTO goat_animals
        (id, farm_owner_id, tag_id, name, breed, sex, date_of_birth, status, notes,
         production_type, herd_id, current_weight_kg, target_weight_kg, body_condition_score,
         is_pregnant, expected_kidding_date, last_kidding_date, total_kids_raised,
         is_lactating, current_milk_litre_pd, lactation_number, dry_off_date,
         last_shearing_date, last_deworming_date, famacha_score,
         registration_number, dam_id, specific_data, created_at, updated_at)
      VALUES
        (${a.id}, 'farm-001', ${a.tag_id}, ${a.name}, ${a.breed}, ${a.sex},
         ${a.date_of_birth}, ${a.status}, ${a.notes},
         ${a.production_type}, ${a.herd_id}, ${a.current_weight_kg}, ${a.target_weight_kg},
         ${a.body_condition_score}, ${a.is_pregnant}, ${a.expected_kidding_date},
         ${a.last_kidding_date}, ${a.total_kids_raised}, ${a.is_lactating},
         ${a.current_milk_litre_pd}, ${a.lactation_number}, ${a.dry_off_date},
         ${a.last_shearing_date}, ${a.last_deworming_date}, ${a.famacha_score},
         ${a.registration_number}, ${a.dam_id}, ${a.specific_data}, ${now}, ${now})
      ON DUPLICATE KEY UPDATE
        tag_id = VALUES(tag_id), name = VALUES(name), breed = VALUES(breed),
        sex = VALUES(sex), date_of_birth = VALUES(date_of_birth),
        status = VALUES(status), notes = VALUES(notes),
        production_type = VALUES(production_type), herd_id = VALUES(herd_id),
        current_weight_kg = VALUES(current_weight_kg),
        target_weight_kg = VALUES(target_weight_kg),
        body_condition_score = VALUES(body_condition_score),
        is_pregnant = VALUES(is_pregnant),
        expected_kidding_date = VALUES(expected_kidding_date),
        last_kidding_date = VALUES(last_kidding_date),
        total_kids_raised = VALUES(total_kids_raised),
        is_lactating = VALUES(is_lactating),
        current_milk_litre_pd = VALUES(current_milk_litre_pd),
        lactation_number = VALUES(lactation_number),
        dry_off_date = VALUES(dry_off_date),
        last_shearing_date = VALUES(last_shearing_date),
        last_deworming_date = VALUES(last_deworming_date),
        famacha_score = VALUES(famacha_score),
        registration_number = VALUES(registration_number),
        dam_id = VALUES(dam_id), specific_data = VALUES(specific_data),
        updated_at = VALUES(updated_at)
    `);
  }
  console.log(`goat_animals seeded (${animals.length} animals)`);

  // ── Weight records ────────────────────────────────────────────────────
  const weightRecords = [
    {
      id: "wr-001",
      goat_id: "goat-001",
      recorded_at: "2025-01-15",
      weight_kg: 65.0,
      notes: "BCS 3.0",
    },
    {
      id: "wr-002",
      goat_id: "goat-001",
      recorded_at: "2025-03-01",
      weight_kg: 67.0,
      notes: "BCS 3.5",
    },
    {
      id: "wr-003",
      goat_id: "goat-001",
      recorded_at: "2025-05-01",
      weight_kg: 68.0,
      notes: "BCS 3.5",
    },
    {
      id: "wr-004",
      goat_id: "goat-003",
      recorded_at: "2025-01-15",
      weight_kg: 108.0,
      notes: "BCS 4.0",
    },
    {
      id: "wr-005",
      goat_id: "goat-003",
      recorded_at: "2025-04-10",
      weight_kg: 112.0,
      notes: "BCS 4.0",
    },
    {
      id: "wr-006",
      goat_id: "goat-008",
      recorded_at: "2025-02-10",
      weight_kg: 58.0,
      notes: "Post-kidding weight BCS 2.5",
    },
    {
      id: "wr-007",
      goat_id: "goat-008",
      recorded_at: "2025-04-15",
      weight_kg: 62.0,
      notes: "BCS 3.0",
    },
    {
      id: "wr-008",
      goat_id: "goat-005",
      recorded_at: "2025-03-20",
      weight_kg: 40.0,
      notes: "BCS 3.0",
    },
    {
      id: "wr-009",
      goat_id: "goat-005",
      recorded_at: "2025-05-05",
      weight_kg: 43.0,
      notes: "BCS 3.5",
    },
    {
      id: "wr-010",
      goat_id: "goat-012",
      recorded_at: "2025-02-01",
      weight_kg: 105.0,
      notes: "BCS 3.5",
    },
    {
      id: "wr-011",
      goat_id: "goat-012",
      recorded_at: "2025-05-01",
      weight_kg: 108.0,
      notes: "BCS 4.0",
    },
  ];
  for (const w of weightRecords) {
    await db.execute(sql`
      INSERT INTO goat_weight_records (id, farm_owner_id, goat_id, weight_kg, recorded_at, notes, created_at)
      VALUES (${w.id}, 'farm-001', ${w.goat_id}, ${w.weight_kg}, ${w.recorded_at}, ${w.notes}, ${now})
      ON DUPLICATE KEY UPDATE weight_kg = VALUES(weight_kg), notes = VALUES(notes)
    `);
  }
  console.log(`goat_weight_records seeded (${weightRecords.length})`);

  // ── BCS records ───────────────────────────────────────────────────────
  const bcsRecords = [
    {
      id: "bcs-001",
      goat_id: "goat-001",
      record_date: "2025-05-01",
      score: 3.5,
      notes: null,
    },
    {
      id: "bcs-002",
      goat_id: "goat-008",
      record_date: "2025-04-15",
      score: 3.0,
      notes: "Lactation stress visible",
    },
    {
      id: "bcs-003",
      goat_id: "goat-003",
      record_date: "2025-04-10",
      score: 4.0,
      notes: null,
    },
    {
      id: "bcs-004",
      goat_id: "goat-012",
      record_date: "2025-05-01",
      score: 4.0,
      notes: null,
    },
    {
      id: "bcs-005",
      goat_id: "goat-013",
      record_date: "2025-05-01",
      score: 3.5,
      notes: "Pregnancy drain expected",
    },
  ];
  for (const b of bcsRecords) {
    await db.execute(sql`
      INSERT INTO goat_bcs_records (id, farm_owner_id, goat_id, score, record_date, notes, created_at)
      VALUES (${b.id}, 'farm-001', ${b.goat_id}, ${b.score}, ${b.record_date}, ${b.notes}, ${now})
      ON DUPLICATE KEY UPDATE score = VALUES(score), notes = VALUES(notes)
    `);
  }
  console.log(`goat_bcs_records seeded (${bcsRecords.length})`);

  // ── Mating records ────────────────────────────────────────────────────
  const matingRecords = [
    {
      id: "mat-001",
      doe_id: "goat-001",
      buck_id: "goat-003",
      mating_date: "2025-01-20",
      method: "natural",
      notes: "outcome:pregnant expectedKiddingDate:2025-06-15",
    },
    {
      id: "mat-002",
      doe_id: "goat-004",
      buck_id: "goat-003",
      mating_date: "2025-01-24",
      method: "natural",
      notes: "outcome:pregnant expectedKiddingDate:2025-06-25",
    },
    {
      id: "mat-003",
      doe_id: "goat-009",
      buck_id: "goat-012",
      mating_date: "2025-01-28",
      method: "natural",
      notes: "outcome:pregnant expectedKiddingDate:2025-07-02",
    },
    {
      id: "mat-004",
      doe_id: "goat-013",
      buck_id: "goat-012",
      mating_date: "2025-01-30",
      method: "natural",
      notes: "outcome:pregnant expectedKiddingDate:2025-06-28",
    },
  ];
  for (const m of matingRecords) {
    await db.execute(sql`
      INSERT INTO goat_mating_records (id, farm_owner_id, doe_id, buck_id, mating_date, method, notes, created_at)
      VALUES (${m.id}, 'farm-001', ${m.doe_id}, ${m.buck_id}, ${m.mating_date}, ${m.method}, ${m.notes}, ${now})
      ON DUPLICATE KEY UPDATE method = VALUES(method), notes = VALUES(notes)
    `);
  }
  console.log(`goat_mating_records seeded (${matingRecords.length})`);

  // ── Pregnancy checks ──────────────────────────────────────────────────
  const pregnancyChecks = [
    {
      id: "pc-001",
      goat_id: "goat-001",
      check_date: "2025-02-20",
      result: "pregnant",
      expected_kidding_date: "2025-06-15",
      notes: "method:ultrasound daysPregnant:31",
    },
    {
      id: "pc-002",
      goat_id: "goat-009",
      check_date: "2025-03-10",
      result: "pregnant",
      expected_kidding_date: "2025-07-02",
      notes: "method:ultrasound daysPregnant:42",
    },
  ];
  for (const p of pregnancyChecks) {
    await db.execute(sql`
      INSERT INTO goat_pregnancy_checks (id, farm_owner_id, goat_id, check_date, result, expected_kidding_date, notes, created_at)
      VALUES (${p.id}, 'farm-001', ${p.goat_id}, ${p.check_date}, ${p.result}, ${p.expected_kidding_date}, ${p.notes}, ${now})
      ON DUPLICATE KEY UPDATE result = VALUES(result), expected_kidding_date = VALUES(expected_kidding_date), notes = VALUES(notes)
    `);
  }
  console.log(`goat_pregnancy_checks seeded (${pregnancyChecks.length})`);

  // ── Kidding events ────────────────────────────────────────────────────
  const kiddingEvents = [
    {
      id: "kid-001",
      doe_id: "goat-001",
      kidding_date: "2024-06-20",
      kids_alive: 2,
      kids_dead: 0,
      notes:
        "totalKidsBorn:2 birthWeights:[3.8,4.1] kidIds:[goat-010] assisted:false",
    },
    {
      id: "kid-002",
      doe_id: "goat-002",
      kidding_date: "2025-03-01",
      kids_alive: 2,
      kids_dead: 1,
      notes:
        "totalKidsBorn:3 birthWeights:[3.2,3.5,null] assisted:true complications:Dystocia — one kid stillborn",
    },
    {
      id: "kid-003",
      doe_id: "goat-008",
      kidding_date: "2025-02-10",
      kids_alive: 2,
      kids_dead: 0,
      notes: "totalKidsBorn:2 birthWeights:[3.6,3.9] assisted:false",
    },
  ];
  for (const k of kiddingEvents) {
    await db.execute(sql`
      INSERT INTO goat_kidding_events (id, farm_owner_id, doe_id, kidding_date, kids_alive, kids_dead, notes, created_at)
      VALUES (${k.id}, 'farm-001', ${k.doe_id}, ${k.kidding_date}, ${k.kids_alive}, ${k.kids_dead}, ${k.notes}, ${now})
      ON DUPLICATE KEY UPDATE kids_alive = VALUES(kids_alive), kids_dead = VALUES(kids_dead), notes = VALUES(notes)
    `);
  }
  console.log(`goat_kidding_events seeded (${kiddingEvents.length})`);

  // ── Daily milk records ────────────────────────────────────────────────
  const milkRecords = [
    {
      id: "mlk-001",
      goat_id: "goat-008",
      record_date: "2025-05-01",
      morning_litres: 2.0,
      evening_litres: 1.8,
      total_litres: 3.8,
      notes: "lactationDay:80",
    },
    {
      id: "mlk-002",
      goat_id: "goat-008",
      record_date: "2025-05-02",
      morning_litres: 2.0,
      evening_litres: 1.9,
      total_litres: 3.9,
      notes: "lactationDay:81",
    },
    {
      id: "mlk-003",
      goat_id: "goat-008",
      record_date: "2025-05-03",
      morning_litres: 1.9,
      evening_litres: 1.8,
      total_litres: 3.7,
      notes: "lactationDay:82",
    },
    {
      id: "mlk-004",
      goat_id: "goat-008",
      record_date: "2025-05-04",
      morning_litres: 2.1,
      evening_litres: 1.7,
      total_litres: 3.8,
      notes: "lactationDay:83",
    },
    {
      id: "mlk-005",
      goat_id: "goat-002",
      record_date: "2025-05-01",
      morning_litres: 0.6,
      evening_litres: 0.6,
      total_litres: 1.2,
      notes: "lactationDay:61",
    },
    {
      id: "mlk-006",
      goat_id: "goat-002",
      record_date: "2025-05-02",
      morning_litres: 0.6,
      evening_litres: 0.5,
      total_litres: 1.1,
      notes: "lactationDay:62",
    },
    {
      id: "mlk-007",
      goat_id: "goat-002",
      record_date: "2025-05-03",
      morning_litres: 0.7,
      evening_litres: 0.5,
      total_litres: 1.2,
      notes: "lactationDay:63",
    },
  ];
  for (const m of milkRecords) {
    await db.execute(sql`
      INSERT INTO goat_daily_milk (id, farm_owner_id, goat_id, record_date, morning_litres, evening_litres, total_litres, created_at)
      VALUES (${m.id}, 'farm-001', ${m.goat_id}, ${m.record_date}, ${m.morning_litres}, ${m.evening_litres}, ${m.total_litres}, ${now})
      ON DUPLICATE KEY UPDATE morning_litres = VALUES(morning_litres), evening_litres = VALUES(evening_litres), total_litres = VALUES(total_litres)
    `);
  }
  console.log(`goat_daily_milk seeded (${milkRecords.length})`);

  // ── Shearing records ──────────────────────────────────────────────────
  const shearingRecords = [
    {
      id: "sh-001",
      goat_id: "goat-006",
      shearing_date: "2024-09-05",
      fleece_weight_kg: 3.6,
      notes: "stapleLength:112.0 micron:29.0 colorGrade:White pricePerKg:415.0",
    },
    {
      id: "sh-002",
      goat_id: "goat-006",
      shearing_date: "2024-03-10",
      fleece_weight_kg: 3.8,
      notes: "stapleLength:118.0 micron:28.5 colorGrade:White pricePerKg:420.0",
    },
    {
      id: "sh-003",
      goat_id: "goat-007",
      shearing_date: "2024-08-20",
      fleece_weight_kg: 4.4,
      notes: "stapleLength:122.0 micron:26.5 colorGrade:White pricePerKg:445.0",
    },
  ];
  for (const s of shearingRecords) {
    await db.execute(sql`
      INSERT INTO goat_shearing_records (id, farm_owner_id, goat_id, shearing_date, fleece_weight_kg, notes, created_at)
      VALUES (${s.id}, 'farm-001', ${s.goat_id}, ${s.shearing_date}, ${s.fleece_weight_kg}, ${s.notes}, ${now})
      ON DUPLICATE KEY UPDATE fleece_weight_kg = VALUES(fleece_weight_kg), notes = VALUES(notes)
    `);
  }
  console.log(`goat_shearing_records seeded (${shearingRecords.length})`);

  // ── Health events ─────────────────────────────────────────────────────
  const healthEvents = [
    {
      id: "he-001",
      goat_id: "goat-008",
      event_date: "2025-04-10",
      event_type: "illness",
      diagnosis: "Haemonchosis",
      treatment: "Closantel 10mg/kg oral",
      outcome: "monitoring",
      notes: "severity:moderate",
    },
    {
      id: "he-002",
      goat_id: "goat-004",
      event_date: "2025-03-22",
      event_type: "illness",
      diagnosis: "Foot rot",
      treatment: "Zinc sulphate foot bath",
      outcome: "resolved",
      notes: "severity:mild",
    },
    {
      id: "he-003",
      goat_id: "goat-011",
      event_date: "2025-02-05",
      event_type: "illness",
      diagnosis: "Pinkeye (Infectious Keratoconjunctivitis)",
      treatment: "Oxytetracycline eye ointment",
      outcome: "resolved",
      notes: "severity:moderate",
    },
    {
      id: "he-004",
      goat_id: "goat-002",
      event_date: "2025-03-05",
      event_type: "illness",
      diagnosis: "Dystocia",
      treatment: "Manual correction; veterinary assist",
      outcome: "resolved",
      notes: "severity:severe vet:Dr. van der Merwe",
    },
    {
      id: "he-005",
      goat_id: "goat-005",
      event_date: "2025-01-18",
      event_type: "illness",
      diagnosis: "Worms (mixed)",
      treatment: "Albendazole 5mg/kg oral",
      outcome: "resolved",
      notes: "severity:mild",
    },
    {
      id: "he-006",
      goat_id: "goat-013",
      event_date: "2025-04-02",
      event_type: "observation",
      diagnosis: "Lumpy Skin Disease (suspected)",
      treatment: "Supportive care; isolation",
      outcome: "monitoring",
      notes: "severity:mild vet:Dr. Pretorius",
    },
  ];
  for (const h of healthEvents) {
    await db.execute(sql`
      INSERT INTO goat_health_events (id, farm_owner_id, goat_id, event_date, event_type, diagnosis, treatment, outcome, notes, created_at)
      VALUES (${h.id}, 'farm-001', ${h.goat_id}, ${h.event_date}, ${h.event_type}, ${h.diagnosis}, ${h.treatment}, ${h.outcome}, ${h.notes}, ${now})
      ON DUPLICATE KEY UPDATE diagnosis = VALUES(diagnosis), treatment = VALUES(treatment), outcome = VALUES(outcome), notes = VALUES(notes)
    `);
  }
  console.log(`goat_health_events seeded (${healthEvents.length})`);

  // ── Medication logs ───────────────────────────────────────────────────
  const medicationLogs = [
    {
      id: "med-001",
      goat_id: "goat-008",
      administered_at: "2025-04-10",
      medication_name: "Closantel 10%",
      dosage: "68ml oral (10mg/kg)",
      administered_by: "Farm Manager",
      notes: "route:oral reason:Haemonchosis withdrawalDays:28",
    },
    {
      id: "med-002",
      goat_id: "goat-001",
      administered_at: "2025-01-10",
      medication_name: "Ivermectin 1%",
      dosage: "0.2mg/kg SC",
      administered_by: "Farm Manager",
      notes: "route:injection reason:Routine deworming withdrawalDays:35",
    },
    {
      id: "med-003",
      goat_id: "goat-005",
      administered_at: "2025-01-18",
      medication_name: "Albendazole 2.5%",
      dosage: "7.5mg/kg oral",
      administered_by: null,
      notes: "route:oral reason:Mixed worm burden withdrawalDays:14",
    },
    {
      id: "med-004",
      goat_id: "goat-004",
      administered_at: "2025-03-22",
      medication_name: "Zinc sulphate 20%",
      dosage: "Foot bath 15 min",
      administered_by: null,
      notes: "route:topical reason:Foot rot withdrawalDays:0",
    },
    {
      id: "med-005",
      goat_id: "goat-011",
      administered_at: "2025-02-05",
      medication_name: "Oxytetracycline eye ointment",
      dosage: "Apply BD × 5 days",
      administered_by: null,
      notes: "route:topical reason:Pinkeye withdrawalDays:0",
    },
  ];
  for (const ml of medicationLogs) {
    await db.execute(sql`
      INSERT INTO goat_medication_logs (id, farm_owner_id, goat_id, medication_name, dosage, administered_at, administered_by, notes, created_at)
      VALUES (${ml.id}, 'farm-001', ${ml.goat_id}, ${ml.medication_name}, ${ml.dosage}, ${ml.administered_at}, ${ml.administered_by}, ${ml.notes}, ${now})
      ON DUPLICATE KEY UPDATE medication_name = VALUES(medication_name), dosage = VALUES(dosage), notes = VALUES(notes)
    `);
  }
  console.log(`goat_medication_logs seeded (${medicationLogs.length})`);

  // ── Vaccinations ──────────────────────────────────────────────────────
  // vaccination_date = givenDate if present, else dueDate
  const vaccinations = [
    {
      id: "vac-001",
      goat_id: "goat-004",
      vaccine_name: "Pasteurella",
      vaccination_date: "2024-04-20",
      next_due_date: "2025-04-20",
      batch_number: null,
      notes: null,
    },
    {
      id: "vac-002",
      goat_id: "goat-001",
      vaccine_name: "Pasteurella",
      vaccination_date: "2025-06-01",
      next_due_date: null,
      batch_number: "PAV-2025-01",
      notes: null,
    },
    {
      id: "vac-003",
      goat_id: "goat-001",
      vaccine_name: "Pulpy kidney (Clostridium D)",
      vaccination_date: "2024-12-03",
      next_due_date: null,
      batch_number: "CLO-2024-22",
      notes: "administeredBy:Farm Manager",
    },
    {
      id: "vac-004",
      goat_id: "goat-003",
      vaccine_name: "Pulpy kidney (Clostridium D)",
      vaccination_date: "2025-05-05",
      next_due_date: null,
      batch_number: "CLO-2025-08",
      notes: "administeredBy:Farm Manager",
    },
    {
      id: "vac-005",
      goat_id: "goat-008",
      vaccine_name: "Brucellosis Rev.1",
      vaccination_date: "2025-03-04",
      next_due_date: null,
      batch_number: "BRU-2025-02",
      notes: null,
    },
    {
      id: "vac-006",
      goat_id: "goat-012",
      vaccine_name: "Pasteurella",
      vaccination_date: "2025-07-01",
      next_due_date: null,
      batch_number: null,
      notes: null,
    },
    {
      id: "vac-007",
      goat_id: "goat-013",
      vaccine_name: "Pulpy kidney (Clostridium D)",
      vaccination_date: "2025-06-15",
      next_due_date: null,
      batch_number: null,
      notes: null,
    },
    {
      id: "vac-008",
      goat_id: "goat-006",
      vaccine_name: "Orf (Contagious ecthyma)",
      vaccination_date: "2025-04-12",
      next_due_date: null,
      batch_number: "ORF-2025-01",
      notes: null,
    },
  ];
  for (const v of vaccinations) {
    await db.execute(sql`
      INSERT INTO goat_vaccinations (id, farm_owner_id, goat_id, vaccine_name, vaccination_date, next_due_date, batch_number, notes, created_at)
      VALUES (${v.id}, 'farm-001', ${v.goat_id}, ${v.vaccine_name}, ${v.vaccination_date}, ${v.next_due_date}, ${v.batch_number}, ${v.notes}, ${now})
      ON DUPLICATE KEY UPDATE vaccine_name = VALUES(vaccine_name), vaccination_date = VALUES(vaccination_date), next_due_date = VALUES(next_due_date), batch_number = VALUES(batch_number), notes = VALUES(notes)
    `);
  }
  console.log(`goat_vaccinations seeded (${vaccinations.length})`);

  // ── Sale records ──────────────────────────────────────────────────────
  const saleRecords = [
    {
      id: "sale-001",
      goat_id: "goat-005",
      sale_date: "2025-03-15",
      buyer_name: "N. Steyn (NC Abattoir)",
      sale_price: 1976.0,
      notes: "saleWeightKg:38.0 pricePerKg:52.0 invoiceRef:INV-2025-014",
    },
    {
      id: "sale-002",
      goat_id: "goat-010",
      sale_date: "2025-04-20",
      buyer_name: "Tribal Authority Market",
      sale_price: 1500.0,
      notes: null,
    },
  ];
  for (const s of saleRecords) {
    await db.execute(sql`
      INSERT INTO goat_sale_records (id, farm_owner_id, goat_id, sale_date, buyer_name, sale_price, notes, created_at)
      VALUES (${s.id}, 'farm-001', ${s.goat_id}, ${s.sale_date}, ${s.buyer_name}, ${s.sale_price}, ${s.notes}, ${now})
      ON DUPLICATE KEY UPDATE buyer_name = VALUES(buyer_name), sale_price = VALUES(sale_price), notes = VALUES(notes)
    `);
  }
  console.log(`goat_sale_records seeded (${saleRecords.length})`);

  // ── Feed records ──────────────────────────────────────────────────────
  // Dart feed records are herd-level; mapped to representative animal per herd.
  // herdId stored in notes.
  const feedRecords = [
    {
      id: "feed-001",
      goat_id: "goat-001",
      feed_date: "2025-05-01",
      feed_type: "Game cubes",
      quantity_kg: 45.0,
      notes: "herdId:herd-a costPerKg:8.50",
    },
    {
      id: "feed-002",
      goat_id: "goat-001",
      feed_date: "2025-05-02",
      feed_type: "Game cubes",
      quantity_kg: 45.0,
      notes: "herdId:herd-a costPerKg:8.50",
    },
    {
      id: "feed-003",
      goat_id: "goat-008",
      feed_date: "2025-05-01",
      feed_type: "Dairy goat pellet",
      quantity_kg: 20.0,
      notes: "herdId:herd-d costPerKg:12.0",
    },
    {
      id: "feed-004",
      goat_id: "goat-008",
      feed_date: "2025-05-02",
      feed_type: "Dairy goat pellet",
      quantity_kg: 20.0,
      notes: "herdId:herd-d costPerKg:12.0",
    },
    {
      id: "feed-005",
      goat_id: "goat-006",
      feed_date: "2025-05-01",
      feed_type: "Veld hay",
      quantity_kg: 30.0,
      notes: "herdId:herd-c costPerKg:3.20",
    },
    {
      id: "feed-006",
      goat_id: "goat-012",
      feed_date: "2025-05-01",
      feed_type: "Game cubes",
      quantity_kg: 55.0,
      notes: "herdId:herd-f costPerKg:8.50",
    },
  ];
  for (const f of feedRecords) {
    await db.execute(sql`
      INSERT INTO goat_feed_records (id, farm_owner_id, goat_id, feed_type, quantity_kg, feed_date, notes, created_at)
      VALUES (${f.id}, 'farm-001', ${f.goat_id}, ${f.feed_type}, ${f.quantity_kg}, ${f.feed_date}, ${f.notes}, ${now})
      ON DUPLICATE KEY UPDATE feed_type = VALUES(feed_type), quantity_kg = VALUES(quantity_kg), notes = VALUES(notes)
    `);
  }
  console.log(`goat_feed_records seeded (${feedRecords.length})`);

  // ── Pasture records ───────────────────────────────────────────────────
  // Dart pasture records have herdId + campId; campId used as pasture_name.
  // entryDate used as move_date; remaining fields in notes.
  const pastureRecords = [
    {
      id: "pas-001",
      pasture_name: "Camp-A1",
      move_date: "2025-04-01",
      notes: "herdId:herd-a estimatedHa:12.5 veldCondition:good",
    },
    {
      id: "pas-002",
      pasture_name: "Camp-B3",
      move_date: "2025-03-15",
      notes:
        "herdId:herd-b estimatedHa:25.0 veldCondition:fair exitDate:2025-04-14",
    },
    {
      id: "pas-003",
      pasture_name: "Camp-B4",
      move_date: "2025-04-15",
      notes: "herdId:herd-b estimatedHa:28.0 veldCondition:good",
    },
    {
      id: "pas-004",
      pasture_name: "Communal-1",
      move_date: "2025-01-01",
      notes: "herdId:herd-e estimatedHa:8.0 veldCondition:poor",
    },
  ];
  for (const p of pastureRecords) {
    await db.execute(sql`
      INSERT INTO goat_pasture_records (id, farm_owner_id, pasture_name, move_date, notes, created_at)
      VALUES (${p.id}, 'farm-001', ${p.pasture_name}, ${p.move_date}, ${p.notes}, ${now})
      ON DUPLICATE KEY UPDATE pasture_name = VALUES(pasture_name), move_date = VALUES(move_date), notes = VALUES(notes)
    `);
  }
  console.log(`goat_pasture_records seeded (${pastureRecords.length})`);

  // ── FAMACHA records ───────────────────────────────────────────────────
  const famachaRecords = [
    {
      id: "fam-001",
      goat_id: "goat-008",
      record_date: "2025-05-02",
      score: 4,
      notes: "actionTaken:drenched Closantel administered",
    },
    {
      id: "fam-002",
      goat_id: "goat-004",
      record_date: "2025-05-02",
      score: 3,
      notes: "actionTaken:monitored",
    },
    {
      id: "fam-003",
      goat_id: "goat-011",
      record_date: "2025-05-02",
      score: 3,
      notes: "actionTaken:monitored",
    },
    {
      id: "fam-004",
      goat_id: "goat-001",
      record_date: "2025-05-02",
      score: 2,
      notes: "actionTaken:none",
    },
    {
      id: "fam-005",
      goat_id: "goat-002",
      record_date: "2025-05-02",
      score: 2,
      notes: "actionTaken:none",
    },
    {
      id: "fam-006",
      goat_id: "goat-005",
      record_date: "2025-05-02",
      score: 2,
      notes: "actionTaken:none",
    },
  ];
  for (const f of famachaRecords) {
    await db.execute(sql`
      INSERT INTO goat_famacha_records (id, farm_owner_id, goat_id, score, record_date, notes, created_at)
      VALUES (${f.id}, 'farm-001', ${f.goat_id}, ${f.score}, ${f.record_date}, ${f.notes}, ${now})
      ON DUPLICATE KEY UPDATE score = VALUES(score), notes = VALUES(notes)
    `);
  }
  console.log(`goat_famacha_records seeded (${famachaRecords.length})`);
}
