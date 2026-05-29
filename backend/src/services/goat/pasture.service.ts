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

export const goatPastureService = {
  listPastureRecords: (farmOwnerId: string) =>
    goatRepo.listPastureRecords(farmOwnerId),

  createPastureRecord: async (
    farmOwnerId: string,
    input: z.infer<typeof createPastureRecordSchema>,
  ) => {
    const id = randomUUID();
    await goatRepo.createPastureRecord({
      id,
      farmOwnerId,
      herdId: input.herdId ?? null,
      campId: input.campId ?? null,
      entryDate: input.entryDate,
      exitDate: input.exitDate ?? null,
      estimatedHa: input.estimatedHa ?? null,
      veldCondition: input.veldCondition ?? null,
      notes: input.notes ?? null,
      createdAt: new Date(),
    });
    return goatRepo.findPastureRecordById(farmOwnerId, id);
  },

  exitPasture: async (
    farmOwnerId: string,
    id: string,
    input: z.infer<typeof exitPastureSchema>,
  ) => {
    const existing = await goatRepo.findPastureRecordById(farmOwnerId, id);
    if (!existing) notFound();
    await goatRepo.updatePastureRecord(farmOwnerId, id, {
      exitDate: input.exitDate,
    });
    return goatRepo.findPastureRecordById(farmOwnerId, id);
  },
};

