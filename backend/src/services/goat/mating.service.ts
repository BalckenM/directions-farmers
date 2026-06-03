import { randomUUID } from "crypto";
import type { z } from "zod";
import { goatRepo } from "../../repositories/goat/goat.repo";
import type {
    createMatingSchema,
    updateMatingSchema,
} from "../../validators/goat/goat.validator";

function notFound(): never {
  throw Object.assign(new Error("Not found"), {
    status: 404,
    code: "NOT_FOUND",
  });
}


export const goatMatingService = {
  listMatings: (farmOwnerId: string) => goatRepo.listMatings(farmOwnerId),

  createMating: async (
    farmOwnerId: string,
    input: z.infer<typeof createMatingSchema>,
  ) => {
    const id = randomUUID();
    await goatRepo.createMating({
      id,
      farmOwnerId,
      doeId: input.doeId,
      buckId: input.buckId ?? null,
      matingDate: input.serviceDate, // Flutter: serviceDate → DB: matingDate
      method: input.serviceMethod ?? null, // Flutter: serviceMethod → DB: method
      notes: input.notes ?? null,
      createdAt: new Date(),
    });
    return goatRepo.findMatingById(farmOwnerId, id);
  },

  updateMating: async (
    farmOwnerId: string,
    id: string,
    input: z.infer<typeof updateMatingSchema>,
  ) => {
    const existing = await goatRepo.findMatingById(farmOwnerId, id);
    if (!existing) notFound();
    const patch: Record<string, unknown> = {};
    if (input.serviceDate !== undefined)
      patch["matingDate"] = input.serviceDate;
    if (input.buckId !== undefined) patch["buckId"] = input.buckId;
    if (input.serviceMethod !== undefined)
      patch["method"] = input.serviceMethod;
    if (input.notes !== undefined) patch["notes"] = input.notes;
    await goatRepo.updateMating(farmOwnerId, id, patch);
    return goatRepo.findMatingById(farmOwnerId, id);
  },
};
