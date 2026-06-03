import { randomUUID } from "crypto";
import type { z } from "zod";
import { payrollRepo } from "../../repositories/payroll/payroll.repo";
import type {
  createGarnisheeOrderSchema,
  createPayStructureSchema,
  updateGarnisheeOrderSchema,
  updatePayStructureSchema,
} from "../../validators/payroll/payroll.validator";

/** Normalise legacy DB values (salary/daily/hourly/monthly) to Flutter enum names. */
function normaliseWageType(raw: unknown): string {
  switch (String(raw ?? "").toLowerCase()) {
    case "hourly":
      return "hourlyRate";
    case "daily":
      return "dailyRate";
    case "piecework":
      return "piecework";
    case "salary":
    case "monthly":
    case "monthlysalary":
    default:
      return "monthlySalary";
  }
}

function mapPayStructureRow(
  row: Record<string, unknown>,
): Record<string, unknown> {
  const toIso = (v: unknown) =>
    v instanceof Date ? v.toISOString() : v ? String(v) : null;
  return {
    id: row.id,
    name: row.name,
    wageType: normaliseWageType(row.wageType),
    baseRate: parseFloat(String(row.baseRate ?? 0)),
    nmwaEnforced: Boolean(row.nmwaEnforced ?? true),
    overtimeMultiplier: 1.5,
    sundayMultiplier: 2.0,
    publicHolidayMultiplier: 2.0,
    pieceworkUnit: row.pieceworkUnit ?? null,
    pieceworkMinUnitsPerDay:
      row.pieceworkMinUnitsPerDay != null
        ? parseFloat(String(row.pieceworkMinUnitsPerDay))
        : null,
    createdAt: toIso(row.createdAt),
  };
}

export const payrollPayStructuresService = {
  listPayStructures: (farmOwnerId: string) =>
    payrollRepo
      .listPayStructures(farmOwnerId)
      .then((rows) =>
        (rows as Record<string, unknown>[]).map(mapPayStructureRow),
      ),

  createPayStructure: async (
    farmOwnerId: string,
    input: z.infer<typeof createPayStructureSchema>,
  ) => {
    const id = randomUUID();
    await payrollRepo.createPayStructure({
      id,
      farmOwnerId,
      ...input,
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    return id;
  },

  updatePayStructure: async (
    farmOwnerId: string,
    id: string,
    input: z.infer<typeof updatePayStructureSchema>,
  ) => {
    await payrollRepo.updatePayStructure(farmOwnerId, id, input);
  },

  // Garnishee orders
  listGarnisheeOrders: (farmOwnerId: string) =>
    payrollRepo.listGarnisheeOrders(farmOwnerId).then((rows) =>
      (rows as Record<string, unknown>[]).map((row) => {
        const toIso = (v: unknown) =>
          v instanceof Date ? v.toISOString() : v ? String(v) : null;
        return {
          id: row.id,
          employeeId: row.employeeId,
          courtOrderRef: (row.courtOrderRef as string | null) ?? "",
          creditorName: (row.creditorName as string | null) ?? "",
          monthlyDeductionAmount: parseFloat(
            String(row.monthlyDeductionAmount ?? 0),
          ),
          totalOwed: parseFloat(String(row.totalOwed ?? 0)),
          amountDeducted: parseFloat(String(row.amountDeducted ?? 0)),
          status: (row.status as string | null) ?? "active",
          notes: row.notes ?? null,
          satisfiedAt: toIso(row.satisfiedAt) ?? null,
          createdAt: toIso(row.createdAt),
        };
      }),
    ),

  createGarnisheeOrder: async (
    farmOwnerId: string,
    input: z.infer<typeof createGarnisheeOrderSchema>,
  ) => {
    const id = randomUUID();
    await payrollRepo.createGarnisheeOrder({
      id,
      farmOwnerId,
      employeeId: input.employeeId,
      courtOrderRef: input.caseNumber ?? "",
      creditorName: input.creditorName ?? "",
      monthlyDeductionAmount: String(input.amount),
      totalOwed: String(input.amount),
      amountDeducted: "0",
      status: "active",
      notes: input.notes ?? null,
      createdAt: new Date(),
    });
    return id;
  },

  updateGarnisheeOrder: async (
    farmOwnerId: string,
    id: string,
    input: z.infer<typeof updateGarnisheeOrderSchema>,
  ) => {
    await payrollRepo.updateGarnisheeOrder(farmOwnerId, id, {
      ...(input.amount !== undefined
        ? { monthlyDeductionAmount: String(input.amount) }
        : {}),
      ...(input.creditorName !== undefined
        ? { creditorName: input.creditorName }
        : {}),
      ...(input.caseNumber !== undefined
        ? { courtOrderRef: input.caseNumber }
        : {}),
      ...(input.notes !== undefined ? { notes: input.notes } : {}),
    });
  },
};
