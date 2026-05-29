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

export const cattleWeightService = {
  listWeightRecords: (farmOwnerId: string) =>
    cattleRepo.listWeightRecords(farmOwnerId),

  addWeightRecord: async (
    farmOwnerId: string,
    input: z.infer<typeof createWeightRecordSchema>,
  ) => {
    await cattleService.getAnimal(farmOwnerId, input.cattleId);
    const id = randomUUID();
    await cattleRepo.createWeightRecord({
      id,
      farmOwnerId,
      cattleId: input.cattleId,
      weightKg: String(input.weightKg),
      recordedAt: new Date(input.recordDate),
      notes: input.notes,
      createdAt: new Date(),
    });
    return cattleRepo.findWeightRecordById(farmOwnerId, id);
  },

  deleteWeightRecord: async (farmOwnerId: string, id: string) => {
    await cattleRepo.deleteWeightRecord(farmOwnerId, id);
  },
};

