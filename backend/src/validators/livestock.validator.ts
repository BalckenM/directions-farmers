import { z } from "zod";

export const createLivestockGroupSchema = z
  .object({
    name: z.string().min(1).max(100),
    species: z.string().min(1).max(50),
    count: z.number().int().min(0).default(0),
    notes: z.string().max(1000).optional(),
  })
  .strict();

export const updateLivestockGroupSchema = createLivestockGroupSchema.partial();

export type CreateLivestockGroupInput = z.infer<typeof createLivestockGroupSchema>;
export type UpdateLivestockGroupInput = z.infer<typeof updateLivestockGroupSchema>;
