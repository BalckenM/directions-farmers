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

export const cattleMedicationsService = {
  listMedicationLogs: (farmOwnerId: string) =>
    cattleRepo.listMedicationLogs(farmOwnerId),

  addMedicationLog: async (
    farmOwnerId: string,
    input: z.infer<typeof createMedicationLogSchema>,
  ) => {
    await cattleService.getAnimal(farmOwnerId, input.cattleId);
    const id = randomUUID();
    await cattleRepo.createMedicationLog({
      id,
      farmOwnerId,
      cattleId: input.cattleId,
      medicationName: input.medicationName,
      dosage: input.dosage,
      administeredAt: new Date(input.administeredAt),
      administeredBy: input.administeredBy,
      notes: input.notes,
      createdAt: new Date(),
    });
    return cattleRepo.findMedicationLogById(farmOwnerId, id);
  },
};

