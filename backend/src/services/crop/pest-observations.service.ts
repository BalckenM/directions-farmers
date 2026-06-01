import { randomUUID } from "crypto";
import { parsePagination } from "../../lib/pagination";
import { cropPestObservationsRepo } from "../../repositories/crop/pest-observations.repo";

export const cropPestObservationsService = {
  listPestObservations: (
    farmOwnerId: string,
    query: Record<string, unknown>,
  ) => {
    const { page, limit, offset } = parsePagination(query);
    return cropPestObservationsRepo
      .listPestObservations(farmOwnerId, offset, limit)
      .then(({ rows, total }) => ({
        data: rows,
        meta: { page, limit, total: Number(total) },
      }));
  },

  getPestObservation: async (farmOwnerId: string, id: string) => {
    const row = await cropPestObservationsRepo.findById(farmOwnerId, id);
    if (!row)
      throw Object.assign(new Error("Not found"), {
        status: 404,
        code: "NOT_FOUND",
      });
    return row;
  },

  createPestObservation: async (farmOwnerId: string, input: any) => {
    const id = randomUUID();
    await cropPestObservationsRepo.create({
      id,
      farmOwnerId,
      ...input,
      createdAt: new Date(),
    });
    return cropPestObservationsRepo.findById(farmOwnerId, id);
  },

  updatePestObservation: async (
    farmOwnerId: string,
    id: string,
    input: any,
  ) => {
    await cropPestObservationsService.getPestObservation(farmOwnerId, id);
    await cropPestObservationsRepo.update(farmOwnerId, id, input);
    return cropPestObservationsRepo.findById(farmOwnerId, id);
  },

  deletePestObservation: async (farmOwnerId: string, id: string) => {
    await cropPestObservationsService.getPestObservation(farmOwnerId, id);
    await cropPestObservationsRepo.delete(farmOwnerId, id);
  },
};
