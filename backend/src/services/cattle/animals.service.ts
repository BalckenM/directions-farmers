import { randomUUID } from "crypto";
import type { z } from "zod";
import { cattleRepo } from "../../repositories/cattle/cattle.repo";
import type {
  createCattleSchema,
  updateCattleSchema,
} from "../../validators/cattle.validator";

import { cattleService } from "./cattle.service";

export const cattleAnimalsService = {
  listAnimals: (farmOwnerId: string, _query?: Record<string, unknown>) =>
    cattleRepo.listAnimals(farmOwnerId),

  getAnimal: async (farmOwnerId: string, id: string) => {
    const animal = await cattleRepo.findAnimalById(farmOwnerId, id);
    if (!animal)
      throw Object.assign(new Error("Not found"), {
        status: 404,
        code: "NOT_FOUND",
      });
    return animal;
  },

  createAnimal: async (
    farmOwnerId: string,
    input: z.infer<typeof createCattleSchema>,
  ) => {
    const id = randomUUID();
    const now = new Date();
    await cattleRepo.createAnimal({
      id,
      farmOwnerId,
      tagId: input.tagNumber,
      name: input.name ?? null,
      breed: input.breed ?? null,
      sex: input.sex,
      dateOfBirth: input.dateOfBirth ? new Date(input.dateOfBirth) : null,
      status: input.status ?? "active",
      notes: input.notes ?? null,
      createdAt: now,
      updatedAt: now,
    });
    return cattleRepo.findAnimalById(farmOwnerId, id);
  },

  updateAnimal: async (
    farmOwnerId: string,
    id: string,
    input: z.infer<typeof updateCattleSchema>,
  ) => {
    await cattleService.getAnimal(farmOwnerId, id);
    const patch: Record<string, unknown> = {};
    if (input.tagNumber !== undefined) patch["tagId"] = input.tagNumber;
    if (input.name !== undefined) patch["name"] = input.name;
    if (input.breed !== undefined) patch["breed"] = input.breed;
    if (input.sex !== undefined) patch["sex"] = input.sex;
    if (input.status !== undefined) patch["status"] = input.status;
    if (input.dateOfBirth !== undefined)
      patch["dateOfBirth"] = input.dateOfBirth ? new Date(input.dateOfBirth) : null;
    if (input.notes !== undefined) patch["notes"] = input.notes;
    await cattleRepo.updateAnimal(farmOwnerId, id, patch);
    return cattleRepo.findAnimalById(farmOwnerId, id);
  },

  deleteAnimal: async (farmOwnerId: string, id: string) => {
    await cattleService.getAnimal(farmOwnerId, id);
    await cattleRepo.deleteAnimal(farmOwnerId, id);
  },
};
