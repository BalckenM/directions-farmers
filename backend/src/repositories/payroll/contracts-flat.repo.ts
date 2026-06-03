import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { payrollContracts } from "../../db/schema";


export const payrollContractsFlatRepo = {
  // Flat contract list (all employees)
  listAllContracts: (farmOwnerId: string) =>
    db
      .select()
      .from(payrollContracts)
      .where(eq(payrollContracts.farmOwnerId, farmOwnerId))
      .orderBy(desc(payrollContracts.createdAt)),


  voidContract: (
    farmOwnerId: string,
    id: string,
    data: Partial<typeof payrollContracts.$inferInsert>,
  ) =>
    db
      .update(payrollContracts)
      .set({ ...data, updatedAt: new Date() })
      .where(
        and(
          eq(payrollContracts.farmOwnerId, farmOwnerId),
          eq(payrollContracts.id, id),
        ),
      ),
};
