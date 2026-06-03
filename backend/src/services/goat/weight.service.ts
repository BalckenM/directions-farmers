import { randomUUID } from "crypto";
import type { z } from "zod";
import { goatRepo } from "../../repositories/goat/goat.repo";
import type { createWeightRecordSchema } from "../../validators/goat/goat.validator";



export const goatWeightService = {
  listWeightRecords: (farmOwnerId: string) =>
    goatRepo.listWeightRecords(farmOwnerId),

  createWeightRecord: async (
    farmOwnerId: string,
    input: z.infer<typeof createWeightRecordSchema>,
  ) => {
    const id = randomUUID();
    await goatRepo.createWeightRecord({
      id,
      farmOwnerId,
      goatId: input.animalId, // Flutter: animalId → DB: goatId
      weightKg: String(input.weightKg),
      recordedAt: input.date, // Flutter: date → DB: recordedAt
      notes: input.notes ?? null,
      createdAt: new Date(),
    });
    return goatRepo.findWeightRecordById(farmOwnerId, id);
  },

  deleteWeightRecord: async (farmOwnerId: string, id: string) => {
    await goatRepo.deleteWeightRecord(farmOwnerId, id);
  },
};
