import { randomUUID } from "crypto";
import type { z } from "zod";
import { payrollRepo } from "../../repositories/payroll/payroll.repo";
import type {
  createLeaveRequestSchema,
  createPieceworkLogSchema,
} from "../../validators/payroll/payroll.validator";

function toIso(v: unknown): string | null {
  return v instanceof Date ? v.toISOString() : v ? String(v) : null;
}

function mapLeaveTypeRow(
  row: Record<string, unknown>,
): Record<string, unknown> {
  return {
    id: row.id,
    code: row.code,
    name: row.name,
    annualEntitlementDays: parseFloat(String(row.annualEntitlementDays ?? 0)),
    isPaid: row.isPaid ?? true,
    requiresApproval: row.requiresApproval ?? false,
    colorHex: row.colorHex ?? null,
    description: row.description ?? null,
  };
}

function mapLeaveRequestRow(
  row: Record<string, unknown>,
): Record<string, unknown> {
  return {
    id: row.id,
    employeeId: row.employeeId,
    leaveTypeId: row.leaveTypeId,
    startDate: toIso(row.startDate),
    endDate: toIso(row.endDate),
    submittedAt: toIso(row.submittedAt) ?? toIso(row.createdAt),
    daysRequested: parseFloat(String(row.daysRequested ?? 0)),
    reason: (row.reason as string | null) ?? "",
    status: row.status ?? "pending",
    reviewedByUserId: row.reviewedByUserId ?? null,
    reviewedAt: toIso(row.reviewedAt) ?? null,
    rejectionReason: row.rejectionReason ?? null,
  };
}

export const payrollLeaveService = {
  listLeaveRequests: (farmOwnerId: string) =>
    payrollRepo
      .listLeaveRequests(farmOwnerId)
      .then((rows) =>
        rows.map((r) => mapLeaveRequestRow(r as Record<string, unknown>)),
      ),

  createLeaveRequest: async (
    farmOwnerId: string,
    input: z.infer<typeof createLeaveRequestSchema>,
  ) => {
    const id = randomUUID();
    await payrollRepo.createLeaveRequest({
      id,
      farmOwnerId,
      ...input,
      startDate: new Date(input.startDate),
      endDate: new Date(input.endDate),
      daysRequested: String(input.daysRequested),
      status: "pending",
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    return id;
  },

  approveLeaveRequest: async (farmOwnerId: string, id: string) => {
    await payrollRepo.updateLeaveRequest(farmOwnerId, id, {
      status: "approved",
    });
  },

  rejectLeaveRequest: async (farmOwnerId: string, id: string) => {
    await payrollRepo.updateLeaveRequest(farmOwnerId, id, {
      status: "rejected",
    });
  },

  deleteLeaveRequest: async (farmOwnerId: string, id: string) => {
    await payrollRepo.deleteLeaveRequest(farmOwnerId, id);
  },

  listLeaveTypes: (farmOwnerId: string) =>
    payrollRepo
      .listLeaveTypes(farmOwnerId)
      .then((rows) =>
        rows.map((r) => mapLeaveTypeRow(r as Record<string, unknown>)),
      ),

  // Piecework
  listPieceworkLogs: (farmOwnerId: string) =>
    payrollRepo.listPieceworkLogs(farmOwnerId),

  createPieceworkLog: async (
    farmOwnerId: string,
    input: z.infer<typeof createPieceworkLogSchema>,
  ) => {
    const id = randomUUID();
    await payrollRepo.createPieceworkLog({
      id,
      farmOwnerId,
      ...input,
      workDate: new Date(input.workDate),
      quantity: String(input.quantity),
      ratePerUnit: String(input.ratePerUnit),
      totalAmount: String(input.totalAmount),
      createdAt: new Date(),
    });
    return id;
  },

  deletePieceworkLog: async (farmOwnerId: string, id: string) => {
    await payrollRepo.deletePieceworkLog(farmOwnerId, id);
  },

  // Transactions
  listTransactions: (farmOwnerId: string) =>
    payrollRepo.listTransactions(farmOwnerId).then((rows) =>
      (rows as Record<string, unknown>[]).map((row) => {
        const toIso = (v: unknown) =>
          v instanceof Date ? v.toISOString() : v ? String(v) : null;
        return {
          id: row.id,
          employeeId: row.employeeId,
          payRunId: (row.payRunId as string | null) ?? "",
          amount: parseFloat(String(row.amount ?? 0)),
          currency: (row.currency as string | null) ?? "ZAR",
          method: (row.method as string | null) ?? "cash",
          status: (row.status as string | null) ?? "initiated",
          reference: row.reference ?? null,
          bankName: row.bankName ?? null,
          accountNumber: row.accountNumber ?? null,
          initiatedAt: toIso(row.initiatedAt) ?? null,
          completedAt: toIso(row.completedAt) ?? null,
          failureReason: row.failureReason ?? null,
          createdAt: toIso(row.createdAt),
        };
      }),
    ),
};
