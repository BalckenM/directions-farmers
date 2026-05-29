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


export const payrollPayslipsRepo = {
  listPayslips: (farmOwnerId: string) =>
    db
      .select({
        id: payrollPayslips.id,
        payRunId: payrollPayslips.payRunId,
        employeeId: payrollPayslips.employeeId,
        grossPay: payrollPayslips.grossPay,
        totalDeductions: payrollPayslips.totalDeductions,
        netPay: payrollPayslips.netPay,
        lineItems: payrollPayslips.lineItems,
        createdAt: payrollPayslips.createdAt,
      })
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
