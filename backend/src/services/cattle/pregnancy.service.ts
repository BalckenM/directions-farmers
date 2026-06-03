import { randomUUID } from "crypto";
import type { z } from "zod";
import { cattleRepo } from "../../repositories/cattle/cattle.repo";
import type { createPregnancyCheckSchema } from "../../validators/cattle/cattle.validator";

export const cattlePregnancyService = {
  listPregnancyChecks: (farmOwnerId: string) =>
    cattleRepo.listPregnancyChecks(farmOwnerId),

  addPregnancyCheck: async (
    farmOwnerId: string,
    input: z.infer<typeof createPregnancyCheckSchema>,
  ) => {
    const id = randomUUID();
    await cattleRepo.createPregnancyCheck({
      id,
      farmOwnerId,
      animalId: input.animalId,
      date: new Date(input.date),
      status: input.status,
      method: input.method,
      dayspregnant: input.dayspregnant,
      checkedBy: input.checkedBy,
      expectedCalvingDate: input.expectedCalvingDate ? new Date(input.expectedCalvingDate) : null,
      notes: input.notes,
      createdAt: new Date(),
    });
    return cattleRepo.findPregnancyCheckById(farmOwnerId, id);
  },
};
