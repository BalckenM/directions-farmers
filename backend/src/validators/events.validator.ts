import { z } from "zod";

const dateRegex = /^\d{4}-\d{2}-\d{2}$/;

export const addHealthEventSchema = z
  .object({
    animalId: z.string().uuid(),
    species: z.enum(["goat", "cattle"]),
    eventDate: z.string().regex(dateRegex),
    eventType: z.string().min(1).max(50),
    description: z.string().max(1000).optional(),
  })
  .strict();

export const addWeightRecordSchema = z
  .object({
    animalId: z.string().uuid(),
    species: z.enum(["goat", "cattle"]),
    recordDate: z.string().regex(dateRegex),
    weightKg: z.string().min(1).max(20),
  })
  .strict();

export const addBreedingEventSchema = z
  .object({
    animalId: z.string().uuid(),
    species: z.enum(["goat", "cattle"]),
    eventDate: z.string().regex(dateRegex),
    eventType: z.string().min(1).max(50),
    description: z.string().max(1000).optional(),
  })
  .strict();

export type AddHealthEventInput = z.infer<typeof addHealthEventSchema>;
export type AddWeightRecordInput = z.infer<typeof addWeightRecordSchema>;
export type AddBreedingEventInput = z.infer<typeof addBreedingEventSchema>;
