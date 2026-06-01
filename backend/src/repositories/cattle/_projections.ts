import {
  cattleAnimals,
  cattleBcsRecords,
  cattleBreedingRecords,
  cattleCalvingEvents,
  cattleDailyMilk,
  cattleDippingRecords,
  cattleFeedRecords,
  cattleHealthEvents,
  cattleMedicationLogs,
  cattlePastureRecords,
  cattlePregnancyChecks,
  cattleSaleRecords,
  cattleVaccinations,
  cattleWeightRecords,
} from "../../db/schema";

// SELECT projections — aligned to the ACTUAL schema columns

export const animalSelect = {
  id: cattleAnimals.id,
  farmOwnerId: cattleAnimals.farmOwnerId,
  tagId: cattleAnimals.tagId,
  name: cattleAnimals.name,
  breed: cattleAnimals.breed,
  sex: cattleAnimals.sex,
  dateOfBirth: cattleAnimals.dateOfBirth,
  color: cattleAnimals.color,
  status: cattleAnimals.status,
  productionType: cattleAnimals.productionType,
  herdId: cattleAnimals.herdId,
  isPregnant: cattleAnimals.isPregnant,
  isLactating: cattleAnimals.isLactating,
  notes: cattleAnimals.notes,
  createdAt: cattleAnimals.createdAt,
  updatedAt: cattleAnimals.updatedAt,
};

export const weightSelect = {
  id: cattleWeightRecords.id,
  cattleId: cattleWeightRecords.cattleId,
  weightKg: cattleWeightRecords.weightKg,
  recordedAt: cattleWeightRecords.recordedAt,
  notes: cattleWeightRecords.notes,
};

export const breedingSelect = {
  id: cattleBreedingRecords.id,
  cowId: cattleBreedingRecords.cowId,
  bullId: cattleBreedingRecords.bullId,
  breedingDate: cattleBreedingRecords.breedingDate,
  method: cattleBreedingRecords.method,
  notes: cattleBreedingRecords.notes,
};

export const pregnancyCheckSelect = {
  id: cattlePregnancyChecks.id,
  cattleId: cattlePregnancyChecks.cattleId,
  checkDate: cattlePregnancyChecks.checkDate,
  result: cattlePregnancyChecks.result,
  expectedCalvingDate: cattlePregnancyChecks.expectedCalvingDate,
  notes: cattlePregnancyChecks.notes,
};

export const calvingSelect = {
  id: cattleCalvingEvents.id,
  cowId: cattleCalvingEvents.cowId,
  calvingDate: cattleCalvingEvents.calvingDate,
  calvesAlive: cattleCalvingEvents.calvesAlive,
  calvesDead: cattleCalvingEvents.calvesDead,
  notes: cattleCalvingEvents.notes,
};

export const milkSelect = {
  id: cattleDailyMilk.id,
  cattleId: cattleDailyMilk.cattleId,
  recordDate: cattleDailyMilk.recordDate,
  morningLitres: cattleDailyMilk.morningLitres,
  eveningLitres: cattleDailyMilk.eveningLitres,
  totalLitres: cattleDailyMilk.totalLitres,
};

export const healthSelect = {
  id: cattleHealthEvents.id,
  cattleId: cattleHealthEvents.cattleId,
  eventDate: cattleHealthEvents.eventDate,
  eventType: cattleHealthEvents.eventType,
  diagnosis: cattleHealthEvents.diagnosis,
  treatment: cattleHealthEvents.treatment,
  outcome: cattleHealthEvents.outcome,
  notes: cattleHealthEvents.notes,
};

export const medicationSelect = {
  id: cattleMedicationLogs.id,
  cattleId: cattleMedicationLogs.cattleId,
  medicationName: cattleMedicationLogs.medicationName,
  dosage: cattleMedicationLogs.dosage,
  administeredAt: cattleMedicationLogs.administeredAt,
  administeredBy: cattleMedicationLogs.administeredBy,
  notes: cattleMedicationLogs.notes,
};

export const vaccinationSelect = {
  id: cattleVaccinations.id,
  cattleId: cattleVaccinations.cattleId,
  vaccineName: cattleVaccinations.vaccineName,
  vaccinationDate: cattleVaccinations.vaccinationDate,
  nextDueDate: cattleVaccinations.nextDueDate,
  batchNumber: cattleVaccinations.batchNumber,
  notes: cattleVaccinations.notes,
};

export const saleSelect = {
  id: cattleSaleRecords.id,
  cattleId: cattleSaleRecords.cattleId,
  saleDate: cattleSaleRecords.saleDate,
  buyerName: cattleSaleRecords.buyerName,
  salePrice: cattleSaleRecords.salePrice,
  notes: cattleSaleRecords.notes,
};

export const feedSelect = {
  id: cattleFeedRecords.id,
  cattleId: cattleFeedRecords.cattleId,
  feedType: cattleFeedRecords.feedType,
  quantityKg: cattleFeedRecords.quantityKg,
  feedDate: cattleFeedRecords.feedDate,
  notes: cattleFeedRecords.notes,
};

export const pastureSelect = {
  id: cattlePastureRecords.id,
  pastureName: cattlePastureRecords.pastureName,
  moveDate: cattlePastureRecords.moveDate,
  notes: cattlePastureRecords.notes,
};

export const bcsSelect = {
  id: cattleBcsRecords.id,
  cattleId: cattleBcsRecords.cattleId,
  score: cattleBcsRecords.score,
  recordDate: cattleBcsRecords.recordDate,
  notes: cattleBcsRecords.notes,
};

export const dippingSelect = {
  id: cattleDippingRecords.id,
  dippingDate: cattleDippingRecords.dippingDate,
  chemical: cattleDippingRecords.chemical,
  concentration: cattleDippingRecords.concentration,
  numberOfCattle: cattleDippingRecords.numberOfCattle,
  notes: cattleDippingRecords.notes,
};
