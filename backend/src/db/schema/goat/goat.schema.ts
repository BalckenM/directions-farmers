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

export const goatAnimals = mysqlTable(
  "goat_animals",
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
    expectedKiddingDate: date("expected_kidding_date"),
    lastKiddingDate: date("last_kidding_date"),
    totalKidsRaised: int("total_kids_raised").notNull().default(0),
    isLactating: boolean("is_lactating").notNull().default(false),
    currentMilkLitrePd: decimal("current_milk_litre_pd", {
      precision: 6,
      scale: 2,
    }),
    lactationNumber: int("lactation_number").notNull().default(0),
    dryOffDate: date("dry_off_date"),
    lastShearingDate: date("last_shearing_date"),
    lastDewormingDate: date("last_deworming_date"),
    famachaScore: int("famacha_score"),
    registrationNumber: varchar("registration_number", { length: 100 }),
    damId: varchar("dam_id", { length: 36 }),
    specificData: text("specific_data"),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
    updatedAt: datetime("updated_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("goat_animals_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const goatWeightRecords = mysqlTable(
  "goat_weight_records",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    goatId: varchar("goat_id", { length: 36 }).notNull(),
    weightKg: decimal("weight_kg", { precision: 6, scale: 2 }).notNull(),
    recordedAt: date("recorded_at").notNull(),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    goatIdx: index("goat_weight_records_goat_idx").on(t.goatId),
    farmOwnerIdx: index("goat_weight_records_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const goatMatingRecords = mysqlTable(
  "goat_mating_records",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    doeId: varchar("doe_id", { length: 36 }).notNull(),
    buckId: varchar("buck_id", { length: 36 }),
    matingDate: date("mating_date").notNull(),
    method: varchar("method", { length: 50 }),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("goat_mating_records_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const goatPregnancyChecks = mysqlTable(
  "goat_pregnancy_checks",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    goatId: varchar("goat_id", { length: 36 }).notNull(),
    checkDate: date("check_date").notNull(),
    result: varchar("result", { length: 20 }).notNull(),
    expectedKiddingDate: date("expected_kidding_date"),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("goat_pregnancy_checks_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);

export const goatKiddingEvents = mysqlTable(
  "goat_kidding_events",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    doeId: varchar("doe_id", { length: 36 }).notNull(),
    kiddingDate: date("kidding_date").notNull(),
    kidsAlive: int("kids_alive").notNull().default(0),
    kidsDead: int("kids_dead").notNull().default(0),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("goat_kidding_events_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const goatDailyMilk = mysqlTable(
  "goat_daily_milk",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    goatId: varchar("goat_id", { length: 36 }).notNull(),
    recordDate: date("record_date").notNull(),
    morningLitres: decimal("morning_litres", { precision: 6, scale: 2 }),
    eveningLitres: decimal("evening_litres", { precision: 6, scale: 2 }),
    totalLitres: decimal("total_litres", { precision: 6, scale: 2 }).notNull(),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("goat_daily_milk_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const goatShearingRecords = mysqlTable(
  "goat_shearing_records",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    goatId: varchar("goat_id", { length: 36 }).notNull(),
    shearingDate: date("shearing_date").notNull(),
    fleeceWeightKg: decimal("fleece_weight_kg", { precision: 6, scale: 2 }),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("goat_shearing_records_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);

export const goatHealthEvents = mysqlTable(
  "goat_health_events",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    goatId: varchar("goat_id", { length: 36 }).notNull(),
    eventDate: date("event_date").notNull(),
    eventType: varchar("event_type", { length: 50 }).notNull(),
    diagnosis: varchar("diagnosis", { length: 255 }),
    treatment: text("treatment"),
    outcome: varchar("outcome", { length: 50 }),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("goat_health_events_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const goatMedicationLogs = mysqlTable(
  "goat_medication_logs",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    goatId: varchar("goat_id", { length: 36 }).notNull(),
    medicationName: varchar("medication_name", { length: 255 }).notNull(),
    dosage: varchar("dosage", { length: 100 }),
    administeredAt: date("administered_at").notNull(),
    administeredBy: varchar("administered_by", { length: 100 }),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("goat_medication_logs_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);

export const goatVaccinations = mysqlTable(
  "goat_vaccinations",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    goatId: varchar("goat_id", { length: 36 }).notNull(),
    vaccineName: varchar("vaccine_name", { length: 255 }).notNull(),
    vaccinationDate: date("vaccination_date").notNull(),
    nextDueDate: date("next_due_date"),
    batchNumber: varchar("batch_number", { length: 100 }),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("goat_vaccinations_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const goatSaleRecords = mysqlTable(
  "goat_sale_records",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    goatId: varchar("goat_id", { length: 36 }).notNull(),
    saleDate: date("sale_date").notNull(),
    buyerName: varchar("buyer_name", { length: 255 }),
    salePrice: decimal("sale_price", { precision: 10, scale: 2 }).notNull(),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("goat_sale_records_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const goatFeedRecords = mysqlTable(
  "goat_feed_records",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    goatId: varchar("goat_id", { length: 36 }),
    feedType: varchar("feed_type", { length: 100 }).notNull(),
    quantityKg: decimal("quantity_kg", { precision: 8, scale: 2 }).notNull(),
    feedDate: date("feed_date").notNull(),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("goat_feed_records_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const goatPastureRecords = mysqlTable(
  "goat_pasture_records",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    pastureId: varchar("pasture_id", { length: 36 }),
    pastureName: varchar("pasture_name", { length: 100 }).notNull(),
    moveDate: date("move_date").notNull(),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("goat_pasture_records_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);

export const goatFamachaRecords = mysqlTable(
  "goat_famacha_records",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    goatId: varchar("goat_id", { length: 36 }).notNull(),
    score: int("score").notNull(),
    recordDate: date("record_date").notNull(),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("goat_famacha_records_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);

export const goatBcsRecords = mysqlTable(
  "goat_bcs_records",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    goatId: varchar("goat_id", { length: 36 }).notNull(),
    score: decimal("score", { precision: 3, scale: 1 }).notNull(),
    recordDate: date("record_date").notNull(),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("goat_bcs_records_farm_owner_idx").on(t.farmOwnerId),
  }),
);
