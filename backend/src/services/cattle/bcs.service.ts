import { randomUUID } from "crypto";
import type { z } from "zod";
import { cattleRepo } from "../../repositories/cattle/cattle.repo";
import type { createBcsRecordSchema } from "../../validators/cattle/cattle.validator";
import { cattleService } from "./cattle.service";

export const cattleBcsService = {
  listBcsRecords: (farmOwnerId: string) =>
    cattleRepo.listBcsRecords(farmOwnerId),

  addBcsRecord: async (
    farmOwnerId: string,
    input: z.infer<typeof createBcsRecordSchema>,
  ) => {
    await cattleService.getAnimal(farmOwnerId, input.animalId);
    const id = randomUUID();
    await cattleRepo.createBcsRecord({
      id,
      farmOwnerId,
      animalId: input.animalId,
      score: String(input.score),
      date: new Date(input.date),
      assessedBy: input.assessedBy,
      notes: input.notes,
      createdAt: new Date(),
    });
    return cattleRepo.findBcsRecordById(farmOwnerId, id);
  },
};
