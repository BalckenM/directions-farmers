import {
    date,
    datetime,
    decimal,
    index,
    int,
    mysqlTable,
    varchar
} from "drizzle-orm/mysql-core";

export const productionMilkRecords = mysqlTable(
  "production_milk_records",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    animalId: varchar("animal_id", { length: 36 }).notNull(),
    species: varchar("species", { length: 20 }).notNull(),
    recordDate: date("record_date").notNull(),
    totalLitres: decimal("total_litres", { precision: 7, scale: 2 }).notNull(),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("production_milk_records_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);

export const productionEggRecords = mysqlTable(
  "production_egg_records",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    flockId: varchar("flock_id", { length: 36 }).notNull(),
    recordDate: date("record_date").notNull(),
    eggsCollected: int("eggs_collected").notNull(),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("production_egg_records_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);

export const productionWoolRecords = mysqlTable(
  "production_wool_records",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    animalId: varchar("animal_id", { length: 36 }).notNull(),
    shearingDate: date("shearing_date").notNull(),
    fleeceWeightKg: decimal("fleece_weight_kg", {
      precision: 6,
      scale: 2,
    }).notNull(),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("production_wool_records_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);
