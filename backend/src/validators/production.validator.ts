import { z } from "zod";

const dateRegex = /^\d{4}-\d{2}-\d{2}$/;

export const addMilkRecordSchema = z
  .object({
    animalId: z.string().uuid(),
    species: z.enum(["goat", "cattle"]),
    recordDate: z.string().regex(dateRegex),
    totalLitres: z.string().min(1).max(20),
  })
  .strict();

export const addEggRecordSchema = z
  .object({
    flockId: z.string().uuid(),
    recordDate: z.string().regex(dateRegex),
    eggsCollected: z.number().int().min(0),
  })
  .strict();

export const addWoolRecordSchema = z
  .object({
    animalId: z.string().uuid(),
    shearingDate: z.string().regex(dateRegex),
    fleeceWeightKg: z.string().min(1).max(20),
  })
  .strict();

export type AddMilkRecordInput = z.infer<typeof addMilkRecordSchema>;
export type AddEggRecordInput = z.infer<typeof addEggRecordSchema>;
export type AddWoolRecordInput = z.infer<typeof addWoolRecordSchema>;
