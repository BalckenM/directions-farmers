import { randomUUID } from "crypto";
import type { z } from "zod";
import { cropHarvestRepo } from "../../repositories/crop/harvest.repo";
import type { createHarvestRecordSchema } from "../../validators/crop/crop.validator";
import { cropPlantingPlansService } from "./planting-plans.service";

export const cropHarvestService = {
  listHarvestRecords: (farmOwnerId: string, planId: string) =>
    cropHarvestRepo.listHarvestRecords(farmOwnerId, planId),

  addHarvestRecord: async (
    farmOwnerId: string,
    planId: string,
    input: z.infer<typeof createHarvestRecordSchema>,
  ) => {
    await cropPlantingPlansService.getPlantingPlan(farmOwnerId, planId);
    const id = randomUUID();
    await cropHarvestRepo.createHarvestRecord({
      id,
      farmOwnerId,
      ...input,
      createdAt: new Date(),
    });
    return id;
  },
};
