import { z } from "zod";

const baseAnimal = {
  tagNumber: z.string().min(1).max(50),
  name: z.string().max(100).optional(),
  breed: z.string().max(100).optional(),
  sex: z.enum(["male", "female"]),
  dateOfBirth: z.string().date().optional(),
  status: z.enum(["active", "sold", "deceased", "culled"]).default("active"),
  productionType: z.string().max(50).optional(),
  herdId: z.string().uuid().optional(),
  notes: z.string().max(2000).optional(),
};

export const createGoatSchema = z.object(baseAnimal).strict();
export const updateGoatSchema = z
  .object({
    ...baseAnimal,
    tagNumber: baseAnimal.tagNumber.optional(),
    sex: baseAnimal.sex.optional(),
    status: baseAnimal.status.optional(),
  })
  .strict();

// Flutter sends: animalId, weightKg, date, notes
export const createWeightRecordSchema = z
  .object({
    animalId: z.string().uuid(),
    weightKg: z.number().positive(),
    date: z.string().date(),
    notes: z.string().max(500).optional(),
  })
  .strict();

// Flutter sends: animalId, date, condition, severity, treatment, vet, outcome, notes
export const createHealthEventSchema = z
  .object({
    animalId: z.string().uuid(),
    date: z.string().date(),
    condition: z.string().min(1).max(50),
    severity: z.string().max(20).optional(),
    treatment: z.string().max(2000).optional(),
    vet: z.string().max(100).optional(),
    outcome: z.string().max(50).optional(),
    notes: z.string().max(2000).optional(),
  })
  .strict();

export const updateHealthEventSchema = createHealthEventSchema
  .omit({ animalId: true })
  .partial();

// Flutter sends: animalId, vaccineName, dueDate, givenDate, nextDueDate, batchNumber, administeredBy
export const createVaccinationSchema = z
  .object({
    animalId: z.string().uuid(),
    vaccineName: z.string().min(1).max(255),
    dueDate: z.string().date().optional(),
    givenDate: z.string().date().optional(),
    nextDueDate: z.string().date().optional(),
    batchNumber: z.string().max(50).optional(),
    administeredBy: z.string().max(100).optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

export const markVaccinationGivenSchema = z
  .object({
    givenDate: z.string().date(),
    batchNumber: z.string().max(50).optional(),
  })
  .strict();

// Flutter sends: doeId, buckId, serviceDate, serviceMethod, notes
export const createMatingSchema = z
  .object({
    doeId: z.string().uuid(),
    buckId: z.string().uuid().optional(),
    serviceDate: z.string().date(),
    serviceMethod: z.string().max(50).optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

export const updateMatingSchema = createMatingSchema.omit({ doeId: true }).partial();

// Flutter sends: animalId, date, morningLitres, eveningLitres, totalLitres, notes
export const createDailyMilkSchema = z
  .object({
    animalId: z.string().uuid(),
    date: z.string().date(),
    morningLitres: z.number().nonnegative().optional(),
    eveningLitres: z.number().nonnegative().optional(),
    totalLitres: z.number().nonnegative(),
    notes: z.string().max(500).optional(),
  })
  .strict();

// Flutter sends: animalId, date, method, result, expectedKiddingDate, daysPregnant, notes
export const createPregnancyCheckSchema = z
  .object({
    animalId: z.string().uuid(),
    date: z.string().date(),
    method: z.string().max(50).optional(),
    result: z.enum(["positive", "negative", "inconclusive"]),
    expectedKiddingDate: z.string().date().optional(),
    daysPregnant: z.number().int().nonnegative().optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

// Flutter sends: damId, kiddingDate, totalKidsBorn, kidsAliveBorn, kidsStillborn, birthWeights, kidIds, assisted, complications, notes
export const createKiddingEventSchema = z
  .object({
    damId: z.string().uuid(),
    kiddingDate: z.string().date(),
    totalKidsBorn: z.number().int().nonnegative().optional(),
    kidsAliveBorn: z.number().int().nonnegative().default(0),
    kidsStillborn: z.number().int().nonnegative().default(0),
    birthWeights: z.array(z.number().nonnegative()).optional(),
    kidIds: z.array(z.string().uuid()).optional(),
    assisted: z.boolean().optional(),
    complications: z.string().max(500).optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

// Flutter sends: animalId, drug, dose, route, reason, withdrawalDays, date, administeredBy, notes
export const createMedicationLogSchema = z
  .object({
    animalId: z.string().uuid(),
    drug: z.string().min(1).max(255),
    dose: z.string().max(100).optional(),
    route: z.string().max(50).optional(),
    reason: z.string().max(255).optional(),
    withdrawalDays: z.number().int().nonnegative().optional(),
    date: z.string().date(),
    administeredBy: z.string().max(100).optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

// Flutter sends: animalId, shearingDate, fleeceWeightKg, stapleLength, micron, colorGrade, pricePerKg, notes
export const createShearingRecordSchema = z
  .object({
    animalId: z.string().uuid(),
    shearingDate: z.string().date(),
    fleeceWeightKg: z.number().nonnegative().optional(),
    stapleLength: z.number().nonnegative().optional(),
    micron: z.number().nonnegative().optional(),
    colorGrade: z.string().max(50).optional(),
    pricePerKg: z.number().nonnegative().optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

// Flutter sends: animalId, saleDate, buyerName, saleWeightKg, pricePerKg, totalRevenue, invoiceRef, notes
export const createSaleRecordSchema = z
  .object({
    animalId: z.string().uuid(),
    saleDate: z.string().date(),
    buyerName: z.string().max(100).optional(),
    saleWeightKg: z.number().nonnegative().optional(),
    pricePerKg: z.number().nonnegative().optional(),
    totalRevenue: z.number().nonnegative().optional(),
    invoiceRef: z.string().max(100).optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

export const updateSaleRecordSchema = createSaleRecordSchema
  .omit({ animalId: true })
  .partial();

// Flutter sends: herdId(optional=goatId), feedType, quantityKg, costPerKg, date, notes
export const createFeedRecordSchema = z
  .object({
    herdId: z.string().uuid().optional(),
    feedType: z.string().min(1).max(100),
    quantityKg: z.number().nonnegative(),
    costPerKg: z.number().nonnegative().optional(),
    date: z.string().date(),
    notes: z.string().max(500).optional(),
  })
  .strict();

// Flutter sends: herdId, campId, entryDate, exitDate, estimatedHa, veldCondition, notes
export const createPastureRecordSchema = z
  .object({
    herdId: z.string().uuid().optional(),
    campId: z.string().uuid().optional(),
    entryDate: z.string().date(),
    exitDate: z.string().date().optional(),
    estimatedHa: z.number().nonnegative().optional(),
    veldCondition: z.string().max(50).optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

export const exitPastureSchema = z
  .object({
    exitDate: z.string().date(),
  })
  .strict();

// Flutter sends: animalId, score, date, actionTaken, notes
export const createFamachaRecordSchema = z
  .object({
    animalId: z.string().uuid(),
    score: z.number().int().min(1).max(5),
    date: z.string().date(),
    actionTaken: z.string().max(255).optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

// Flutter sends: animalId, score, date, notes
export const createBcsRecordSchema = z
  .object({
    animalId: z.string().uuid(),
    score: z.number().min(1).max(5),
    date: z.string().date(),
    notes: z.string().max(500).optional(),
  })
  .strict();

export type CreateGoatInput = z.infer<typeof createGoatSchema>;
export type UpdateGoatInput = z.infer<typeof updateGoatSchema>;

