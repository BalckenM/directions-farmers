import type { Connection } from "mysql2/promise";

export async function up(connection: Connection): Promise<void> {
  const statements: string[] = [
    // subscription_plans — tiers available for purchase
    `CREATE TABLE IF NOT EXISTS \`subscription_plans\` (
      \`id\` varchar(36) NOT NULL,
      \`name\` varchar(100) NOT NULL,
      \`description\` varchar(500),
      \`price_monthly\` int NOT NULL DEFAULT 0,
      \`price_annual\` int NOT NULL DEFAULT 0,
      \`is_active\` boolean NOT NULL DEFAULT true,
      \`created_at\` datetime NOT NULL,
      \`updated_at\` datetime NOT NULL,
      CONSTRAINT \`subscription_plans_id\` PRIMARY KEY (\`id\`)
    )`,

    // modules — feature modules available on the platform
    `CREATE TABLE IF NOT EXISTS \`modules\` (
      \`id\` varchar(36) NOT NULL,
      \`name\` varchar(100) NOT NULL,
      \`slug\` varchar(100) NOT NULL,
      \`description\` varchar(500),
      \`is_active\` boolean NOT NULL DEFAULT true,
      \`created_at\` datetime NOT NULL,
      \`updated_at\` datetime NOT NULL,
      CONSTRAINT \`modules_id\` PRIMARY KEY (\`id\`)
    )`,

    // plan_module_access — which modules each plan includes
    `CREATE TABLE IF NOT EXISTS \`plan_module_access\` (
      \`id\` varchar(36) NOT NULL,
      \`plan_id\` varchar(36) NOT NULL,
      \`module_id\` varchar(36) NOT NULL,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`plan_module_access_id\` PRIMARY KEY (\`id\`)
    )`,

    // farm_subscriptions — active subscription per farm owner
    `CREATE TABLE IF NOT EXISTS \`farm_subscriptions\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`plan_id\` varchar(36) NOT NULL,
      \`status\` varchar(20) NOT NULL DEFAULT 'active',
      \`start_date\` datetime NOT NULL,
      \`end_date\` datetime,
      \`created_at\` datetime NOT NULL,
      \`updated_at\` datetime NOT NULL,
      CONSTRAINT \`farm_subscriptions_id\` PRIMARY KEY (\`id\`)
    )`,

    // farm_module_activations — per-farm module toggle overrides
    `CREATE TABLE IF NOT EXISTS \`farm_module_activations\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`module_id\` varchar(36) NOT NULL,
      \`is_active\` boolean NOT NULL DEFAULT true,
      \`activated_at\` datetime NOT NULL,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`farm_module_activations_id\` PRIMARY KEY (\`id\`)
    )`,

    // Indexes
    `CREATE INDEX IF NOT EXISTS \`plan_module_access_plan_module_idx\` ON \`plan_module_access\` (\`plan_id\`, \`module_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`farm_subscriptions_farm_owner_idx\` ON \`farm_subscriptions\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`farm_module_activations_owner_module_idx\` ON \`farm_module_activations\` (\`farm_owner_id\`, \`module_id\`)`,
  ];

  for (const sql of statements) {
    await connection.execute(sql);
  }
}
