import type { Connection } from "mysql2/promise";

export async function up(connection: Connection): Promise<void> {
  const statements: string[] = [
    // farm_owners — primary user account
    `CREATE TABLE IF NOT EXISTS \`farm_owners\` (
      \`id\` varchar(36) NOT NULL,
      \`email\` varchar(255) NOT NULL,
      \`password_hash\` varchar(255) NOT NULL,
      \`first_name\` varchar(100) NOT NULL,
      \`last_name\` varchar(100) NOT NULL,
      \`phone\` varchar(20),
      \`email_verified_at\` datetime,
      \`created_at\` datetime NOT NULL,
      \`updated_at\` datetime NOT NULL,
      CONSTRAINT \`farm_owners_id\` PRIMARY KEY (\`id\`),
      CONSTRAINT \`farm_owners_email_idx\` UNIQUE (\`email\`)
    )`,

    // farm_staff — workers employed by farm owner
    `CREATE TABLE IF NOT EXISTS \`farm_staff\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`email\` varchar(255) NOT NULL,
      \`password_hash\` varchar(255) NOT NULL,
      \`first_name\` varchar(100) NOT NULL,
      \`last_name\` varchar(100) NOT NULL,
      \`role\` varchar(50) NOT NULL DEFAULT 'staff',
      \`is_active\` boolean NOT NULL DEFAULT true,
      \`created_at\` datetime NOT NULL,
      \`updated_at\` datetime NOT NULL,
      CONSTRAINT \`farm_staff_id\` PRIMARY KEY (\`id\`),
      CONSTRAINT \`farm_staff_email_idx\` UNIQUE (\`email\`)
    )`,

    // refresh_tokens — JWT refresh token store
    `CREATE TABLE IF NOT EXISTS \`refresh_tokens\` (
      \`id\` varchar(36) NOT NULL,
      \`user_id\` varchar(36) NOT NULL,
      \`user_type\` varchar(10) NOT NULL,
      \`token_hash\` varchar(255) NOT NULL,
      \`expires_at\` datetime NOT NULL,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`refresh_tokens_id\` PRIMARY KEY (\`id\`)
    )`,

    // email_verification_tokens — one-time email verification links
    `CREATE TABLE IF NOT EXISTS \`email_verification_tokens\` (
      \`id\` varchar(36) NOT NULL,
      \`user_id\` varchar(36) NOT NULL,
      \`token\` varchar(255) NOT NULL,
      \`expires_at\` datetime NOT NULL,
      \`used_at\` datetime,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`email_verification_tokens_id\` PRIMARY KEY (\`id\`),
      CONSTRAINT \`email_verification_tokens_token_idx\` UNIQUE (\`token\`)
    )`,

    // password_reset_tokens — one-time password reset links
    `CREATE TABLE IF NOT EXISTS \`password_reset_tokens\` (
      \`id\` varchar(36) NOT NULL,
      \`user_id\` varchar(36) NOT NULL,
      \`user_type\` varchar(10) NOT NULL,
      \`token\` varchar(255) NOT NULL,
      \`expires_at\` datetime NOT NULL,
      \`used_at\` datetime,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`password_reset_tokens_id\` PRIMARY KEY (\`id\`),
      CONSTRAINT \`password_reset_tokens_token_idx\` UNIQUE (\`token\`)
    )`,

    // staff_invite_tokens — owner-generated invitations for new staff
    `CREATE TABLE IF NOT EXISTS \`staff_invite_tokens\` (
      \`id\` varchar(36) NOT NULL,
      \`farm_owner_id\` varchar(36) NOT NULL,
      \`email\` varchar(255) NOT NULL,
      \`role\` varchar(50) NOT NULL DEFAULT 'staff',
      \`token\` varchar(255) NOT NULL,
      \`expires_at\` datetime NOT NULL,
      \`accepted_at\` datetime,
      \`created_at\` datetime NOT NULL,
      CONSTRAINT \`staff_invite_tokens_id\` PRIMARY KEY (\`id\`),
      CONSTRAINT \`staff_invite_tokens_token_idx\` UNIQUE (\`token\`)
    )`,

    // seed_history — tracks which seed scripts have run
    `CREATE TABLE IF NOT EXISTS \`seed_history\` (
      \`id\` varchar(36) NOT NULL,
      \`name\` varchar(255) NOT NULL,
      \`applied_at\` datetime NOT NULL,
      CONSTRAINT \`seed_history_id\` PRIMARY KEY (\`id\`)
    )`,

    // Indexes
    `CREATE INDEX IF NOT EXISTS \`farm_staff_farm_owner_idx\` ON \`farm_staff\` (\`farm_owner_id\`)`,
    `CREATE INDEX IF NOT EXISTS \`refresh_tokens_user_idx\` ON \`refresh_tokens\` (\`user_id\`)`,
  ];

  for (const sql of statements) {
    await connection.execute(sql);
  }
}
