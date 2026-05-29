import { randomUUID } from "crypto";
import type { z } from "zod";
import { cattleRepo } from "../../repositories/cattle/cattle.repo";
import type {
    createBcsRecordSchema,
    createBreedingRecordSchema,
    createCalvingEventSchema,
    createCattleSchema,
    createDailyMilkSchema,
    createDippingRecordSchema,
    createFeedRecordSchema,
    createHealthEventSchema,
    createMedicationLogSchema,
    createPastureRecordSchema,
    createPregnancyCheckSchema,
    createSaleRecordSchema,
    createVaccinationSchema,
    createWeightRecordSchema,
    exitPastureSchema,
    markVaccinationGivenSchema,
    updateBreedingRecordSchema,
    updateCattleSchema,
    updateHealthEventSchema,
    updateSaleRecordSchema,
} from "../../validators/cattle.validator";

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
      cattleId: input.cattleId,
      feedType: input.feedType,
      quantityKg: String(input.quantityKg),
      feedDate: new Date(input.feedDate),
      notes: input.notes,
      createdAt: new Date(),
    });
    return cattleRepo.findFeedRecordById(farmOwnerId, id);
  },

  deleteFeedRecord: async (farmOwnerId: string, id: string) => {
    await cattleRepo.deleteFeedRecord(farmOwnerId, id);
  },
};

