import type { Connection } from "mysql2/promise";

import { addColumnIfNotExists } from "./_helpers";

/**
 * Migration 0014: Add missing columns to cattle_animals.
 *
 * The Dart CattleAnimal model contains many fields that were absent from
 * the original migration (0004_create_cattle_tables.ts).  All new columns
 * are added with sensible defaults so existing rows remain valid.
 *
 * New fields:
 *   production_type        — 'beef' | 'dairy' | 'dual'
 *   herd_id                — FK-like reference to a named herd
 *   current_weight_kg      — latest recorded live weight
 *   target_weight_kg       — target weight for the current phase
 *   body_condition_score   — latest BCS (1.0 – 5.0)
 *   is_pregnant            — current pregnancy status flag
 *   expected_calving_date  — next expected calving date
 *   last_calving_date      — date of most recent calving
 *   total_calves_raised    — lifetime calves raised
 *   is_lactating           — current lactation status flag
 *   current_milk_litre_pd  — current daily milk yield (litres)
 *   lactation_number       — number of completed lactations
 *   brucella_tested        — whether Brucellosis test has been done
 *   brucella_test_date     — date of last Brucellosis test
 *   fmd_zone               — FMD zone classification (e.g. 'free', 'buffer')
 *   registration_number    — breed-society / stud-book registration
 *   brand_number           — fire or freeze-brand reference
 *   brand_position         — body position of the brand
 *   dam_id                 — self-referencing id of the dam animal
 *   specific_data          — JSON blob for BeefSpecific / DairySpecific fields
 *
 * Idempotency: each column is added only if it does not yet exist.
 */
export async function up(connection: Connection): Promise<void> {
  await addColumnIfNotExists(
    connection,
    "cattle_animals",
    "production_type",
    "varchar(50) NULL AFTER `status`",
  );
  await addColumnIfNotExists(
    connection,
    "cattle_animals",
    "herd_id",
    "varchar(36) NULL AFTER `production_type`",
  );
  await addColumnIfNotExists(
    connection,
    "cattle_animals",
    "current_weight_kg",
    "decimal(7,2) NULL AFTER `herd_id`",
  );
  await addColumnIfNotExists(
    connection,
    "cattle_animals",
    "target_weight_kg",
    "decimal(7,2) NULL AFTER `current_weight_kg`",
  );
  await addColumnIfNotExists(
    connection,
    "cattle_animals",
    "body_condition_score",
    "decimal(3,1) NULL AFTER `target_weight_kg`",
  );
  await addColumnIfNotExists(
    connection,
    "cattle_animals",
    "is_pregnant",
    "boolean NOT NULL DEFAULT false AFTER `body_condition_score`",
  );
  await addColumnIfNotExists(
    connection,
    "cattle_animals",
    "expected_calving_date",
    "date NULL AFTER `is_pregnant`",
  );
  await addColumnIfNotExists(
    connection,
    "cattle_animals",
    "last_calving_date",
    "date NULL AFTER `expected_calving_date`",
  );
  await addColumnIfNotExists(
    connection,
    "cattle_animals",
    "total_calves_raised",
    "int NOT NULL DEFAULT 0 AFTER `last_calving_date`",
  );
  await addColumnIfNotExists(
    connection,
    "cattle_animals",
    "is_lactating",
    "boolean NOT NULL DEFAULT false AFTER `total_calves_raised`",
  );
  await addColumnIfNotExists(
    connection,
    "cattle_animals",
    "current_milk_litre_pd",
    "decimal(6,2) NULL AFTER `is_lactating`",
  );
  await addColumnIfNotExists(
    connection,
    "cattle_animals",
    "lactation_number",
    "int NOT NULL DEFAULT 0 AFTER `current_milk_litre_pd`",
  );
  await addColumnIfNotExists(
    connection,
    "cattle_animals",
    "brucella_tested",
    "boolean NOT NULL DEFAULT false AFTER `lactation_number`",
  );
  await addColumnIfNotExists(
    connection,
    "cattle_animals",
    "brucella_test_date",
    "date NULL AFTER `brucella_tested`",
  );
  await addColumnIfNotExists(
    connection,
    "cattle_animals",
    "fmd_zone",
    "varchar(20) NULL AFTER `brucella_test_date`",
  );
  await addColumnIfNotExists(
    connection,
    "cattle_animals",
    "registration_number",
    "varchar(100) NULL AFTER `fmd_zone`",
  );
  await addColumnIfNotExists(
    connection,
    "cattle_animals",
    "brand_number",
    "varchar(50) NULL AFTER `registration_number`",
  );
  await addColumnIfNotExists(
    connection,
    "cattle_animals",
    "brand_position",
    "varchar(100) NULL AFTER `brand_number`",
  );
  await addColumnIfNotExists(
    connection,
    "cattle_animals",
    "dam_id",
    "varchar(36) NULL AFTER `brand_position`",
  );
  await addColumnIfNotExists(
    connection,
    "cattle_animals",
    "specific_data",
    "text NULL AFTER `dam_id`",
  );
}
