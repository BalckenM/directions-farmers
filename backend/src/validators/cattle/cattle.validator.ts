import { z } from "zod";

const baseAnimal = {
  tagNumber: z.string().min(1).max(50),
  name: z.string().max(100).optional(),
  breed: z.string().max(100).optional(),
  sex: z.enum(["male", "female"]),
  dateOfBirth: z.string().date().optional(),
  status: z.enum(["active", "sold", "deceased", "culled"]).default("active"),
  productionType: z.string().max(50).optional(),
  color: z.string().max(50).optional(),
  herdId: z.string().uuid().optional(),
  damId: z.string().uuid().optional(),
  sireId: z.string().uuid().optional(),
  purchaseDate: z.string().date().optional(),
  purchasePrice: z.number().nonnegative().optional(),
  registrationNumber: z.string().max(100).optional(),
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

// ── Weight records ────────────────────────────────────────────────────────────
export const createWeightRecordSchema = z
  .object({
    animalId: z.string().uuid(),
    weightKg: z.number().positive(),
    date: z.string().date(),
    bodyConditionScore: z.number().min(1).max(5).optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

// ── Health events ─────────────────────────────────────────────────────────────
export const createHealthEventSchema = z
  .object({
    animalId: z.string().uuid(),
    date: z.string().date(),
    eventType: z.string().min(1).max(50),
    diagnosis: z.string().max(500).optional(),
    treatment: z.string().max(500).optional(),
    severity: z.string().max(50).optional(),
    treatedBy: z.string().max(200).optional(),
    isNotifiable: z.boolean().optional(),
    outcome: z.string().max(100).optional(),
    cost: z.number().nonnegative().optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

export const updateHealthEventSchema = createHealthEventSchema.partial();

// ── Vaccinations ──────────────────────────────────────────────────────────────
export const createVaccinationSchema = z
  .object({
    animalId: z.string().uuid(),
    vaccineName: z.string().min(1).max(255),
    dueDate: z.string().date(),
    givenDate: z.string().date().optional(),
    route: z.string().max(50).optional(),
    siteOnBody: z.string().max(100).optional(),
    administeredBy: z.string().max(200).optional(),
    nextDueDate: z.string().date().optional(),
    batchNumber: z.string().max(50).optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

export const markVaccinationGivenSchema = z
  .object({
    givenDate: z.string().date().optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

// ── Breeding records ──────────────────────────────────────────────────────────
export const createBreedingRecordSchema = z
  .object({
    cowId: z.string().uuid(),
    bullId: z.string().uuid().optional(),
    serviceDate: z.string().date(),
    serviceMethod: z.string().max(50).optional(),
    semenSource: z.string().max(200).optional(),
    technician: z.string().max(200).optional(),
    expectedCalvingDate: z.string().date().optional(),
    outcome: z.string().max(50).optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

export const updateBreedingRecordSchema = createBreedingRecordSchema.partial();

// ── Daily milk ────────────────────────────────────────────────────────────────
export const createDailyMilkSchema = z
  .object({
    animalId: z.string().uuid(),
    date: z.string().date(),
    morningLitres: z.number().nonnegative().optional(),
    eveningLitres: z.number().nonnegative().optional(),
    totalLitres: z.number().nonnegative(),
    lactationDay: z.number().int().nonnegative().optional(),
    qualityFlag: z.string().max(50).optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

// ── Dipping records ───────────────────────────────────────────────────────────
export const createDippingRecordSchema = z
  .object({
    animalId: z.string().uuid().optional(),
    dippingDate: z.string().date(),
    productUsed: z.string().max(200).optional(),
    method: z.string().max(50).optional(),
    concentration: z.string().max(50).optional(),
    nextDueDays: z.number().int().nonnegative().optional(),
    veterinarianApproved: z.boolean().optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

// ── Pregnancy checks ──────────────────────────────────────────────────────────
export const createPregnancyCheckSchema = z
  .object({
    animalId: z.string().uuid(),
    date: z.string().date(),
    status: z.enum(["positive", "negative", "inconclusive"]),
    method: z.string().max(50).optional(),
    dayspregnant: z.number().int().nonnegative().optional(),
    checkedBy: z.string().max(200).optional(),
    expectedCalvingDate: z.string().date().optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

// ── Calving events ────────────────────────────────────────────────────────────
export const createCalvingEventSchema = z
  .object({
    damId: z.string().uuid(),
    calvingDate: z.string().date(),
    calvingEase: z.string().max(50).optional(),
    calfAlive: z.boolean().optional(),
    calfId: z.string().uuid().optional(),
    calfSex: z.enum(["male", "female"]).optional(),
    calfWeightKg: z.number().nonnegative().optional(),
    complications: z.string().max(1000).optional(),
    calvesAlive: z.number().int().min(0).default(0),
    calvesDead: z.number().int().min(0).default(0),
    notes: z.string().max(500).optional(),
  })
  .strict();

// ── Medication logs ───────────────────────────────────────────────────────────
export const createMedicationLogSchema = z
  .object({
    animalId: z.string().uuid(),
    medicationName: z.string().min(1).max(255),
    doseMg: z.number().nonnegative().optional(),
    date: z.string().date(),
    route: z.string().max(50).optional(),
    withdrawalDaysMeat: z.number().int().nonnegative().optional(),
    withdrawalDaysMilk: z.number().int().nonnegative().optional(),
    veterinarianApproved: z.boolean().optional(),
    administeredBy: z.string().max(200).optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

// ── Sale records ──────────────────────────────────────────────────────────────
export const createSaleRecordSchema = z
  .object({
    animalId: z.string().uuid(),
    saleDate: z.string().date(),
    buyerName: z.string().max(255).optional(),
    totalAmount: z.number().nonnegative(),
    saleWeightKg: z.number().nonnegative().optional(),
    pricePerKg: z.number().nonnegative().optional(),
    transportCost: z.number().nonnegative().optional(),
    permitNumber: z.string().max(100).optional(),
    invoiceRef: z.string().max(200).optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

export const updateSaleRecordSchema = createSaleRecordSchema.partial();

// ── Feed records ──────────────────────────────────────────────────────────────
export const createFeedRecordSchema = z
  .object({
    animalId: z.string().uuid().optional(),
    feedType: z.string().min(1).max(100),
    quantityKg: z.number().nonnegative(),
    date: z.string().date(),
    costPerKg: z.number().nonnegative().optional(),
    feedlotPenId: z.string().uuid().optional(),
    rationName: z.string().max(200).optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

// ── Pasture records ───────────────────────────────────────────────────────────
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
    exitDate: z.string().date().optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

// ── BCS records ───────────────────────────────────────────────────────────────
export const createBcsRecordSchema = z
  .object({
    animalId: z.string().uuid(),
    score: z.number().min(1).max(5),
    date: z.string().date(),
    assessedBy: z.string().max(200).optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

// ── Type exports ──────────────────────────────────────────────────────────────
export type CreateCattleInput = z.infer<typeof createCattleSchema>;
export type UpdateCattleInput = z.infer<typeof updateCattleSchema>;
