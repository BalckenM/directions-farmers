import { desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { payrollTransactions } from "../../db/schema";


export const payrollTransactionsRepo = {
  listTransactions: (farmOwnerId: string) =>
    db
      .select()
      .from(payrollTransactions)
      .where(eq(payrollTransactions.farmOwnerId, farmOwnerId))
      .orderBy(desc(payrollTransactions.transactionDate)),

  // Flat contract list (all employees)
};
