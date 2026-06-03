import { randomUUID } from "crypto";
import type { z } from "zod";
import { goatRepo } from "../../repositories/goat/goat.repo";
import type { createShearingRecordSchema } from "../../validators/goat/goat.validator";



export const goatShearingService = {
  listShearingRecords: (farmOwnerId: string) =>
    goatRepo.listShearingRecords(farmOwnerId),

  createShearingRecord: async (
    farmOwnerId: string,
    input: z.infer<typeof createShearingRecordSchema>,
  ) => {
    const id = randomUUID();
    await goatRepo.createShearingRecord({
      id,
      farmOwnerId,
      goatId: input.animalId, // Flutter: animalId → DB: goatId
      shearingDate: input.shearingDate,
      fleeceWeightKg: input.fleeceWeightKg ?? null,
      stapleLength: input.stapleLength ?? null,
      micron: input.micron ?? null,
      colorGrade: input.colorGrade ?? null,
      pricePerKg: input.pricePerKg ?? null,
      notes: input.notes ?? null,
      createdAt: new Date(),
    });
    return goatRepo.findShearingRecordById(farmOwnerId, id);
  },
};
