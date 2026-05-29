import type { Connection } from "mysql2/promise";

import { addColumnIfNotExists } from "./_helpers";

/**
 * Migration 0015: Add missing columns to goat_animals.
 *
 * Mirrors the same approach used for cattle in 0014.
 * New fields match the Dart GoatAnimal model exactly.
 *
 * New fields:
 *   production_type       — 'meat' | 'dairy' | 'fiber' | 'dual'
 *   herd_id               — FK-like reference to a named herd / group
 *   current_weight_kg     — latest recorded live weight
 *   target_weight_kg      — target weight for the current phase
 *   body_condition_score  — latest BCS (1.0 – 5.0)
 *   is_pregnant           — current pregnancy status flag
 *   expected_kidding_date — next expected kidding date
 *   last_kidding_date     — date of most recent kidding
 *   total_kids_raised     — lifetime kids raised
 *   is_lactating          — current lactation status flag
 *   current_milk_litre_pd — current daily milk yield (litres)
 *   lactation_number      — number of completed lactations
 *   dry_off_date          — scheduled/actual dry-off date
 *   last_shearing_date    — date of most recent shearing
 *   last_deworming_date   — date of most recent deworming
 *   famacha_score         — latest FAMACHA eye-colour score (1–5)
 *   registration_number   — breed-society / stud-book registration
 *   dam_id                — self-referencing id of the dam animal
 *   specific_data         — JSON blob for MeatSpecific / DairySpecific /
 *                           FiberSpecific / BreederSpecific fields
 *
 * Idempotency: each column is added only if it does not yet exist.
 */
export async function up(connection: Connection): Promise<void> {
  await addColumnIfNotExists(
    connection,
    "goat_animals",
    "production_type",
    "varchar(50) NULL AFTER `status`",
  );
  await addColumnIfNotExists(
    connection,
    "goat_animals",
    "herd_id",
    "varchar(36) NULL AFTER `production_type`",
  );
  await addColumnIfNotExists(
    connection,
    "goat_animals",
    "current_weight_kg",
    "decimal(7,2) NULL AFTER `herd_id`",
  );
  await addColumnIfNotExists(
    connection,
    "goat_animals",
    "target_weight_kg",
    "decimal(7,2) NULL AFTER `current_weight_kg`",
  );
  await addColumnIfNotExists(
    connection,
    "goat_animals",
    "body_condition_score",
    "decimal(3,1) NULL AFTER `target_weight_kg`",
  );
  await addColumnIfNotExists(
    connection,
    "goat_animals",
    "is_pregnant",
    "boolean NOT NULL DEFAULT false AFTER `body_condition_score`",
  );
  await addColumnIfNotExists(
    connection,
    "goat_animals",
    "expected_kidding_date",
    "date NULL AFTER `is_pregnant`",
  );
  await addColumnIfNotExists(
    connection,
    "goat_animals",
    "last_kidding_date",
    "date NULL AFTER `expected_kidding_date`",
  );
  await addColumnIfNotExists(
    connection,
    "goat_animals",
    "total_kids_raised",
    "int NOT NULL DEFAULT 0 AFTER `last_kidding_date`",
  );
  await addColumnIfNotExists(
    connection,
    "goat_animals",
    "is_lactating",
    "boolean NOT NULL DEFAULT false AFTER `total_kids_raised`",
  );
  await addColumnIfNotExists(
    connection,
    "goat_animals",
    "current_milk_litre_pd",
    "decimal(6,2) NULL AFTER `is_lactating`",
  );
  await addColumnIfNotExists(
    connection,
    "goat_animals",
    "lactation_number",
    "int NOT NULL DEFAULT 0 AFTER `current_milk_litre_pd`",
  );
  await addColumnIfNotExists(
    connection,
    "goat_animals",
    "dry_off_date",
    "date NULL AFTER `lactation_number`",
  );
  await addColumnIfNotExists(
    connection,
    "goat_animals",
    "last_shearing_date",
    "date NULL AFTER `dry_off_date`",
  );
  await addColumnIfNotExists(
    connection,
    "goat_animals",
    "last_deworming_date",
    "date NULL AFTER `last_shearing_date`",
  );
  await addColumnIfNotExists(
    connection,
    "goat_animals",
    "famacha_score",
    "int NULL AFTER `last_deworming_date`",
  );
  await addColumnIfNotExists(
    connection,
    "goat_animals",
    "registration_number",
    "varchar(100) NULL AFTER `famacha_score`",
  );
  await addColumnIfNotExists(
    connection,
    "goat_animals",
    "dam_id",
    "varchar(36) NULL AFTER `registration_number`",
  );
  await addColumnIfNotExists(
    connection,
    "goat_animals",
    "specific_data",
    "text NULL AFTER `dam_id`",
  );
}
