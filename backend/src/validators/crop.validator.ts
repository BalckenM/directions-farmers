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

export type CreateFieldInput = z.infer<typeof createFieldSchema>;
export type CreatePlantingPlanInput = z.infer<typeof createPlantingPlanSchema>;
