import { z } from "zod";

const baseAnimal = {
  tagNumber: z.string().min(1).max(50),
  name: z.string().max(100).optional(),
  breed: z.string().max(100).optional(),
  sex: z.enum(["male", "female"]),
  dateOfBirth: z.string().date().optional(),
  status: z.enum(["active", "sold", "deceased", "culled"]).default("active"),
  notes: z.string().max(2000).optional(),
};

export const createCattleSchema = z.object(baseAnimal).strict();
export const updateCattleSchema = z
  .object({
    ...baseAnimal,
    tagNumber: baseAnimal.tagNumber.optional(),
    sex: baseAnimal.sex.optional(),
    status: baseAnimal.status.optional(),
  })
  .strict();

export const createWeightRecordSchema = z
  .object({
    cattleId: z.string().uuid(),
    weightKg: z.number().positive(),
    recordDate: z.string().date(),
    notes: z.string().max(500).optional(),
  })
  .strict();

export const createHealthEventSchema = z
  .object({
    cattleId: z.string().uuid(),
    eventDate: z.string().date(),
    eventType: z.string().min(1).max(50),
    description: z.string().max(2000).optional(),
    vetName: z.string().max(100).optional(),
    cost: z.number().nonnegative().optional(),
  })
  .strict();

export const createVaccinationSchema = z
  .object({
    cattleId: z.string().uuid(),
    vaccineName: z.string().min(1).max(255),
    vaccinationDate: z.string().date(),
    nextDueDate: z.string().date().optional(),
    batchNumber: z.string().max(50).optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

export const createBreedingRecordSchema = z
  .object({
    cowId: z.string().uuid(),
    breedingDate: z.string().date(),
    bullId: z.string().uuid().optional(),
    method: z.string().max(50).optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

export const createDailyMilkSchema = z
  .object({
    cattleId: z.string().uuid(),
    recordDate: z.string().date(),
    amLitres: z.number().nonnegative().optional(),
    pmLitres: z.number().nonnegative().optional(),
    totalLitres: z.number().nonnegative(),
  })
  .strict();

export const createDippingRecordSchema = z
  .object({
    dippingDate: z.string().date(),
    chemical: z.string().min(1).max(255).optional(),
    concentration: z.string().max(50).optional(),
    numberOfCattle: z.number().int().min(0).optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

export const updateBreedingRecordSchema = createBreedingRecordSchema.partial();
export const updateHealthEventSchema = createHealthEventSchema.partial();

export const createPregnancyCheckSchema = z
  .object({
    cattleId: z.string().uuid(),
    checkDate: z.string().date(),
    result: z.enum(["positive", "negative", "inconclusive"]),
    expectedCalvingDate: z.string().date().optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

export const createCalvingEventSchema = z
  .object({
    cowId: z.string().uuid(),
    calvingDate: z.string().date(),
    calvesAlive: z.number().int().min(0).default(0),
    calvesDead: z.number().int().min(0).default(0),
    notes: z.string().max(500).optional(),
  })
  .strict();

export const createMedicationLogSchema = z
  .object({
    cattleId: z.string().uuid(),
    medicationName: z.string().min(1).max(255),
    dosage: z.string().max(100).optional(),
    administeredAt: z.string().date(),
    administeredBy: z.string().max(100).optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

export const markVaccinationGivenSchema = z
  .object({
    vaccinationDate: z.string().date().optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

export const createSaleRecordSchema = z
  .object({
    cattleId: z.string().uuid(),
    saleDate: z.string().date(),
    buyerName: z.string().max(255).optional(),
    salePrice: z.number().nonnegative(),
    notes: z.string().max(500).optional(),
  })
  .strict();

export const updateSaleRecordSchema = createSaleRecordSchema.partial();

export const createFeedRecordSchema = z
  .object({
    cattleId: z.string().uuid().optional(),
    feedType: z.string().min(1).max(100),
    quantityKg: z.number().nonnegative(),
    feedDate: z.string().date(),
    notes: z.string().max(500).optional(),
  })
  .strict();

export const createPastureRecordSchema = z
  .object({
    pastureName: z.string().min(1).max(100),
    moveDate: z.string().date(),
    notes: z.string().max(500).optional(),
  })
  .strict();

export const exitPastureSchema = z
  .object({
    notes: z.string().max(500).optional(),
  })
  .strict();

export const createBcsRecordSchema = z
  .object({
    cattleId: z.string().uuid(),
    score: z.number().min(1).max(5),
    recordDate: z.string().date(),
    notes: z.string().max(500).optional(),
  })
  .strict();

export type CreateCattleInput = z.infer<typeof createCattleSchema>;
export type UpdateCattleInput = z.infer<typeof updateCattleSchema>;
