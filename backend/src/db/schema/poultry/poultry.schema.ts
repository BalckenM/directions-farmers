import {
  date,
  datetime,
  decimal,
  index,
  int,
  mysqlTable,
  text,
  varchar,
} from "drizzle-orm/mysql-core";

export const poultryFlocks = mysqlTable(
  "poultry_flocks",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    name: varchar("name", { length: 100 }).notNull(),
    species: varchar("species", { length: 50 }).notNull(),
    breed: varchar("breed", { length: 100 }),
    purpose: varchar("purpose", { length: 50 }),
    houseNumber: varchar("house_number", { length: 50 }),
    placementDate: date("placement_date"),
    initialCount: int("initial_count").notNull().default(0),
    currentCount: int("current_count").notNull().default(0),
    mortalityTotal: int("mortality_total").notNull().default(0),
    mortalityPct: decimal("mortality_pct", { precision: 5, scale: 2 }),
    dayOfAge: int("day_of_age"),
    weekOfAge: int("week_of_age"),
    currentStage: varchar("current_stage", { length: 50 }),
    currentAvgWeightG: int("current_avg_weight_g"),
    feedConsumedTotalKg: decimal("feed_consumed_total_kg", {
      precision: 10,
      scale: 2,
    }),
    fcrToDate: decimal("fcr_to_date", { precision: 5, scale: 3 }),
    targetSlaughterWeightG: int("target_slaughter_weight_g"),
    projectedSlaughterDate: date("projected_slaughter_date"),
    unitCostPerChick: decimal("unit_cost_per_chick", {
      precision: 8,
      scale: 2,
    }),
    livabilityPct: decimal("livability_pct", { precision: 5, scale: 2 }),
    specificData: text("specific_data"),
    status: varchar("status", { length: 20 }).notNull().default("active"),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
    updatedAt: datetime("updated_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("poultry_flocks_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const poultryDailyRecords = mysqlTable(
  "poultry_daily_records",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    flockId: varchar("flock_id", { length: 36 }).notNull(),
    recordDate: date("record_date").notNull(),
    mortalityCount: int("mortality_count").notNull().default(0),
    culledCount: int("culled_count").notNull().default(0),
    eggsCollected: int("eggs_collected").notNull().default(0),
    feedConsumedKg: decimal("feed_consumed_kg", { precision: 8, scale: 2 }),
    waterConsumedLitres: decimal("water_consumed_litres", {
      precision: 8,
      scale: 2,
    }),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("poultry_daily_records_farm_owner_idx").on(
      t.farmOwnerId,
    ),
    flockIdx: index("poultry_daily_records_flock_idx").on(t.flockId),
  }),
);

export const poultryVaccinationSchedules = mysqlTable(
  "poultry_vaccination_schedules",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    flockId: varchar("flock_id", { length: 36 }).notNull(),
    vaccineName: varchar("vaccine_name", { length: 255 }).notNull(),
    scheduledDate: date("scheduled_date").notNull(),
    administeredDate: date("administered_date"),
    method: varchar("method", { length: 50 }),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("poultry_vaccination_schedules_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);

export const poultryFeedPhases = mysqlTable(
  "poultry_feed_phases",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    flockId: varchar("flock_id", { length: 36 }).notNull(),
    phaseName: varchar("phase_name", { length: 100 }).notNull(),
    feedType: varchar("feed_type", { length: 100 }).notNull(),
    startDay: int("start_day").notNull(),
    endDay: int("end_day"),
    dailyRationGrams: decimal("daily_ration_grams", { precision: 8, scale: 2 }),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("poultry_feed_phases_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const poultryHarvestRecords = mysqlTable(
  "poultry_harvest_records",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    flockId: varchar("flock_id", { length: 36 }).notNull(),
    harvestDate: date("harvest_date").notNull(),
    birdsHarvested: int("birds_harvested").notNull(),
    averageWeightKg: decimal("average_weight_kg", { precision: 5, scale: 2 }),
    totalWeightKg: decimal("total_weight_kg", { precision: 10, scale: 2 }),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("poultry_harvest_records_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);

export const poultryMedicationLogs = mysqlTable(
  "poultry_medication_logs",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    flockId: varchar("flock_id", { length: 36 }).notNull(),
    medicationName: varchar("medication_name", { length: 255 }).notNull(),
    dosage: varchar("dosage", { length: 100 }),
    administeredAt: date("administered_at").notNull(),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("poultry_medication_logs_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);

export const poultryDiseaseEvents = mysqlTable(
  "poultry_disease_events",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    flockId: varchar("flock_id", { length: 36 }).notNull(),
    eventDate: date("event_date").notNull(),
    diseaseName: varchar("disease_name", { length: 255 }),
    affectedCount: int("affected_count").notNull().default(0),
    treatment: text("treatment"),
    outcome: varchar("outcome", { length: 50 }),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("poultry_disease_events_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);

export const poultryEnvironmentReadings = mysqlTable(
  "poultry_environment_readings",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    flockId: varchar("flock_id", { length: 36 }).notNull(),
    recordedAt: datetime("recorded_at").notNull(),
    temperatureCelsius: decimal("temperature_celsius", {
      precision: 5,
      scale: 2,
    }),
    humidityPercent: decimal("humidity_percent", { precision: 5, scale: 2 }),
    ammoniaPpm: decimal("ammonia_ppm", { precision: 6, scale: 2 }),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("poultry_environment_readings_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);

export const poultryInventory = mysqlTable(
  "poultry_inventory",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    itemName: varchar("item_name", { length: 255 }).notNull(),
    category: varchar("category", { length: 50 }).notNull(),
    quantity: decimal("quantity", { precision: 10, scale: 2 }).notNull(),
    unit: varchar("unit", { length: 20 }).notNull(),
    notes: text("notes"),
    updatedAt: datetime("updated_at").notNull(),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("poultry_inventory_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const poultryEggSales = mysqlTable(
  "poultry_egg_sales",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    flockId: varchar("flock_id", { length: 36 }),
    saleDate: date("sale_date").notNull(),
    eggsCount: int("eggs_count").notNull(),
    pricePerEgg: decimal("price_per_egg", { precision: 8, scale: 4 }).notNull(),
    totalAmount: decimal("total_amount", { precision: 10, scale: 2 }).notNull(),
    buyerName: varchar("buyer_name", { length: 255 }),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("poultry_egg_sales_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const poultryChickSales = mysqlTable(
  "poultry_chick_sales",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    flockId: varchar("flock_id", { length: 36 }),
    saleDate: date("sale_date").notNull(),
    chicksCount: int("chicks_count").notNull(),
    pricePerChick: decimal("price_per_chick", {
      precision: 8,
      scale: 2,
    }).notNull(),
    totalAmount: decimal("total_amount", { precision: 10, scale: 2 }).notNull(),
    buyerName: varchar("buyer_name", { length: 255 }),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("poultry_chick_sales_farm_owner_idx").on(t.farmOwnerId),
  }),
);
