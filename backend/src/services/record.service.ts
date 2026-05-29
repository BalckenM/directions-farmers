import { randomUUID } from "crypto";
import { parsePagination } from "../lib/pagination";
import { recordRepo } from "../repositories/record.repo";
import type { AddFeedLogInput } from "../validators/record.validator";

export const recordService = {
  list: async (farmOwnerId: string, query: Record<string, unknown>) => {
    const { page, limit, offset } = parsePagination(query);
    const { rows, total } = await recordRepo.list(farmOwnerId, offset, limit);
    return { data: rows, meta: { page, limit, total: Number(total) } };
  },

  add: async (farmOwnerId: string, input: AddFeedLogInput) => {
    const id = randomUUID();
    await recordRepo.create({ id, farmOwnerId, ...input, createdAt: new Date() });
    return recordRepo.findById(farmOwnerId, id);
  },
};
