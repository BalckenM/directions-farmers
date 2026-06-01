import { randomUUID } from "crypto";
import { parsePagination } from "../../lib/pagination";
import { cropSeasonsRepo } from "../../repositories/crop/seasons.repo";

export const cropSeasonsService = {
  listSeasons: (farmOwnerId: string, query: Record<string, unknown>) => {
    const { page, limit, offset } = parsePagination(query);
    return cropSeasonsRepo
      .listSeasons(farmOwnerId, offset, limit)
      .then(({ rows, total }) => ({
        data: rows,
        meta: { page, limit, total: Number(total) },
      }));
  },

  getSeason: async (farmOwnerId: string, id: string) => {
    const row = await cropSeasonsRepo.findSeasonById(farmOwnerId, id);
    if (!row)
      throw Object.assign(new Error("Not found"), {
        status: 404,
        code: "NOT_FOUND",
      });
    return row;
  },

  createSeason: async (farmOwnerId: string, input: any) => {
    const id = randomUUID();
    await cropSeasonsRepo.createSeason({
      id,
      farmOwnerId,
      ...input,
      createdAt: new Date(),
    });
    return cropSeasonsRepo.findSeasonById(farmOwnerId, id);
  },

  updateSeason: async (farmOwnerId: string, id: string, input: any) => {
    await cropSeasonsService.getSeason(farmOwnerId, id);
    await cropSeasonsRepo.updateSeason(farmOwnerId, id, input);
    return cropSeasonsRepo.findSeasonById(farmOwnerId, id);
  },

  deleteSeason: async (farmOwnerId: string, id: string) => {
    await cropSeasonsService.getSeason(farmOwnerId, id);
    await cropSeasonsRepo.deleteSeason(farmOwnerId, id);
  },
};
