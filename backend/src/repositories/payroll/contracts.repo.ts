import { and, eq } from "drizzle-orm";
import { db } from "../../config/database";
import {
    payrollContracts
} from "../../db/schema";


export const payrollContractsRepo = {
  listContracts: (farmOwnerId: string, employeeId: string) =>
    db
      .select()
      .from(payrollContracts)
      .where(
        and(
          eq(payrollContracts.farmOwnerId, farmOwnerId),
          eq(payrollContracts.employeeId, employeeId),
        ),
      ),


  createContract: (data: typeof payrollContracts.$inferInsert) =>
    db.insert(payrollContracts).values(data),

  findContractById: async (farmOwnerId: string, id: string) => {
    const [row] = await db
      .select()
      .from(payrollContracts)
      .where(
        and(
          eq(payrollContracts.farmOwnerId, farmOwnerId),
          eq(payrollContracts.id, id),
        ),
      );
    return row ?? null;
  },

  updateContract: (
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
