// Recovery script: completes migration 0020 from cattle_pregnancy_checks onward
// Run: node scripts/recover_0020.js
const mysql = require("mysql2/promise");

async function main() {
  const conn = await mysql.createConnection(
    "mysql://punfrohs_d4-farming:Ze3g5cJC3xbA4T8AuGC4@148.251.246.72:3306/punfrohs_d4-farming",
  );

  const statements = [
    // cattle_pregnancy_checks
    `ALTER TABLE \`cattle_pregnancy_checks\`
      CHANGE COLUMN \`cattle_id\` \`animal_id\` char(36) NOT NULL,
      CHANGE COLUMN \`check_date\` \`date\` date NOT NULL,
      ADD COLUMN \`method\` varchar(50) DEFAULT NULL AFTER \`result\`,
      ADD COLUMN \`days_pregnant\` int DEFAULT NULL AFTER \`method\`,
      ADD COLUMN \`checked_by\` varchar(200) DEFAULT NULL AFTER \`days_pregnant\``,

    // cattle_calving_events
    `ALTER TABLE \`cattle_calving_events\`
      CHANGE COLUMN \`cow_id\` \`dam_id\` char(36) NOT NULL,
      ADD COLUMN \`calving_ease\` varchar(50) DEFAULT NULL AFTER \`dam_id\`,
      ADD COLUMN \`calf_alive\` tinyint(1) NOT NULL DEFAULT 1 AFTER \`calving_ease\`,
      ADD COLUMN \`calf_id\` char(36) DEFAULT NULL AFTER \`calf_alive\`,
      ADD COLUMN \`calf_sex\` varchar(10) DEFAULT NULL AFTER \`calf_id\`,
      ADD COLUMN \`calf_weight_kg\` decimal(6,2) DEFAULT NULL AFTER \`calf_sex\`,
      ADD COLUMN \`complications\` text DEFAULT NULL AFTER \`calf_weight_kg\``,

    // cattle_daily_milk
    `ALTER TABLE \`cattle_daily_milk\`
      CHANGE COLUMN \`cattle_id\` \`animal_id\` char(36) NOT NULL,
      CHANGE COLUMN \`record_date\` \`date\` date NOT NULL,
      ADD COLUMN \`lactation_day\` int DEFAULT NULL AFTER \`total_litres\`,
      ADD COLUMN \`quality_flag\` varchar(50) DEFAULT NULL AFTER \`lactation_day\``,

    // cattle_health_events
    `ALTER TABLE \`cattle_health_events\`
      CHANGE COLUMN \`cattle_id\` \`animal_id\` char(36) NOT NULL,
      CHANGE COLUMN \`event_date\` \`date\` date NOT NULL,
      ADD COLUMN \`severity\` varchar(50) DEFAULT NULL AFTER \`diagnosis\`,
      ADD COLUMN \`treated_by\` varchar(200) DEFAULT NULL AFTER \`severity\`,
      ADD COLUMN \`is_notifiable\` tinyint(1) NOT NULL DEFAULT 0 AFTER \`treated_by\``,

    // cattle_medication_logs
    `ALTER TABLE \`cattle_medication_logs\`
      CHANGE COLUMN \`cattle_id\` \`animal_id\` char(36) NOT NULL,
      CHANGE COLUMN \`administered_at\` \`date\` date NOT NULL,
      CHANGE COLUMN \`dosage\` \`dose_mg\` decimal(10,2) DEFAULT NULL,
      ADD COLUMN \`route\` varchar(50) DEFAULT NULL AFTER \`dose_mg\`,
      ADD COLUMN \`withdrawal_days_meat\` int DEFAULT NULL AFTER \`route\`,
      ADD COLUMN \`withdrawal_days_milk\` int DEFAULT NULL AFTER \`withdrawal_days_meat\`,
      ADD COLUMN \`veterinarian_approved\` tinyint(1) NOT NULL DEFAULT 0 AFTER \`withdrawal_days_milk\``,

    // cattle_vaccinations
    `ALTER TABLE \`cattle_vaccinations\`
      CHANGE COLUMN \`cattle_id\` \`animal_id\` char(36) NOT NULL,
      CHANGE COLUMN \`vaccination_date\` \`due_date\` date NOT NULL,
      ADD COLUMN \`given_date\` date DEFAULT NULL AFTER \`due_date\`,
      ADD COLUMN \`route\` varchar(50) DEFAULT NULL AFTER \`given_date\`,
      ADD COLUMN \`site_on_body\` varchar(100) DEFAULT NULL AFTER \`route\`,
      ADD COLUMN \`administered_by\` varchar(200) DEFAULT NULL AFTER \`site_on_body\``,

    // cattle_sale_records
    `ALTER TABLE \`cattle_sale_records\`
      CHANGE COLUMN \`cattle_id\` \`animal_id\` char(36) NOT NULL,
      CHANGE COLUMN \`sale_price\` \`total_amount\` decimal(10,2) NOT NULL,
      ADD COLUMN \`sale_weight_kg\` decimal(8,2) DEFAULT NULL AFTER \`total_amount\`,
      ADD COLUMN \`price_per_kg\` decimal(8,2) DEFAULT NULL AFTER \`sale_weight_kg\`,
      ADD COLUMN \`transport_cost\` decimal(10,2) DEFAULT NULL AFTER \`price_per_kg\`,
      ADD COLUMN \`permit_number\` varchar(100) DEFAULT NULL AFTER \`transport_cost\`,
      ADD COLUMN \`invoice_ref\` varchar(200) DEFAULT NULL AFTER \`permit_number\``,

    // cattle_feed_records
    `ALTER TABLE \`cattle_feed_records\`
      CHANGE COLUMN \`cattle_id\` \`animal_id\` char(36) NOT NULL,
      CHANGE COLUMN \`feed_date\` \`date\` date NOT NULL,
      ADD COLUMN \`cost_per_kg\` decimal(8,2) DEFAULT NULL AFTER \`quantity_kg\`,
      ADD COLUMN \`feedlot_pen_id\` char(36) DEFAULT NULL AFTER \`cost_per_kg\`,
      ADD COLUMN \`ration_name\` varchar(200) DEFAULT NULL AFTER \`feedlot_pen_id\``,

    // cattle_pasture_records - add new cols first
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

    // cattle_bcs_records
    `ALTER TABLE \`cattle_bcs_records\`
      CHANGE COLUMN \`cattle_id\` \`animal_id\` char(36) NOT NULL,
      CHANGE COLUMN \`record_date\` \`date\` date NOT NULL,
      ADD COLUMN \`assessed_by\` varchar(200) DEFAULT NULL AFTER \`score\``,

    // cattle_dipping_records - add new cols
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

  for (let i = 0; i < statements.length; i++) {
    try {
      await conn.execute(statements[i]);
      console.log(`OK [${i}]`);
    } catch (e) {
      console.error(`FAILED [${i}]:`, e.message);
      await conn.end();
      process.exit(1);
    }
  }

  // Mark migration as applied
  await conn.execute(
    "INSERT INTO schema_migrations (name, applied_at) VALUES (?, NOW())",
    ["0020_cattle_schema_overhaul.ts"],
  );
  console.log("Migration 0020 marked as applied ✓");
  await conn.end();
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
