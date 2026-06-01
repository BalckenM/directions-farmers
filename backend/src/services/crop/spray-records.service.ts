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

  getSprayRecord: async (farmOwnerId: string, id: string) => {
    const row = await cropSprayRecordsRepo.findById(farmOwnerId, id);
    if (!row)
      throw Object.assign(new Error("Not found"), {
        status: 404,
        code: "NOT_FOUND",
      });
    return row;
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

  updateSprayRecord: async (farmOwnerId: string, id: string, input: any) => {
    await cropSprayRecordsService.getSprayRecord(farmOwnerId, id);
    await cropSprayRecordsRepo.updateSprayRecord(farmOwnerId, id, input);
    return cropSprayRecordsRepo.findById(farmOwnerId, id);
  },

  deleteSprayRecord: async (farmOwnerId: string, id: string) => {
    await cropSprayRecordsService.getSprayRecord(farmOwnerId, id);
    await cropSprayRecordsRepo.deleteSprayRecord(farmOwnerId, id);
  },
};
