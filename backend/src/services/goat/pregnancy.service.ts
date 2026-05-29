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

export const goatPregnancyService = {
  listPregnancyChecks: (farmOwnerId: string) =>
    goatRepo.listPregnancyChecks(farmOwnerId),

  createPregnancyCheck: async (
    farmOwnerId: string,
    input: z.infer<typeof createPregnancyCheckSchema>,
  ) => {
    const id = randomUUID();
    await goatRepo.createPregnancyCheck({
      id,
      farmOwnerId,
      goatId: input.animalId,              // Flutter: animalId → DB: goatId
      checkDate: input.date,               // Flutter: date → DB: checkDate
      method: input.method ?? null,
      result: input.result,
      expectedKiddingDate: input.expectedKiddingDate ?? null,
      daysPregnant: input.daysPregnant ?? null,
      notes: input.notes ?? null,
      createdAt: new Date(),
    });
    return goatRepo.findPregnancyCheckById(farmOwnerId, id);
  },
};

