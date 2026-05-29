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

export const cattleCalvingService = {
  listCalvingEvents: (farmOwnerId: string) =>
    cattleRepo.listCalvingEvents(farmOwnerId),

  addCalvingEvent: async (
    farmOwnerId: string,
    input: z.infer<typeof createCalvingEventSchema>,
  ) => {
    const id = randomUUID();
    await cattleRepo.createCalvingEvent({
      id,
      farmOwnerId,
      cowId: input.cowId,
      calvingDate: new Date(input.calvingDate),
      calvesAlive: input.calvesAlive,
      calvesDead: input.calvesDead,
      notes: input.notes,
      createdAt: new Date(),
    });
    return cattleRepo.findCalvingEventById(farmOwnerId, id);
  },
};

