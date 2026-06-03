import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { payrollComplianceAlerts } from "../../db/schema";

export const payrollComplianceRepo = {
  listComplianceAlerts: (farmOwnerId: string) =>
    db
      .select()
      .from(payrollComplianceAlerts)
      .where(eq(payrollComplianceAlerts.farmOwnerId, farmOwnerId))
      .orderBy(desc(payrollComplianceAlerts.createdAt)),

  resolveComplianceAlert: (
    farmOwnerId: string,
    id: string,
    data: Partial<typeof payrollComplianceAlerts.$inferInsert>,
  ) =>
    db
      .update(payrollComplianceAlerts)
      .set(data)
      .where(
        and(
          eq(payrollComplianceAlerts.farmOwnerId, farmOwnerId),
          eq(payrollComplianceAlerts.id, id),
        ),
      ),
};

