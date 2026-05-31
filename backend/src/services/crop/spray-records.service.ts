import { randomUUID } from "crypto";
import type { z } from "zod";
import { parsePagination } from "../../lib/pagination";
import { cropSprayRecordsRepo } from "../../repositories/crop/spray-records.repo";
import type { createSprayRecordSchema } from "../../validators/crop/crop.validator";

export const cropSprayRecordsService = {
  listSprayRecords: (farmOwnerId: string, query: Record<string, unknown>) => {
    const { limit, offset } = parsePagination(query);
    return cropSprayRecordsRepo.listSprayRecords(farmOwnerId, offset, limit);
  },

  createSprayRecord: async (
    farmOwnerId: string,
    input: z.infer<typeof createSprayRecordSchema>,
  ) => {
    const id = randomUUID();
    await cropSprayRecordsRepo.createSprayRecord({
      id,
      farmOwnerId,
      ...input,
      createdAt: new Date(),
    });
    return id;
  },
};
