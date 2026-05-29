import { z } from "zod";

export const addMovementSchema = z
  .object({
    animalId: z.string().uuid(),
    species: z.enum(["goat", "cattle"]),
    movementType: z.string().min(1).max(50),
    fromLocation: z.string().max(255).optional(),
    toLocation: z.string().max(255).optional(),
    movementDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
    reason: z.string().max(255).optional(),
    notes: z.string().max(1000).optional(),
  })
  .strict();

export type AddMovementInput = z.infer<typeof addMovementSchema>;
