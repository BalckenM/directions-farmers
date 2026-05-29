import { z } from "zod";

export const addFeedLogSchema = z
  .object({
    animalId: z.string().uuid().optional(),
    groupId: z.string().uuid().optional(),
    species: z.enum(["goat", "cattle", "poultry"]),
    feedType: z.string().min(1).max(100),
    quantityKg: z.string().min(1).max(20),
    feedDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
    notes: z.string().max(1000).optional(),
  })
  .strict();

export type AddFeedLogInput = z.infer<typeof addFeedLogSchema>;
