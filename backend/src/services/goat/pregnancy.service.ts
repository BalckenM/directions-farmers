import { randomUUID } from "crypto";
import type { z } from "zod";
import { goatRepo } from "../../repositories/goat/goat.repo";
import type { createPregnancyCheckSchema } from "../../validators/goat/goat.validator";



export const goatPregnancyService = {
  listPregnancyChecks: (farmOwnerId: string) =>
    goatRepo.listPregnancyChecks(farmOwnerId),

  createPregnancyCheck: async (
    farmOwnerId: string,
    input: z.infer<typeof createPregnancyCheckSchema>,
  ) => {
    const id = randomUUID();
    await goatRepo.createPregnancyCheck({
      id,
      farmOwnerId,
      goatId: input.animalId, // Flutter: animalId → DB: goatId
      checkDate: input.date, // Flutter: date → DB: checkDate
      method: input.method ?? null,
      result: input.result,
      expectedKiddingDate: input.expectedKiddingDate ?? null,
      daysPregnant: input.daysPregnant ?? null,
      notes: input.notes ?? null,
      createdAt: new Date(),
    });
    return goatRepo.findPregnancyCheckById(farmOwnerId, id);
  },
};
