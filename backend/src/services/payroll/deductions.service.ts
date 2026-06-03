import { randomUUID } from "crypto";
import type { z } from "zod";
import { payrollRepo } from "../../repositories/payroll/payroll.repo";
import type {
  createDeductionRuleSchema,
  updateDeductionRuleSchema,
} from "../../validators/payroll/payroll.validator";

function mapDeductionRow(
  row: Record<string, unknown>,
): Record<string, unknown> {
  const toIso = (v: unknown) =>
    v instanceof Date ? v.toISOString() : v ? String(v) : null;
  let employeeIds: string[] | null = null;
  if (row.employeeIds && typeof row.employeeIds === "string") {
    try {
      employeeIds = JSON.parse(row.employeeIds) as string[];
    } catch {
      employeeIds = null;
    }
  }
  const basisMap: Record<string, string> = {
    percentage: "percentage",
    fixed: "fixedAmount",
    fixed_amount: "fixedAmount",
    fixedAmount: "fixedAmount",
  };
  return {
    id: row.id,
    code: row.code ?? "",
    label: row.name,
    type: row.type,
    basis: basisMap[row.calculationMethod as string] ?? "fixedAmount",
    value: parseFloat(String(row.value ?? 0)),
    cappedAt: row.cappedAt != null ? parseFloat(String(row.cappedAt)) : null,
    employeeIds,
    isActive: row.isActive ?? true,
    createdAt: toIso(row.createdAt),
  };
}

export const payrollDeductionsService = {
  listDeductionRules: (farmOwnerId: string) =>
    payrollRepo
      .listDeductionRules(farmOwnerId)
      .then((rows) =>
        rows.map((r) => mapDeductionRow(r as Record<string, unknown>)),
      ),

  createDeductionRule: async (
    farmOwnerId: string,
    input: z.infer<typeof createDeductionRuleSchema>,
  ) => {
    const id = randomUUID();
    await payrollRepo.createDeductionRule({
      id,
      farmOwnerId,
      ...input,
      value: String(input.value),
      isActive: true,
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    return id;
  },

  updateDeductionRule: async (
    farmOwnerId: string,
    id: string,
    input: z.infer<typeof updateDeductionRuleSchema>,
  ) => {
    await payrollRepo.updateDeductionRule(farmOwnerId, id, {
      ...input,
      value: input.value !== undefined ? String(input.value) : undefined,
    });
  },

  deactivateDeductionRule: async (farmOwnerId: string, id: string) => {
    await payrollRepo.deactivateDeductionRule(farmOwnerId, id);
  },
};
