import { randomUUID } from "crypto";
import type { z } from "zod";
import { parsePagination } from "../lib/pagination";
import { financialRepo } from "../repositories/financial.repo";
import type {
  createTransactionSchema,
  updateTransactionSchema,
} from "../validators/financial.validator";

export const financialService = {
  list: (farmOwnerId: string, query: Record<string, unknown>) => {
    const { page, limit, offset } = parsePagination(query);
    return financialRepo
      .list(farmOwnerId, offset, limit)
      .then(({ rows, total }) => ({
        data: rows,
        meta: { page, limit, total: Number(total) },
      }));
  },

  getById: async (farmOwnerId: string, id: string) => {
    const tx = await financialRepo.findById(farmOwnerId, id);
    if (!tx)
      throw Object.assign(new Error("Not found"), {
        status: 404,
        code: "NOT_FOUND",
      });
    return tx;
  },

  create: async (
    farmOwnerId: string,
    input: z.infer<typeof createTransactionSchema>,
  ) => {
    const id = randomUUID();
    await financialRepo.create({
      id,
      farmOwnerId,
      ...input,
      amount: String(input.amount),
      transactionDate: new Date(input.transactionDate),
      createdAt: new Date(),
      updatedAt: new Date(),
    });
    return financialRepo.findById(farmOwnerId, id);
  },

  update: async (
    farmOwnerId: string,
    id: string,
    input: z.infer<typeof updateTransactionSchema>,
  ) => {
    await financialService.getById(farmOwnerId, id);
    await financialRepo.update(farmOwnerId, id, {
      ...input,
      ...(input.amount !== undefined ? { amount: String(input.amount) } : {}),
      ...(input.transactionDate !== undefined ? { transactionDate: new Date(input.transactionDate) } : {}),
    } as Parameters<typeof financialRepo.update>[2]);
    return financialRepo.findById(farmOwnerId, id);
  },

  delete: async (farmOwnerId: string, id: string) => {
    await financialService.getById(farmOwnerId, id);
    await financialRepo.delete(farmOwnerId, id);
  },
};
