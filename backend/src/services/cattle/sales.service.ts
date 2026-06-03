import { randomUUID } from "crypto";
import type { z } from "zod";
import { cattleRepo } from "../../repositories/cattle/cattle.repo";
import type { createSaleRecordSchema, updateSaleRecordSchema } from "../../validators/cattle/cattle.validator";
import { cattleService } from "./cattle.service";

export const cattleSalesService = {
  listSaleRecords: (farmOwnerId: string) =>
    cattleRepo.listSaleRecords(farmOwnerId),

  addSaleRecord: async (
    farmOwnerId: string,
    input: z.infer<typeof createSaleRecordSchema>,
  ) => {
    await cattleService.getAnimal(farmOwnerId, input.animalId);
    const id = randomUUID();
    await cattleRepo.createSaleRecord({
      id,
      farmOwnerId,
      animalId: input.animalId,
      saleDate: new Date(input.saleDate),
      buyerName: input.buyerName,
      totalAmount: String(input.totalAmount),
      saleWeightKg: input.saleWeightKg !== undefined ? String(input.saleWeightKg) : null,
      pricePerKg: input.pricePerKg !== undefined ? String(input.pricePerKg) : null,
      transportCost: input.transportCost !== undefined ? String(input.transportCost) : null,
      permitNumber: input.permitNumber,
      invoiceRef: input.invoiceRef,
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
    if (!existing) throw Object.assign(new Error("Not found"), { status: 404, code: "NOT_FOUND" });
    const patch: Record<string, unknown> = { ...input };
    if (input.totalAmount !== undefined) patch["totalAmount"] = String(input.totalAmount);
    if (input.saleWeightKg !== undefined) patch["saleWeightKg"] = String(input.saleWeightKg);
    if (input.pricePerKg !== undefined) patch["pricePerKg"] = String(input.pricePerKg);
    if (input.transportCost !== undefined) patch["transportCost"] = String(input.transportCost);
    await cattleRepo.updateSaleRecord(farmOwnerId, id, patch);
    return cattleRepo.findSaleRecordById(farmOwnerId, id);
  },

  deleteSaleRecord: async (farmOwnerId: string, id: string) => {
    await cattleRepo.deleteSaleRecord(farmOwnerId, id);
  },
};
