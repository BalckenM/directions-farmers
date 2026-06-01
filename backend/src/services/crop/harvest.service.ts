import { randomUUID } from "crypto";
import type { z } from "zod";
import { cropHarvestRepo } from "../../repositories/crop/harvest.repo";
import type { createHarvestRecordSchema } from "../../validators/crop/crop.validator";

export const cropHarvestService = {
  listHarvestRecords: (farmOwnerId: string, planId?: string) =>
    cropHarvestRepo.listHarvestRecords(farmOwnerId, planId),

  getHarvestRecord: async (farmOwnerId: string, id: string) => {
    const row = await cropHarvestRepo.findById(farmOwnerId, id);
    if (!row)
      throw Object.assign(new Error("Not found"), {
        status: 404,
        code: "NOT_FOUND",
      });
    return row;
  },

  addHarvestRecord: async (
    farmOwnerId: string,
    input: z.infer<typeof createHarvestRecordSchema>,
  ) => {
    const id = randomUUID();
    await cropHarvestRepo.createHarvestRecord({
      id,
      farmOwnerId,
      ...input,
      createdAt: new Date(),
    });
    return id;
  },

  updateHarvestRecord: async (farmOwnerId: string, id: string, input: any) => {
    await cropHarvestService.getHarvestRecord(farmOwnerId, id);
    await cropHarvestRepo.updateHarvestRecord(farmOwnerId, id, input);
    return cropHarvestRepo.findById(farmOwnerId, id);
  },

  deleteHarvestRecord: async (farmOwnerId: string, id: string) => {
    await cropHarvestService.getHarvestRecord(farmOwnerId, id);
    await cropHarvestRepo.deleteHarvestRecord(farmOwnerId, id);
  },
};
