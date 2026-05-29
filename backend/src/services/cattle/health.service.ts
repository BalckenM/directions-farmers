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

export const cattleHealthService = {
  listHealthEvents: (farmOwnerId: string) =>
    cattleRepo.listHealthEvents(farmOwnerId),

  addHealthEvent: async (
    farmOwnerId: string,
    input: z.infer<typeof createHealthEventSchema>,
  ) => {
    await cattleService.getAnimal(farmOwnerId, input.cattleId);
    const id = randomUUID();
    await cattleRepo.createHealthEvent({
      id,
      farmOwnerId,
      cattleId: input.cattleId,
      eventDate: new Date(input.eventDate),
      eventType: input.eventType,
      notes: input.description,
      createdAt: new Date(),
    });
    return cattleRepo.findHealthEventById(farmOwnerId, id);
  },

  updateHealthEvent: async (
    farmOwnerId: string,
    id: string,
    input: z.infer<typeof updateHealthEventSchema>,
  ) => {
    const existing = await cattleRepo.findHealthEventById(farmOwnerId, id);
    if (!existing)
      throw Object.assign(new Error("Not found"), { status: 404, code: "NOT_FOUND" });
    const patch: Record<string, unknown> = {};
    if (input.eventDate !== undefined) patch["eventDate"] = input.eventDate;
    if (input.eventType !== undefined) patch["eventType"] = input.eventType;
    if (input.description !== undefined) patch["notes"] = input.description;
    await cattleRepo.updateHealthEvent(farmOwnerId, id, patch);
    return cattleRepo.findHealthEventById(farmOwnerId, id);
  },
};

