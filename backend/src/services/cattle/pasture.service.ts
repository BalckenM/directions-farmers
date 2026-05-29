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

export const cattlePastureService = {
  listPastureRecords: (farmOwnerId: string) =>
    cattleRepo.listPastureRecords(farmOwnerId),

  addPastureRecord: async (
    farmOwnerId: string,
    input: z.infer<typeof createPastureRecordSchema>,
  ) => {
    const id = randomUUID();
    await cattleRepo.createPastureRecord({
      id,
      farmOwnerId,
      pastureName: input.pastureName,
      moveDate: new Date(input.moveDate),
      notes: input.notes,
      createdAt: new Date(),
    });
    return cattleRepo.findPastureRecordById(farmOwnerId, id);
  },

  exitPasture: async (
    farmOwnerId: string,
    id: string,
    input: z.infer<typeof exitPastureSchema>,
  ) => {
    const existing = await cattleRepo.findPastureRecordById(farmOwnerId, id);
    if (!existing)
      throw Object.assign(new Error("Not found"), { status: 404, code: "NOT_FOUND" });
    await cattleRepo.updatePastureRecord(farmOwnerId, id, input);
    return cattleRepo.findPastureRecordById(farmOwnerId, id);
  },
};

