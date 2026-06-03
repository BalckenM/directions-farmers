import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
import { payrollPayslips } from "../../db/schema";

export const payrollPayslipsRepo = {
  listPayslips: (farmOwnerId: string) =>
    db
      .select()
      .from(payrollPayslips)
      .where(eq(payrollPayslips.farmOwnerId, farmOwnerId))
      .orderBy(desc(payrollPayslips.createdAt)),

  findPayslipById: (farmOwnerId: string, id: string) =>
    db
      .select()
      .from(payrollPayslips)
      .where(
        and(
          eq(payrollPayslips.farmOwnerId, farmOwnerId),
          eq(payrollPayslips.id, id),
        ),
      )
      .then((r) => r[0] ?? null),

  createPayslip: (data: typeof payrollPayslips.$inferInsert) =>
    db.insert(payrollPayslips).values(data),
};
