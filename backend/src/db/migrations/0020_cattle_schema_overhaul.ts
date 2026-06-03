import type { Connection } from "mysql2/promise";

export async function up(connection: Connection): Promise<void> {
  const statements: string[] = [
    // ── cattle_animals ──────────────────────────────────────────────────────
    `ALTER TABLE \`cattle_animals\`
      CHANGE COLUMN \`tag_id\` \`tag_number\` varchar(50) NOT NULL,
      ADD COLUMN \`sire_id\` char(36) DEFAULT NULL AFTER \`tag_number\`,
      ADD COLUMN \`purchase_date\` date DEFAULT NULL AFTER \`sire_id\`,
      ADD COLUMN \`purchase_price\` decimal(10,2) DEFAULT NULL AFTER \`purchase_date\`,
      ADD COLUMN \`dry_off_date\` date DEFAULT NULL AFTER \`purchase_price\`,
      ADD COLUMN \`last_deworming_date\` date DEFAULT NULL AFTER \`dry_off_date\`,
      ADD COLUMN \`last_dipping_date\` date DEFAULT NULL AFTER \`last_deworming_date\`,
      ADD COLUMN \`earmark_desc\` varchar(200) DEFAULT NULL AFTER \`last_dipping_date\`,
      ADD COLUMN \`niis_eid_number\` varchar(100) DEFAULT NULL AFTER \`earmark_desc\``,

    // ── cattle_weight_records ────────────────────────────────────────────────
    `ALTER TABLE \`cattle_weight_records\`
      CHANGE COLUMN \`cattle_id\` \`animal_id\` char(36) NOT NULL,
      CHANGE COLUMN \`recorded_at\` \`date\` date NOT NULL,
      ADD COLUMN \`body_condition_score\` decimal(3,1) DEFAULT NULL AFTER \`weight_kg\``,

    // ── cattle_breeding_records ──────────────────────────────────────────────
    `ALTER TABLE \`cattle_breeding_records\`
      CHANGE COLUMN \`breeding_date\` \`service_date\` date NOT NULL,
      CHANGE COLUMN \`method\` \`service_method\` varchar(50) NOT NULL,
      ADD COLUMN \`semen_source\` varchar(200) DEFAULT NULL AFTER \`service_method\`,
      ADD COLUMN \`technician\` varchar(200) DEFAULT NULL AFTER \`semen_source\`,
      ADD COLUMN \`expected_calving_date\` date DEFAULT NULL AFTER \`technician\`,
      ADD COLUMN \`outcome\` varchar(50) DEFAULT NULL AFTER \`expected_calving_date\``,

    // ── cattle_pregnancy_checks ──────────────────────────────────────────────
    `ALTER TABLE \`cattle_pregnancy_checks\`
      CHANGE COLUMN \`cattle_id\` \`animal_id\` char(36) NOT NULL,
      CHANGE COLUMN \`check_date\` \`date\` date NOT NULL,
      ADD COLUMN \`method\` varchar(50) DEFAULT NULL AFTER \`result\`,
      ADD COLUMN \`days_pregnant\` int DEFAULT NULL AFTER \`method\`,
      ADD COLUMN \`checked_by\` varchar(200) DEFAULT NULL AFTER \`days_pregnant\``,

    // ── cattle_calving_events ────────────────────────────────────────────────
    `ALTER TABLE \`cattle_calving_events\`
      CHANGE COLUMN \`cow_id\` \`dam_id\` char(36) NOT NULL,
      ADD COLUMN \`calving_ease\` varchar(50) DEFAULT NULL AFTER \`dam_id\`,
      ADD COLUMN \`calf_alive\` tinyint(1) NOT NULL DEFAULT 1 AFTER \`calving_ease\`,
      ADD COLUMN \`calf_id\` char(36) DEFAULT NULL AFTER \`calf_alive\`,
      ADD COLUMN \`calf_sex\` varchar(10) DEFAULT NULL AFTER \`calf_id\`,
      ADD COLUMN \`calf_weight_kg\` decimal(6,2) DEFAULT NULL AFTER \`calf_sex\`,
      ADD COLUMN \`complications\` text DEFAULT NULL AFTER \`calf_weight_kg\``,

    // ── cattle_daily_milk ────────────────────────────────────────────────────
    `ALTER TABLE \`cattle_daily_milk\`
      CHANGE COLUMN \`cattle_id\` \`animal_id\` char(36) NOT NULL,
      CHANGE COLUMN \`record_date\` \`date\` date NOT NULL,
      ADD COLUMN \`lactation_day\` int DEFAULT NULL AFTER \`total_litres\`,
      ADD COLUMN \`quality_flag\` varchar(50) DEFAULT NULL AFTER \`lactation_day\``,

    // ── cattle_health_events ─────────────────────────────────────────────────
    `ALTER TABLE \`cattle_health_events\`
      CHANGE COLUMN \`cattle_id\` \`animal_id\` char(36) NOT NULL,
      CHANGE COLUMN \`event_date\` \`date\` date NOT NULL,
      ADD COLUMN \`severity\` varchar(50) DEFAULT NULL AFTER \`diagnosis\`,
      ADD COLUMN \`treated_by\` varchar(200) DEFAULT NULL AFTER \`severity\`,
      ADD COLUMN \`is_notifiable\` tinyint(1) NOT NULL DEFAULT 0 AFTER \`treated_by\``,

    // ── cattle_medication_logs ───────────────────────────────────────────────
    `ALTER TABLE \`cattle_medication_logs\`
      CHANGE COLUMN \`cattle_id\` \`animal_id\` char(36) NOT NULL,
      CHANGE COLUMN \`administered_at\` \`date\` date NOT NULL,
      CHANGE COLUMN \`dosage\` \`dose_mg\` decimal(10,2) DEFAULT NULL,
      ADD COLUMN \`route\` varchar(50) DEFAULT NULL AFTER \`dose_mg\`,
      ADD COLUMN \`withdrawal_days_meat\` int DEFAULT NULL AFTER \`route\`,
      ADD COLUMN \`withdrawal_days_milk\` int DEFAULT NULL AFTER \`withdrawal_days_meat\`,
      ADD COLUMN \`veterinarian_approved\` tinyint(1) NOT NULL DEFAULT 0 AFTER \`withdrawal_days_milk\``,

    // ── cattle_vaccinations ──────────────────────────────────────────────────
    `ALTER TABLE \`cattle_vaccinations\`
      CHANGE COLUMN \`cattle_id\` \`animal_id\` char(36) NOT NULL,
      CHANGE COLUMN \`vaccination_date\` \`due_date\` date NOT NULL,
      ADD COLUMN \`given_date\` date DEFAULT NULL AFTER \`due_date\`,
      ADD COLUMN \`route\` varchar(50) DEFAULT NULL AFTER \`given_date\`,
      ADD COLUMN \`site_on_body\` varchar(100) DEFAULT NULL AFTER \`route\`,
      ADD COLUMN \`administered_by\` varchar(200) DEFAULT NULL AFTER \`site_on_body\``,

    // ── cattle_sale_records ──────────────────────────────────────────────────
    `ALTER TABLE \`cattle_sale_records\`
      CHANGE COLUMN \`cattle_id\` \`animal_id\` char(36) NOT NULL,
      CHANGE COLUMN \`sale_price\` \`total_amount\` decimal(10,2) NOT NULL,
      ADD COLUMN \`sale_weight_kg\` decimal(8,2) DEFAULT NULL AFTER \`total_amount\`,
      ADD COLUMN \`price_per_kg\` decimal(8,2) DEFAULT NULL AFTER \`sale_weight_kg\`,
      ADD COLUMN \`transport_cost\` decimal(10,2) DEFAULT NULL AFTER \`price_per_kg\`,
      ADD COLUMN \`permit_number\` varchar(100) DEFAULT NULL AFTER \`transport_cost\`,
      ADD COLUMN \`invoice_ref\` varchar(200) DEFAULT NULL AFTER \`permit_number\``,

    // ── cattle_feed_records ──────────────────────────────────────────────────
    `ALTER TABLE \`cattle_feed_records\`
      CHANGE COLUMN \`cattle_id\` \`animal_id\` char(36) NOT NULL,
      CHANGE COLUMN \`feed_date\` \`date\` date NOT NULL,
      ADD COLUMN \`cost_per_kg\` decimal(8,2) DEFAULT NULL AFTER \`quantity_kg\`,
      ADD COLUMN \`feedlot_pen_id\` char(36) DEFAULT NULL AFTER \`cost_per_kg\`,
      ADD COLUMN \`ration_name\` varchar(200) DEFAULT NULL AFTER \`feedlot_pen_id\``,

    // ── cattle_pasture_records ───────────────────────────────────────────────
    `ALTER TABLE \`cattle_pasture_records\`
      ADD COLUMN \`herd_id\` char(36) DEFAULT NULL AFTER \`farm_owner_id\`,
      ADD COLUMN \`camp_id\` char(36) DEFAULT NULL AFTER \`herd_id\`,
      ADD COLUMN \`entry_date\` date DEFAULT NULL AFTER \`camp_id\`,
      ADD COLUMN \`exit_date\` date DEFAULT NULL AFTER \`entry_date\`,
      ADD COLUMN \`estimated_ha\` decimal(10,2) DEFAULT NULL AFTER \`exit_date\`,
      ADD COLUMN \`veld_condition\` varchar(50) DEFAULT NULL AFTER \`estimated_ha\``,

    `ALTER TABLE \`cattle_pasture_records\`
      DROP COLUMN \`pasture_name\`,
      DROP COLUMN \`move_date\``,

    // ── cattle_bcs_records ───────────────────────────────────────────────────
    `ALTER TABLE \`cattle_bcs_records\`
      CHANGE COLUMN \`cattle_id\` \`animal_id\` char(36) NOT NULL,
      CHANGE COLUMN \`record_date\` \`date\` date NOT NULL,
      ADD COLUMN \`assessed_by\` varchar(200) DEFAULT NULL AFTER \`score\``,

    // ── cattle_dipping_records ───────────────────────────────────────────────
    `ALTER TABLE \`cattle_dipping_records\`
      ADD COLUMN \`animal_id\` char(36) DEFAULT NULL AFTER \`farm_owner_id\`,
      ADD COLUMN \`product_used\` varchar(200) DEFAULT NULL AFTER \`animal_id\`,
      ADD COLUMN \`method\` varchar(50) DEFAULT NULL AFTER \`product_used\`,
      ADD COLUMN \`next_due_days\` int DEFAULT NULL AFTER \`method\`,
      ADD COLUMN \`veterinarian_approved\` tinyint(1) NOT NULL DEFAULT 0 AFTER \`next_due_days\``,

    `ALTER TABLE \`cattle_dipping_records\`
      DROP COLUMN \`chemical\`,
      DROP COLUMN \`number_of_cattle\``,
  ];

  for (const sql of statements) {
    await connection.execute(sql);
  }
}

export async function down(connection: Connection): Promise<void> {
  const statements: string[] = [
    // Reverse cattle_animals
    `ALTER TABLE \`cattle_animals\`
      DROP COLUMN \`niis_eid_number\`,
      DROP COLUMN \`earmark_desc\`,
      DROP COLUMN \`last_dipping_date\`,
      DROP COLUMN \`last_deworming_date\`,
      DROP COLUMN \`dry_off_date\`,
      DROP COLUMN \`purchase_price\`,
      DROP COLUMN \`purchase_date\`,
      DROP COLUMN \`sire_id\`,
      CHANGE COLUMN \`tag_number\` \`tag_id\` varchar(50) NOT NULL`,

    // Reverse cattle_weight_records
    `ALTER TABLE \`cattle_weight_records\`
      DROP COLUMN \`body_condition_score\`,
      CHANGE COLUMN \`date\` \`recorded_at\` date NOT NULL,
      CHANGE COLUMN \`animal_id\` \`cattle_id\` char(36) NOT NULL`,

    // Reverse cattle_breeding_records
    `ALTER TABLE \`cattle_breeding_records\`
      DROP COLUMN \`outcome\`,
      DROP COLUMN \`expected_calving_date\`,
      DROP COLUMN \`technician\`,
      DROP COLUMN \`semen_source\`,
      CHANGE COLUMN \`service_method\` \`method\` varchar(50) NOT NULL,
      CHANGE COLUMN \`service_date\` \`breeding_date\` date NOT NULL`,

    // Reverse cattle_pregnancy_checks
    `ALTER TABLE \`cattle_pregnancy_checks\`
      DROP COLUMN \`checked_by\`,
      DROP COLUMN \`days_pregnant\`,
      DROP COLUMN \`method\`,
      CHANGE COLUMN \`date\` \`check_date\` date NOT NULL,
      CHANGE COLUMN \`animal_id\` \`cattle_id\` char(36) NOT NULL`,

    // Reverse cattle_calving_events
    `ALTER TABLE \`cattle_calving_events\`
      DROP COLUMN \`complications\`,
      DROP COLUMN \`calf_weight_kg\`,
      DROP COLUMN \`calf_sex\`,
      DROP COLUMN \`calf_id\`,
      DROP COLUMN \`calf_alive\`,
      DROP COLUMN \`calving_ease\`,
      CHANGE COLUMN \`dam_id\` \`cow_id\` char(36) NOT NULL`,

    // Reverse cattle_daily_milk
    `ALTER TABLE \`cattle_daily_milk\`
      DROP COLUMN \`quality_flag\`,
      DROP COLUMN \`lactation_day\`,
      CHANGE COLUMN \`date\` \`record_date\` date NOT NULL,
      CHANGE COLUMN \`animal_id\` \`cattle_id\` char(36) NOT NULL`,

    // Reverse cattle_health_events
    `ALTER TABLE \`cattle_health_events\`
      DROP COLUMN \`is_notifiable\`,
      DROP COLUMN \`treated_by\`,
      DROP COLUMN \`severity\`,
      CHANGE COLUMN \`date\` \`event_date\` date NOT NULL,
      CHANGE COLUMN \`animal_id\` \`cattle_id\` char(36) NOT NULL`,

    // Reverse cattle_medication_logs
    `ALTER TABLE \`cattle_medication_logs\`
      DROP COLUMN \`veterinarian_approved\`,
      DROP COLUMN \`withdrawal_days_milk\`,
      DROP COLUMN \`withdrawal_days_meat\`,
      DROP COLUMN \`route\`,
      CHANGE COLUMN \`dose_mg\` \`dosage\` decimal(10,2) DEFAULT NULL,
      CHANGE COLUMN \`date\` \`administered_at\` date NOT NULL,
      CHANGE COLUMN \`animal_id\` \`cattle_id\` char(36) NOT NULL`,

    // Reverse cattle_vaccinations
    `ALTER TABLE \`cattle_vaccinations\`
      DROP COLUMN \`administered_by\`,
      DROP COLUMN \`site_on_body\`,
      DROP COLUMN \`route\`,
      DROP COLUMN \`given_date\`,
      CHANGE COLUMN \`due_date\` \`vaccination_date\` date NOT NULL,
      CHANGE COLUMN \`animal_id\` \`cattle_id\` char(36) NOT NULL`,

    // Reverse cattle_sale_records
    `ALTER TABLE \`cattle_sale_records\`
      DROP COLUMN \`invoice_ref\`,
      DROP COLUMN \`permit_number\`,
      DROP COLUMN \`transport_cost\`,
      DROP COLUMN \`price_per_kg\`,
      DROP COLUMN \`sale_weight_kg\`,
      CHANGE COLUMN \`total_amount\` \`sale_price\` decimal(10,2) NOT NULL,
      CHANGE COLUMN \`animal_id\` \`cattle_id\` char(36) NOT NULL`,

    // Reverse cattle_feed_records
    `ALTER TABLE \`cattle_feed_records\`
      DROP COLUMN \`ration_name\`,
      DROP COLUMN \`feedlot_pen_id\`,
      DROP COLUMN \`cost_per_kg\`,
      CHANGE COLUMN \`date\` \`feed_date\` date NOT NULL,
      CHANGE COLUMN \`animal_id\` \`cattle_id\` char(36) NOT NULL`,

    // Reverse cattle_pasture_records
    `ALTER TABLE \`cattle_pasture_records\`
      ADD COLUMN \`pasture_name\` varchar(200) DEFAULT NULL,
      ADD COLUMN \`move_date\` date DEFAULT NULL`,

    `ALTER TABLE \`cattle_pasture_records\`
      DROP COLUMN \`veld_condition\`,
      DROP COLUMN \`estimated_ha\`,
      DROP COLUMN \`exit_date\`,
      DROP COLUMN \`entry_date\`,
      DROP COLUMN \`camp_id\`,
      DROP COLUMN \`herd_id\``,

    // Reverse cattle_bcs_records
    `ALTER TABLE \`cattle_bcs_records\`
      DROP COLUMN \`assessed_by\`,
      CHANGE COLUMN \`date\` \`record_date\` date NOT NULL,
      CHANGE COLUMN \`animal_id\` \`cattle_id\` char(36) NOT NULL`,

    // Reverse cattle_dipping_records
    `ALTER TABLE \`cattle_dipping_records\`
      ADD COLUMN \`chemical\` varchar(200) DEFAULT NULL,
      ADD COLUMN \`number_of_cattle\` int DEFAULT NULL`,

    `ALTER TABLE \`cattle_dipping_records\`
      DROP COLUMN \`veterinarian_approved\`,
      DROP COLUMN \`next_due_days\`,
      DROP COLUMN \`method\`,
      DROP COLUMN \`product_used\`,
      DROP COLUMN \`animal_id\``,
  ];

  for (const sql of statements) {
    await connection.execute(sql);
  }
}
