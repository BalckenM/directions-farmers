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

