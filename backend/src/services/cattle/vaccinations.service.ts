import { randomUUID } from "crypto";
import type { z } from "zod";
import { cattleRepo } from "../../repositories/cattle/cattle.repo";
import type { createVaccinationSchema, markVaccinationGivenSchema } from "../../validators/cattle/cattle.validator";
import { cattleService } from "./cattle.service";

export const cattleVaccinationsService = {
  listVaccinations: (farmOwnerId: string) =>
    cattleRepo.listVaccinations(farmOwnerId),

  addVaccination: async (
    farmOwnerId: string,
    input: z.infer<typeof createVaccinationSchema>,
  ) => {
    await cattleService.getAnimal(farmOwnerId, input.animalId);
    const id = randomUUID();
    await cattleRepo.createVaccination({
      id,
      farmOwnerId,
      animalId: input.animalId,
      vaccineName: input.vaccineName,
      dueDate: new Date(input.dueDate),
      givenDate: input.givenDate ? new Date(input.givenDate) : null,
      route: input.route,
      siteOnBody: input.siteOnBody,
      administeredBy: input.administeredBy,
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
    if (!existing) throw Object.assign(new Error("Not found"), { status: 404, code: "NOT_FOUND" });
    const vPatch: Record<string, unknown> = {};
    if (input.givenDate !== undefined) vPatch["givenDate"] = new Date(input.givenDate);
    if (input.notes !== undefined) vPatch["notes"] = input.notes;
    await cattleRepo.updateVaccination(farmOwnerId, id, vPatch);
    return cattleRepo.findVaccinationById(farmOwnerId, id);
  },
};
