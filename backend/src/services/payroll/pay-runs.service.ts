import { randomUUID } from "crypto";
import type { z } from "zod";
import { parsePagination } from "../../lib/pagination";
import { payrollRepo } from "../../repositories/payroll/payroll.repo";
import type { createPayRunSchema } from "../../validators/payroll/payroll.validator";

import { payrollService } from "./payroll.service";

function parseJsonField(v: unknown): unknown[] {
  if (!v) return [];
  if (typeof v === "string") {
    try {
      return JSON.parse(v) as unknown[];
    } catch {
      return [];
    }
  }
  return Array.isArray(v) ? v : [];
}

function mapPayRunStatus(s: string | null | undefined): string {
  if (!s) return "draft";
  const map: Record<string, string> = {
    draft: "draft",
    calculated: "calculated",
    pending_approval: "pendingApproval",
    approved: "approved",
    disbursed: "disbursed",
    cancelled: "cancelled",
    finalized: "approved",
  };
  return map[s] ?? s;
}

function mapPayRunRow(row: Record<string, unknown>): Record<string, unknown> {
  const toIso = (v: unknown) => {
    if (v instanceof Date) return isNaN(v.getTime()) ? null : v.toISOString();
    return v ? String(v) : null;
  };
  // payDate must never be null — Flutter's PayRun.fromJson does DateTime.parse() without null check.
  // Fallback: use periodEnd (already a valid date) when payDate is null/invalid.
  const rawPayDate = toIso(row.payDate);
  const payDate =
    rawPayDate ?? toIso(row.periodEnd) ?? new Date().toISOString();
  return {
    id: row.id,
    payGroupId: row.payGroupId ?? "",
    periodStart: toIso(row.periodStart),
    periodEnd: toIso(row.periodEnd),
    payDate,
    status: mapPayRunStatus(row.status as string | null),
    totalGross: parseFloat(String(row.totalGross ?? 0)),
    totalDeductions: parseFloat(String(row.totalDeductions ?? 0)),
    totalNet: parseFloat(String(row.totalNet ?? 0)),
    sdlContribution: parseFloat(String(row.sdlContribution ?? 0)),
    etiCredit: parseFloat(String(row.etiCredit ?? 0)),
    totalCoidaContribution: parseFloat(String(row.totalCoidaContribution ?? 0)),
    employeeCount: Number(row.employeeCount ?? 0),
    approvedByUserId: row.approvedByUserId ?? null,
    approvedAt: toIso(row.approvedAt) ?? null,
    disbursedAt: toIso(row.disbursedAt) ?? null,
    notes: row.notes ?? null,
    complianceAlertIds: parseJsonField(row.complianceAlertIds),
    lineItems: parseJsonField(row.lineItems).map((item: unknown) => {
      const i = item as Record<string, unknown>;
      return {
        code: i.code ?? "",
        description: i.description ?? "",
        quantity: i.quantity ?? 1,
        rate: i.rate ?? 0,
        amount: i.amount ?? 0,
        isStatutory: i.isStatutory ?? false,
      };
    }),
    approvalChain: parseJsonField(row.approvalChain).map((entry: unknown) => {
      const e = entry as Record<string, unknown>;
      return {
        userId: e.userId ?? "",
        displayName: e.displayName ?? "",
        role: e.role ?? "",
        decidedAt: e.decidedAt ?? null,
        approved: e.approved ?? null,
        comment: e.comment ?? null,
      };
    }),
    requiredApprovers: Number(row.requiredApprovers ?? 1),
    createdAt: toIso(row.createdAt),
    updatedAt: toIso(row.updatedAt),
  };
}

export const payrollPayRunsService = {
  listPayRuns: (farmOwnerId: string, query: Record<string, unknown>) => {
    const { page, limit, offset } = parsePagination(query);
    return payrollRepo
      .listPayRuns(farmOwnerId, offset, limit)
      .then(({ rows, total }) => ({
        rows: rows.map((r) => mapPayRunRow(r as Record<string, unknown>)),
        meta: { page, limit, total: Number(total) },
      }));
  },

  getPayRun: async (farmOwnerId: string, id: string) => {
    const run = await payrollRepo.findPayRunById(farmOwnerId, id);
    if (!run)
      throw Object.assign(new Error("Not found"), {
        status: 404,
        code: "NOT_FOUND",
      });
    return run;
  },

  createPayRun: async (
    farmOwnerId: string,
    input: z.infer<typeof createPayRunSchema>,
  ) => {
    const id = randomUUID();
    await payrollRepo.createPayRun({
      id,
      farmOwnerId,
      ...input,
      periodStart: new Date(input.periodStart),
      periodEnd: new Date(input.periodEnd),
      payDate: new Date(input.payDate),
      status: "draft",
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    return payrollRepo.findPayRunById(farmOwnerId, id);
  },

  updatePayRun: async (
    farmOwnerId: string,
    id: string,
    input: Record<string, unknown>,
  ) => {
    await payrollService.getPayRun(farmOwnerId, id);
    await payrollRepo.updatePayRun(farmOwnerId, id, input);
    return payrollRepo.findPayRunById(farmOwnerId, id);
  },

  finalizePayRun: async (farmOwnerId: string, id: string) => {
    await payrollService.getPayRun(farmOwnerId, id);
    await payrollRepo.updatePayRun(farmOwnerId, id, { status: "finalized" });
    return payrollRepo.findPayRunById(farmOwnerId, id);
  },
};
