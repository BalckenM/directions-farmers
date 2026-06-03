import { randomUUID } from "crypto";
import type { z } from "zod";
import { goatRepo } from "../../repositories/goat/goat.repo";
import type {
    createPastureRecordSchema,
    exitPastureSchema,
} from "../../validators/goat/goat.validator";

function notFound(): never {
  throw Object.assign(new Error("Not found"), {
    status: 404,
    code: "NOT_FOUND",
  });
}


export const goatPastureService = {
  listPastureRecords: (farmOwnerId: string) =>
    goatRepo.listPastureRecords(farmOwnerId),

  createPastureRecord: async (
    farmOwnerId: string,
    input: z.infer<typeof createPastureRecordSchema>,
  ) => {
    const id = randomUUID();
    await goatRepo.createPastureRecord({
      id,
      farmOwnerId,
      herdId: input.herdId ?? null,
      campId: input.campId ?? null,
      entryDate: input.entryDate,
      exitDate: input.exitDate ?? null,
      estimatedHa: input.estimatedHa ?? null,
      veldCondition: input.veldCondition ?? null,
      notes: input.notes ?? null,
      createdAt: new Date(),
    });
    return goatRepo.findPastureRecordById(farmOwnerId, id);
  },

  exitPasture: async (
    farmOwnerId: string,
    id: string,
    input: z.infer<typeof exitPastureSchema>,
  ) => {
    const existing = await goatRepo.findPastureRecordById(farmOwnerId, id);
    if (!existing) notFound();
    await goatRepo.updatePastureRecord(farmOwnerId, id, {
      exitDate: input.exitDate,
    });
    return goatRepo.findPastureRecordById(farmOwnerId, id);
  },
};
