import { randomUUID } from "crypto";
import type { z } from "zod";
import { parsePagination } from "../lib/pagination";
import { poultryRepo } from "../repositories/poultry.repo";
import type {
    createDailyRecordSchema,
    createFlockSchema,
    createHarvestRecordSchema,
    createVaccinationScheduleSchema,
    updateFlockSchema,
} from "../validators/poultry.validator";

export const poultryService = {
  listFlocks: (farmOwnerId: string, query: Record<string, unknown>) => {
    const { page, limit, offset } = parsePagination(query);
    return poultryRepo
      .listFlocks(farmOwnerId, offset, limit)
      .then(({ rows, total }) => ({
        data: rows,
        meta: { page, limit, total: Number(total) },
      }));
  },

  getFlock: async (farmOwnerId: string, id: string) => {
    const flock = await poultryRepo.findFlockById(farmOwnerId, id);
    if (!flock)
      throw Object.assign(new Error("Not found"), {
        status: 404,
        code: "NOT_FOUND",
      });
    return flock;
  },

  createFlock: async (
    farmOwnerId: string,
    input: z.infer<typeof createFlockSchema>,
  ) => {
    const id = randomUUID();
    await poultryRepo.createFlock({
      id,
      farmOwnerId,
      ...input,
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    return poultryRepo.findFlockById(farmOwnerId, id);
  },

  updateFlock: async (
    farmOwnerId: string,
    id: string,
    input: z.infer<typeof updateFlockSchema>,
  ) => {
    await poultryService.getFlock(farmOwnerId, id);
    await poultryRepo.updateFlock(farmOwnerId, id, input);
    return poultryRepo.findFlockById(farmOwnerId, id);
  },

  deleteFlock: async (farmOwnerId: string, id: string) => {
    await poultryService.getFlock(farmOwnerId, id);
    await poultryRepo.deleteFlock(farmOwnerId, id);
  },

  listDailyRecords: (farmOwnerId: string, flockId: string) =>
    poultryRepo.listDailyRecords(farmOwnerId, flockId),
  addDailyRecord: async (
    farmOwnerId: string,
    flockId: string,
    input: z.infer<typeof createDailyRecordSchema>,
  ) => {
    await poultryService.getFlock(farmOwnerId, flockId);
    const id = randomUUID();
    await poultryRepo.createDailyRecord({
      id,
      farmOwnerId,
      flockId,
      ...input,
      createdAt: new Date(),
    });
    return id;
  },

  listVaccinationSchedules: (farmOwnerId: string, flockId: string) =>
    poultryRepo.listVaccinationSchedules(farmOwnerId, flockId),
  addVaccinationSchedule: async (
    farmOwnerId: string,
    flockId: string,
    input: z.infer<typeof createVaccinationScheduleSchema>,
  ) => {
    await poultryService.getFlock(farmOwnerId, flockId);
    const id = randomUUID();
    await poultryRepo.createVaccinationSchedule({
      id,
      farmOwnerId,
      flockId,
      ...input,
      createdAt: new Date(),
    });
    return id;
  },

  listHarvestRecords: (farmOwnerId: string, flockId: string) =>
    poultryRepo.listHarvestRecords(farmOwnerId, flockId),
  addHarvestRecord: async (
    farmOwnerId: string,
    flockId: string,
    input: z.infer<typeof createHarvestRecordSchema>,
  ) => {
    await poultryService.getFlock(farmOwnerId, flockId);
    const id = randomUUID();
    await poultryRepo.createHarvestRecord({
      id,
      farmOwnerId,
      flockId,
      ...input,
      createdAt: new Date(),
    });
    return id;
  },
};
