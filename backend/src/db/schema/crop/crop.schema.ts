import {
    boolean,
    date,
    datetime,
    decimal,
    index,
    mysqlTable,
    text,
    varchar
} from "drizzle-orm/mysql-core";

export const cropCategories = mysqlTable("crop_categories", {
  id: varchar("id", { length: 36 }).primaryKey(),
  name: varchar("name", { length: 100 }).notNull(),
  createdAt: datetime("created_at").notNull(),
});

export const crops = mysqlTable(
  "crops",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    categoryId: varchar("category_id", { length: 36 }),
    name: varchar("name", { length: 100 }).notNull(),
    variety: varchar("variety", { length: 100 }),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
    updatedAt: datetime("updated_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("crops_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const cropFields = mysqlTable(
  "crop_fields",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    name: varchar("name", { length: 100 }).notNull(),
    areaHectares: decimal("area_hectares", { precision: 10, scale: 4 }),
    soilType: varchar("soil_type", { length: 100 }),
    irrigationType: varchar("irrigation_type", { length: 50 }),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
    updatedAt: datetime("updated_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("crop_fields_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const cropSeasons = mysqlTable(
  "crop_seasons",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    name: varchar("name", { length: 100 }).notNull(),
    startDate: date("start_date").notNull(),
    endDate: date("end_date"),
    isActive: boolean("is_active").notNull().default(true),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("crop_seasons_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const cropPlantingPlans = mysqlTable(
  "crop_planting_plans",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    cropId: varchar("crop_id", { length: 36 }).notNull(),
    fieldId: varchar("field_id", { length: 36 }).notNull(),
    seasonId: varchar("season_id", { length: 36 }),
    plantingDate: date("planting_date"),
    expectedHarvestDate: date("expected_harvest_date"),
    status: varchar("status", { length: 20 }).notNull().default("planned"),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
    updatedAt: datetime("updated_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("crop_planting_plans_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const cropTasks = mysqlTable(
  "crop_tasks",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    plantingPlanId: varchar("planting_plan_id", { length: 36 }),
    fieldId: varchar("field_id", { length: 36 }),
    title: varchar("title", { length: 255 }).notNull(),
    taskType: varchar("task_type", { length: 50 }).notNull(),
    dueDate: date("due_date"),
    completedAt: datetime("completed_at"),
    status: varchar("status", { length: 20 }).notNull().default("pending"),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
    updatedAt: datetime("updated_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("crop_tasks_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const cropPestObservations = mysqlTable(
  "crop_pest_observations",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    fieldId: varchar("field_id", { length: 36 }),
    plantingPlanId: varchar("planting_plan_id", { length: 36 }),
    observationDate: date("observation_date").notNull(),
    pestName: varchar("pest_name", { length: 255 }).notNull(),
    severity: varchar("severity", { length: 20 }),
    affectedAreaHa: decimal("affected_area_ha", { precision: 8, scale: 4 }),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("crop_pest_observations_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);

export const cropSprayRecords = mysqlTable(
  "crop_spray_records",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    fieldId: varchar("field_id", { length: 36 }),
    sprayDate: date("spray_date").notNull(),
    chemical: varchar("chemical", { length: 255 }).notNull(),
    dosagePerHa: varchar("dosage_per_ha", { length: 50 }),
    areaSprayedHa: decimal("area_sprayed_ha", { precision: 8, scale: 4 }),
    operatorName: varchar("operator_name", { length: 100 }),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("crop_spray_records_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const cropExpenses = mysqlTable(
  "crop_expenses",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    plantingPlanId: varchar("planting_plan_id", { length: 36 }),
    fieldId: varchar("field_id", { length: 36 }),
    expenseDate: date("expense_date").notNull(),
    category: varchar("category", { length: 50 }).notNull(),
    description: varchar("description", { length: 255 }),
    amount: decimal("amount", { precision: 10, scale: 2 }).notNull(),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("crop_expenses_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const cropHarvestRecords = mysqlTable(
  "crop_harvest_records",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    plantingPlanId: varchar("planting_plan_id", { length: 36 }).notNull(),
    harvestDate: date("harvest_date").notNull(),
    quantityKg: decimal("quantity_kg", { precision: 10, scale: 2 }).notNull(),
    qualityGrade: varchar("quality_grade", { length: 20 }),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("crop_harvest_records_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);

export const cropSales = mysqlTable(
  "crop_sales",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    harvestRecordId: varchar("harvest_record_id", { length: 36 }),
    saleDate: date("sale_date").notNull(),
    buyerName: varchar("buyer_name", { length: 255 }),
    quantityKg: decimal("quantity_kg", { precision: 10, scale: 2 }).notNull(),
    pricePerKg: decimal("price_per_kg", { precision: 8, scale: 4 }).notNull(),
    totalAmount: decimal("total_amount", { precision: 12, scale: 2 }).notNull(),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("crop_sales_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const cropCalendarEvents = mysqlTable(
  "crop_calendar_events",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    title: varchar("title", { length: 255 }).notNull(),
    eventType: varchar("event_type", { length: 50 }).notNull(),
    eventDate: date("event_date").notNull(),
    fieldId: varchar("field_id", { length: 36 }),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("crop_calendar_events_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);

export const cropAdvisoryContent = mysqlTable(
  "crop_advisory_content",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    title: varchar("title", { length: 255 }).notNull(),
    content: text("content").notNull(),
    category: varchar("category", { length: 50 }),
    publishedAt: datetime("published_at"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("crop_advisory_content_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);
