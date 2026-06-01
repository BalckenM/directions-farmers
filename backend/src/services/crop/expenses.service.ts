import { randomUUID } from "crypto";
import { parsePagination } from "../../lib/pagination";
import { cropExpensesRepo } from "../../repositories/crop/expenses.repo";

export const cropExpensesService = {
  listExpenses: (farmOwnerId: string, query: Record<string, unknown>) => {
    const { page, limit, offset } = parsePagination(query);
    return cropExpensesRepo
      .listExpenses(farmOwnerId, offset, limit)
      .then(({ rows, total }) => ({
        data: rows,
        meta: { page, limit, total: Number(total) },
      }));
  },

  getExpense: async (farmOwnerId: string, id: string) => {
    const row = await cropExpensesRepo.findById(farmOwnerId, id);
    if (!row)
      throw Object.assign(new Error("Not found"), {
        status: 404,
        code: "NOT_FOUND",
      });
    return row;
  },

  createExpense: async (farmOwnerId: string, input: any) => {
    const id = randomUUID();
    await cropExpensesRepo.create({
      id,
      farmOwnerId,
      ...input,
      createdAt: new Date(),
    });
    return cropExpensesRepo.findById(farmOwnerId, id);
  },

  updateExpense: async (farmOwnerId: string, id: string, input: any) => {
    await cropExpensesService.getExpense(farmOwnerId, id);
    await cropExpensesRepo.update(farmOwnerId, id, input);
    return cropExpensesRepo.findById(farmOwnerId, id);
  },

  deleteExpense: async (farmOwnerId: string, id: string) => {
    await cropExpensesService.getExpense(farmOwnerId, id);
    await cropExpensesRepo.delete(farmOwnerId, id);
  },
};
