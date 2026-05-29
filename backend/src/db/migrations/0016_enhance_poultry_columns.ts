import type { Connection } from "mysql2/promise";

import { addColumnIfNotExists } from "./_helpers";

/**
 * Migration 0016: Add missing columns to poultry_flocks.
 *
 * The Dart PoultryFlock model contains production-metric fields that are
 * absent from the original migration (0006_create_poultry_tables.ts).
 *
 * Existing columns already cover:
 *   id, farm_owner_id, name (== batchName), species, breed (== strain),
 *   purpose (== productionType), house_number, placement_date,
 *   initial_count, current_count, status, notes.
 *
 * New fields added here:
 *   mortality_total          — cumulative mortality head-count
 *   mortality_pct            — cumulative mortality as a percentage
 *   day_of_age               — current flock age in days
 *   week_of_age              — current flock age in weeks
 *   current_stage            — production stage (e.g. 'starter', 'grower', 'layer')
 *   current_avg_weight_g     — current average bird weight in grams
 *   feed_consumed_total_kg   — cumulative feed consumed in kg
 *   fcr_to_date              — feed-conversion ratio to date
 *   target_slaughter_weight_g — target live weight at slaughter (broilers)
 *   projected_slaughter_date  — projected slaughter / harvest date
 *   unit_cost_per_chick      — placement cost per chick / poult (ZAR)
 *   livability_pct           — livability percentage to date
 *   specific_data            — JSON blob for BroilerSpecific / LayerSpecific /
 *                              BreederSpecific / DuckSpecific fields
 *
 * Idempotency: each column is added only if it does not yet exist.
 */
export async function up(connection: Connection): Promise<void> {
  await addColumnIfNotExists(
    connection,
    "poultry_flocks",
    "mortality_total",
    "int NOT NULL DEFAULT 0 AFTER `current_count`",
  );
  await addColumnIfNotExists(
    connection,
    "poultry_flocks",
    "mortality_pct",
    "decimal(5,2) NULL AFTER `mortality_total`",
  );
  await addColumnIfNotExists(
    connection,
    "poultry_flocks",
    "day_of_age",
    "int NULL AFTER `mortality_pct`",
  );
  await addColumnIfNotExists(
    connection,
    "poultry_flocks",
    "week_of_age",
    "int NULL AFTER `day_of_age`",
  );
  await addColumnIfNotExists(
    connection,
    "poultry_flocks",
    "current_stage",
    "varchar(50) NULL AFTER `week_of_age`",
  );
  await addColumnIfNotExists(
    connection,
    "poultry_flocks",
    "current_avg_weight_g",
    "int NULL AFTER `current_stage`",
  );
  await addColumnIfNotExists(
    connection,
    "poultry_flocks",
    "feed_consumed_total_kg",
    "decimal(10,2) NULL AFTER `current_avg_weight_g`",
  );
  await addColumnIfNotExists(
    connection,
    "poultry_flocks",
    "fcr_to_date",
    "decimal(5,3) NULL AFTER `feed_consumed_total_kg`",
  );
  await addColumnIfNotExists(
    connection,
    "poultry_flocks",
    "target_slaughter_weight_g",
    "int NULL AFTER `fcr_to_date`",
  );
  await addColumnIfNotExists(
    connection,
    "poultry_flocks",
    "projected_slaughter_date",
    "date NULL AFTER `target_slaughter_weight_g`",
  );
  await addColumnIfNotExists(
    connection,
    "poultry_flocks",
    "unit_cost_per_chick",
    "decimal(8,2) NULL AFTER `projected_slaughter_date`",
  );
  await addColumnIfNotExists(
    connection,
    "poultry_flocks",
    "livability_pct",
    "decimal(5,2) NULL AFTER `unit_cost_per_chick`",
  );
  await addColumnIfNotExists(
    connection,
    "poultry_flocks",
    "specific_data",
    "text NULL AFTER `livability_pct`",
  );
}
