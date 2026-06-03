import {
    boolean,
    date,
    datetime,
    decimal,
    index,
    int,
    mysqlTable,
    text,
    tinyint,
    varchar,
} from "drizzle-orm/mysql-core";

export const cattleAnimals = mysqlTable(
  "cattle_animals",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    tagNumber: varchar("tag_number", { length: 50 }).notNull(),
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
    bodyConditionScore: decimal("body_condition_score", { precision: 3, scale: 1 }),
    isPregnant: boolean("is_pregnant").notNull().default(false),
    expectedCalvingDate: date("expected_calving_date"),
    lastCalvingDate: date("last_calving_date"),
    totalCalvesRaised: int("total_calves_raised").notNull().default(0),
    isLactating: boolean("is_lactating").notNull().default(false),
    currentMilkLitrePd: decimal("current_milk_litre_pd", { precision: 6, scale: 2 }),
    lactationNumber: int("lactation_number").notNull().default(0),
    brucellaTested: boolean("brucella_tested").notNull().default(false),
    brucellaTestDate: date("brucella_test_date"),
    fmdZone: varchar("fmd_zone", { length: 20 }),
    registrationNumber: varchar("registration_number", { length: 100 }),
    brandNumber: varchar("brand_number", { length: 50 }),
    brandPosition: varchar("brand_position", { length: 100 }),
    sireId: varchar("sire_id", { length: 36 }),
    damId: varchar("dam_id", { length: 36 }),
    purchaseDate: date("purchase_date"),
    purchasePrice: decimal("purchase_price", { precision: 10, scale: 2 }),
    dryOffDate: date("dry_off_date"),
    lastDewormingDate: date("last_deworming_date"),
    lastDippingDate: date("last_dipping_date"),
    earmarkDesc: varchar("earmark_desc", { length: 200 }),
    niisEidNumber: varchar("niis_eid_number", { length: 100 }),
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
    animalId: varchar("animal_id", { length: 36 }).notNull(),
    weightKg: decimal("weight_kg", { precision: 7, scale: 2 }).notNull(),
    date: date("date").notNull(),
    bodyConditionScore: decimal("body_condition_score", { precision: 3, scale: 1 }),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("cattle_weight_records_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const cattleBreedingRecords = mysqlTable(
  "cattle_breeding_records",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    cowId: varchar("cow_id", { length: 36 }).notNull(),
    bullId: varchar("bull_id", { length: 36 }),
    serviceDate: date("service_date").notNull(),
    serviceMethod: varchar("service_method", { length: 50 }),
    semenSource: varchar("semen_source", { length: 200 }),
    technician: varchar("technician", { length: 200 }),
    expectedCalvingDate: date("expected_calving_date"),
    outcome: varchar("outcome", { length: 50 }),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("cattle_breeding_records_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const cattlePregnancyChecks = mysqlTable(
  "cattle_pregnancy_checks",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    animalId: varchar("animal_id", { length: 36 }).notNull(),
    date: date("date").notNull(),
    status: varchar("result", { length: 20 }).notNull(),
    method: varchar("method", { length: 50 }),
    dayspregnant: int("days_pregnant"),
    checkedBy: varchar("checked_by", { length: 200 }),
    expectedCalvingDate: date("expected_calving_date"),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("cattle_pregnancy_checks_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const cattleCalvingEvents = mysqlTable(
  "cattle_calving_events",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    damId: varchar("dam_id", { length: 36 }).notNull(),
    calvingDate: date("calving_date").notNull(),
    calvingEase: varchar("calving_ease", { length: 50 }),
    calfAlive: tinyint("calf_alive").notNull().default(1),
    calfId: varchar("calf_id", { length: 36 }),
    calfSex: varchar("calf_sex", { length: 10 }),
    calfWeightKg: decimal("calf_weight_kg", { precision: 6, scale: 2 }),
    complications: text("complications"),
    calvesAlive: int("calves_alive").notNull().default(0),
    calvesDead: int("calves_dead").notNull().default(0),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("cattle_calving_events_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const cattleDailyMilk = mysqlTable(
  "cattle_daily_milk",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    animalId: varchar("animal_id", { length: 36 }).notNull(),
    date: date("date").notNull(),
    morningLitres: decimal("morning_litres", { precision: 7, scale: 2 }),
    eveningLitres: decimal("evening_litres", { precision: 7, scale: 2 }),
    totalLitres: decimal("total_litres", { precision: 7, scale: 2 }).notNull(),
    lactationDay: int("lactation_day"),
    qualityFlag: varchar("quality_flag", { length: 50 }),
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
    animalId: varchar("animal_id", { length: 36 }).notNull(),
    date: date("date").notNull(),
    eventType: varchar("event_type", { length: 50 }).notNull(),
    diagnosis: varchar("diagnosis", { length: 255 }),
    treatment: text("treatment"),
    severity: varchar("severity", { length: 50 }),
    treatedBy: varchar("treated_by", { length: 200 }),
    isNotifiable: tinyint("is_notifiable").notNull().default(0),
    outcome: varchar("outcome", { length: 50 }),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("cattle_health_events_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const cattleMedicationLogs = mysqlTable(
  "cattle_medication_logs",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    animalId: varchar("animal_id", { length: 36 }).notNull(),
    medicationName: varchar("medication_name", { length: 255 }).notNull(),
    doseMg: decimal("dose_mg", { precision: 10, scale: 2 }),
    date: date("date").notNull(),
    route: varchar("route", { length: 50 }),
    withdrawalDaysMeat: int("withdrawal_days_meat"),
    withdrawalDaysMilk: int("withdrawal_days_milk"),
    veterinarianApproved: tinyint("veterinarian_approved").notNull().default(0),
    administeredBy: varchar("administered_by", { length: 100 }),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("cattle_medication_logs_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const cattleVaccinations = mysqlTable(
  "cattle_vaccinations",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    animalId: varchar("animal_id", { length: 36 }).notNull(),
    vaccineName: varchar("vaccine_name", { length: 255 }).notNull(),
    dueDate: date("due_date").notNull(),
    givenDate: date("given_date"),
    route: varchar("route", { length: 50 }),
    siteOnBody: varchar("site_on_body", { length: 100 }),
    administeredBy: varchar("administered_by", { length: 200 }),
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
    animalId: varchar("animal_id", { length: 36 }).notNull(),
    saleDate: date("sale_date").notNull(),
    buyerName: varchar("buyer_name", { length: 255 }),
    totalAmount: decimal("total_amount", { precision: 10, scale: 2 }).notNull(),
    saleWeightKg: decimal("sale_weight_kg", { precision: 8, scale: 2 }),
    pricePerKg: decimal("price_per_kg", { precision: 8, scale: 2 }),
    transportCost: decimal("transport_cost", { precision: 10, scale: 2 }),
    permitNumber: varchar("permit_number", { length: 100 }),
    invoiceRef: varchar("invoice_ref", { length: 200 }),
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
    animalId: varchar("animal_id", { length: 36 }),
    feedType: varchar("feed_type", { length: 100 }).notNull(),
    quantityKg: decimal("quantity_kg", { precision: 8, scale: 2 }).notNull(),
    date: date("date").notNull(),
    costPerKg: decimal("cost_per_kg", { precision: 8, scale: 2 }),
    feedlotPenId: varchar("feedlot_pen_id", { length: 36 }),
    rationName: varchar("ration_name", { length: 200 }),
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
    herdId: varchar("herd_id", { length: 36 }),
    campId: varchar("camp_id", { length: 36 }),
    entryDate: date("entry_date"),
    exitDate: date("exit_date"),
    estimatedHa: decimal("estimated_ha", { precision: 10, scale: 2 }),
    veldCondition: varchar("veld_condition", { length: 50 }),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("cattle_pasture_records_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const cattleBcsRecords = mysqlTable(
  "cattle_bcs_records",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    animalId: varchar("animal_id", { length: 36 }).notNull(),
    score: decimal("score", { precision: 3, scale: 1 }).notNull(),
    assessedBy: varchar("assessed_by", { length: 200 }),
    date: date("date").notNull(),
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
    animalId: varchar("animal_id", { length: 36 }),
    productUsed: varchar("product_used", { length: 200 }),
    method: varchar("method", { length: 50 }),
    dippingDate: date("dipping_date").notNull(),
    concentration: varchar("concentration", { length: 50 }),
    nextDueDays: int("next_due_days"),
    veterinarianApproved: tinyint("veterinarian_approved").notNull().default(0),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("cattle_dipping_records_farm_owner_idx").on(t.farmOwnerId),
  }),
);
