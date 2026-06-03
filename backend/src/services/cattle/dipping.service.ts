import { randomUUID } from "crypto";
import type { z } from "zod";
import { cattleRepo } from "../../repositories/cattle/cattle.repo";
import type { createDippingRecordSchema } from "../../validators/cattle/cattle.validator";

export const cattleDippingService = {
  listDippingRecords: (farmOwnerId: string) =>
    cattleRepo.listDippingRecords(farmOwnerId),

  addDippingRecord: async (
    farmOwnerId: string,
    input: z.infer<typeof createDippingRecordSchema>,
  ) => {
    const id = randomUUID();
    await cattleRepo.createDippingRecord({
      id,
      farmOwnerId,
      animalId: input.animalId,
      dippingDate: new Date(input.dippingDate),
      productUsed: input.productUsed,
      method: input.method,
      concentration: input.concentration,
      nextDueDays: input.nextDueDays,
      veterinarianApproved: input.veterinarianApproved ? 1 : 0,
      notes: input.notes,
      createdAt: new Date(),
    });
    return cattleRepo.findDippingRecordById(farmOwnerId, id);
  },
};
