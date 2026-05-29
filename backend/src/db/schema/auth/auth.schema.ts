import {
  boolean,
  datetime,
  index,
  mysqlTable,
  uniqueIndex,
  varchar,
} from "drizzle-orm/mysql-core";

export const farmOwners = mysqlTable(
  "farm_owners",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    email: varchar("email", { length: 255 }).notNull(),
    passwordHash: varchar("password_hash", { length: 255 }).notNull(),
    firstName: varchar("first_name", { length: 100 }).notNull(),
    lastName: varchar("last_name", { length: 100 }).notNull(),
    phone: varchar("phone", { length: 20 }),
    emailVerifiedAt: datetime("email_verified_at"),
    createdAt: datetime("created_at").notNull(),
    updatedAt: datetime("updated_at").notNull(),
  },
  (t) => ({
    emailIdx: uniqueIndex("farm_owners_email_idx").on(t.email),
  }),
);

export const farmStaff = mysqlTable(
  "farm_staff",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    email: varchar("email", { length: 255 }).notNull(),
    passwordHash: varchar("password_hash", { length: 255 }).notNull(),
    firstName: varchar("first_name", { length: 100 }).notNull(),
    lastName: varchar("last_name", { length: 100 }).notNull(),
    role: varchar("role", { length: 50 }).notNull().default("staff"),
    isActive: boolean("is_active").notNull().default(true),
    createdAt: datetime("created_at").notNull(),
    updatedAt: datetime("updated_at").notNull(),
  },
  (t) => ({
    emailIdx: uniqueIndex("farm_staff_email_idx").on(t.email),
    farmOwnerIdx: index("farm_staff_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const refreshTokens = mysqlTable(
  "refresh_tokens",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    userId: varchar("user_id", { length: 36 }).notNull(),
    userType: varchar("user_type", { length: 10 }).notNull(),
    tokenHash: varchar("token_hash", { length: 255 }).notNull(),
    expiresAt: datetime("expires_at").notNull(),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    userIdx: index("refresh_tokens_user_idx").on(t.userId),
  }),
);

export const emailVerificationTokens = mysqlTable(
  "email_verification_tokens",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    userId: varchar("user_id", { length: 36 }).notNull(),
    token: varchar("token", { length: 255 }).notNull(),
    expiresAt: datetime("expires_at").notNull(),
    usedAt: datetime("used_at"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    tokenIdx: uniqueIndex("email_verification_tokens_token_idx").on(t.token),
  }),
);

export const passwordResetTokens = mysqlTable(
  "password_reset_tokens",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    userId: varchar("user_id", { length: 36 }).notNull(),
    userType: varchar("user_type", { length: 10 }).notNull(),
    token: varchar("token", { length: 255 }).notNull(),
    expiresAt: datetime("expires_at").notNull(),
    usedAt: datetime("used_at"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    tokenIdx: uniqueIndex("password_reset_tokens_token_idx").on(t.token),
  }),
);

export const staffInviteTokens = mysqlTable(
  "staff_invite_tokens",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    email: varchar("email", { length: 255 }).notNull(),
    role: varchar("role", { length: 50 }).notNull().default("staff"),
    token: varchar("token", { length: 255 }).notNull(),
    expiresAt: datetime("expires_at").notNull(),
    acceptedAt: datetime("accepted_at"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    tokenIdx: uniqueIndex("staff_invite_tokens_token_idx").on(t.token),
  }),
);
