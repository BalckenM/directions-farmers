import { randomUUID } from "crypto";
import { parsePagination } from "../../lib/pagination";
import { cropSalesRepo } from "../../repositories/crop/sales.repo";

export const cropSalesService = {
  listSales: (farmOwnerId: string, query: Record<string, unknown>) => {
    const { page, limit, offset } = parsePagination(query);
    return cropSalesRepo
      .listSales(farmOwnerId, offset, limit)
      .then(({ rows, total }) => ({
        data: rows,
        meta: { page, limit, total: Number(total) },
      }));
  },

  getSale: async (farmOwnerId: string, id: string) => {
    const row = await cropSalesRepo.findById(farmOwnerId, id);
    if (!row)
      throw Object.assign(new Error("Not found"), {
        status: 404,
        code: "NOT_FOUND",
      });
    return row;
  },

  createSale: async (farmOwnerId: string, input: any) => {
    const id = randomUUID();
    await cropSalesRepo.create({
      id,
      farmOwnerId,
      ...input,
      createdAt: new Date(),
    });
    return cropSalesRepo.findById(farmOwnerId, id);
  },

  updateSale: async (farmOwnerId: string, id: string, input: any) => {
    await cropSalesService.getSale(farmOwnerId, id);
    await cropSalesRepo.update(farmOwnerId, id, input);
    return cropSalesRepo.findById(farmOwnerId, id);
  },

  deleteSale: async (farmOwnerId: string, id: string) => {
    await cropSalesService.getSale(farmOwnerId, id);
    await cropSalesRepo.delete(farmOwnerId, id);
  },
};
