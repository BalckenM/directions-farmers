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

import { cattleService } from "./cattle.service";

export const cattleBcsService = {
  listBcsRecords: (farmOwnerId: string) =>
    cattleRepo.listBcsRecords(farmOwnerId),

  addBcsRecord: async (
    farmOwnerId: string,
    input: z.infer<typeof createBcsRecordSchema>,
  ) => {
    await cattleService.getAnimal(farmOwnerId, input.cattleId);
    const id = randomUUID();
    await cattleRepo.createBcsRecord({
      id,
      farmOwnerId,
      cattleId: input.cattleId,
      score: String(input.score),
      recordDate: new Date(input.recordDate),
      notes: input.notes,
      createdAt: new Date(),
    });
    return cattleRepo.findBcsRecordById(farmOwnerId, id);
  },
};

