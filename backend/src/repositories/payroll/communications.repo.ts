import { desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { payrollCommunications } from "../../db/schema";

export const payrollCommunicationsRepo = {
  listCommunications: (farmOwnerId: string) =>
    db
      .select()
      .from(payrollCommunications)
      .where(eq(payrollCommunications.farmOwnerId, farmOwnerId))
      .orderBy(desc(payrollCommunications.createdAt)),

  createCommunication: (data: typeof payrollCommunications.$inferInsert) =>
    db.insert(payrollCommunications).values(data),
};

