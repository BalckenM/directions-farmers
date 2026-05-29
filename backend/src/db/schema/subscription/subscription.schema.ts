import {
  boolean,
  datetime,
  index,
  int,
  mysqlTable,
  uniqueIndex,
  varchar,
} from "drizzle-orm/mysql-core";

export const subscriptionPlans = mysqlTable("subscription_plans", {
  id: varchar("id", { length: 36 }).primaryKey(),
  name: varchar("name", { length: 100 }).notNull(),
  description: varchar("description", { length: 500 }),
  priceMonthly: int("price_monthly").notNull().default(0),
  priceAnnual: int("price_annual").notNull().default(0),
  isActive: boolean("is_active").notNull().default(true),
  createdAt: datetime("created_at").notNull(),
  updatedAt: datetime("updated_at").notNull(),
});

export const modules = mysqlTable("modules", {
  id: varchar("id", { length: 36 }).primaryKey(),
  name: varchar("name", { length: 100 }).notNull(),
  slug: varchar("slug", { length: 100 }).notNull(),
  description: varchar("description", { length: 500 }),
  isActive: boolean("is_active").notNull().default(true),
  createdAt: datetime("created_at").notNull(),
  updatedAt: datetime("updated_at").notNull(),
});

export const planModuleAccess = mysqlTable(
  "plan_module_access",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    planId: varchar("plan_id", { length: 36 }).notNull(),
    moduleId: varchar("module_id", { length: 36 }).notNull(),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    planModuleIdx: uniqueIndex("plan_module_access_plan_module_idx").on(
      t.planId,
      t.moduleId,
    ),
  }),
);

export const farmSubscriptions = mysqlTable(
  "farm_subscriptions",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    planId: varchar("plan_id", { length: 36 }).notNull(),
    status: varchar("status", { length: 20 }).notNull().default("active"),
    startDate: datetime("start_date").notNull(),
    endDate: datetime("end_date"),
    createdAt: datetime("created_at").notNull(),
    updatedAt: datetime("updated_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("farm_subscriptions_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const farmModuleActivations = mysqlTable(
  "farm_module_activations",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    moduleId: varchar("module_id", { length: 36 }).notNull(),
    isActive: boolean("is_active").notNull().default(true),
    activatedAt: datetime("activated_at").notNull(),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerModuleIdx: index("farm_module_activations_owner_module_idx").on(
      t.farmOwnerId,
      t.moduleId,
    ),
  }),
);
