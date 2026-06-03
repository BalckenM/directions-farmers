import { randomUUID } from "crypto";
import type { z } from "zod";
import { cattleRepo } from "../../repositories/cattle/cattle.repo";
import type { createMedicationLogSchema } from "../../validators/cattle/cattle.validator";
import { cattleService } from "./cattle.service";

export const cattleMedicationsService = {
  listMedicationLogs: (farmOwnerId: string) =>
    cattleRepo.listMedicationLogs(farmOwnerId),

  addMedicationLog: async (
    farmOwnerId: string,
    input: z.infer<typeof createMedicationLogSchema>,
  ) => {
    await cattleService.getAnimal(farmOwnerId, input.animalId);
    const id = randomUUID();
    await cattleRepo.createMedicationLog({
      id,
      farmOwnerId,
      animalId: input.animalId,
      medicationName: input.medicationName,
      doseMg: input.doseMg !== undefined ? String(input.doseMg) : null,
      date: new Date(input.date),
      route: input.route,
      withdrawalDaysMeat: input.withdrawalDaysMeat,
      withdrawalDaysMilk: input.withdrawalDaysMilk,
      veterinarianApproved: input.veterinarianApproved ? 1 : 0,
      administeredBy: input.administeredBy,
      notes: input.notes,
      createdAt: new Date(),
    });
    return cattleRepo.findMedicationLogById(farmOwnerId, id);
  },
};
