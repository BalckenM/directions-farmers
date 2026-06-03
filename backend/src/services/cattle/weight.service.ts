import { randomUUID } from "crypto";
import type { z } from "zod";
import { cattleRepo } from "../../repositories/cattle/cattle.repo";
import type { createWeightRecordSchema } from "../../validators/cattle/cattle.validator";
import { cattleService } from "./cattle.service";

export const cattleWeightService = {
  listWeightRecords: (farmOwnerId: string) =>
    cattleRepo.listWeightRecords(farmOwnerId),

  addWeightRecord: async (
    farmOwnerId: string,
    input: z.infer<typeof createWeightRecordSchema>,
  ) => {
    await cattleService.getAnimal(farmOwnerId, input.animalId);
    const id = randomUUID();
    await cattleRepo.createWeightRecord({
      id,
      farmOwnerId,
      animalId: input.animalId,
      weightKg: String(input.weightKg),
      date: new Date(input.date),
      bodyConditionScore: input.bodyConditionScore !== undefined ? String(input.bodyConditionScore) : null,
      notes: input.notes,
      createdAt: new Date(),
    });
    return cattleRepo.findWeightRecordById(farmOwnerId, id);
  },

  deleteWeightRecord: async (farmOwnerId: string, id: string) => {
    await cattleRepo.deleteWeightRecord(farmOwnerId, id);
  },
};
