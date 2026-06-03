import { randomUUID } from "crypto";
import type { z } from "zod";
import { cattleRepo } from "../../repositories/cattle/cattle.repo";
import type { createCalvingEventSchema } from "../../validators/cattle/cattle.validator";

export const cattleCalvingService = {
  listCalvingEvents: (farmOwnerId: string) =>
    cattleRepo.listCalvingEvents(farmOwnerId),

  addCalvingEvent: async (
    farmOwnerId: string,
    input: z.infer<typeof createCalvingEventSchema>,
  ) => {
    const id = randomUUID();
    await cattleRepo.createCalvingEvent({
      id,
      farmOwnerId,
      damId: input.damId,
      calvingDate: new Date(input.calvingDate),
      calvingEase: input.calvingEase,
      calfAlive: input.calfAlive ? 1 : 0,
      calfId: input.calfId,
      calfSex: input.calfSex,
      calfWeightKg: input.calfWeightKg !== undefined ? String(input.calfWeightKg) : null,
      complications: input.complications,
      calvesAlive: input.calvesAlive,
      calvesDead: input.calvesDead,
      notes: input.notes,
      createdAt: new Date(),
    });
    return cattleRepo.findCalvingEventById(farmOwnerId, id);
  },
};
