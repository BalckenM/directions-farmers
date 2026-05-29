import {
    date,
    datetime,
    index,
    mysqlTable,
    text,
    varchar,
} from "drizzle-orm/mysql-core";

export const movementRecords = mysqlTable(
  "movement_records",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    animalId: varchar("animal_id", { length: 36 }).notNull(),
    species: varchar("species", { length: 20 }).notNull(),
    movementType: varchar("movement_type", { length: 50 }).notNull(),
    fromLocation: varchar("from_location", { length: 255 }),
    toLocation: varchar("to_location", { length: 255 }),
    movementDate: date("movement_date").notNull(),
    reason: varchar("reason", { length: 255 }),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("movement_records_farm_owner_idx").on(t.farmOwnerId),
    animalIdx: index("movement_records_animal_idx").on(t.animalId),
  }),
);
