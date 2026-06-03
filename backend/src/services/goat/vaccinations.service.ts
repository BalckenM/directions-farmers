import { randomUUID } from "crypto";
import type { z } from "zod";
import { goatRepo } from "../../repositories/goat/goat.repo";
import type {
    createVaccinationSchema,
    markVaccinationGivenSchema,
} from "../../validators/goat/goat.validator";

function notFound(): never {
  throw Object.assign(new Error("Not found"), {
    status: 404,
    code: "NOT_FOUND",
  });
}


export const goatVaccinationsService = {
  listVaccinations: (farmOwnerId: string) =>
    goatRepo.listVaccinations(farmOwnerId),

  createVaccination: async (
    farmOwnerId: string,
    input: z.infer<typeof createVaccinationSchema>,
  ) => {
    const id = randomUUID();
    await goatRepo.createVaccination({
      id,
      farmOwnerId,
      goatId: input.animalId, // Flutter: animalId → DB: goatId
      vaccineName: input.vaccineName,
      dueDate: input.dueDate ?? null,
      vaccinationDate: input.givenDate ?? null, // Flutter: givenDate → DB: vaccinationDate
      nextDueDate: input.nextDueDate ?? null,
      batchNumber: input.batchNumber ?? null,
      administeredBy: input.administeredBy ?? null,
      createdAt: new Date(),
    });
    return goatRepo.findVaccinationById(farmOwnerId, id);
  },

  markVaccinationGiven: async (
    farmOwnerId: string,
    id: string,
    input: z.infer<typeof markVaccinationGivenSchema>,
  ) => {
    const existing = await goatRepo.findVaccinationById(farmOwnerId, id);
    if (!existing) notFound();
    await goatRepo.updateVaccination(farmOwnerId, id, {
      vaccinationDate: input.givenDate, // Flutter: givenDate → DB: vaccinationDate
      ...(input.batchNumber !== undefined
        ? { batchNumber: input.batchNumber }
        : {}),
    });
    return goatRepo.findVaccinationById(farmOwnerId, id);
  },
};
