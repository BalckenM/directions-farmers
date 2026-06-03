import { randomUUID } from "crypto";
import type { z } from "zod";
import { goatRepo } from "../../repositories/goat/goat.repo";
import type { createFeedRecordSchema } from "../../validators/goat/goat.validator";



export const goatFeedService = {
  listFeedRecords: (farmOwnerId: string) =>
    goatRepo.listFeedRecords(farmOwnerId),

  createFeedRecord: async (
    farmOwnerId: string,
    input: z.infer<typeof createFeedRecordSchema>,
  ) => {
    const id = randomUUID();
    await goatRepo.createFeedRecord({
      id,
      farmOwnerId,
      goatId: input.herdId ?? null, // Flutter: herdId → DB: goatId (reused)
      feedType: input.feedType,
      quantityKg: input.quantityKg,
      costPerKg: input.costPerKg ?? null,
      feedDate: input.date, // Flutter: date → DB: feedDate
      notes: input.notes ?? null,
      createdAt: new Date(),
    });
    return goatRepo.findFeedRecordById(farmOwnerId, id);
  },

  deleteFeedRecord: async (farmOwnerId: string, id: string) => {
    await goatRepo.deleteFeedRecord(farmOwnerId, id);
  },
};
