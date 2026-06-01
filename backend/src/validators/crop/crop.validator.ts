import { z } from "zod";

export const createFieldSchema = z
  .object({
    name: z.string().min(1).max(100),
    areaHectares: z.number().positive().optional(),
    soilType: z.string().max(100).optional(),
    irrigationType: z.string().max(50).optional(),
    notes: z.string().max(2000).optional(),
  })
  .strict();

export const updateFieldSchema = createFieldSchema.partial();

export const createPlantingPlanSchema = z
  .object({
    cropId: z.string().uuid(),
    fieldId: z.string().uuid(),
    seasonId: z.string().uuid().optional(),
    plantingDate: z.string().date().optional(),
    expectedHarvestDate: z.string().date().optional(),
    status: z
      .enum(["planned", "planted", "growing", "harvested", "failed"])
      .default("planned"),
    notes: z.string().max(2000).optional(),
  })
  .strict();

export const updatePlantingPlanSchema = createPlantingPlanSchema.partial();

export const createHarvestRecordSchema = z
  .object({
    plantingPlanId: z.string().uuid(),
    harvestDate: z.string().date(),
    quantityKg: z.number().positive(),
    qualityGrade: z.string().max(20).optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

export const createSprayRecordSchema = z
  .object({
    fieldId: z.string().uuid().optional(),
    sprayDate: z.string().date(),
    chemical: z.string().min(1).max(255),
    dosagePerHa: z.string().max(50).optional(),
    areaSprayedHa: z.number().positive().optional(),
    operatorName: z.string().max(100).optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

export const createTaskSchema = z
  .object({
    title: z.string().min(1).max(255),
    taskType: z.string().min(1).max(50),
    plantingPlanId: z.string().uuid().optional(),
    fieldId: z.string().uuid().optional(),
    dueDate: z.string().date().optional(),
    status: z
      .enum(["pending", "in_progress", "completed", "cancelled"])
      .default("pending"),
    notes: z.string().max(500).optional(),
  })
  .strict();

export const updateTaskSchema = createTaskSchema.partial();

export const createSeasonSchema = z
  .object({
    name: z.string().min(1).max(100),
    startDate: z.string().date(),
    endDate: z.string().date().optional(),
    isActive: z.boolean().default(true),
    notes: z.string().max(2000).optional(),
  })
  .strict();

export const updateSeasonSchema = createSeasonSchema.partial();

export const createPestObservationSchema = z
  .object({
    fieldId: z.string().uuid().optional(),
    plantingPlanId: z.string().uuid().optional(),
    observationDate: z.string().date(),
    pestName: z.string().min(1).max(255),
    severity: z.enum(["low", "medium", "high", "critical"]).optional(),
    affectedAreaHa: z.number().positive().optional(),
    notes: z.string().max(2000).optional(),
  })
  .strict();

export const updatePestObservationSchema = createPestObservationSchema.partial();

export const createExpenseSchema = z
  .object({
    plantingPlanId: z.string().uuid().optional(),
    fieldId: z.string().uuid().optional(),
    expenseDate: z.string().date(),
    category: z.string().min(1).max(50),
    description: z.string().max(255).optional(),
    amount: z.number().positive(),
    notes: z.string().max(2000).optional(),
  })
  .strict();

export const updateExpenseSchema = createExpenseSchema.partial();

export const createCalendarEventSchema = z
  .object({
    title: z.string().min(1).max(255),
    eventType: z.string().min(1).max(50),
    eventDate: z.string().date(),
    fieldId: z.string().uuid().optional(),
    notes: z.string().max(2000).optional(),
  })
  .strict();

export const updateCalendarEventSchema = createCalendarEventSchema.partial();

export const createSaleSchema = z
  .object({
    harvestRecordId: z.string().uuid().optional(),
    saleDate: z.string().date(),
    buyerName: z.string().max(255).optional(),
    quantityKg: z.number().positive(),
    pricePerKg: z.number().positive(),
    totalAmount: z.number().positive(),
    notes: z.string().max(2000).optional(),
  })
  .strict();

export const updateSaleSchema = createSaleSchema.partial();

export const updateHarvestRecordSchema = createHarvestRecordSchema.partial();
export const updateSprayRecordSchema = createSprayRecordSchema.partial();

export type CreateFieldInput = z.infer<typeof createFieldSchema>;
export type CreatePlantingPlanInput = z.infer<typeof createPlantingPlanSchema>;
