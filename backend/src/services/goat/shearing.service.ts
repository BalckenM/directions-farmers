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

export const goatShearingService = {
  listShearingRecords: (farmOwnerId: string) =>
    goatRepo.listShearingRecords(farmOwnerId),

  createShearingRecord: async (
    farmOwnerId: string,
    input: z.infer<typeof createShearingRecordSchema>,
  ) => {
    const id = randomUUID();
    await goatRepo.createShearingRecord({
      id,
      farmOwnerId,
      goatId: input.animalId,           // Flutter: animalId → DB: goatId
      shearingDate: input.shearingDate,
      fleeceWeightKg: input.fleeceWeightKg ?? null,
      stapleLength: input.stapleLength ?? null,
      micron: input.micron ?? null,
      colorGrade: input.colorGrade ?? null,
      pricePerKg: input.pricePerKg ?? null,
      notes: input.notes ?? null,
      createdAt: new Date(),
    });
    return goatRepo.findShearingRecordById(farmOwnerId, id);
  },
};

