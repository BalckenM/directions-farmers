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

export const goatMilkService = {
  listDailyMilk: (farmOwnerId: string) => goatRepo.listDailyMilk(farmOwnerId),

  createDailyMilk: async (
    farmOwnerId: string,
    input: z.infer<typeof createDailyMilkSchema>,
  ) => {
    const id = randomUUID();
    const morning = input.morningLitres ?? 0;
    const evening = input.eveningLitres ?? 0;
    await goatRepo.createDailyMilk({
      id,
      farmOwnerId,
      goatId: input.animalId,           // Flutter: animalId → DB: goatId
      recordDate: input.date,           // Flutter: date → DB: recordDate
      morningLitres: morning,
      eveningLitres: evening,
      totalLitres: morning + evening,   // computed for DB
      notes: null,
      createdAt: new Date(),
    });
    return goatRepo.findDailyMilkById(farmOwnerId, id);
  },

  deleteDailyMilk: async (farmOwnerId: string, id: string) => {
    await goatRepo.deleteDailyMilk(farmOwnerId, id);
  },
};

