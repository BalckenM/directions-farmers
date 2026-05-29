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

export const goatWeightService = {
  listWeightRecords: (farmOwnerId: string) =>
    goatRepo.listWeightRecords(farmOwnerId),

  createWeightRecord: async (
    farmOwnerId: string,
    input: z.infer<typeof createWeightRecordSchema>,
  ) => {
    const id = randomUUID();
    await goatRepo.createWeightRecord({
      id,
      farmOwnerId,
      goatId: input.animalId,         // Flutter: animalId → DB: goatId
      weightKg: String(input.weightKg),
      recordedAt: input.date,          // Flutter: date → DB: recordedAt
      notes: input.notes ?? null,
      createdAt: new Date(),
    });
    return goatRepo.findWeightRecordById(farmOwnerId, id);
  },

  deleteWeightRecord: async (farmOwnerId: string, id: string) => {
    await goatRepo.deleteWeightRecord(farmOwnerId, id);
  },
};

