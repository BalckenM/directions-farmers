import type { Connection } from "mysql2/promise";

export async function up(connection: Connection): Promise<void> {
  const statements: string[] = [
    // farm_paddocks — named land parcels / grazing areas
    `CREATE TABLE IF NOT EXISTS \`farm_paddocks\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`name\` varchar(100) NOT NULL,
      \`description\` text,
      \`coordinates\` json,
      \`created_at\` datetime NOT NULL,
      \`updated_at\` datetime NOT NULL,
      CONSTRAINT \`farm_paddocks_id\` PRIMARY KEY (\`id\`)
    )`,

    // farm_settings — key-value configuration per farm
    `CREATE TABLE IF NOT EXISTS \`farm_settings\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`setting_key\` varchar(100) NOT NULL,
      \`setting_value\` text,
      \`updated_at\` datetime NOT NULL,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`farm_settings_id\` PRIMARY KEY (\`id\`)
    )`,

    // audit_logs — immutable record of all data changes
    `CREATE TABLE IF NOT EXISTS \`audit_logs\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`actor_id\` varchar(36) NOT NULL,
      \`actor_type\` varchar(10) NOT NULL,
      \`action\` varchar(100) NOT NULL,
      \`resource\` varchar(100) NOT NULL,
      \`resource_id\` varchar(36),
      \`old_values\` text,
      \`new_values\` text,
      \`ip_address\` varchar(45),
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`audit_logs_id\` PRIMARY KEY (\`id\`)
    )`,

    // Indexes
    `CREATE INDEX IF NOT EXISTS \`farm_paddocks_farm_owner_idx\` ON \`farm_paddocks\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`farm_settings_farm_owner_idx\` ON \`farm_settings\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`audit_logs_farm_owner_idx\` ON \`audit_logs\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`audit_logs_created_at_idx\` ON \`audit_logs\` (\`created_at\`)`,
  ];

  for (const sql of statements) {
    await connection.execute(sql);
  }
}
