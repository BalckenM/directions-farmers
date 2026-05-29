import {
    date,
    datetime,
    decimal,
    index,
    mysqlTable,
    text,
    varchar,
} from "drizzle-orm/mysql-core";

export const financialTransactions = mysqlTable(
  "financial_transactions",
  {
    id: varchar("id", { length: 36 }).primaryKey(),
    farmOwnerId: varchar("farm_owner_id", { length: 36 }).notNull(),
    type: varchar("type", { length: 10 }).notNull(),
    category: varchar("category", { length: 50 }).notNull(),
    description: varchar("description", { length: 255 }),
    amount: decimal("amount", { precision: 12, scale: 2 }).notNull(),
    transactionDate: date("transaction_date").notNull(),
    reference: varchar("reference", { length: 100 }),
    notes: text("notes"),
    createdAt: datetime("created_at").notNull(),
    updatedAt: datetime("updated_at").notNull(),
  },
  (t) => ({
    farmOwnerIdx: index("financial_transactions_farm_owner_idx").on(
      t.farmOwnerId,
    ),
    dateIdx: index("financial_transactions_date_idx").on(t.transactionDate),
  }),
);
