import { and, count, desc, eq, or } from "drizzle-orm";
import { db } from "../../config/database";
import {
    payrollAuditLog,
    payrollCommunications,
    payrollComplianceAlerts,
    payrollContracts,
    payrollDeductionRules,
    payrollEmployees,
    payrollGarnisheeOrders,
    payrollIncidents,
    payrollLeaveBalances,
    payrollLeaveRequests,
    payrollLeaveTypes,
    payrollPayGroups,
    payrollPayRuns,
    payrollPayslips,
    payrollPayStructures,
    payrollPieceworkLogs,
    payrollTransactions,
} from "../../db/schema";

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

