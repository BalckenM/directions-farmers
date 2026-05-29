import { sql } from "drizzle-orm";
import { db } from "../../config/database";

/**
 * Seed 009: poultry_flocks and all related records.
 *
 * All data mirrors poultry_mock_data_source.dart exactly:
 *   14 flocks (broiler, layer, duck_meat, breeder, pullet, free_range,
 *              turkey_meat, quail, hatchery)
 *   with daily records, vaccination schedules, feed phases, harvest records,
 *   medication logs, disease events, environment readings, inventory,
 *   egg sales and chick sales.
 *
 * Column mapping from Dart → DB:
 *   batchName → name         strain → breed       productionType → purpose
 *   houseId   → house_number  placementCount → initial_count
 *
 * BroilerSpecific / LayerSpecific / BreederSpecific / DuckSpecific are stored
 * as JSON in the `specific_data` column added by migration 0016.
 */
const now = "2025-05-28 00:00:00";

export async function runPoultrySeed(): Promise<void> {
  // ── Flocks ───────────────────────────────────────────────────────────────
  type FlockRow = {
    id: string;
    name: string;
    species: string;
    breed: string | null;
    purpose: string;
    house_number: string | null;
    status: string;
    placement_date: string | null;
    initial_count: number;
    current_count: number;
    mortality_total: number;
    mortality_pct: number | null;
    day_of_age: number | null;
    week_of_age: number | null;
    current_stage: string | null;
    current_avg_weight_g: number | null;
    feed_consumed_total_kg: number | null;
    fcr_to_date: number | null;
    target_slaughter_weight_g: number | null;
    projected_slaughter_date: string | null;
    unit_cost_per_chick: number | null;
    livability_pct: number | null;
    specific_data: string | null;
  };

  const flocks: FlockRow[] = [
    {
      id: "flock-001",
      name: "Broiler Batch March 2024",
      species: "chicken",
      breed: "Ross 308",
      purpose: "broiler",
      house_number: "house-a",
      status: "active",
      placement_date: "2024-03-01",
      initial_count: 5000,
      current_count: 4920,
      mortality_total: 80,
      mortality_pct: 1.6,
      day_of_age: 28,
      week_of_age: null,
      current_stage: null,
      current_avg_weight_g: 920,
      feed_consumed_total_kg: 3800.0,
      fcr_to_date: 1.42,
      target_slaughter_weight_g: 2400,
      projected_slaughter_date: "2024-04-08",
      unit_cost_per_chick: 16.5,
      livability_pct: null,
      specific_data: JSON.stringify({
        broilerSpecific: {
          target7dWeightG: 170,
          target14dWeightG: 380,
          target21dWeightG: 680,
          target28dWeightG: 1060,
          target35dWeightG: 1500,
          target42dWeightG: 2200,
          actual7dWeightG: 172,
          actual14dWeightG: 388,
          actual21dWeightG: 695,
          actual28dWeightG: 920,
          uniformityPct: 82.5,
          targetFcr42d: 1.65,
          epefCurrent: 298,
          lightingProgram: "23L:1D day 1-7, 18L:6D from day 8",
          ventilationMode: "tunnel",
        },
      }),
    },
    {
      id: "flock-002",
      name: "Layer Flock Lohmann 2024",
      species: "chicken",
      breed: "Lohmann Brown Classic",
      purpose: "layer",
      house_number: "house-b",
      status: "active",
      placement_date: "2024-01-15",
      initial_count: 3000,
      current_count: 2960,
      mortality_total: 40,
      mortality_pct: 1.33,
      day_of_age: 75,
      week_of_age: 10,
      current_stage: "laying",
      current_avg_weight_g: null,
      feed_consumed_total_kg: null,
      fcr_to_date: null,
      target_slaughter_weight_g: null,
      projected_slaughter_date: null,
      unit_cost_per_chick: null,
      livability_pct: 98.67,
      specific_data: JSON.stringify({
        layerSpecific: {
          pointOfLayDate: "2024-03-20",
          peakProductionDate: "2024-05-01",
          peakHdpPct: 92.4,
          currentHdpPct: 78.5,
          totalEggsProduced: 56420,
          avgEggWeightG: 61.2,
          feedPerDozenKg: 1.82,
          lightingProgram: "16L:8D",
          henHousedAvgPct: 74.8,
          eggMassGPerHenPerDay: 48.0,
        },
      }),
    },
    {
      id: "flock-003",
      name: "Duck Batch Cherry Valley Q1 2024",
      species: "duck",
      breed: "Cherry Valley",
      purpose: "duck_meat",
      house_number: "house-c",
      status: "active",
      placement_date: "2024-02-10",
      initial_count: 2000,
      current_count: 1965,
      mortality_total: 35,
      mortality_pct: 1.75,
      day_of_age: 32,
      week_of_age: null,
      current_stage: null,
      current_avg_weight_g: 1450,
      feed_consumed_total_kg: 2200.0,
      fcr_to_date: 2.1,
      target_slaughter_weight_g: 3200,
      projected_slaughter_date: "2024-03-31",
      unit_cost_per_chick: null,
      livability_pct: null,
      specific_data: JSON.stringify({
        duckSpecific: {
          waterAccess: true,
          target42dWeightG: 3200,
          targetFcr42d: 2.2,
        },
      }),
    },
    {
      id: "flock-004",
      name: "Broiler Batch Cobb500 Jan 2024",
      species: "chicken",
      breed: "Cobb 500",
      purpose: "broiler",
      house_number: "house-d",
      status: "harvested",
      placement_date: "2024-01-02",
      initial_count: 4800,
      current_count: 0,
      mortality_total: 120,
      mortality_pct: 2.5,
      day_of_age: 42,
      week_of_age: null,
      current_stage: null,
      current_avg_weight_g: 2380,
      feed_consumed_total_kg: 17200.0,
      fcr_to_date: 1.72,
      target_slaughter_weight_g: 2400,
      projected_slaughter_date: "2024-02-13",
      unit_cost_per_chick: null,
      livability_pct: null,
      specific_data: JSON.stringify({
        broilerSpecific: {
          target42dWeightG: 2400,
          actual42dWeightG: 2380,
          uniformityPct: 80.1,
          targetFcr42d: 1.7,
          epefCurrent: 261,
          lightingProgram: "23L:1D day 1-7, 18L:6D from day 8",
          ventilationMode: "tunnel",
        },
      }),
    },
    {
      id: "flock-005",
      name: "Layer Flock Hy-Line 2023",
      species: "chicken",
      breed: "Hy-Line Brown",
      purpose: "layer",
      house_number: "house-e",
      status: "depleted",
      placement_date: "2023-01-10",
      initial_count: 2500,
      current_count: 0,
      mortality_total: 312,
      mortality_pct: 12.5,
      day_of_age: 420,
      week_of_age: 60,
      current_stage: "depleted",
      current_avg_weight_g: null,
      feed_consumed_total_kg: null,
      fcr_to_date: null,
      target_slaughter_weight_g: null,
      projected_slaughter_date: null,
      unit_cost_per_chick: null,
      livability_pct: 87.5,
      specific_data: JSON.stringify({
        layerSpecific: {
          pointOfLayDate: "2023-06-05",
          peakProductionDate: "2023-08-12",
          peakHdpPct: 91.8,
          currentHdpPct: 0.0,
          totalEggsProduced: 582000,
          avgEggWeightG: 62.4,
          feedPerDozenKg: 1.91,
          lightingProgram: "16L:8D",
          henHousedAvgPct: 63.2,
        },
      }),
    },
    {
      id: "flock-006",
      name: "Ross PM3 Breeder Flock 2024",
      species: "chicken",
      breed: "Ross PM3",
      purpose: "breeder",
      house_number: "house-f",
      status: "active",
      placement_date: "2023-09-01",
      initial_count: 1200,
      current_count: 1162,
      mortality_total: 38,
      mortality_pct: 3.17,
      day_of_age: 185,
      week_of_age: 26,
      current_stage: "production",
      current_avg_weight_g: null,
      feed_consumed_total_kg: null,
      fcr_to_date: null,
      target_slaughter_weight_g: null,
      projected_slaughter_date: null,
      unit_cost_per_chick: null,
      livability_pct: null,
      specific_data: JSON.stringify({
        breederSpecific: {
          henCount: 1050,
          roosterCount: 112,
          maleFemaleRatio: "1:9.4",
          pointOfLayDate: "2024-01-20",
          peakProductionDate: "2024-03-15",
          peakHdpPct: 84.5,
          currentHdpPct: 82.1,
          fertilityPct: 94.2,
          hatchabilityPct: 88.6,
          totalHatchingEggs: 48500,
          totalChicksProduced: 42970,
          totalChicksSold: 40000,
          avgChickWeightG: 43.5,
          lightingProgram: "8L:16D rearing, 14L:10D production",
          projectedDepletionDate: "2025-06-01",
        },
      }),
    },
    {
      id: "flock-007",
      name: "Broiler Batch Ross308 April 2024",
      species: "chicken",
      breed: "Ross 308",
      purpose: "broiler",
      house_number: "house-g",
      status: "active",
      placement_date: "2024-04-01",
      initial_count: 5200,
      current_count: 5145,
      mortality_total: 55,
      mortality_pct: 1.06,
      day_of_age: 15,
      week_of_age: null,
      current_stage: null,
      current_avg_weight_g: 385,
      feed_consumed_total_kg: 1620.0,
      fcr_to_date: 1.3,
      target_slaughter_weight_g: 2400,
      projected_slaughter_date: "2024-05-10",
      unit_cost_per_chick: null,
      livability_pct: null,
      specific_data: JSON.stringify({
        broilerSpecific: {
          target7dWeightG: 170,
          target14dWeightG: 380,
          actual7dWeightG: 175,
          actual14dWeightG: 385,
          uniformityPct: 85.0,
          targetFcr42d: 1.65,
          epefCurrent: 312,
          lightingProgram: "23L:1D day 1-7, 18L:6D from day 8",
          ventilationMode: "tunnel",
        },
      }),
    },
    {
      id: "flock-008",
      name: "Free-Range ISA Brown Flock 2024",
      species: "chicken",
      breed: "ISA Brown",
      purpose: "free_range",
      house_number: "house-h",
      status: "active",
      placement_date: "2023-10-01",
      initial_count: 2800,
      current_count: 2761,
      mortality_total: 39,
      mortality_pct: 1.39,
      day_of_age: 185,
      week_of_age: 26,
      current_stage: "laying",
      current_avg_weight_g: null,
      feed_consumed_total_kg: null,
      fcr_to_date: null,
      target_slaughter_weight_g: null,
      projected_slaughter_date: null,
      unit_cost_per_chick: null,
      livability_pct: 98.61,
      specific_data: null,
    },
    {
      id: "flock-009",
      name: "Pullet Rearing Cobb500 April 2024",
      species: "chicken",
      breed: "Cobb 500",
      purpose: "pullet",
      house_number: "house-i",
      status: "active",
      placement_date: "2024-04-05",
      initial_count: 4600,
      current_count: 4558,
      mortality_total: 42,
      mortality_pct: 0.91,
      day_of_age: 11,
      week_of_age: null,
      current_stage: null,
      current_avg_weight_g: 225,
      feed_consumed_total_kg: 680.0,
      fcr_to_date: 1.24,
      target_slaughter_weight_g: null,
      projected_slaughter_date: null,
      unit_cost_per_chick: null,
      livability_pct: null,
      specific_data: null,
    },
    {
      id: "flock-010",
      name: "Arbor Acres Breeder Flock 2023",
      species: "chicken",
      breed: "Arbor Acres Plus",
      purpose: "breeder",
      house_number: "house-j",
      status: "active",
      placement_date: "2023-07-15",
      initial_count: 1000,
      current_count: 965,
      mortality_total: 35,
      mortality_pct: 3.5,
      day_of_age: 259,
      week_of_age: 37,
      current_stage: "production",
      current_avg_weight_g: null,
      feed_consumed_total_kg: null,
      fcr_to_date: null,
      target_slaughter_weight_g: null,
      projected_slaughter_date: null,
      unit_cost_per_chick: null,
      livability_pct: null,
      specific_data: JSON.stringify({
        breederSpecific: {
          henCount: 880,
          roosterCount: 85,
          maleFemaleRatio: "1:10.4",
          pointOfLayDate: "2023-11-10",
          peakProductionDate: "2024-01-20",
          peakHdpPct: 83.8,
          currentHdpPct: 79.5,
          fertilityPct: 93.0,
          hatchabilityPct: 86.4,
          totalHatchingEggs: 96200,
          totalChicksProduced: 83100,
          totalChicksSold: 79000,
          avgChickWeightG: 42.8,
          lightingProgram: "8L:16D rearing, 14L:10D production",
          projectedDepletionDate: "2025-02-01",
        },
      }),
    },
    {
      id: "flock-011",
      name: "Turkey Batch Nicholas 700 2024",
      species: "turkey",
      breed: "Nicholas 700",
      purpose: "turkey_meat",
      house_number: "house-k",
      status: "active",
      placement_date: "2024-01-20",
      initial_count: 800,
      current_count: 782,
      mortality_total: 18,
      mortality_pct: 2.25,
      day_of_age: 76,
      week_of_age: null,
      current_stage: null,
      current_avg_weight_g: 5800,
      feed_consumed_total_kg: 6200.0,
      fcr_to_date: 2.48,
      target_slaughter_weight_g: 14000,
      projected_slaughter_date: "2024-07-15",
      unit_cost_per_chick: null,
      livability_pct: null,
      specific_data: null,
    },
    {
      id: "flock-012",
      name: "Layer Flock Bovans Brown 2024",
      species: "chicken",
      breed: "Bovans Brown",
      purpose: "layer",
      house_number: "house-l",
      status: "active",
      placement_date: "2023-12-01",
      initial_count: 3500,
      current_count: 3448,
      mortality_total: 52,
      mortality_pct: 1.49,
      day_of_age: 133,
      week_of_age: 19,
      current_stage: "laying",
      current_avg_weight_g: null,
      feed_consumed_total_kg: null,
      fcr_to_date: null,
      target_slaughter_weight_g: null,
      projected_slaughter_date: null,
      unit_cost_per_chick: null,
      livability_pct: 98.51,
      specific_data: JSON.stringify({
        layerSpecific: {
          pointOfLayDate: "2024-03-01",
          currentHdpPct: 88.4,
          totalEggsProduced: 127400,
          avgEggWeightG: 60.8,
          feedPerDozenKg: 1.85,
          lightingProgram: "16L:8D",
          henHousedAvgPct: 85.0,
          eggMassGPerHenPerDay: 53.8,
        },
      }),
    },
    {
      id: "flock-013",
      name: "Quail Batch Japanese 2024",
      species: "quail",
      breed: "Japanese Quail",
      purpose: "quail",
      house_number: "house-m",
      status: "active",
      placement_date: "2024-02-01",
      initial_count: 1500,
      current_count: 1482,
      mortality_total: 18,
      mortality_pct: 1.2,
      day_of_age: 60,
      week_of_age: null,
      current_stage: null,
      current_avg_weight_g: 240,
      feed_consumed_total_kg: 540.0,
      fcr_to_date: 3.24,
      target_slaughter_weight_g: null,
      projected_slaughter_date: null,
      unit_cost_per_chick: null,
      livability_pct: null,
      specific_data: null,
    },
    {
      id: "flock-014",
      name: "Main Hatchery — Ross PM3",
      species: "chicken",
      breed: "Ross PM3",
      purpose: "hatchery",
      house_number: "house-n",
      status: "active",
      placement_date: "2024-01-01",
      initial_count: 50000,
      current_count: 50000,
      mortality_total: 0,
      mortality_pct: 0.0,
      day_of_age: 120,
      week_of_age: null,
      current_stage: null,
      current_avg_weight_g: null,
      feed_consumed_total_kg: null,
      fcr_to_date: null,
      target_slaughter_weight_g: null,
      projected_slaughter_date: null,
      unit_cost_per_chick: null,
      livability_pct: null,
      specific_data: null,
    },
  ];

  for (const f of flocks) {
    await db.execute(sql`
      INSERT INTO poultry_flocks
        (id, farm_owner_id, name, species, breed, purpose, house_number,
         placement_date, initial_count, current_count, mortality_total, mortality_pct,
         day_of_age, week_of_age, current_stage, current_avg_weight_g,
         feed_consumed_total_kg, fcr_to_date, target_slaughter_weight_g,
         projected_slaughter_date, unit_cost_per_chick, livability_pct,
         specific_data, status, notes, created_at, updated_at)
      VALUES
        (${f.id}, 'farm-001', ${f.name}, ${f.species}, ${f.breed}, ${f.purpose},
         ${f.house_number}, ${f.placement_date}, ${f.initial_count}, ${f.current_count},
         ${f.mortality_total}, ${f.mortality_pct}, ${f.day_of_age}, ${f.week_of_age},
         ${f.current_stage}, ${f.current_avg_weight_g}, ${f.feed_consumed_total_kg},
         ${f.fcr_to_date}, ${f.target_slaughter_weight_g}, ${f.projected_slaughter_date},
         ${f.unit_cost_per_chick}, ${f.livability_pct}, ${f.specific_data},
         ${f.status}, NULL, ${now}, ${now})
      ON DUPLICATE KEY UPDATE
        name = VALUES(name), breed = VALUES(breed), purpose = VALUES(purpose),
        status = VALUES(status), current_count = VALUES(current_count),
        mortality_total = VALUES(mortality_total), mortality_pct = VALUES(mortality_pct),
        day_of_age = VALUES(day_of_age), week_of_age = VALUES(week_of_age),
        current_stage = VALUES(current_stage),
        current_avg_weight_g = VALUES(current_avg_weight_g),
        feed_consumed_total_kg = VALUES(feed_consumed_total_kg),
        fcr_to_date = VALUES(fcr_to_date),
        target_slaughter_weight_g = VALUES(target_slaughter_weight_g),
        projected_slaughter_date = VALUES(projected_slaughter_date),
        unit_cost_per_chick = VALUES(unit_cost_per_chick),
        livability_pct = VALUES(livability_pct),
        specific_data = VALUES(specific_data),
        updated_at = VALUES(updated_at)
    `);
  }
  console.log(`poultry_flocks seeded (${flocks.length} flocks)`);

  // ── Daily records ─────────────────────────────────────────────────────────
  // DR-001: flock-001, broiler day 28 record
  // DR-002: flock-002, layer day 75 record (eggs AM=1180, PM=480)
  const dailyRecords = [
    {
      id: "DR-001",
      flock_id: "flock-001",
      record_date: "2024-03-28",
      mortality_count: 3,
      culled_count: 0,
      eggs_collected: 0,
      feed_consumed_kg: 198.5,
      water_consumed_litres: 420.0,
      notes:
        "mortalityCause:sds feedType:grower avgHouseTempC:27.5 avgBodyWeightG:920",
    },
    {
      id: "DR-002",
      flock_id: "flock-002",
      record_date: "2024-03-28",
      mortality_count: 0,
      culled_count: 0,
      eggs_collected: 1660,
      feed_consumed_kg: 285.0,
      water_consumed_litres: null,
      notes:
        "eggsCollectedAm:1180 eggsCollectedPm:480 brokenEggs:12 avgEggWeightG:61.5 hdpPct:56.1",
    },
  ];
  for (const d of dailyRecords) {
    await db.execute(sql`
      INSERT INTO poultry_daily_records
        (id, farm_owner_id, flock_id, record_date, mortality_count, culled_count,
         eggs_collected, feed_consumed_kg, water_consumed_litres, notes, created_at)
      VALUES
        (${d.id}, 'farm-001', ${d.flock_id}, ${d.record_date}, ${d.mortality_count},
         ${d.culled_count}, ${d.eggs_collected}, ${d.feed_consumed_kg},
         ${d.water_consumed_litres}, ${d.notes}, ${now})
      ON DUPLICATE KEY UPDATE
        mortality_count = VALUES(mortality_count), eggs_collected = VALUES(eggs_collected),
        feed_consumed_kg = VALUES(feed_consumed_kg), notes = VALUES(notes)
    `);
  }
  console.log(`poultry_daily_records seeded (${dailyRecords.length})`);

  // ── Vaccination schedules ─────────────────────────────────────────────────
  // VS-001 for flock-001 (placementDate 2024-03-01):
  //   Day 1 → scheduled 2024-03-01  Day 7 → 2024-03-08
  //   Day 14 → 2024-03-15           Day 18 → 2024-03-19
  const vaccSchedules = [
    {
      id: "VS-001-1",
      flock_id: "flock-001",
      vaccine_name: "Marek's Disease",
      scheduled_date: "2024-03-01",
      administered_date: "2024-03-01",
      method: "injection",
      notes: "targetDay:1",
    },
    {
      id: "VS-001-2",
      flock_id: "flock-001",
      vaccine_name: "Newcastle Disease (ND)",
      scheduled_date: "2024-03-08",
      administered_date: "2024-03-08",
      method: "drinking_water",
      notes: "targetDay:7",
    },
    {
      id: "VS-001-3",
      flock_id: "flock-001",
      vaccine_name: "Infectious Bronchitis (IB)",
      scheduled_date: "2024-03-15",
      administered_date: "2024-03-15",
      method: "spray",
      notes: "targetDay:14",
    },
    {
      id: "VS-001-4",
      flock_id: "flock-001",
      vaccine_name: "Gumboro (IBD)",
      scheduled_date: "2024-03-19",
      administered_date: null,
      method: "drinking_water",
      notes: "targetDay:18 status:pending dueDate:2024-03-19",
    },
  ];
  for (const v of vaccSchedules) {
    await db.execute(sql`
      INSERT INTO poultry_vaccination_schedules
        (id, farm_owner_id, flock_id, vaccine_name, scheduled_date, administered_date, method, notes, created_at)
      VALUES
        (${v.id}, 'farm-001', ${v.flock_id}, ${v.vaccine_name}, ${v.scheduled_date},
         ${v.administered_date}, ${v.method}, ${v.notes}, ${now})
      ON DUPLICATE KEY UPDATE
        administered_date = VALUES(administered_date), notes = VALUES(notes)
    `);
  }
  console.log(`poultry_vaccination_schedules seeded (${vaccSchedules.length})`);

  // ── Feed phases ───────────────────────────────────────────────────────────
  const feedPhases = [
    {
      id: "FP-001",
      flock_id: "flock-001",
      phase_name: "Starter",
      feed_type: "starter",
      start_day: 0,
      end_day: 14,
      daily_ration_grams: 28.0,
      notes: "feedProduct:ProStart Broiler 22%",
    },
    {
      id: "FP-002",
      flock_id: "flock-001",
      phase_name: "Grower",
      feed_type: "grower",
      start_day: 15,
      end_day: 28,
      daily_ration_grams: 62.0,
      notes: "feedProduct:ProGrow Broiler 19%",
    },
    {
      id: "FP-003",
      flock_id: "flock-001",
      phase_name: "Finisher",
      feed_type: "finisher",
      start_day: 29,
      end_day: 38,
      daily_ration_grams: 130.0,
      notes: "feedProduct:ProFinish Broiler 17%",
    },
  ];
  for (const fp of feedPhases) {
    await db.execute(sql`
      INSERT INTO poultry_feed_phases
        (id, farm_owner_id, flock_id, phase_name, feed_type, start_day, end_day,
         daily_ration_grams, notes, created_at)
      VALUES
        (${fp.id}, 'farm-001', ${fp.flock_id}, ${fp.phase_name}, ${fp.feed_type},
         ${fp.start_day}, ${fp.end_day}, ${fp.daily_ration_grams}, ${fp.notes}, ${now})
      ON DUPLICATE KEY UPDATE
        daily_ration_grams = VALUES(daily_ration_grams), notes = VALUES(notes)
    `);
  }
  console.log(`poultry_feed_phases seeded (${feedPhases.length})`);

  // ── Harvest records ───────────────────────────────────────────────────────
  // HR-001: flock-004, 4620 birds, 10995.6 kg total → avg 2.38 kg/bird
  const harvestRecords = [
    {
      id: "HR-001",
      flock_id: "flock-004",
      harvest_date: "2024-02-14",
      birds_harvested: 4620,
      average_weight_kg: 2.38,
      total_weight_kg: 10995.6,
      notes:
        "processorName:Valley Abattoir carcassGradeAPct:92.8 condemnationRatePct:1.4 pricePerKgZar:24.50",
    },
  ];
  for (const h of harvestRecords) {
    await db.execute(sql`
      INSERT INTO poultry_harvest_records
        (id, farm_owner_id, flock_id, harvest_date, birds_harvested, average_weight_kg,
         total_weight_kg, notes, created_at)
      VALUES
        (${h.id}, 'farm-001', ${h.flock_id}, ${h.harvest_date}, ${h.birds_harvested},
         ${h.average_weight_kg}, ${h.total_weight_kg}, ${h.notes}, ${now})
      ON DUPLICATE KEY UPDATE
        birds_harvested = VALUES(birds_harvested), total_weight_kg = VALUES(total_weight_kg),
        notes = VALUES(notes)
    `);
  }
  console.log(`poultry_harvest_records seeded (${harvestRecords.length})`);

  // ── Medication logs ───────────────────────────────────────────────────────
  const medicationLogs = [
    {
      id: "ML-001",
      flock_id: "flock-001",
      medication_name: "Amoxicillin",
      dosage: "10 mg/kg BW",
      administered_at: "2024-03-20",
      notes:
        "route:drinking_water diagnosis:Mild respiratory signs withdrawalDays:5 prescribedBy:Dr. Nkosi",
    },
  ];
  for (const m of medicationLogs) {
    await db.execute(sql`
      INSERT INTO poultry_medication_logs
        (id, farm_owner_id, flock_id, medication_name, dosage, administered_at, notes, created_at)
      VALUES
        (${m.id}, 'farm-001', ${m.flock_id}, ${m.medication_name}, ${m.dosage},
         ${m.administered_at}, ${m.notes}, ${now})
      ON DUPLICATE KEY UPDATE
        dosage = VALUES(dosage), notes = VALUES(notes)
    `);
  }
  console.log(`poultry_medication_logs seeded (${medicationLogs.length})`);

  // ── Disease events ────────────────────────────────────────────────────────
  const diseaseEvents = [
    {
      id: "DE-001",
      flock_id: "flock-001",
      event_date: "2024-03-20",
      disease_name: "Chronic Respiratory Disease (CRD)",
      affected_count: 45,
      treatment: null,
      outcome: "Treated — responding well",
      notes:
        "severity:low symptoms:Rales, nasal discharge, reduced feed intake diagnosticTest:Field examination testResult:Presumptive CRD isNotifiable:false",
    },
  ];
  for (const d of diseaseEvents) {
    await db.execute(sql`
      INSERT INTO poultry_disease_events
        (id, farm_owner_id, flock_id, event_date, disease_name, affected_count,
         treatment, outcome, notes, created_at)
      VALUES
        (${d.id}, 'farm-001', ${d.flock_id}, ${d.event_date}, ${d.disease_name},
         ${d.affected_count}, ${d.treatment}, ${d.outcome}, ${d.notes}, ${now})
      ON DUPLICATE KEY UPDATE
        affected_count = VALUES(affected_count), outcome = VALUES(outcome), notes = VALUES(notes)
    `);
  }
  console.log(`poultry_disease_events seeded (${diseaseEvents.length})`);

  // ── Environment readings ──────────────────────────────────────────────────
  const envReadings = [
    {
      id: "ER-001",
      flock_id: "flock-001",
      recorded_at: "2024-03-28 08:00:00",
      temperature_celsius: 27.5,
      humidity_percent: 62.0,
      ammonia_ppm: 8.2,
      notes: "sensorZone:north co2Ppm:1850.0 lightLux:20.0",
    },
    {
      id: "ER-002",
      flock_id: "flock-001",
      recorded_at: "2024-03-28 08:00:00",
      temperature_celsius: 28.1,
      humidity_percent: 64.5,
      ammonia_ppm: 9.8,
      notes: "sensorZone:south co2Ppm:1920.0 lightLux:18.5",
    },
  ];
  for (const e of envReadings) {
    await db.execute(sql`
      INSERT INTO poultry_environment_readings
        (id, farm_owner_id, flock_id, recorded_at, temperature_celsius, humidity_percent,
         ammonia_ppm, notes, created_at)
      VALUES
        (${e.id}, 'farm-001', ${e.flock_id}, ${e.recorded_at}, ${e.temperature_celsius},
         ${e.humidity_percent}, ${e.ammonia_ppm}, ${e.notes}, ${now})
      ON DUPLICATE KEY UPDATE
        temperature_celsius = VALUES(temperature_celsius),
        humidity_percent = VALUES(humidity_percent),
        ammonia_ppm = VALUES(ammonia_ppm), notes = VALUES(notes)
    `);
  }
  console.log(`poultry_environment_readings seeded (${envReadings.length})`);

  // ── Inventory ─────────────────────────────────────────────────────────────
  // Table is poultry_inventory (not poultry_inventory_items).
  // Columns: id, farm_owner_id, item_name, category, quantity, unit, notes, updated_at, created_at
  const inventoryItems = [
    {
      id: "INV-001",
      item_name: "ProGrow Broiler 19% Pellets",
      category: "feed",
      quantity: 3200.0,
      unit: "kg",
      notes: "minThreshold:500.0 pricePerUnit:8.50 lastDeliveryDate:2024-03-20",
    },
    {
      id: "INV-002",
      item_name: "Newcastle ND-Clone 30 Vaccine",
      category: "vaccine",
      quantity: 2000.0,
      unit: "dose",
      notes: "minThreshold:200.0 pricePerUnit:0.85 lastDeliveryDate:2024-03-01",
    },
    {
      id: "INV-003",
      item_name: "Amoxicillin 20% Soluble Powder",
      category: "medication",
      quantity: 150.0,
      unit: "g",
      notes: "minThreshold:200.0 pricePerUnit:12.00 belowMinThreshold:true",
    },
  ];
  for (const i of inventoryItems) {
    await db.execute(sql`
      INSERT INTO poultry_inventory
        (id, farm_owner_id, item_name, category, quantity, unit, notes, updated_at, created_at)
      VALUES
        (${i.id}, 'farm-001', ${i.item_name}, ${i.category}, ${i.quantity}, ${i.unit},
         ${i.notes}, ${now}, ${now})
      ON DUPLICATE KEY UPDATE
        quantity = VALUES(quantity), notes = VALUES(notes), updated_at = VALUES(updated_at)
    `);
  }
  console.log(`poultry_inventory seeded (${inventoryItems.length})`);

  // ── Egg sales ─────────────────────────────────────────────────────────────
  // ES-001: flock-002, 120 dozens @ R42/dozen
  //   eggs_count = 120 * 12 = 1440, price_per_egg = 42/12 = 3.5, total = 5040
  const eggSales = [
    {
      id: "ES-001",
      flock_id: "flock-002",
      sale_date: "2024-03-25",
      eggs_count: 1440,
      price_per_egg: 3.5,
      total_amount: 5040.0,
      buyer_name: "Sunshine Supermarket",
      notes:
        "dozensTotal:120 pricePerDozen:42.00 gradeBreakdown:large:900,medium:480,small:60 invoiceRef:INV-2024-0325",
    },
  ];
  for (const e of eggSales) {
    await db.execute(sql`
      INSERT INTO poultry_egg_sales
        (id, farm_owner_id, flock_id, sale_date, eggs_count, price_per_egg,
         total_amount, buyer_name, notes, created_at)
      VALUES
        (${e.id}, 'farm-001', ${e.flock_id}, ${e.sale_date}, ${e.eggs_count},
         ${e.price_per_egg}, ${e.total_amount}, ${e.buyer_name}, ${e.notes}, ${now})
      ON DUPLICATE KEY UPDATE
        eggs_count = VALUES(eggs_count), total_amount = VALUES(total_amount),
        buyer_name = VALUES(buyer_name), notes = VALUES(notes)
    `);
  }
  console.log(`poultry_egg_sales seeded (${eggSales.length})`);

  // ── Chick sales ───────────────────────────────────────────────────────────
  // CS-001: flock-006, 1200 chicks @ R18.50
  const chickSales = [
    {
      id: "CS-001",
      flock_id: "flock-006",
      sale_date: "2024-03-21",
      chicks_count: 1200,
      price_per_chick: 18.5,
      total_amount: 22200.0,
      buyer_name: "Green Valley Broiler Farm",
      notes: "hatchDate:2024-03-20 chickSex:mixed avgChickWeightG:42.0",
    },
  ];
  for (const c of chickSales) {
    await db.execute(sql`
      INSERT INTO poultry_chick_sales
        (id, farm_owner_id, flock_id, sale_date, chicks_count, price_per_chick,
         total_amount, buyer_name, notes, created_at)
      VALUES
        (${c.id}, 'farm-001', ${c.flock_id}, ${c.sale_date}, ${c.chicks_count},
         ${c.price_per_chick}, ${c.total_amount}, ${c.buyer_name}, ${c.notes}, ${now})
      ON DUPLICATE KEY UPDATE
        chicks_count = VALUES(chicks_count), total_amount = VALUES(total_amount),
        buyer_name = VALUES(buyer_name), notes = VALUES(notes)
    `);
  }
  console.log(`poultry_chick_sales seeded (${chickSales.length})`);
}
