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

export const goatKiddingService = {
  listKiddingEvents: async (farmOwnerId: string) => {
    const rows = await goatRepo.listKiddingEvents(farmOwnerId);
    return rows.map((r) =>
      mapKidding(r as Parameters<typeof mapKidding>[0]),
    );
  },

  createKiddingEvent: async (
    farmOwnerId: string,
    input: z.infer<typeof createKiddingEventSchema>,
  ) => {
    const id = randomUUID();
    await goatRepo.createKiddingEvent({
      id,
      farmOwnerId,
      doeId: input.damId,                           // Flutter: damId → DB: doeId
      kiddingDate: input.kiddingDate,
      totalKidsBorn: input.totalKidsBorn ?? null,
      kidsAlive: input.kidsAliveBorn ?? 0,          // Flutter: kidsAliveBorn → DB: kidsAlive
      kidsDead: input.kidsStillborn ?? 0,           // Flutter: kidsStillborn → DB: kidsDead
      birthWeights: input.birthWeights
        ? JSON.stringify(input.birthWeights)
        : null,
      kidIds: input.kidIds ? JSON.stringify(input.kidIds) : null,
      assisted: input.assisted ?? null,
      complications: input.complications ?? null,
      notes: input.notes ?? null,
      createdAt: new Date(),
    });
    const raw = await goatRepo.findKiddingEventById(farmOwnerId, id);
    return mapKidding(raw);
  },
};

