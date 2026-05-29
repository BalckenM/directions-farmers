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

export const cattlePregnancyService = {
  listPregnancyChecks: (farmOwnerId: string) =>
    cattleRepo.listPregnancyChecks(farmOwnerId),

  addPregnancyCheck: async (
    farmOwnerId: string,
    input: z.infer<typeof createPregnancyCheckSchema>,
  ) => {
    const id = randomUUID();
    await cattleRepo.createPregnancyCheck({
      id,
      farmOwnerId,
      cattleId: input.cattleId,
      checkDate: new Date(input.checkDate),
      result: input.result,
      expectedCalvingDate: input.expectedCalvingDate ? new Date(input.expectedCalvingDate) : null,
      notes: input.notes,
      createdAt: new Date(),
    });
    return cattleRepo.findPregnancyCheckById(farmOwnerId, id);
  },
};

