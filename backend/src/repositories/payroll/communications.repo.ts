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

