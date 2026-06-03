import { randomUUID } from "crypto";
import type { z } from "zod";
import { goatRepo } from "../../repositories/goat/goat.repo";
import type { createFamachaRecordSchema } from "../../validators/goat/goat.validator";



export const goatFamachaService = {
  listFamachaRecords: (farmOwnerId: string) =>
    goatRepo.listFamachaRecords(farmOwnerId),

  createFamachaRecord: async (
    farmOwnerId: string,
    input: z.infer<typeof createFamachaRecordSchema>,
  ) => {
    const id = randomUUID();
    await goatRepo.createFamachaRecord({
      id,
      farmOwnerId,
      goatId: input.animalId, // Flutter: animalId → DB: goatId
      score: input.score,
      recordDate: input.date, // Flutter: date → DB: recordDate
      actionTaken: input.actionTaken ?? null,
      notes: input.notes ?? null,
      createdAt: new Date(),
    });
    return goatRepo.findFamachaRecordById(farmOwnerId, id);
  },
};
