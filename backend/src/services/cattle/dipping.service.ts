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

export const cattleDippingService = {
  listDippingRecords: (farmOwnerId: string) =>
    cattleRepo.listDippingRecords(farmOwnerId),

  addDippingRecord: async (
    farmOwnerId: string,
    input: z.infer<typeof createDippingRecordSchema>,
  ) => {
    const id = randomUUID();
    await cattleRepo.createDippingRecord({
      id,
      farmOwnerId,
      dippingDate: new Date(input.dippingDate),
      chemical: input.chemical,
      concentration: input.concentration,
      numberOfCattle: input.numberOfCattle,
      notes: input.notes,
      createdAt: new Date(),
    });
    return cattleRepo.findDippingRecordById(farmOwnerId, id);
  },
};

