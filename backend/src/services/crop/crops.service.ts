import { parsePagination } from "../../lib/pagination";
import { cropsRepo } from "../../repositories/crop/crops.repo";

export const cropsService = {
  listCrops: (farmOwnerId: string, query: Record<string, unknown>) => {
    const { page, limit, offset } = parsePagination(query);
    return cropsRepo
      .listCrops(farmOwnerId, offset, limit)
      .then(({ rows, total }) => ({
        data: rows,
        meta: { page, limit, total: Number(total) },
      }));
  },
};
