import type { Connection } from "mysql2/promise";

export async function up(connection: Connection): Promise<void> {
  const statements: string[] = [
    // poultry_flocks — batch/flock registry per farm
    `CREATE TABLE IF NOT EXISTS \`poultry_flocks\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`name\` varchar(100) NOT NULL,
      \`species\` varchar(50) NOT NULL,
      \`breed\` varchar(100),
      \`purpose\` varchar(50),
      \`house_number\` varchar(50),
      \`placement_date\` date,
      \`initial_count\` int NOT NULL DEFAULT 0,
      \`current_count\` int NOT NULL DEFAULT 0,
      \`status\` varchar(20) NOT NULL DEFAULT 'active',
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      \`updated_at\` datetime NOT NULL,
      CONSTRAINT \`poultry_flocks_id\` PRIMARY KEY (\`id\`)
    )`,

    // poultry_daily_records — daily mortality, culls, eggs, feed and water
    `CREATE TABLE IF NOT EXISTS \`poultry_daily_records\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`flock_id\` varchar(36) NOT NULL,
      \`record_date\` date NOT NULL,
      \`mortality_count\` int NOT NULL DEFAULT 0,
      \`culled_count\` int NOT NULL DEFAULT 0,
      \`eggs_collected\` int NOT NULL DEFAULT 0,
      \`feed_consumed_kg\` decimal(8,2),
      \`water_consumed_litres\` decimal(8,2),
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`poultry_daily_records_id\` PRIMARY KEY (\`id\`)
    )`,

    // poultry_disease_events — flock-level disease outbreaks
    `CREATE TABLE IF NOT EXISTS \`poultry_disease_events\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`flock_id\` varchar(36) NOT NULL,
      \`event_date\` date NOT NULL,
      \`disease_name\` varchar(255),
      \`affected_count\` int NOT NULL DEFAULT 0,
      \`treatment\` text,
      \`outcome\` varchar(50),
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`poultry_disease_events_id\` PRIMARY KEY (\`id\`)
    )`,

    // poultry_egg_sales — egg revenue transactions
    `CREATE TABLE IF NOT EXISTS \`poultry_egg_sales\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`flock_id\` varchar(36),
      \`sale_date\` date NOT NULL,
      \`eggs_count\` int NOT NULL,
      \`price_per_egg\` decimal(8,4) NOT NULL,
      \`total_amount\` decimal(10,2) NOT NULL,
      \`buyer_name\` varchar(255),
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`poultry_egg_sales_id\` PRIMARY KEY (\`id\`)
    )`,

    // poultry_environment_readings — temperature, humidity and ammonia monitoring
    `CREATE TABLE IF NOT EXISTS \`poultry_environment_readings\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`flock_id\` varchar(36) NOT NULL,
      \`recorded_at\` datetime NOT NULL,
      \`temperature_celsius\` decimal(5,2),
      \`humidity_percent\` decimal(5,2),
      \`ammonia_ppm\` decimal(6,2),
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`poultry_environment_readings_id\` PRIMARY KEY (\`id\`)
    )`,

    // poultry_feed_phases — feed programme phases (starter, grower, finisher)
    `CREATE TABLE IF NOT EXISTS \`poultry_feed_phases\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`flock_id\` varchar(36) NOT NULL,
      \`phase_name\` varchar(100) NOT NULL,
      \`feed_type\` varchar(100) NOT NULL,
      \`start_day\` int NOT NULL,
      \`end_day\` int,
      \`daily_ration_grams\` decimal(8,2),
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`poultry_feed_phases_id\` PRIMARY KEY (\`id\`)
    )`,

    // poultry_harvest_records — slaughter / live bird sale records
    `CREATE TABLE IF NOT EXISTS \`poultry_harvest_records\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`flock_id\` varchar(36) NOT NULL,
      \`harvest_date\` date NOT NULL,
      \`birds_harvested\` int NOT NULL,
      \`average_weight_kg\` decimal(5,2),
      \`total_weight_kg\` decimal(10,2),
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`poultry_harvest_records_id\` PRIMARY KEY (\`id\`)
    )`,

    // poultry_inventory — feed, medicine and equipment stock
    `CREATE TABLE IF NOT EXISTS \`poultry_inventory\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`item_name\` varchar(255) NOT NULL,
      \`category\` varchar(50) NOT NULL,
      \`quantity\` decimal(10,2) NOT NULL,
      \`unit\` varchar(20) NOT NULL,
      \`notes\` text,
      \`updated_at\` datetime NOT NULL,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`poultry_inventory_id\` PRIMARY KEY (\`id\`)
    )`,

    // poultry_medication_logs — medicine administration per flock
    `CREATE TABLE IF NOT EXISTS \`poultry_medication_logs\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`flock_id\` varchar(36) NOT NULL,
      \`medication_name\` varchar(255) NOT NULL,
      \`dosage\` varchar(100),
      \`administered_at\` date NOT NULL,
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`poultry_medication_logs_id\` PRIMARY KEY (\`id\`)
    )`,

    // poultry_vaccination_schedules — vaccination plan and completion status
    `CREATE TABLE IF NOT EXISTS \`poultry_vaccination_schedules\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`flock_id\` varchar(36) NOT NULL,
      \`vaccine_name\` varchar(255) NOT NULL,
      \`scheduled_date\` date NOT NULL,
      \`administered_date\` date,
      \`method\` varchar(50),
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`poultry_vaccination_schedules_id\` PRIMARY KEY (\`id\`)
    )`,

    // poultry_chick_sales — day-old or live chick revenue transactions
    `CREATE TABLE IF NOT EXISTS \`poultry_chick_sales\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`flock_id\` varchar(36),
      \`sale_date\` date NOT NULL,
      \`chicks_count\` int NOT NULL,
      \`price_per_chick\` decimal(8,2) NOT NULL,
      \`total_amount\` decimal(10,2) NOT NULL,
      \`buyer_name\` varchar(255),
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`poultry_chick_sales_id\` PRIMARY KEY (\`id\`)
    )`,

    // Indexes
    `CREATE INDEX IF NOT EXISTS \`poultry_flocks_farm_owner_idx\` ON \`poultry_flocks\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`poultry_daily_records_farm_owner_idx\` ON \`poultry_daily_records\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`poultry_daily_records_flock_idx\` ON \`poultry_daily_records\` (\`flock_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`poultry_disease_events_farm_owner_idx\` ON \`poultry_disease_events\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`poultry_egg_sales_farm_owner_idx\` ON \`poultry_egg_sales\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`poultry_environment_readings_farm_owner_idx\` ON \`poultry_environment_readings\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`poultry_feed_phases_farm_owner_idx\` ON \`poultry_feed_phases\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`poultry_harvest_records_farm_owner_idx\` ON \`poultry_harvest_records\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`poultry_inventory_farm_owner_idx\` ON \`poultry_inventory\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`poultry_medication_logs_farm_owner_idx\` ON \`poultry_medication_logs\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`poultry_vaccination_schedules_farm_owner_idx\` ON \`poultry_vaccination_schedules\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`poultry_chick_sales_farm_owner_idx\` ON \`poultry_chick_sales\` (\`farm_owner_id\`)`,
  ];

  for (const sql of statements) {
    await connection.execute(sql);
  }
}
