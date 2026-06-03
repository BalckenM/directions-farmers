import { payrollRepo } from "../../repositories/payroll/payroll.repo";

function parseJsonField(v: unknown, fallback: unknown = []): unknown {
  if (v === null || v === undefined) return fallback;
  if (typeof v === "string") {
    try {
      return JSON.parse(v);
    } catch {
      return fallback;
    }
  }
  return v;
}

function mapPayslipRow(row: Record<string, unknown>): Record<string, unknown> {
  const toIso = (v: unknown) =>
    v instanceof Date ? v.toISOString() : v ? String(v) : null;
  return {
    id: row.id,
    payRunId: row.payRunId,
    employeeId: row.employeeId,
    periodStart: toIso(row.periodStart),
    periodEnd: toIso(row.periodEnd),
    payDate: toIso(row.payDate),
    basicWage: parseFloat(String(row.basicWage ?? 0)),
    overtimePay: parseFloat(String(row.overtimePay ?? 0)),
    holidayPay: parseFloat(String(row.holidayPay ?? 0)),
    inKindHousing: parseFloat(String(row.inKindHousing ?? 0)),
    inKindFood: parseFloat(String(row.inKindFood ?? 0)),
    otherEarnings: parseFloat(String(row.otherEarnings ?? 0)),
    grossPay: parseFloat(String(row.grossPay ?? 0)),
    totalDeductions: parseFloat(String(row.totalDeductions ?? 0)),
    netPay: parseFloat(String(row.netPay ?? 0)),
    deductions: parseJsonField(row.deductions, []),
    leaveBalanceSnapshot: parseJsonField(row.leaveBalanceSnapshot, {}),
    payslipNumber: row.payslipNumber ?? null,
    createdAt: toIso(row.createdAt),
  };
}

export const payrollPayslipsService = {
  listPayslips: (farmOwnerId: string) =>
    payrollRepo
      .listPayslips(farmOwnerId)
      .then((rows) =>
        rows.map((r) => mapPayslipRow(r as Record<string, unknown>)),
      ),

  getPayslip: async (farmOwnerId: string, id: string) => {
    const ps = await payrollRepo.findPayslipById(farmOwnerId, id);
    if (!ps)
      throw Object.assign(new Error("Not found"), {
        status: 404,
        code: "NOT_FOUND",
      });
    return mapPayslipRow(ps as Record<string, unknown>);
  },
};
