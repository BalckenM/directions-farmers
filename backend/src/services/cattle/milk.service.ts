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

export const cattleMilkService = {
  listDailyMilk: (farmOwnerId: string) =>
    cattleRepo.listDailyMilk(farmOwnerId),

  addDailyMilk: async (
    farmOwnerId: string,
    input: z.infer<typeof createDailyMilkSchema>,
  ) => {
    await cattleService.getAnimal(farmOwnerId, input.cattleId);
    const id = randomUUID();
    await cattleRepo.createDailyMilk({
      id,
      farmOwnerId,
      cattleId: input.cattleId,
      recordDate: new Date(input.recordDate),
      morningLitres: input.amLitres !== undefined ? String(input.amLitres) : undefined,
      eveningLitres: input.pmLitres !== undefined ? String(input.pmLitres) : undefined,
      totalLitres: String(input.totalLitres),
      createdAt: new Date(),
    });
    return cattleRepo.findDailyMilkById(farmOwnerId, id);
  },

  deleteDailyMilk: async (farmOwnerId: string, id: string) => {
    await cattleRepo.deleteDailyMilk(farmOwnerId, id);
  },
};

