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

export const goatHealthService = {
  listHealthEvents: (farmOwnerId: string) =>
    goatRepo.listHealthEvents(farmOwnerId),

  createHealthEvent: async (
    farmOwnerId: string,
    input: z.infer<typeof createHealthEventSchema>,
  ) => {
    const id = randomUUID();
    await goatRepo.createHealthEvent({
      id,
      farmOwnerId,
      goatId: input.animalId,           // Flutter: animalId → DB: goatId
      eventDate: input.date,            // Flutter: date → DB: eventDate
      eventType: input.condition,       // Flutter: condition → DB: eventType
      severity: input.severity ?? null,
      treatment: input.treatment ?? null,
      vet: input.vet ?? null,
      outcome: input.outcome ?? null,
      notes: input.notes ?? null,
      createdAt: new Date(),
    });
    return goatRepo.findHealthEventById(farmOwnerId, id);
  },

  updateHealthEvent: async (
    farmOwnerId: string,
    id: string,
    input: z.infer<typeof updateHealthEventSchema>,
  ) => {
    const existing = await goatRepo.findHealthEventById(farmOwnerId, id);
    if (!existing) notFound();
    const patch: Record<string, unknown> = {};
    if (input.date !== undefined) patch["eventDate"] = input.date;
    if (input.condition !== undefined) patch["eventType"] = input.condition;
    if (input.severity !== undefined) patch["severity"] = input.severity;
    if (input.treatment !== undefined) patch["treatment"] = input.treatment;
    if (input.vet !== undefined) patch["vet"] = input.vet;
    if (input.outcome !== undefined) patch["outcome"] = input.outcome;
    if (input.notes !== undefined) patch["notes"] = input.notes;
    await goatRepo.updateHealthEvent(farmOwnerId, id, patch);
    return goatRepo.findHealthEventById(farmOwnerId, id);
  },
};

