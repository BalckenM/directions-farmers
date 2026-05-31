import { randomUUID } from "crypto";
import type { z } from "zod";
import { poultryDailyRecordsRepo } from "../../repositories/poultry/daily-records.repo";
import type { createDailyRecordSchema } from "../../validators/poultry/poultry.validator";
import { poultryFlocksService } from "./flocks.service";

export const poultryDailyRecordsService = {
  listDailyRecords: (farmOwnerId: string, flockId: string) =>
    poultryDailyRecordsRepo.listDailyRecords(farmOwnerId, flockId),

  addDailyRecord: async (
    farmOwnerId: string,
    flockId: string,
    input: z.infer<typeof createDailyRecordSchema>,
  ) => {
    await poultryFlocksService.getFlock(farmOwnerId, flockId);
    const id = randomUUID();
    await poultryDailyRecordsRepo.createDailyRecord({
      id,
      farmOwnerId,
      flockId,
      ...input,
      createdAt: new Date(),
    });
    return id;
  },
};
