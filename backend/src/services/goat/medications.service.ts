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

export const goatMedicationsService = {
  listMedicationLogs: (farmOwnerId: string) =>
    goatRepo.listMedicationLogs(farmOwnerId),

  createMedicationLog: async (
    farmOwnerId: string,
    input: z.infer<typeof createMedicationLogSchema>,
  ) => {
    const id = randomUUID();
    await goatRepo.createMedicationLog({
      id,
      farmOwnerId,
      goatId: input.animalId,               // Flutter: animalId → DB: goatId
      medicationName: input.drug,           // Flutter: drug → DB: medicationName
      dosage: input.dose ?? null,           // Flutter: dose → DB: dosage
      route: input.route ?? null,
      reason: input.reason ?? null,
      withdrawalDays: input.withdrawalDays ?? null,
      administeredAt: input.date,           // Flutter: date → DB: administeredAt
      administeredBy: input.administeredBy ?? null,
      notes: input.notes ?? null,
      createdAt: new Date(),
    });
    return goatRepo.findMedicationLogById(farmOwnerId, id);
  },
};

