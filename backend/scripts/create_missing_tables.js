const mysql = require("mysql2/promise");

async function main() {
  const c = await mysql.createConnection(
    "mysql://punfrohs_d4-farming:Ze3g5cJC3xbA4T8AuGC4@148.251.246.72:3306/punfrohs_d4-farming",
  );
  const OID = "1244ea30-ac19-4fc9-b4a1-7a87b678060d";

  await c.query(`CREATE TABLE IF NOT EXISTS \`payroll_payment_transactions\` (
    \`id\` varchar(36) NOT NULL,
    \`farm_owner_id\` varchar(36) NOT NULL,
    \`pay_run_id\` varchar(36) NOT NULL,
    \`employee_id\` varchar(36) NOT NULL,
    \`amount\` decimal(10,2) NOT NULL,
    \`currency\` varchar(10) NOT NULL DEFAULT 'ZAR',
    \`method\` varchar(20) NOT NULL DEFAULT 'bank',
    \`status\` varchar(20) NOT NULL DEFAULT 'completed',
    \`reference\` varchar(100),
    \`bank_name\` varchar(100),
    \`account_number\` varchar(50),
    \`initiated_at\` datetime,
    \`completed_at\` datetime,
    \`failure_reason\` text,
    \`created_at\` datetime NOT NULL,
    CONSTRAINT \`payroll_payment_transactions_id\` PRIMARY KEY (\`id\`)
  )`);
  console.log("payroll_payment_transactions: table created");

  await c.query(`CREATE TABLE IF NOT EXISTS \`payroll_employer_configs\` (
    \`id\` varchar(36) NOT NULL,
    \`farm_owner_id\` varchar(36) NOT NULL UNIQUE,
    \`name\` varchar(255) NOT NULL,
    \`registration_number\` varchar(100) NOT NULL,
    \`uif_reference_number\` varchar(100) NOT NULL,
    \`paye_number\` varchar(100) NOT NULL,
    \`created_at\` datetime NOT NULL,
    \`updated_at\` datetime NOT NULL,
    CONSTRAINT \`payroll_employer_configs_id\` PRIMARY KEY (\`id\`)
  )`);
  console.log("payroll_employer_configs: table created");

  // Seed employer_config for 4DFARM
  await c.query(
    `INSERT IGNORE INTO \`payroll_employer_configs\`
    (id, farm_owner_id, name, registration_number, uif_reference_number, paye_number, created_at, updated_at)
    VALUES (UUID(), ?, '4Directions Farm (Pty) Ltd', '2019/123456/07', 'U4567890', '7890123456', NOW(), NOW())`,
    [OID],
  );
  console.log("payroll_employer_configs: seeded");

  // Seed payment transactions tied to disbursed pay runs
  const [payRuns] = await c.query(
    "SELECT id, farm_owner_id FROM payroll_pay_runs WHERE farm_owner_id=? AND status='disbursed'",
    [OID],
  );

  const [employees] = await c.query(
    "SELECT id FROM payroll_employees WHERE farm_owner_id=? LIMIT 5",
    [OID],
  );

  if (employees.length === 0) {
    console.log("No employees found, skipping transactions");
    await c.end();
    return;
  }

  let inserted = 0;
  for (const run of payRuns) {
    for (const emp of employees) {
      const now = new Date().toISOString().replace("T", " ").substring(0, 19);
      await c.query(
        `INSERT IGNORE INTO \`payroll_payment_transactions\`
        (id, farm_owner_id, pay_run_id, employee_id, amount, currency, method, status, reference, bank_name, account_number, initiated_at, completed_at, created_at)
        VALUES (UUID(), ?, ?, ?, 7650.00, 'ZAR', 'bank', 'completed', ?, 'FNB', '62012345678', ?, ?, ?)`,
        [
          OID,
          run.id,
          emp.id,
          "TXN-" + Math.random().toString(36).substring(2, 10).toUpperCase(),
          now,
          now,
          now,
        ],
      );
      inserted++;
    }
  }
  console.log(`payroll_payment_transactions: ${inserted} rows seeded`);

  // Verify
  const [r1] = await c.query(
    "SELECT COUNT(*) as n FROM payroll_payment_transactions WHERE farm_owner_id=?",
    [OID],
  );
  const [r2] = await c.query(
    "SELECT COUNT(*) as n FROM payroll_employer_configs WHERE farm_owner_id=?",
    [OID],
  );
  console.log("payroll_payment_transactions count:", r1[0].n);
  console.log("payroll_employer_configs count:", r2[0].n);

  await c.end();
}

main().catch(console.error);
