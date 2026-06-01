import type { Connection } from "mysql2/promise";

export async function up(connection: Connection): Promise<void> {
  const statements: string[] = [
    `ALTER TABLE \`farm_owners\`
      ADD COLUMN \`farm_name\` varchar(200) DEFAULT NULL AFTER \`phone\`,
      ADD COLUMN \`country\` varchar(100) DEFAULT NULL AFTER \`farm_name\`,
      ADD COLUMN \`province\` varchar(100) DEFAULT NULL AFTER \`country\``,
  ];

  for (const sql of statements) {
    await connection.execute(sql);
  }
}

export async function down(connection: Connection): Promise<void> {
  await connection.execute(
    `ALTER TABLE \`farm_owners\`
      DROP COLUMN \`farm_name\`,
      DROP COLUMN \`country\`,
      DROP COLUMN \`province\``
  );
}
