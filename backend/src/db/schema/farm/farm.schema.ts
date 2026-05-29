import {
    datetime,
    index,
    json,
    mysqlTable,
    text,
    varchar,
} from "drizzle-orm/mysql-core";

export const farmPaddocks = mysqlTable(
  "farm_paddocks",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    name: varchar("name", { length: 100 }).notNull(),
    description: text("description"),
    coordinates: json("coordinates"),
    createdAt: datetime("created_at").notNull(),
    updatedAt: datetime("updated_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("farm_paddocks_farm_owner_idx").on(t.farmOwnerId),
  }),
);

export const farmSettings = mysqlTable(
  "farm_settings",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    settingKey: varchar("setting_key", { length: 100 }).notNull(),
    settingValue: text("setting_value"),
    updatedAt: datetime("updated_at").notNull(),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("farm_settings_farm_owner_idx").on(t.farmOwnerId),
  }),
);
