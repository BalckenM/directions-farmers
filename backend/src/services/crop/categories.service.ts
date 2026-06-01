import { parsePagination } from "../../lib/pagination";
import { cropCategoriesRepo } from "../../repositories/crop/categories.repo";

export const cropCategoriesService = {
  listCategories: (query: Record<string, unknown>) => {
    const { page, limit, offset } = parsePagination(query);
    return cropCategoriesRepo
      .listCategories(offset, limit)
      .then(({ rows, total }) => ({
        data: rows,
        meta: { page, limit, total: Number(total) },
      }));
  },
};
