import {
    datetime,
    index,
    int,
    mysqlTable,
    text,
    varchar,
} from "drizzle-orm/mysql-core";

export const livestockGroups = mysqlTable(
  "livestock_groups",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    name: varchar("name", { length: 100 }).notNull(),
    species: varchar("species", { length: 50 }).notNull(),
    count: int("count").notNull().default(0),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
    updatedAt: datetime("updated_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("livestock_groups_farm_owner_idx").on(t.farmOwnerId),
  }),
);
