import type { Connection } from "mysql2/promise";

export async function up(connection: Connection): Promise<void> {
  const statements: string[] = [
    // movement_records — animal movement log for traceability (DAFF / SARS compliance)
    `CREATE TABLE IF NOT EXISTS \`movement_records\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`animal_id\` varchar(36) NOT NULL,
      \`species\` varchar(20) NOT NULL,
      \`movement_type\` varchar(50) NOT NULL,
      \`from_location\` varchar(255),
      \`to_location\` varchar(255),
      \`movement_date\` date NOT NULL,
      \`reason\` varchar(255),
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`movement_records_id\` PRIMARY KEY (\`id\`)
    )`,

    // Indexes
    `CREATE INDEX IF NOT EXISTS \`movement_records_farm_owner_idx\` ON \`movement_records\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`movement_records_animal_idx\` ON \`movement_records\` (\`animal_id\`)`,
  ];

  for (const sql of statements) {
    await connection.execute(sql);
  }
}
