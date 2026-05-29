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

export const cattleVaccinationsService = {
  listVaccinations: (farmOwnerId: string) =>
    cattleRepo.listVaccinations(farmOwnerId),

  addVaccination: async (
    farmOwnerId: string,
    input: z.infer<typeof createVaccinationSchema>,
  ) => {
    await cattleService.getAnimal(farmOwnerId, input.cattleId);
    const id = randomUUID();
    await cattleRepo.createVaccination({
      id,
      farmOwnerId,
      cattleId: input.cattleId,
      vaccineName: input.vaccineName,
      vaccinationDate: new Date(input.vaccinationDate),
      nextDueDate: input.nextDueDate ? new Date(input.nextDueDate) : null,
      batchNumber: input.batchNumber,
      notes: input.notes,
      createdAt: new Date(),
    });
    return cattleRepo.findVaccinationById(farmOwnerId, id);
  },

  markVaccinationGiven: async (
    farmOwnerId: string,
    id: string,
    input: z.infer<typeof markVaccinationGivenSchema>,
  ) => {
    const existing = await cattleRepo.findVaccinationById(farmOwnerId, id);
    if (!existing)
      throw Object.assign(new Error("Not found"), { status: 404, code: "NOT_FOUND" });
    const vPatch: Record<string, unknown> = {};
    if (input.vaccinationDate !== undefined) vPatch["vaccinationDate"] = new Date(input.vaccinationDate);
    if (input.notes !== undefined) vPatch["notes"] = input.notes;
    await cattleRepo.updateVaccination(farmOwnerId, id, vPatch);
    return cattleRepo.findVaccinationById(farmOwnerId, id);
  },
};

