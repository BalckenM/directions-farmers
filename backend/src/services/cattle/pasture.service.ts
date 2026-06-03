import { randomUUID } from "crypto";
import type { z } from "zod";
import { cattleRepo } from "../../repositories/cattle/cattle.repo";
import type { createPastureRecordSchema, exitPastureSchema } from "../../validators/cattle/cattle.validator";

export const cattlePastureService = {
  listPastureRecords: (farmOwnerId: string) =>
    cattleRepo.listPastureRecords(farmOwnerId),

  addPastureRecord: async (
    farmOwnerId: string,
    input: z.infer<typeof createPastureRecordSchema>,
  ) => {
    const id = randomUUID();
    await cattleRepo.createPastureRecord({
      id,
      farmOwnerId,
      herdId: input.herdId,
      campId: input.campId,
      entryDate: input.entryDate ? new Date(input.entryDate) : null,
      exitDate: input.exitDate ? new Date(input.exitDate) : null,
      estimatedHa: input.estimatedHa !== undefined ? String(input.estimatedHa) : null,
      veldCondition: input.veldCondition,
      notes: input.notes,
      createdAt: new Date(),
    });
    return cattleRepo.findPastureRecordById(farmOwnerId, id);
  },

  exitPasture: async (
    farmOwnerId: string,
    id: string,
    input: z.infer<typeof exitPastureSchema>,
  ) => {
    const existing = await cattleRepo.findPastureRecordById(farmOwnerId, id);
    if (!existing) throw Object.assign(new Error("Not found"), { status: 404, code: "NOT_FOUND" });
    await cattleRepo.updatePastureRecord(farmOwnerId, id, input);
    return cattleRepo.findPastureRecordById(farmOwnerId, id);
  },
};
