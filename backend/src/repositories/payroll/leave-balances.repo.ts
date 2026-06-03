import { eq } from "drizzle-orm";
import { db } from "../../config/database";
import { payrollLeaveBalances } from "../../db/schema";

export const payrollLeaveBalancesRepo = {
  listLeaveBalances: (farmOwnerId: string) =>
    db
      .select()
      .from(payrollLeaveBalances)
      .where(eq(payrollLeaveBalances.farmOwnerId, farmOwnerId)),
};

