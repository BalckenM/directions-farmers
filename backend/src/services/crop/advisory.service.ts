import { parsePagination } from "../../lib/pagination";
import { cropAdvisoryRepo } from "../../repositories/crop/advisory.repo";

export const cropAdvisoryService = {
  listAdvisoryContent: (
    farmOwnerId: string,
    query: Record<string, unknown>,
  ) => {
    const { page, limit, offset } = parsePagination(query);
    return cropAdvisoryRepo
      .listAdvisoryContent(farmOwnerId, offset, limit)
      .then(({ rows, total }) => ({
        data: rows,
        meta: { page, limit, total: Number(total) },
      }));
  },
};
