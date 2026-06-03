import { randomUUID } from "crypto";
import type { z } from "zod";
import { goatRepo } from "../../repositories/goat/goat.repo";
import type { createBcsRecordSchema } from "../../validators/goat/goat.validator";



export const goatBcsService = {
  listBcsRecords: (farmOwnerId: string) => goatRepo.listBcsRecords(farmOwnerId),

  createBcsRecord: async (
    farmOwnerId: string,
    input: z.infer<typeof createBcsRecordSchema>,
  ) => {
    const id = randomUUID();
    await goatRepo.createBcsRecord({
      id,
      farmOwnerId,
      goatId: input.animalId, // Flutter: animalId → DB: goatId
      score: input.score,
      recordDate: input.date, // Flutter: date → DB: recordDate
      notes: input.notes ?? null,
      createdAt: new Date(),
    });
    return goatRepo.findBcsRecordById(farmOwnerId, id);
  },
};
