import { randomUUID } from "crypto";
import { parsePagination } from "../lib/pagination";
import { productionRepo } from "../repositories/production.repo";
import type {
  AddEggRecordInput,
  AddMilkRecordInput,
  AddWoolRecordInput,
} from "../validators/production.validator";

export const productionService = {
  listMilk: async (farmOwnerId: string, query: Record<string, unknown>) => {
    const { page, limit, offset } = parsePagination(query);
    const { rows, total } = await productionRepo.listMilk(farmOwnerId, offset, limit);
    return { data: rows, meta: { page, limit, total: Number(total) } };
  },

  addMilk: async (farmOwnerId: string, input: AddMilkRecordInput) => {
    const id = randomUUID();
    await productionRepo.insertMilk({ id, farmOwnerId, ...input, createdAt: new Date() });
    return productionRepo.findMilkById(farmOwnerId, id);
  },

  listEggs: async (farmOwnerId: string, query: Record<string, unknown>) => {
    const { page, limit, offset } = parsePagination(query);
    const { rows, total } = await productionRepo.listEggs(farmOwnerId, offset, limit);
    return { data: rows, meta: { page, limit, total: Number(total) } };
  },

  addEggs: async (farmOwnerId: string, input: AddEggRecordInput) => {
    const id = randomUUID();
    await productionRepo.insertEggs({ id, farmOwnerId, ...input, createdAt: new Date() });
    return productionRepo.findEggsById(farmOwnerId, id);
  },

  listWool: async (farmOwnerId: string, query: Record<string, unknown>) => {
    const { page, limit, offset } = parsePagination(query);
    const { rows, total } = await productionRepo.listWool(farmOwnerId, offset, limit);
    return { data: rows, meta: { page, limit, total: Number(total) } };
  },

  addWool: async (farmOwnerId: string, input: AddWoolRecordInput) => {
    const id = randomUUID();
    await productionRepo.insertWool({ id, farmOwnerId, ...input, createdAt: new Date() });
    return productionRepo.findWoolById(farmOwnerId, id);
  },
};
