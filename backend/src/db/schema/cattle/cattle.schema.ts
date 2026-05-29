import {
    boolean,
    date,
    datetime,
    decimal,
    index,
    int,
    mysqlTable,
    text,
    varchar,
} from "drizzle-orm/mysql-core";

export const cattleAnimals = mysqlTable(
  "cattle_animals",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    tagId: varchar("tag_id", { length: 100 }).notNull(),
    name: varchar("name", { length: 100 }),
    breed: varchar("breed", { length: 100 }),
    sex: varchar("sex", { length: 10 }).notNull(),
    dateOfBirth: date("date_of_birth"),
    color: varchar("color", { length: 50 }),
    status: varchar("status", { length: 20 }).notNull().default("active"),
    productionType: varchar("production_type", { length: 50 }),
    herdId: varchar("herd_id", { length: 36 }),
    currentWeightKg: decimal("current_weight_kg", { precision: 7, scale: 2 }),
    targetWeightKg: decimal("target_weight_kg", { precision: 7, scale: 2 }),
    bodyConditionScore: decimal("body_condition_score", {
      precision: 3,
      scale: 1,
    }),
    isPregnant: boolean("is_pregnant").notNull().default(false),
    expectedCalvingDate: date("expected_calving_date"),
    lastCalvingDate: date("last_calving_date"),
    totalCalvesRaised: int("total_calves_raised").notNull().default(0),
    isLactating: boolean("is_lactating").notNull().default(false),
    currentMilkLitrePd: decimal("current_milk_litre_pd", {
      precision: 6,
      scale: 2,
    }),
    lactationNumber: int("lactation_number").notNull().default(0),
    brucellaTested: boolean("brucella_tested").notNull().default(false),
    brucellaTestDate: date("brucella_test_date"),
    fmdZone: varchar("fmd_zone", { length: 20 }),
    registrationNumber: varchar("registration_number", { length: 100 }),
    brandNumber: varchar("brand_number", { length: 50 }),
    brandPosition: varchar("brand_position", { length: 100 }),
    damId: varchar("dam_id", { length: 36 }),
    specificData: text("specific_data"),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
    updatedAt: datetime("updated_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("cattle_animals_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const cattleWeightRecords = mysqlTable(
  "cattle_weight_records",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    cattleId: varchar("cattle_id", { length: 36 }).notNull(),
    weightKg: decimal("weight_kg", { precision: 7, scale: 2 }).notNull(),
    recordedAt: date("recorded_at").notNull(),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("cattle_weight_records_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);

export const cattleBreedingRecords = mysqlTable(
  "cattle_breeding_records",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    cowId: varchar("cow_id", { length: 36 }).notNull(),
    bullId: varchar("bull_id", { length: 36 }),
    breedingDate: date("breeding_date").notNull(),
    method: varchar("method", { length: 50 }),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("cattle_breeding_records_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);

export const cattlePregnancyChecks = mysqlTable(
  "cattle_pregnancy_checks",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    cattleId: varchar("cattle_id", { length: 36 }).notNull(),
    checkDate: date("check_date").notNull(),
    result: varchar("result", { length: 20 }).notNull(),
    expectedCalvingDate: date("expected_calving_date"),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("cattle_pregnancy_checks_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);

export const cattleCalvingEvents = mysqlTable(
  "cattle_calving_events",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    cowId: varchar("cow_id", { length: 36 }).notNull(),
    calvingDate: date("calving_date").notNull(),
    calvesAlive: int("calves_alive").notNull().default(0),
    calvesDead: int("calves_dead").notNull().default(0),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("cattle_calving_events_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);

export const cattleDailyMilk = mysqlTable(
  "cattle_daily_milk",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    cattleId: varchar("cattle_id", { length: 36 }).notNull(),
    recordDate: date("record_date").notNull(),
    morningLitres: decimal("morning_litres", { precision: 7, scale: 2 }),
    eveningLitres: decimal("evening_litres", { precision: 7, scale: 2 }),
    totalLitres: decimal("total_litres", { precision: 7, scale: 2 }).notNull(),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("cattle_daily_milk_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const cattleHealthEvents = mysqlTable(
  "cattle_health_events",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    cattleId: varchar("cattle_id", { length: 36 }).notNull(),
    eventDate: date("event_date").notNull(),
    eventType: varchar("event_type", { length: 50 }).notNull(),
    diagnosis: varchar("diagnosis", { length: 255 }),
    treatment: text("treatment"),
    outcome: varchar("outcome", { length: 50 }),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("cattle_health_events_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);

export const cattleMedicationLogs = mysqlTable(
  "cattle_medication_logs",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    cattleId: varchar("cattle_id", { length: 36 }).notNull(),
    medicationName: varchar("medication_name", { length: 255 }).notNull(),
    dosage: varchar("dosage", { length: 100 }),
    administeredAt: date("administered_at").notNull(),
    administeredBy: varchar("administered_by", { length: 100 }),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("cattle_medication_logs_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);

export const cattleVaccinations = mysqlTable(
  "cattle_vaccinations",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    cattleId: varchar("cattle_id", { length: 36 }).notNull(),
    vaccineName: varchar("vaccine_name", { length: 255 }).notNull(),
    vaccinationDate: date("vaccination_date").notNull(),
    nextDueDate: date("next_due_date"),
    batchNumber: varchar("batch_number", { length: 100 }),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("cattle_vaccinations_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const cattleSaleRecords = mysqlTable(
  "cattle_sale_records",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    cattleId: varchar("cattle_id", { length: 36 }).notNull(),
    saleDate: date("sale_date").notNull(),
    buyerName: varchar("buyer_name", { length: 255 }),
    salePrice: decimal("sale_price", { precision: 10, scale: 2 }).notNull(),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("cattle_sale_records_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const cattleFeedRecords = mysqlTable(
  "cattle_feed_records",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    cattleId: varchar("cattle_id", { length: 36 }),
    feedType: varchar("feed_type", { length: 100 }).notNull(),
    quantityKg: decimal("quantity_kg", { precision: 8, scale: 2 }).notNull(),
    feedDate: date("feed_date").notNull(),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("cattle_feed_records_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const cattlePastureRecords = mysqlTable(
  "cattle_pasture_records",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    pastureName: varchar("pasture_name", { length: 100 }).notNull(),
    moveDate: date("move_date").notNull(),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("cattle_pasture_records_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);

export const cattleBcsRecords = mysqlTable(
  "cattle_bcs_records",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    cattleId: varchar("cattle_id", { length: 36 }).notNull(),
    score: decimal("score", { precision: 3, scale: 1 }).notNull(),
    recordDate: date("record_date").notNull(),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("cattle_bcs_records_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const cattleDippingRecords = mysqlTable(
  "cattle_dipping_records",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    dippingDate: date("dipping_date").notNull(),
    chemical: varchar("chemical", { length: 255 }),
    concentration: varchar("concentration", { length: 50 }),
    numberOfCattle: int("number_of_cattle"),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("cattle_dipping_records_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);
