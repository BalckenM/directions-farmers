import { randomUUID } from "crypto";
import type { z } from "zod";
import { parsePagination } from "../../lib/pagination";
import { poultryFlocksRepo } from "../../repositories/poultry/flocks.repo";
import type {
  createFlockSchema,
  updateFlockSchema,
} from "../../validators/poultry/poultry.validator";

export const poultryFlocksService = {
  listFlocks: (farmOwnerId: string, query: Record<string, unknown>) => {
    const { page, limit, offset } = parsePagination(query);
    return poultryFlocksRepo
      .listFlocks(farmOwnerId, offset, limit)
      .then(({ rows, total }) => ({
        data: rows,
        meta: { page, limit, total: Number(total) },
      }));
  },

  getFlock: async (farmOwnerId: string, id: string) => {
    const flock = await poultryFlocksRepo.findFlockById(farmOwnerId, id);
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
    await poultryFlocksRepo.createFlock({
      id,
      farmOwnerId,
      ...input,
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    return poultryFlocksRepo.findFlockById(farmOwnerId, id);
  },

  updateFlock: async (
    farmOwnerId: string,
    id: string,
    input: z.infer<typeof updateFlockSchema>,
  ) => {
    await poultryFlocksService.getFlock(farmOwnerId, id);
    await poultryFlocksRepo.updateFlock(farmOwnerId, id, input);
    return poultryFlocksRepo.findFlockById(farmOwnerId, id);
  },

  deleteFlock: async (farmOwnerId: string, id: string) => {
    await poultryFlocksService.getFlock(farmOwnerId, id);
    await poultryFlocksRepo.deleteFlock(farmOwnerId, id);
  },
};
