import type { Connection } from "mysql2/promise";

export async function up(connection: Connection): Promise<void> {
  const statements: string[] = [
    // livestock_groups — named groups of animals for batch management
    `CREATE TABLE IF NOT EXISTS \`livestock_groups\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`name\` varchar(100) NOT NULL,
      \`species\` varchar(50) NOT NULL,
      \`count\` int NOT NULL DEFAULT 0,
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      \`updated_at\` datetime NOT NULL,
      CONSTRAINT \`livestock_groups_id\` PRIMARY KEY (\`id\`)
    )`,

    // farm_health_events — cross-species health event log
    `CREATE TABLE IF NOT EXISTS \`farm_health_events\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`animal_id\` varchar(36) NOT NULL,
      \`species\` varchar(20) NOT NULL,
      \`event_date\` date NOT NULL,
      \`event_type\` varchar(50) NOT NULL,
      \`description\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`farm_health_events_id\` PRIMARY KEY (\`id\`)
    )`,

    // farm_weight_records — cross-species weight log
    `CREATE TABLE IF NOT EXISTS \`farm_weight_records\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`animal_id\` varchar(36) NOT NULL,
      \`species\` varchar(20) NOT NULL,
      \`record_date\` date NOT NULL,
      \`weight_kg\` varchar(20) NOT NULL,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`farm_weight_records_id\` PRIMARY KEY (\`id\`)
    )`,

    // farm_breeding_events — cross-species breeding event log
    `CREATE TABLE IF NOT EXISTS \`farm_breeding_events\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`animal_id\` varchar(36) NOT NULL,
      \`species\` varchar(20) NOT NULL,
      \`event_date\` date NOT NULL,
      \`event_type\` varchar(50) NOT NULL,
      \`description\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`farm_breeding_events_id\` PRIMARY KEY (\`id\`)
    )`,

    // production_milk_records — aggregated daily milk totals per animal
    `CREATE TABLE IF NOT EXISTS \`production_milk_records\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`animal_id\` varchar(36) NOT NULL,
      \`species\` varchar(20) NOT NULL,
      \`record_date\` date NOT NULL,
      \`total_litres\` decimal(7,2) NOT NULL,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`production_milk_records_id\` PRIMARY KEY (\`id\`)
    )`,

    // production_egg_records — aggregated daily egg collection per flock
    `CREATE TABLE IF NOT EXISTS \`production_egg_records\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`flock_id\` varchar(36) NOT NULL,
      \`record_date\` date NOT NULL,
      \`eggs_collected\` int NOT NULL,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`production_egg_records_id\` PRIMARY KEY (\`id\`)
    )`,

    // production_wool_records — shearing yield per animal
    `CREATE TABLE IF NOT EXISTS \`production_wool_records\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`animal_id\` varchar(36) NOT NULL,
      \`shearing_date\` date NOT NULL,
      \`fleece_weight_kg\` decimal(6,2) NOT NULL,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`production_wool_records_id\` PRIMARY KEY (\`id\`)
    )`,

    // feed_logs — feed consumption log spanning all species / groups
    `CREATE TABLE IF NOT EXISTS \`feed_logs\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`animal_id\` varchar(36),
      \`group_id\` varchar(36),
      \`species\` varchar(20) NOT NULL,
      \`feed_type\` varchar(100) NOT NULL,
      \`quantity_kg\` decimal(8,2) NOT NULL,
      \`feed_date\` date NOT NULL,
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`feed_logs_id\` PRIMARY KEY (\`id\`)
    )`,

    // Indexes
    `CREATE INDEX IF NOT EXISTS \`livestock_groups_farm_owner_idx\` ON \`livestock_groups\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`farm_health_events_farm_owner_idx\` ON \`farm_health_events\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`farm_weight_records_farm_owner_idx\` ON \`farm_weight_records\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`farm_breeding_events_farm_owner_idx\` ON \`farm_breeding_events\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`production_milk_records_farm_owner_idx\` ON \`production_milk_records\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`production_egg_records_farm_owner_idx\` ON \`production_egg_records\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`production_wool_records_farm_owner_idx\` ON \`production_wool_records\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`feed_logs_farm_owner_idx\` ON \`feed_logs\` (\`farm_owner_id\`)`,
  ];

  for (const sql of statements) {
    await connection.execute(sql);
  }
}
