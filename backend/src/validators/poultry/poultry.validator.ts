import { z } from "zod";

export const createFlockSchema = z
  .object({
    flockName: z.string().min(1).max(100),
    species: z.string().min(1).max(50),
    breed: z.string().max(100).optional(),
    startDate: z.string().date(),
    initialCount: z.number().int().nonnegative(),
    notes: z.string().max(2000).optional(),
  })
  .strict();

export const updateFlockSchema = z
  .object({
    flockName: z.string().min(1).max(100).optional(),
    breed: z.string().max(100).optional(),
    notes: z.string().max(2000).optional(),
  })
  .strict();

export const createDailyRecordSchema = z
  .object({
    recordDate: z.string().date(),
    mortalityCount: z.number().int().nonnegative().default(0),
    eggsCollected: z.number().int().nonnegative().optional(),
    feedConsumedKg: z.number().nonnegative().optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

export const createHarvestRecordSchema = z
  .object({
    harvestDate: z.string().date(),
    birdCount: z.number().int().positive(),
    averageWeightKg: z.number().positive(),
    totalWeightKg: z.number().positive(),
    pricePerKg: z.number().positive().optional(),
    buyerName: z.string().max(255).optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

export const createVaccinationScheduleSchema = z
  .object({
    vaccineName: z.string().min(1).max(255),
    scheduledDate: z.string().date(),
    completedDate: z.string().date().optional(),
    batchNumber: z.string().max(50).optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

export type CreateFlockInput = z.infer<typeof createFlockSchema>;
export type UpdateFlockInput = z.infer<typeof updateFlockSchema>;
