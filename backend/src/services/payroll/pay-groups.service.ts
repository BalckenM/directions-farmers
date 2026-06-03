import { randomUUID } from "crypto";
import type { z } from "zod";
import { payrollRepo } from "../../repositories/payroll/payroll.repo";
import type {
  createPayGroupSchema,
  updatePayGroupSchema,
} from "../../validators/payroll/payroll.validator";

function mapPayGroupRow(row: Record<string, unknown>): Record<string, unknown> {
  const toIso = (v: unknown) =>
    v instanceof Date ? v.toISOString() : v ? String(v) : null;
  return {
    id: row.id,
    name: row.name,
    frequency: row.payFrequency ?? "monthly",
    payDayOffset: Number(row.payDay ?? 25),
    description: row.description ?? null,
    isActive: Boolean(row.isActive),
    createdAt: toIso(row.createdAt),
  };
}

export const payrollPayGroupsService = {
  listPayGroups: (farmOwnerId: string) =>
    payrollRepo
      .listPayGroups(farmOwnerId)
      .then((rows) => (rows as Record<string, unknown>[]).map(mapPayGroupRow)),

  createPayGroup: async (
    farmOwnerId: string,
    input: z.infer<typeof createPayGroupSchema>,
  ) => {
    const id = randomUUID();
    await payrollRepo.createPayGroup({
      id,
      farmOwnerId,
      ...input,
      createdAt: new Date(),
    });
    return id;
  },

  updatePayGroup: async (
    farmOwnerId: string,
    id: string,
    input: z.infer<typeof updatePayGroupSchema>,
  ) => {
    await payrollRepo.updatePayGroup(farmOwnerId, id, input);
  },
};
