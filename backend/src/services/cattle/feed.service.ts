import { randomUUID } from "crypto";
import type { z } from "zod";
import { cattleRepo } from "../../repositories/cattle/cattle.repo";
import type { createFeedRecordSchema } from "../../validators/cattle/cattle.validator";

export const cattleFeedService = {
  listFeedRecords: (farmOwnerId: string) =>
    cattleRepo.listFeedRecords(farmOwnerId),

  addFeedRecord: async (
    farmOwnerId: string,
    input: z.infer<typeof createFeedRecordSchema>,
  ) => {
    const id = randomUUID();
    await cattleRepo.createFeedRecord({
      id,
      farmOwnerId,
      animalId: input.animalId,
      feedType: input.feedType,
      quantityKg: String(input.quantityKg),
      date: new Date(input.date),
      costPerKg: input.costPerKg !== undefined ? String(input.costPerKg) : null,
      feedlotPenId: input.feedlotPenId,
      rationName: input.rationName,
      notes: input.notes,
      createdAt: new Date(),
    });
    return cattleRepo.findFeedRecordById(farmOwnerId, id);
  },

  deleteFeedRecord: async (farmOwnerId: string, id: string) => {
    await cattleRepo.deleteFeedRecord(farmOwnerId, id);
  },
};
