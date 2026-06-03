import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { payrollAuditLog, payrollIncidents } from "../../db/schema";

export const payrollAuditRepo = {
  listAuditLog: (farmOwnerId: string) =>
    db
      .select()
      .from(payrollAuditLog)
      .where(eq(payrollAuditLog.farmOwnerId, farmOwnerId))
      .orderBy(desc(payrollAuditLog.createdAt)),

  // Incidents
  listIncidents: (farmOwnerId: string) =>
    db
      .select()
      .from(payrollIncidents)
      .where(eq(payrollIncidents.farmOwnerId, farmOwnerId))
      .orderBy(desc(payrollIncidents.createdAt)),

  createIncident: (data: typeof payrollIncidents.$inferInsert) =>
    db.insert(payrollIncidents).values(data),

  updateIncident: (
    farmOwnerId: string,
    id: string,
    data: Partial<typeof payrollIncidents.$inferInsert>,
  ) =>
    db
      .update(payrollIncidents)
      .set({ ...data, updatedAt: new Date() })
      .where(
        and(
          eq(payrollIncidents.farmOwnerId, farmOwnerId),
          eq(payrollIncidents.id, id),
        ),
      ),
};

