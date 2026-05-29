import type { Connection } from "mysql2/promise";

export async function up(connection: Connection): Promise<void> {
  const statements: string[] = [
    // goat_animals — individual goat registry
    `CREATE TABLE IF NOT EXISTS \`goat_animals\` (
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
      CONSTRAINT \`goat_animals_id\` PRIMARY KEY (\`id\`)
    )`,

    // goat_bcs_records — body condition scoring
    `CREATE TABLE IF NOT EXISTS \`goat_bcs_records\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`goat_id\` varchar(36) NOT NULL,
      \`score\` decimal(3,1) NOT NULL,
      \`record_date\` date NOT NULL,
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`goat_bcs_records_id\` PRIMARY KEY (\`id\`)
    )`,

    // goat_daily_milk — morning and evening milk yields
    `CREATE TABLE IF NOT EXISTS \`goat_daily_milk\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`goat_id\` varchar(36) NOT NULL,
      \`record_date\` date NOT NULL,
      \`morning_litres\` decimal(6,2),
      \`evening_litres\` decimal(6,2),
      \`total_litres\` decimal(6,2) NOT NULL,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`goat_daily_milk_id\` PRIMARY KEY (\`id\`)
    )`,

    // goat_famacha_records — FAMACHA eye score (worm burden indicator)
    `CREATE TABLE IF NOT EXISTS \`goat_famacha_records\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`goat_id\` varchar(36) NOT NULL,
      \`score\` int NOT NULL,
      \`record_date\` date NOT NULL,
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`goat_famacha_records_id\` PRIMARY KEY (\`id\`)
    )`,

    // goat_feed_records — feed type and quantity per goat or herd
    `CREATE TABLE IF NOT EXISTS \`goat_feed_records\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`goat_id\` varchar(36),
      \`feed_type\` varchar(100) NOT NULL,
      \`quantity_kg\` decimal(8,2) NOT NULL,
      \`feed_date\` date NOT NULL,
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`goat_feed_records_id\` PRIMARY KEY (\`id\`)
    )`,

    // goat_health_events — illness diagnoses and treatments
    `CREATE TABLE IF NOT EXISTS \`goat_health_events\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`goat_id\` varchar(36) NOT NULL,
      \`event_date\` date NOT NULL,
      \`event_type\` varchar(50) NOT NULL,
      \`diagnosis\` varchar(255),
      \`treatment\` text,
      \`outcome\` varchar(50),
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`goat_health_events_id\` PRIMARY KEY (\`id\`)
    )`,

    // goat_kidding_events — birth outcomes per doe
    `CREATE TABLE IF NOT EXISTS \`goat_kidding_events\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`doe_id\` varchar(36) NOT NULL,
      \`kidding_date\` date NOT NULL,
      \`kids_alive\` int NOT NULL DEFAULT 0,
      \`kids_dead\` int NOT NULL DEFAULT 0,
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`goat_kidding_events_id\` PRIMARY KEY (\`id\`)
    )`,

    // goat_mating_records — natural service and AI events
    `CREATE TABLE IF NOT EXISTS \`goat_mating_records\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`doe_id\` varchar(36) NOT NULL,
      \`buck_id\` varchar(36),
      \`mating_date\` date NOT NULL,
      \`method\` varchar(50),
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`goat_mating_records_id\` PRIMARY KEY (\`id\`)
    )`,

    // goat_medication_logs — medicine administration per goat
    `CREATE TABLE IF NOT EXISTS \`goat_medication_logs\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`goat_id\` varchar(36) NOT NULL,
      \`medication_name\` varchar(255) NOT NULL,
      \`dosage\` varchar(100),
      \`administered_at\` date NOT NULL,
      \`administered_by\` varchar(100),
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`goat_medication_logs_id\` PRIMARY KEY (\`id\`)
    )`,

    // goat_pasture_records — paddock rotation tracking
    `CREATE TABLE IF NOT EXISTS \`goat_pasture_records\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`pasture_id\` varchar(36),
      \`pasture_name\` varchar(100) NOT NULL,
      \`move_date\` date NOT NULL,
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`goat_pasture_records_id\` PRIMARY KEY (\`id\`)
    )`,

    // goat_pregnancy_checks — preg test results and expected kidding dates
    `CREATE TABLE IF NOT EXISTS \`goat_pregnancy_checks\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`goat_id\` varchar(36) NOT NULL,
      \`check_date\` date NOT NULL,
      \`result\` varchar(20) NOT NULL,
      \`expected_kidding_date\` date,
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`goat_pregnancy_checks_id\` PRIMARY KEY (\`id\`)
    )`,

    // goat_sale_records — sale transactions per goat
    `CREATE TABLE IF NOT EXISTS \`goat_sale_records\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`goat_id\` varchar(36) NOT NULL,
      \`sale_date\` date NOT NULL,
      \`buyer_name\` varchar(255),
      \`sale_price\` decimal(10,2) NOT NULL,
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`goat_sale_records_id\` PRIMARY KEY (\`id\`)
    )`,

    // goat_shearing_records — fleece harvest records
    `CREATE TABLE IF NOT EXISTS \`goat_shearing_records\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`goat_id\` varchar(36) NOT NULL,
      \`shearing_date\` date NOT NULL,
      \`fleece_weight_kg\` decimal(6,2),
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`goat_shearing_records_id\` PRIMARY KEY (\`id\`)
    )`,

    // goat_vaccinations — vaccine schedule and administration records
    `CREATE TABLE IF NOT EXISTS \`goat_vaccinations\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`goat_id\` varchar(36) NOT NULL,
      \`vaccine_name\` varchar(255) NOT NULL,
      \`vaccination_date\` date NOT NULL,
      \`next_due_date\` date,
      \`batch_number\` varchar(100),
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`goat_vaccinations_id\` PRIMARY KEY (\`id\`)
    )`,

    // goat_weight_records — growth tracking by weight over time
    `CREATE TABLE IF NOT EXISTS \`goat_weight_records\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`goat_id\` varchar(36) NOT NULL,
      \`weight_kg\` decimal(6,2) NOT NULL,
      \`recorded_at\` date NOT NULL,
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`goat_weight_records_id\` PRIMARY KEY (\`id\`)
    )`,

    // Indexes
    `CREATE INDEX IF NOT EXISTS \`goat_animals_farm_owner_idx\` ON \`goat_animals\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`goat_bcs_records_farm_owner_idx\` ON \`goat_bcs_records\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`goat_daily_milk_farm_owner_idx\` ON \`goat_daily_milk\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`goat_famacha_records_farm_owner_idx\` ON \`goat_famacha_records\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`goat_feed_records_farm_owner_idx\` ON \`goat_feed_records\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`goat_health_events_farm_owner_idx\` ON \`goat_health_events\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`goat_kidding_events_farm_owner_idx\` ON \`goat_kidding_events\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`goat_mating_records_farm_owner_idx\` ON \`goat_mating_records\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`goat_medication_logs_farm_owner_idx\` ON \`goat_medication_logs\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`goat_pasture_records_farm_owner_idx\` ON \`goat_pasture_records\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`goat_pregnancy_checks_farm_owner_idx\` ON \`goat_pregnancy_checks\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`goat_sale_records_farm_owner_idx\` ON \`goat_sale_records\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`goat_shearing_records_farm_owner_idx\` ON \`goat_shearing_records\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`goat_vaccinations_farm_owner_idx\` ON \`goat_vaccinations\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`goat_weight_records_goat_idx\` ON \`goat_weight_records\` (\`goat_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`goat_weight_records_farm_owner_idx\` ON \`goat_weight_records\` (\`farm_owner_id\`)`,
  ];

  for (const sql of statements) {
    await connection.execute(sql);
  }
}
