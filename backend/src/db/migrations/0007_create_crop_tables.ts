import type { Connection } from "mysql2/promise";

export async function up(connection: Connection): Promise<void> {
  const statements: string[] = [
    // crop_categories — lookup table for crop types (e.g. Vegetables, Grains)
    `CREATE TABLE IF NOT EXISTS \`crop_categories\` (
      \`id\` varchar(36) NOT NULL,
      \`name\` varchar(100) NOT NULL,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`crop_categories_id\` PRIMARY KEY (\`id\`)
    )`,

    // crops — crop varieties registered by each farm
    `CREATE TABLE IF NOT EXISTS \`crops\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`category_id\` varchar(36),
      \`name\` varchar(100) NOT NULL,
      \`variety\` varchar(100),
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      \`updated_at\` datetime NOT NULL,
      CONSTRAINT \`crops_id\` PRIMARY KEY (\`id\`)
    )`,

    // crop_fields — named physical fields with area and soil info
    `CREATE TABLE IF NOT EXISTS \`crop_fields\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`name\` varchar(100) NOT NULL,
      \`area_hectares\` decimal(10,4),
      \`soil_type\` varchar(100),
      \`irrigation_type\` varchar(50),
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      \`updated_at\` datetime NOT NULL,
      CONSTRAINT \`crop_fields_id\` PRIMARY KEY (\`id\`)
    )`,

    // crop_seasons — named growing seasons (e.g. Summer 2024/25)
    `CREATE TABLE IF NOT EXISTS \`crop_seasons\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`name\` varchar(100) NOT NULL,
      \`start_date\` date NOT NULL,
      \`end_date\` date,
      \`is_active\` boolean NOT NULL DEFAULT true,
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`crop_seasons_id\` PRIMARY KEY (\`id\`)
    )`,

    // crop_planting_plans — what is planted in which field for which season
    `CREATE TABLE IF NOT EXISTS \`crop_planting_plans\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`crop_id\` varchar(36) NOT NULL,
      \`field_id\` varchar(36) NOT NULL,
      \`season_id\` varchar(36),
      \`planting_date\` date,
      \`expected_harvest_date\` date,
      \`status\` varchar(20) NOT NULL DEFAULT 'planned',
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      \`updated_at\` datetime NOT NULL,
      CONSTRAINT \`crop_planting_plans_id\` PRIMARY KEY (\`id\`)
    )`,

    // crop_tasks — field tasks linked to a planting plan or field
    `CREATE TABLE IF NOT EXISTS \`crop_tasks\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`planting_plan_id\` varchar(36),
      \`field_id\` varchar(36),
      \`title\` varchar(255) NOT NULL,
      \`task_type\` varchar(50) NOT NULL,
      \`due_date\` date,
      \`completed_at\` datetime,
      \`status\` varchar(20) NOT NULL DEFAULT 'pending',
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      \`updated_at\` datetime NOT NULL,
      CONSTRAINT \`crop_tasks_id\` PRIMARY KEY (\`id\`)
    )`,

    // crop_pest_observations — pest sightings with severity and affected area
    `CREATE TABLE IF NOT EXISTS \`crop_pest_observations\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`field_id\` varchar(36),
      \`planting_plan_id\` varchar(36),
      \`observation_date\` date NOT NULL,
      \`pest_name\` varchar(255) NOT NULL,
      \`severity\` varchar(20),
      \`affected_area_ha\` decimal(8,4),
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`crop_pest_observations_id\` PRIMARY KEY (\`id\`)
    )`,

    // crop_spray_records — chemical applications with dosage and operator
    `CREATE TABLE IF NOT EXISTS \`crop_spray_records\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`field_id\` varchar(36),
      \`spray_date\` date NOT NULL,
      \`chemical\` varchar(255) NOT NULL,
      \`dosage_per_ha\` varchar(50),
      \`area_sprayed_ha\` decimal(8,4),
      \`operator_name\` varchar(100),
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`crop_spray_records_id\` PRIMARY KEY (\`id\`)
    )`,

    // crop_expenses — cost items linked to a field or planting plan
    `CREATE TABLE IF NOT EXISTS \`crop_expenses\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`planting_plan_id\` varchar(36),
      \`field_id\` varchar(36),
      \`expense_date\` date NOT NULL,
      \`category\` varchar(50) NOT NULL,
      \`description\` varchar(255),
      \`amount\` decimal(10,2) NOT NULL,
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`crop_expenses_id\` PRIMARY KEY (\`id\`)
    )`,

    // crop_harvest_records — yield quantity and quality per planting plan
    `CREATE TABLE IF NOT EXISTS \`crop_harvest_records\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`planting_plan_id\` varchar(36) NOT NULL,
      \`harvest_date\` date NOT NULL,
      \`quantity_kg\` decimal(10,2) NOT NULL,
      \`quality_grade\` varchar(20),
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`crop_harvest_records_id\` PRIMARY KEY (\`id\`)
    )`,

    // crop_sales — revenue from selling harvested produce
    `CREATE TABLE IF NOT EXISTS \`crop_sales\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`harvest_record_id\` varchar(36),
      \`sale_date\` date NOT NULL,
      \`buyer_name\` varchar(255),
      \`quantity_kg\` decimal(10,2) NOT NULL,
      \`price_per_kg\` decimal(8,4) NOT NULL,
      \`total_amount\` decimal(12,2) NOT NULL,
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`crop_sales_id\` PRIMARY KEY (\`id\`)
    )`,

    // crop_calendar_events — scheduled field events (planting, spraying, etc.)
    `CREATE TABLE IF NOT EXISTS \`crop_calendar_events\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`title\` varchar(255) NOT NULL,
      \`event_type\` varchar(50) NOT NULL,
      \`event_date\` date NOT NULL,
      \`field_id\` varchar(36),
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`crop_calendar_events_id\` PRIMARY KEY (\`id\`)
    )`,

    // crop_advisory_content — agronomic tips and advisory articles per farm
    `CREATE TABLE IF NOT EXISTS \`crop_advisory_content\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`title\` varchar(255) NOT NULL,
      \`content\` text NOT NULL,
      \`category\` varchar(50),
      \`published_at\` datetime,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`crop_advisory_content_id\` PRIMARY KEY (\`id\`)
    )`,

    // Indexes
    `CREATE INDEX IF NOT EXISTS \`crops_farm_owner_idx\` ON \`crops\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`crop_fields_farm_owner_idx\` ON \`crop_fields\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`crop_seasons_farm_owner_idx\` ON \`crop_seasons\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`crop_planting_plans_farm_owner_idx\` ON \`crop_planting_plans\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`crop_tasks_farm_owner_idx\` ON \`crop_tasks\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`crop_pest_observations_farm_owner_idx\` ON \`crop_pest_observations\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`crop_spray_records_farm_owner_idx\` ON \`crop_spray_records\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`crop_expenses_farm_owner_idx\` ON \`crop_expenses\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`crop_harvest_records_farm_owner_idx\` ON \`crop_harvest_records\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`crop_sales_farm_owner_idx\` ON \`crop_sales\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`crop_calendar_events_farm_owner_idx\` ON \`crop_calendar_events\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`crop_advisory_content_farm_owner_idx\` ON \`crop_advisory_content\` (\`farm_owner_id\`)`,
  ];

  for (const sql of statements) {
    await connection.execute(sql);
  }
}
