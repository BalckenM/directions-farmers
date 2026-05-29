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

export const cattleBreedingService = {
  listBreedingRecords: (farmOwnerId: string) =>
    cattleRepo.listBreedingRecords(farmOwnerId),

  addBreedingRecord: async (
    farmOwnerId: string,
    input: z.infer<typeof createBreedingRecordSchema>,
  ) => {
    await cattleService.getAnimal(farmOwnerId, input.cowId);
    const id = randomUUID();
    await cattleRepo.createBreedingRecord({
      id,
      farmOwnerId,
      cowId: input.cowId,
      bullId: input.bullId,
      breedingDate: new Date(input.breedingDate),
      method: input.method,
      notes: input.notes,
      createdAt: new Date(),
    });
    return cattleRepo.findBreedingRecordById(farmOwnerId, id);
  },

  updateBreedingRecord: async (
    farmOwnerId: string,
    id: string,
    input: z.infer<typeof updateBreedingRecordSchema>,
  ) => {
    const existing = await cattleRepo.findBreedingRecordById(farmOwnerId, id);
    if (!existing)
      throw Object.assign(new Error("Not found"), { status: 404, code: "NOT_FOUND" });
    const bPatch: Record<string, unknown> = { ...input };
    if (input.breedingDate !== undefined) bPatch["breedingDate"] = new Date(input.breedingDate);
    await cattleRepo.updateBreedingRecord(farmOwnerId, id, bPatch);
    return cattleRepo.findBreedingRecordById(farmOwnerId, id);
  },
};

