import { randomUUID } from "crypto";
import type { z } from "zod";
import { poultryVaccinationsRepo } from "../../repositories/poultry/vaccinations.repo";
import type { createVaccinationScheduleSchema } from "../../validators/poultry/poultry.validator";
import { poultryFlocksService } from "./flocks.service";

export const poultryVaccinationsService = {
  listVaccinationSchedules: (farmOwnerId: string, flockId: string) =>
    poultryVaccinationsRepo.listVaccinationSchedules(farmOwnerId, flockId),

  addVaccinationSchedule: async (
    farmOwnerId: string,
    flockId: string,
    input: z.infer<typeof createVaccinationScheduleSchema>,
  ) => {
    await poultryFlocksService.getFlock(farmOwnerId, flockId);
    const id = randomUUID();
    await poultryVaccinationsRepo.createVaccinationSchedule({
      id,
      farmOwnerId,
      flockId,
      ...input,
      createdAt: new Date(),
    });
    return id;
  },
};
