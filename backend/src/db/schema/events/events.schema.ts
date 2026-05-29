import {
  date,
  datetime,
  decimal,
  index,
  mysqlTable,
  text,
  varchar,
} from "drizzle-orm/mysql-core";

export const farmHealthEvents = mysqlTable(
  "farm_health_events",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    animalId: varchar("animal_id", { length: 36 }).notNull(),
    species: varchar("species", { length: 20 }).notNull(),
    eventDate: date("event_date").notNull(),
    eventType: varchar("event_type", { length: 50 }).notNull(),
    description: text("description"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("farm_health_events_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const farmWeightRecords = mysqlTable(
  "farm_weight_records",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    animalId: varchar("animal_id", { length: 36 }).notNull(),
    species: varchar("species", { length: 20 }).notNull(),
    recordDate: date("record_date").notNull(),
    weightKg: decimal("weight_kg", { precision: 7, scale: 2 }).notNull(),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("farm_weight_records_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const farmBreedingEvents = mysqlTable(
  "farm_breeding_events",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    animalId: varchar("animal_id", { length: 36 }).notNull(),
    species: varchar("species", { length: 20 }).notNull(),
    eventDate: date("event_date").notNull(),
    eventType: varchar("event_type", { length: 50 }).notNull(),
    description: text("description"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("farm_breeding_events_farm_owner_idx").on(
      t.farmOwnerId,
    ),
  }),
);
