import { randomUUID } from "crypto";
import type { z } from "zod";
import { parsePagination } from "../../lib/pagination";
import { goatRepo } from "../../repositories/goat/goat.repo";
import type {
  CreateGoatInput,
  UpdateGoatInput,
  createBcsRecordSchema,
  createDailyMilkSchema,
  createFamachaRecordSchema,
  createFeedRecordSchema,
  createHealthEventSchema,
  createKiddingEventSchema,
  createMatingSchema,
  createMedicationLogSchema,
  createPastureRecordSchema,
  createPregnancyCheckSchema,
  createSaleRecordSchema,
  createShearingRecordSchema,
  createVaccinationSchema,
  createWeightRecordSchema,
  exitPastureSchema,
  markVaccinationGivenSchema,
  updateHealthEventSchema,
  updateMatingSchema,
  updateSaleRecordSchema,
} from "../../validators/goat.validator";

function notFound(): never {
  throw Object.assign(new Error("Not found"), {
    status: 404,
    code: "NOT_FOUND",
  });
}

// Post-process kidding event rows
function mapKidding(raw: Awaited<ReturnType<typeof goatRepo.findKiddingEventById>>) {
  if (!raw) return null;
  return { ...raw };
}

export const goatSalesService = {
  listSaleRecords: (farmOwnerId: string) =>
    goatRepo.listSaleRecords(farmOwnerId),

  createSaleRecord: async (
    farmOwnerId: string,
    input: z.infer<typeof createSaleRecordSchema>,
  ) => {
    const id = randomUUID();
    await goatRepo.createSaleRecord({
      id,
      farmOwnerId,
      goatId: input.animalId,              // Flutter: animalId → DB: goatId
      saleDate: input.saleDate,
      buyerName: input.buyerName ?? null,
      saleWeightKg: input.saleWeightKg ?? null,
      pricePerKg: input.pricePerKg ?? null,
      salePrice: input.totalRevenue ?? null, // Flutter: totalRevenue → DB: salePrice
      invoiceRef: input.invoiceRef ?? null,
      notes: input.notes ?? null,
      createdAt: new Date(),
    });
    return goatRepo.findSaleRecordById(farmOwnerId, id);
  },

  updateSaleRecord: async (
    farmOwnerId: string,
    id: string,
    input: z.infer<typeof updateSaleRecordSchema>,
  ) => {
    const existing = await goatRepo.findSaleRecordById(farmOwnerId, id);
    if (!existing) notFound();
    const patch: Record<string, unknown> = {};
    if (input.saleDate !== undefined) patch["saleDate"] = input.saleDate;
    if (input.buyerName !== undefined) patch["buyerName"] = input.buyerName;
    if (input.saleWeightKg !== undefined)
      patch["saleWeightKg"] = input.saleWeightKg;
    if (input.pricePerKg !== undefined) patch["pricePerKg"] = input.pricePerKg;
    if (input.totalRevenue !== undefined) patch["salePrice"] = input.totalRevenue;
    if (input.invoiceRef !== undefined) patch["invoiceRef"] = input.invoiceRef;
    if (input.notes !== undefined) patch["notes"] = input.notes;
    await goatRepo.updateSaleRecord(farmOwnerId, id, patch);
    return goatRepo.findSaleRecordById(farmOwnerId, id);
  },

  deleteSaleRecord: async (farmOwnerId: string, id: string) => {
    await goatRepo.deleteSaleRecord(farmOwnerId, id);
  },
};

