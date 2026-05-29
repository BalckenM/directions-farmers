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

export const goatBcsService = {
  listBcsRecords: (farmOwnerId: string) =>
    goatRepo.listBcsRecords(farmOwnerId),

  createBcsRecord: async (
    farmOwnerId: string,
    input: z.infer<typeof createBcsRecordSchema>,
  ) => {
    const id = randomUUID();
    await goatRepo.createBcsRecord({
      id,
      farmOwnerId,
      goatId: input.animalId,          // Flutter: animalId → DB: goatId
      score: input.score,
      recordDate: input.date,          // Flutter: date → DB: recordDate
      notes: input.notes ?? null,
      createdAt: new Date(),
    });
    return goatRepo.findBcsRecordById(farmOwnerId, id);
  },
};

