import type { Connection } from "mysql2/promise";

export async function up(connection: Connection): Promise<void> {
  const statements: string[] = [
    // cattle_animals — individual animal registry
    `CREATE TABLE IF NOT EXISTS \`cattle_animals\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`tag_id\` varchar(100) NOT NULL,
      \`name\` varchar(100),
      \`breed\` varchar(100),
      \`sex\` varchar(10) NOT NULL,
      \`date_of_birth\` date,
      \`color\` varchar(50),
      \`status\` varchar(20) NOT NULL DEFAULT 'active',
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      \`updated_at\` datetime NOT NULL,
      CONSTRAINT \`cattle_animals_id\` PRIMARY KEY (\`id\`)
    )`,

    // cattle_bcs_records — body condition scoring over time
    `CREATE TABLE IF NOT EXISTS \`cattle_bcs_records\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`cattle_id\` varchar(36) NOT NULL,
      \`score\` decimal(3,1) NOT NULL,
      \`record_date\` date NOT NULL,
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`cattle_bcs_records_id\` PRIMARY KEY (\`id\`)
    )`,

    // cattle_breeding_records — mating and AI events
    `CREATE TABLE IF NOT EXISTS \`cattle_breeding_records\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`cow_id\` varchar(36) NOT NULL,
      \`bull_id\` varchar(36),
      \`breeding_date\` date NOT NULL,
      \`method\` varchar(50),
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`cattle_breeding_records_id\` PRIMARY KEY (\`id\`)
    )`,

    // cattle_calving_events — birth outcomes per cow
    `CREATE TABLE IF NOT EXISTS \`cattle_calving_events\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`cow_id\` varchar(36) NOT NULL,
      \`calving_date\` date NOT NULL,
      \`calves_alive\` int NOT NULL DEFAULT 0,
      \`calves_dead\` int NOT NULL DEFAULT 0,
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`cattle_calving_events_id\` PRIMARY KEY (\`id\`)
    )`,

    // cattle_daily_milk — morning and evening milk yields
    `CREATE TABLE IF NOT EXISTS \`cattle_daily_milk\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`cattle_id\` varchar(36) NOT NULL,
      \`record_date\` date NOT NULL,
      \`morning_litres\` decimal(7,2),
      \`evening_litres\` decimal(7,2),
      \`total_litres\` decimal(7,2) NOT NULL,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`cattle_daily_milk_id\` PRIMARY KEY (\`id\`)
    )`,

    // cattle_dipping_records — herd-level tick and parasite dipping
    `CREATE TABLE IF NOT EXISTS \`cattle_dipping_records\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`dipping_date\` date NOT NULL,
      \`chemical\` varchar(255),
      \`concentration\` varchar(50),
      \`number_of_cattle\` int,
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`cattle_dipping_records_id\` PRIMARY KEY (\`id\`)
    )`,

    // cattle_feed_records — feed type and quantity per animal or herd
    `CREATE TABLE IF NOT EXISTS \`cattle_feed_records\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`cattle_id\` varchar(36),
      \`feed_type\` varchar(100) NOT NULL,
      \`quantity_kg\` decimal(8,2) NOT NULL,
      \`feed_date\` date NOT NULL,
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`cattle_feed_records_id\` PRIMARY KEY (\`id\`)
    )`,

    // cattle_health_events — illness diagnoses and treatments
    `CREATE TABLE IF NOT EXISTS \`cattle_health_events\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`cattle_id\` varchar(36) NOT NULL,
      \`event_date\` date NOT NULL,
      \`event_type\` varchar(50) NOT NULL,
      \`diagnosis\` varchar(255),
      \`treatment\` text,
      \`outcome\` varchar(50),
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`cattle_health_events_id\` PRIMARY KEY (\`id\`)
    )`,

    // cattle_medication_logs — medicine administration per animal
    `CREATE TABLE IF NOT EXISTS \`cattle_medication_logs\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`cattle_id\` varchar(36) NOT NULL,
      \`medication_name\` varchar(255) NOT NULL,
      \`dosage\` varchar(100),
      \`administered_at\` date NOT NULL,
      \`administered_by\` varchar(100),
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`cattle_medication_logs_id\` PRIMARY KEY (\`id\`)
    )`,

    // cattle_pasture_records — paddock rotation tracking
    `CREATE TABLE IF NOT EXISTS \`cattle_pasture_records\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`pasture_name\` varchar(100) NOT NULL,
      \`move_date\` date NOT NULL,
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`cattle_pasture_records_id\` PRIMARY KEY (\`id\`)
    )`,

    // cattle_pregnancy_checks — preg test results and expected calving dates
    `CREATE TABLE IF NOT EXISTS \`cattle_pregnancy_checks\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`cattle_id\` varchar(36) NOT NULL,
      \`check_date\` date NOT NULL,
      \`result\` varchar(20) NOT NULL,
      \`expected_calving_date\` date,
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`cattle_pregnancy_checks_id\` PRIMARY KEY (\`id\`)
    )`,

    // cattle_sale_records — sale transactions per animal
    `CREATE TABLE IF NOT EXISTS \`cattle_sale_records\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`cattle_id\` varchar(36) NOT NULL,
      \`sale_date\` date NOT NULL,
      \`buyer_name\` varchar(255),
      \`sale_price\` decimal(10,2) NOT NULL,
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`cattle_sale_records_id\` PRIMARY KEY (\`id\`)
    )`,

    // cattle_vaccinations — vaccine schedule and administration records
    `CREATE TABLE IF NOT EXISTS \`cattle_vaccinations\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`cattle_id\` varchar(36) NOT NULL,
      \`vaccine_name\` varchar(255) NOT NULL,
      \`vaccination_date\` date NOT NULL,
      \`next_due_date\` date,
      \`batch_number\` varchar(100),
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`cattle_vaccinations_id\` PRIMARY KEY (\`id\`)
    )`,

    // cattle_weight_records — growth tracking by weight over time
    `CREATE TABLE IF NOT EXISTS \`cattle_weight_records\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`cattle_id\` varchar(36) NOT NULL,
      \`weight_kg\` decimal(7,2) NOT NULL,
      \`recorded_at\` date NOT NULL,
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`cattle_weight_records_id\` PRIMARY KEY (\`id\`)
    )`,

    // Indexes
    `CREATE INDEX IF NOT EXISTS \`cattle_animals_farm_owner_idx\` ON \`cattle_animals\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`cattle_bcs_records_farm_owner_idx\` ON \`cattle_bcs_records\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`cattle_breeding_records_farm_owner_idx\` ON \`cattle_breeding_records\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`cattle_calving_events_farm_owner_idx\` ON \`cattle_calving_events\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`cattle_daily_milk_farm_owner_idx\` ON \`cattle_daily_milk\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`cattle_dipping_records_farm_owner_idx\` ON \`cattle_dipping_records\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`cattle_feed_records_farm_owner_idx\` ON \`cattle_feed_records\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`cattle_health_events_farm_owner_idx\` ON \`cattle_health_events\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`cattle_medication_logs_farm_owner_idx\` ON \`cattle_medication_logs\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`cattle_pasture_records_farm_owner_idx\` ON \`cattle_pasture_records\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`cattle_pregnancy_checks_farm_owner_idx\` ON \`cattle_pregnancy_checks\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`cattle_sale_records_farm_owner_idx\` ON \`cattle_sale_records\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`cattle_vaccinations_farm_owner_idx\` ON \`cattle_vaccinations\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`cattle_weight_records_farm_owner_idx\` ON \`cattle_weight_records\` (\`farm_owner_id\`)`,
  ];

  for (const sql of statements) {
    await connection.execute(sql);
  }
}
