import type { Connection } from "mysql2/promise";

export async function up(connection: Connection): Promise<void> {
  const statements: string[] = [
    // financial_transactions — unified income and expense ledger
    `CREATE TABLE IF NOT EXISTS \`financial_transactions\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`type\` varchar(10) NOT NULL,
      \`category\` varchar(50) NOT NULL,
      \`description\` varchar(255),
      \`amount\` decimal(12,2) NOT NULL,
      \`transaction_date\` date NOT NULL,
      \`reference\` varchar(100),
      \`notes\` text,
      \`created_at\` datetime NOT NULL,
      \`updated_at\` datetime NOT NULL,
      CONSTRAINT \`financial_transactions_id\` PRIMARY KEY (\`id\`)
    )`,

    // Indexes
    `CREATE INDEX IF NOT EXISTS \`financial_transactions_farm_owner_idx\` ON \`financial_transactions\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`financial_transactions_date_idx\` ON \`financial_transactions\` (\`transaction_date\`)`,
  ];

  for (const sql of statements) {
    await connection.execute(sql);
  }
}
