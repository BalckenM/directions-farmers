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

export const createFeedPhaseSchema = z
  .object({
    flockId: z.string().uuid(),
    phaseName: z.string().min(1).max(100),
    feedType: z.string().min(1).max(100),
    startDay: z.number().int().nonnegative(),
    endDay: z.number().int().nonnegative().optional(),
    dailyRationGrams: z.number().positive().optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

export const createMedicationLogSchema = z
  .object({
    flockId: z.string().uuid(),
    medicationName: z.string().min(1).max(255),
    dosage: z.string().max(100).optional(),
    administeredAt: z.string().date(),
    notes: z.string().max(500).optional(),
  })
  .strict();

export const createDiseaseEventSchema = z
  .object({
    flockId: z.string().uuid(),
    eventDate: z.string().date(),
    diseaseName: z.string().max(255).optional(),
    affectedCount: z.number().int().nonnegative().default(0),
    treatment: z.string().max(2000).optional(),
    outcome: z.string().max(50).optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

export const createEnvironmentReadingSchema = z
  .object({
    flockId: z.string().uuid(),
    recordedAt: z.string().datetime(),
    temperatureCelsius: z.number().optional(),
    humidityPercent: z.number().min(0).max(100).optional(),
    ammoniaPpm: z.number().nonnegative().optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

export const createInventoryItemSchema = z
  .object({
    itemName: z.string().min(1).max(255),
    category: z.string().min(1).max(50),
    quantity: z.number().nonnegative(),
    unit: z.string().min(1).max(20),
    notes: z.string().max(500).optional(),
  })
  .strict();

export const createEggSaleSchema = z
  .object({
    flockId: z.string().uuid().optional(),
    saleDate: z.string().date(),
    eggsCount: z.number().int().positive(),
    pricePerEgg: z.number().positive(),
    totalAmount: z.number().positive(),
    buyerName: z.string().max(255).optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

export const createChickSaleSchema = z
  .object({
    flockId: z.string().uuid().optional(),
    saleDate: z.string().date(),
    chicksCount: z.number().int().positive(),
    pricePerChick: z.number().positive(),
    totalAmount: z.number().positive(),
    buyerName: z.string().max(255).optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();
