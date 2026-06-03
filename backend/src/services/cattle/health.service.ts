import { randomUUID } from "crypto";
import type { z } from "zod";
import { cattleRepo } from "../../repositories/cattle/cattle.repo";
import type { createHealthEventSchema, updateHealthEventSchema } from "../../validators/cattle/cattle.validator";
import { cattleService } from "./cattle.service";

export const cattleHealthService = {
  listHealthEvents: (farmOwnerId: string) =>
    cattleRepo.listHealthEvents(farmOwnerId),

  addHealthEvent: async (
    farmOwnerId: string,
    input: z.infer<typeof createHealthEventSchema>,
  ) => {
    await cattleService.getAnimal(farmOwnerId, input.animalId);
    const id = randomUUID();
    await cattleRepo.createHealthEvent({
      id,
      farmOwnerId,
      animalId: input.animalId,
      date: new Date(input.date),
      eventType: input.eventType,
      diagnosis: input.diagnosis,
      treatment: input.treatment,
      severity: input.severity,
      treatedBy: input.treatedBy,
      isNotifiable: input.isNotifiable ? 1 : 0,
      outcome: input.outcome,
      notes: input.notes,
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
    if (!existing) throw Object.assign(new Error("Not found"), { status: 404, code: "NOT_FOUND" });
    const patch: Record<string, unknown> = { ...input };
    if (input.date !== undefined) patch["date"] = new Date(input.date);
    await cattleRepo.updateHealthEvent(farmOwnerId, id, patch);
    return cattleRepo.findHealthEventById(farmOwnerId, id);
  },
};
