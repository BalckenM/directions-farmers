import {
    date,
    datetime,
    decimal,
    index,
    mysqlTable,
    text,
    varchar,
} from "drizzle-orm/mysql-core";

export const feedLogs = mysqlTable(
  "feed_logs",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    animalId: varchar("animal_id", { length: 36 }),
    groupId: varchar("group_id", { length: 36 }),
    species: varchar("species", { length: 20 }).notNull(),
    feedType: varchar("feed_type", { length: 100 }).notNull(),
    quantityKg: decimal("quantity_kg", { precision: 8, scale: 2 }).notNull(),
    feedDate: date("feed_date").notNull(),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("feed_logs_farm_owner_idx").on(t.farmOwnerId),
  }),
);
