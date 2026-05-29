import { randomUUID } from "crypto";
import type { z } from "zod";
import { parsePagination } from "../../lib/pagination";
import { goatRepo } from "../../repositories/goat/goat.repo";
import type {
  CreateGoatInput,
  UpdateGoatInput,
  createBcsRecordSchema,
  createDailyMilkSchema,
  createFamachaRecordSchema,
  createFeedRecordSchema,
  createHealthEventSchema,
  createKiddingEventSchema,
  createMatingSchema,
  createMedicationLogSchema,
  createPastureRecordSchema,
  createPregnancyCheckSchema,
  createSaleRecordSchema,
  createShearingRecordSchema,
  createVaccinationSchema,
  createWeightRecordSchema,
  exitPastureSchema,
  markVaccinationGivenSchema,
  updateHealthEventSchema,
  updateMatingSchema,
  updateSaleRecordSchema,
} from "../../validators/goat.validator";

function notFound(): never {
  throw Object.assign(new Error("Not found"), {
    status: 404,
    code: "NOT_FOUND",
  });
}

// Post-process kidding event rows
function mapKidding(raw: Awaited<ReturnType<typeof goatRepo.findKiddingEventById>>) {
  if (!raw) return null;
  return { ...raw };
}

import { goatService } from "./goat.service";

export const goatAnimalsService = {
  listAnimals: (farmOwnerId: string, query: Record<string, unknown>) => {
    const { page, limit, offset } = parsePagination(query);
    return goatRepo
      .listAnimals(farmOwnerId, offset, limit)
      .then(({ rows, total }) => ({
        data: rows,
        meta: { page, limit, total: Number(total) },
      }));
  },

  getAnimal: async (farmOwnerId: string, id: string) => {
    const animal = await goatRepo.findAnimalById(farmOwnerId, id);
    if (!animal) notFound();
    return animal;
  },

  createAnimal: async (farmOwnerId: string, input: CreateGoatInput) => {
    const id = randomUUID();
    const now = new Date();
    await goatRepo.createAnimal({
      id,
      farmOwnerId,
      tagId: input.tagNumber,
      name: input.name ?? null,
      breed: input.breed ?? null,
      productionType: input.productionType ?? "meat",
      sex: input.sex,
      status: input.status ?? "active",
      herdId: input.herdId ?? null,
      dateOfBirth: input.dateOfBirth ?? null,
      notes: input.notes ?? null,
      createdAt: now,
      updatedAt: now,
    });
    return goatRepo.findAnimalById(farmOwnerId, id);
  },

  updateAnimal: async (
    farmOwnerId: string,
    id: string,
    input: UpdateGoatInput,
  ) => {
    await goatService.getAnimal(farmOwnerId, id);
    const patch: Record<string, unknown> = {};
    if (input.tagNumber !== undefined) patch["tagId"] = input.tagNumber;
    if (input.name !== undefined) patch["name"] = input.name;
    if (input.breed !== undefined) patch["breed"] = input.breed;
    if (input.productionType !== undefined)
      patch["productionType"] = input.productionType;
    if (input.sex !== undefined) patch["sex"] = input.sex;
    if (input.status !== undefined) patch["status"] = input.status;
    if (input.herdId !== undefined) patch["herdId"] = input.herdId;
    if (input.dateOfBirth !== undefined) patch["dateOfBirth"] = input.dateOfBirth;
    if (input.notes !== undefined) patch["notes"] = input.notes;
    await goatRepo.updateAnimal(farmOwnerId, id, patch);
    return goatRepo.findAnimalById(farmOwnerId, id);
  },

  deleteAnimal: async (farmOwnerId: string, id: string) => {
    await goatService.getAnimal(farmOwnerId, id);
    await goatRepo.deleteAnimal(farmOwnerId, id);
  },
};

