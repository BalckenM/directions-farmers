import { randomUUID } from "crypto";
import type { z } from "zod";
import { poultryHarvestRepo } from "../../repositories/poultry/harvest.repo";
import type { createHarvestRecordSchema } from "../../validators/poultry/poultry.validator";
import { poultryFlocksService } from "./flocks.service";

export const poultryHarvestService = {
  listHarvestRecords: (farmOwnerId: string, flockId: string) =>
    poultryHarvestRepo.listHarvestRecords(farmOwnerId, flockId),

  addHarvestRecord: async (
    farmOwnerId: string,
    flockId: string,
    input: z.infer<typeof createHarvestRecordSchema>,
  ) => {
    await poultryFlocksService.getFlock(farmOwnerId, flockId);
    const id = randomUUID();
    await poultryHarvestRepo.createHarvestRecord({
      id,
      farmOwnerId,
      flockId,
      ...input,
      createdAt: new Date(),
    });
    return id;
  },
};
