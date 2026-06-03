import { and, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { payrollPayGroups } from "../../db/schema";

export const payrollPayGroupsRepo = {
  listPayGroups: (farmOwnerId: string) =>
    db
      .select()
      .from(payrollPayGroups)
      .where(eq(payrollPayGroups.farmOwnerId, farmOwnerId)),

  createPayGroup: (data: typeof payrollPayGroups.$inferInsert) =>
    db.insert(payrollPayGroups).values(data),

  updatePayGroup: (
    farmOwnerId: string,
    id: string,
    data: Partial<typeof payrollPayGroups.$inferInsert>,
  ) =>
    db
      .update(payrollPayGroups)
      .set(data)
      .where(
        and(
          eq(payrollPayGroups.farmOwnerId, farmOwnerId),
          eq(payrollPayGroups.id, id),
        ),
      ),
};

