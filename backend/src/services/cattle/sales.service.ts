import { randomUUID } from "crypto";
import type { z } from "zod";
import { cattleRepo } from "../../repositories/cattle/cattle.repo";
import type {
    createBcsRecordSchema,
    createBreedingRecordSchema,
    createCalvingEventSchema,
    createCattleSchema,
    createDailyMilkSchema,
    createDippingRecordSchema,
    createFeedRecordSchema,
    createHealthEventSchema,
    createMedicationLogSchema,
    createPastureRecordSchema,
    createPregnancyCheckSchema,
    createSaleRecordSchema,
    createVaccinationSchema,
    createWeightRecordSchema,
    exitPastureSchema,
    markVaccinationGivenSchema,
    updateBreedingRecordSchema,
    updateCattleSchema,
    updateHealthEventSchema,
    updateSaleRecordSchema,
} from "../../validators/cattle.validator";

import { cattleService } from "./cattle.service";

export const cattleSalesService = {
  listSaleRecords: (farmOwnerId: string) =>
    cattleRepo.listSaleRecords(farmOwnerId),

  addSaleRecord: async (
    farmOwnerId: string,
    input: z.infer<typeof createSaleRecordSchema>,
  ) => {
    await cattleService.getAnimal(farmOwnerId, input.cattleId);
    const id = randomUUID();
    await cattleRepo.createSaleRecord({
      id,
      farmOwnerId,
      cattleId: input.cattleId,
      saleDate: new Date(input.saleDate),
      buyerName: input.buyerName,
      salePrice: String(input.salePrice),
      notes: input.notes,
      createdAt: new Date(),
    });
    return cattleRepo.findSaleRecordById(farmOwnerId, id);
  },

  updateSaleRecord: async (
    farmOwnerId: string,
    id: string,
    input: z.infer<typeof updateSaleRecordSchema>,
  ) => {
    const existing = await cattleRepo.findSaleRecordById(farmOwnerId, id);
    if (!existing)
      throw Object.assign(new Error("Not found"), { status: 404, code: "NOT_FOUND" });
    const patch: Record<string, unknown> = { ...input };
    if (input.salePrice !== undefined) patch["salePrice"] = String(input.salePrice);
    await cattleRepo.updateSaleRecord(farmOwnerId, id, patch);
    return cattleRepo.findSaleRecordById(farmOwnerId, id);
  },

  deleteSaleRecord: async (farmOwnerId: string, id: string) => {
    await cattleRepo.deleteSaleRecord(farmOwnerId, id);
  },
};

