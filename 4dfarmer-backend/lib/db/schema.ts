/**
 * 4D Farmer – Drizzle ORM schema for MySQL
 * All tables follow snake_case naming convention.
 */

import {
  boolean,
  datetime,
  decimal,
  int,
  json,
  mysqlTable,
  text,
  timestamp,
  varchar,
} from 'drizzle-orm/mysql-core';

// ─────────────────────────────────────────────────────────────────────────────
// Subscription Plans  (3 tiers: Starter / Growth / Enterprise)
// ─────────────────────────────────────────────────────────────────────────────
export const subscriptionPlans = mysqlTable('subscription_plans', {
  id: int('id').autoincrement().primaryKey(),
  name: varchar('name', { length: 100 }).notNull(),
  slug: varchar('slug', { length: 50 }).notNull().unique(),
  description: text('description'),
  priceMonthly: decimal('price_monthly', { precision: 10, scale: 2 }).notNull(),
  priceYearly: decimal('price_yearly', { precision: 10, scale: 2 }).notNull(),
  maxLivestockRecords: int('max_livestock_records').notNull().default(100),
  maxFieldRecords: int('max_field_records').notNull().default(10),
  maxUsers: int('max_users').notNull().default(1),
  features: json('features').$type<string[]>().notNull(),
  isActive: boolean('is_active').notNull().default(true),
  createdAt: timestamp('created_at').notNull().defaultNow(),
});

// ─────────────────────────────────────────────────────────────────────────────
// Modules  (one row per activatable feature)
// ─────────────────────────────────────────────────────────────────────────────
export const modules = mysqlTable('modules', {
  id: int('id').autoincrement().primaryKey(),
  name: varchar('name', { length: 100 }).notNull(),
  slug: varchar('slug', { length: 50 }).notNull().unique(),
  description: text('description'),
  icon: varchar('icon', { length: 100 }),
  category: varchar('category', { length: 50 }).notNull(),   // livestock | crop | financial | analytics
  isActive: boolean('is_active').notNull().default(true),
});

// Plan ↔ Module access mapping
export const planModuleAccess = mysqlTable('plan_module_access', {
  planId: int('plan_id').notNull().references(() => subscriptionPlans.id),
  moduleId: int('module_id').notNull().references(() => modules.id),
});

// ─────────────────────────────────────────────────────────────────────────────
// Farmers  (core user table)
// ─────────────────────────────────────────────────────────────────────────────
export const farmers = mysqlTable('farmers', {
  id: varchar('id', { length: 36 }).primaryKey(),             // UUID v4
  email: varchar('email', { length: 255 }).notNull().unique(),
  passwordHash: varchar('password_hash', { length: 255 }).notNull(),
  firstName: varchar('first_name', { length: 100 }).notNull(),
  lastName: varchar('last_name', { length: 100 }).notNull(),
  phone: varchar('phone', { length: 30 }),
  farmName: varchar('farm_name', { length: 200 }),
  country: varchar('country', { length: 100 }),
  province: varchar('province', { length: 100 }),
  emailVerifiedAt: timestamp('email_verified_at'),
  createdAt: timestamp('created_at').notNull().defaultNow(),
  updatedAt: timestamp('updated_at').notNull().defaultNow().onUpdateNow(),
});

// ─────────────────────────────────────────────────────────────────────────────
// Farmer Subscriptions
// ─────────────────────────────────────────────────────────────────────────────
export const farmerSubscriptions = mysqlTable('farmer_subscriptions', {
  id: int('id').autoincrement().primaryKey(),
  farmerId: varchar('farmer_id', { length: 36 }).notNull().references(() => farmers.id),
  planId: int('plan_id').notNull().references(() => subscriptionPlans.id),
  billingCycle: varchar('billing_cycle', { length: 10 }).notNull().default('monthly'), // monthly | yearly
  status: varchar('status', { length: 20 }).notNull().default('trial'),               // trial | active | cancelled | expired
  startedAt: timestamp('started_at').notNull().defaultNow(),
  expiresAt: timestamp('expires_at'),
  createdAt: timestamp('created_at').notNull().defaultNow(),
});

// ─────────────────────────────────────────────────────────────────────────────
// Farmer Module Activations
// ─────────────────────────────────────────────────────────────────────────────
export const farmerModules = mysqlTable('farmer_modules', {
  id: int('id').autoincrement().primaryKey(),
  farmerId: varchar('farmer_id', { length: 36 }).notNull().references(() => farmers.id),
  moduleId: int('module_id').notNull().references(() => modules.id),
  isActive: boolean('is_active').notNull().default(true),
  activatedAt: timestamp('activated_at').notNull().defaultNow(),
});

// ─────────────────────────────────────────────────────────────────────────────
// Auth – Refresh Tokens
// ─────────────────────────────────────────────────────────────────────────────
export const refreshTokens = mysqlTable('refresh_tokens', {
  id: varchar('id', { length: 36 }).primaryKey(),
  farmerId: varchar('farmer_id', { length: 36 }).notNull().references(() => farmers.id),
  tokenHash: varchar('token_hash', { length: 255 }).notNull(),
  expiresAt: timestamp('expires_at').notNull(),
  revokedAt: timestamp('revoked_at'),
  createdAt: timestamp('created_at').notNull().defaultNow(),
});

// ─────────────────────────────────────────────────────────────────────────────
// Livestock  (shared structure, species = cattle | goat | pig | poultry)
// ─────────────────────────────────────────────────────────────────────────────
export const livestock = mysqlTable('livestock', {
  id: varchar('id', { length: 36 }).primaryKey(),
  farmerId: varchar('farmer_id', { length: 36 }).notNull().references(() => farmers.id),
  species: varchar('species', { length: 30 }).notNull(),      // cattle | goat | pig | poultry
  tagNumber: varchar('tag_number', { length: 50 }),
  name: varchar('name', { length: 100 }),
  breed: varchar('breed', { length: 100 }),
  gender: varchar('gender', { length: 10 }),                  // male | female | unknown
  dateOfBirth: datetime('date_of_birth'),
  weightKg: decimal('weight_kg', { precision: 8, scale: 2 }),
  status: varchar('status', { length: 30 }).notNull().default('active'), // active | sold | deceased | transferred
  parentId: varchar('parent_id', { length: 36 }),
  notes: text('notes'),
  createdAt: timestamp('created_at').notNull().defaultNow(),
  updatedAt: timestamp('updated_at').notNull().defaultNow().onUpdateNow(),
});

// ─────────────────────────────────────────────────────────────────────────────
// Aquaculture
// ─────────────────────────────────────────────────────────────────────────────
export const aquaculturePonds = mysqlTable('aquaculture_ponds', {
  id: varchar('id', { length: 36 }).primaryKey(),
  farmerId: varchar('farmer_id', { length: 36 }).notNull().references(() => farmers.id),
  name: varchar('name', { length: 100 }).notNull(),
  species: varchar('species', { length: 100 }),
  capacityLitres: decimal('capacity_litres', { precision: 12, scale: 2 }),
  stockCount: int('stock_count').notNull().default(0),
  status: varchar('status', { length: 30 }).notNull().default('active'),
  notes: text('notes'),
  createdAt: timestamp('created_at').notNull().defaultNow(),
  updatedAt: timestamp('updated_at').notNull().defaultNow().onUpdateNow(),
});

// ─────────────────────────────────────────────────────────────────────────────
// Apiculture (beekeeping)
// ─────────────────────────────────────────────────────────────────────────────
export const apicultureHives = mysqlTable('apiculture_hives', {
  id: varchar('id', { length: 36 }).primaryKey(),
  farmerId: varchar('farmer_id', { length: 36 }).notNull().references(() => farmers.id),
  hiveNumber: varchar('hive_number', { length: 50 }).notNull(),
  queenYear: int('queen_year'),
  status: varchar('status', { length: 30 }).notNull().default('active'), // active | inactive | collapsed
  lastInspection: datetime('last_inspection'),
  honeyYieldKg: decimal('honey_yield_kg', { precision: 8, scale: 2 }),
  notes: text('notes'),
  createdAt: timestamp('created_at').notNull().defaultNow(),
  updatedAt: timestamp('updated_at').notNull().defaultNow().onUpdateNow(),
});

// ─────────────────────────────────────────────────────────────────────────────
// Crops
// ─────────────────────────────────────────────────────────────────────────────
export const cropFields = mysqlTable('crop_fields', {
  id: varchar('id', { length: 36 }).primaryKey(),
  farmerId: varchar('farmer_id', { length: 36 }).notNull().references(() => farmers.id),
  name: varchar('name', { length: 100 }).notNull(),
  areaHectares: decimal('area_hectares', { precision: 10, scale: 4 }),
  soilType: varchar('soil_type', { length: 100 }),
  irrigationType: varchar('irrigation_type', { length: 100 }),
  location: varchar('location', { length: 255 }),
  notes: text('notes'),
  createdAt: timestamp('created_at').notNull().defaultNow(),
  updatedAt: timestamp('updated_at').notNull().defaultNow().onUpdateNow(),
});

export const cropCycles = mysqlTable('crop_cycles', {
  id: varchar('id', { length: 36 }).primaryKey(),
  fieldId: varchar('field_id', { length: 36 }).notNull().references(() => cropFields.id),
  farmerId: varchar('farmer_id', { length: 36 }).notNull().references(() => farmers.id),
  cropType: varchar('crop_type', { length: 100 }).notNull(),
  variety: varchar('variety', { length: 100 }),
  plantingDate: datetime('planting_date'),
  expectedHarvestDate: datetime('expected_harvest_date'),
  actualHarvestDate: datetime('actual_harvest_date'),
  yieldKg: decimal('yield_kg', { precision: 12, scale: 2 }),
  status: varchar('status', { length: 30 }).notNull().default('planned'), // planned | growing | harvested | failed
  notes: text('notes'),
  createdAt: timestamp('created_at').notNull().defaultNow(),
  updatedAt: timestamp('updated_at').notNull().defaultNow().onUpdateNow(),
});

// ─────────────────────────────────────────────────────────────────────────────
// Financial Transactions
// ─────────────────────────────────────────────────────────────────────────────
export const financialTransactions = mysqlTable('financial_transactions', {
  id: varchar('id', { length: 36 }).primaryKey(),
  farmerId: varchar('farmer_id', { length: 36 }).notNull().references(() => farmers.id),
  type: varchar('type', { length: 10 }).notNull(),            // income | expense
  amount: decimal('amount', { precision: 12, scale: 2 }).notNull(),
  currency: varchar('currency', { length: 5 }).notNull().default('ZAR'),
  category: varchar('category', { length: 100 }).notNull(),
  description: text('description'),
  referenceModule: varchar('reference_module', { length: 50 }), // cattle | crop | etc.
  referenceId: varchar('reference_id', { length: 36 }),
  transactionDate: datetime('transaction_date').notNull(),
  createdAt: timestamp('created_at').notNull().defaultNow(),
  updatedAt: timestamp('updated_at').notNull().defaultNow().onUpdateNow(),
});

// ─────────────────────────────────────────────────────────────────────────────
// Events / Calendar
// ─────────────────────────────────────────────────────────────────────────────
export const events = mysqlTable('events', {
  id: varchar('id', { length: 36 }).primaryKey(),
  farmerId: varchar('farmer_id', { length: 36 }).notNull().references(() => farmers.id),
  title: varchar('title', { length: 200 }).notNull(),
  description: text('description'),
  eventType: varchar('event_type', { length: 50 }).notNull(), // vaccination | harvest | feeding | vet | other
  eventDate: datetime('event_date').notNull(),
  isCompleted: boolean('is_completed').notNull().default(false),
  referenceModule: varchar('reference_module', { length: 50 }),
  referenceId: varchar('reference_id', { length: 36 }),
  createdAt: timestamp('created_at').notNull().defaultNow(),
  updatedAt: timestamp('updated_at').notNull().defaultNow().onUpdateNow(),
});

// ─────────────────────────────────────────────────────────────────────────────
// Production Records  (daily/batch output for any module)
// ─────────────────────────────────────────────────────────────────────────────
export const productionRecords = mysqlTable('production_records', {
  id: varchar('id', { length: 36 }).primaryKey(),
  farmerId: varchar('farmer_id', { length: 36 }).notNull().references(() => farmers.id),
  moduleSlug: varchar('module_slug', { length: 50 }).notNull(), // cattle | poultry | crop | etc.
  recordType: varchar('record_type', { length: 100 }).notNull(), // milk | eggs | honey | yield | etc.
  quantity: decimal('quantity', { precision: 12, scale: 3 }).notNull(),
  unit: varchar('unit', { length: 30 }).notNull(),              // litres | kg | units | etc.
  recordDate: datetime('record_date').notNull(),
  referenceId: varchar('reference_id', { length: 36 }),
  notes: text('notes'),
  createdAt: timestamp('created_at').notNull().defaultNow(),
});
