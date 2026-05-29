import {
    datetime,
    index,
    mysqlTable,
    text,
    varchar
} from "drizzle-orm/mysql-core";

export const auditLogs = mysqlTable(
  "audit_logs",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    actorId: varchar("actor_id", { length: 36 }).notNull(),
    actorType: varchar("actor_type", { length: 10 }).notNull(),
    action: varchar("action", { length: 100 }).notNull(),
    resource: varchar("resource", { length: 100 }).notNull(),
    resourceId: varchar("resource_id", { length: 36 }),
    oldValues: text("old_values"),
    newValues: text("new_values"),
    ipAddress: varchar("ip_address", { length: 45 }),
    createdAt: datetime("created_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("audit_logs_farm_owner_idx").on(t.farmOwnerId),
    createdAtIdx: index("audit_logs_created_at_idx").on(t.createdAt),
  }),
);

export const seedHistory = mysqlTable("seed_history", {
  id: varchar("id", { length: 36 }).primaryKey(),
  name: varchar("name", { length: 255 }).notNull(),
  appliedAt: datetime("applied_at").notNull(),
});
