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

export const goatFeedService = {
  listFeedRecords: (farmOwnerId: string) =>
    goatRepo.listFeedRecords(farmOwnerId),

  createFeedRecord: async (
    farmOwnerId: string,
    input: z.infer<typeof createFeedRecordSchema>,
  ) => {
    const id = randomUUID();
    await goatRepo.createFeedRecord({
      id,
      farmOwnerId,
      goatId: input.herdId ?? null,    // Flutter: herdId → DB: goatId (reused)
      feedType: input.feedType,
      quantityKg: input.quantityKg,
      costPerKg: input.costPerKg ?? null,
      feedDate: input.date,            // Flutter: date → DB: feedDate
      notes: input.notes ?? null,
      createdAt: new Date(),
    });
    return goatRepo.findFeedRecordById(farmOwnerId, id);
  },

  deleteFeedRecord: async (farmOwnerId: string, id: string) => {
    await goatRepo.deleteFeedRecord(farmOwnerId, id);
  },
};

