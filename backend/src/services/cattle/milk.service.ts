import { randomUUID } from "crypto";
import type { z } from "zod";
import { cattleRepo } from "../../repositories/cattle/cattle.repo";
import type { createDailyMilkSchema } from "../../validators/cattle/cattle.validator";
import { cattleService } from "./cattle.service";

export const cattleMilkService = {
  listDailyMilk: (farmOwnerId: string) =>
    cattleRepo.listDailyMilk(farmOwnerId),

  addDailyMilk: async (
    farmOwnerId: string,
    input: z.infer<typeof createDailyMilkSchema>,
  ) => {
    await cattleService.getAnimal(farmOwnerId, input.animalId);
    const id = randomUUID();
    await cattleRepo.createDailyMilk({
      id,
      farmOwnerId,
      animalId: input.animalId,
      date: new Date(input.date),
      morningLitres: input.morningLitres !== undefined ? String(input.morningLitres) : null,
      eveningLitres: input.eveningLitres !== undefined ? String(input.eveningLitres) : null,
      totalLitres: String(input.totalLitres),
      lactationDay: input.lactationDay,
      qualityFlag: input.qualityFlag,
      createdAt: new Date(),
    });
    return cattleRepo.findDailyMilkById(farmOwnerId, id);
  },

  deleteDailyMilk: async (farmOwnerId: string, id: string) => {
    await cattleRepo.deleteDailyMilk(farmOwnerId, id);
  },
};
