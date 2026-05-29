import { randomUUID } from "crypto";
import { parsePagination } from "../lib/pagination";
import { traceabilityRepo } from "../repositories/traceability.repo";
import type { AddMovementInput } from "../validators/traceability.validator";

export const traceabilityService = {
  list: async (farmOwnerId: string, query: Record<string, unknown>) => {
    const { page, limit, offset } = parsePagination(query);
    const { rows, total } = await traceabilityRepo.list(farmOwnerId, offset, limit);
    return { data: rows, meta: { page, limit, total: Number(total) } };
  },

  add: async (farmOwnerId: string, input: AddMovementInput) => {
    const id = randomUUID();
    await traceabilityRepo.create({ id, farmOwnerId, ...input, createdAt: new Date() });
    return traceabilityRepo.findById(farmOwnerId, id);
  },
};
