import {
  goatAnimals,
  goatBcsRecords,
  goatDailyMilk,
  goatFamachaRecords,
  goatFeedRecords,
  goatHealthEvents,
  goatKiddingEvents,
  goatMatingRecords,
  goatMedicationLogs,
  goatPastureRecords,
  goatPregnancyChecks,
  goatSaleRecords,
  goatShearingRecords,
  goatVaccinations,
  goatWeightRecords,
} from "../../db/schema";

// SELECT projections (return Flutter field names)

export const animalSelect = {
  id: goatAnimals.id,
  farmId: goatAnimals.farmOwnerId,
  tagNumber: goatAnimals.tagId,
  name: goatAnimals.name,
  breed: goatAnimals.breed,
  productionType: goatAnimals.productionType,
  sex: goatAnimals.sex,
  status: goatAnimals.status,
  herdId: goatAnimals.herdId,
  dateOfBirth: goatAnimals.dateOfBirth,
  color: goatAnimals.color,
  damId: goatAnimals.damId,
  registrationNumber: goatAnimals.registrationNumber,
  currentWeightKg: goatAnimals.currentWeightKg,
  targetWeightKg: goatAnimals.targetWeightKg,
  bodyConditionScore: goatAnimals.bodyConditionScore,
  isPregnant: goatAnimals.isPregnant,
  expectedKiddingDate: goatAnimals.expectedKiddingDate,
  lastKiddingDate: goatAnimals.lastKiddingDate,
  totalKidsRaised: goatAnimals.totalKidsRaised,
  isLactating: goatAnimals.isLactating,
  currentMilkLitrePd: goatAnimals.currentMilkLitrePd,
  lactationNumber: goatAnimals.lactationNumber,
  dryOffDate: goatAnimals.dryOffDate,
  lastShearingDate: goatAnimals.lastShearingDate,
  lastDewormingDate: goatAnimals.lastDewormingDate,
  famachaScore: goatAnimals.famachaScore,
  specificData: goatAnimals.specificData,
  notes: goatAnimals.notes,
  createdAt: goatAnimals.createdAt,
  updatedAt: goatAnimals.updatedAt,
};

export const weightSelect = {
  id: goatWeightRecords.id,
  goatId: goatWeightRecords.goatId,
  weightKg: goatWeightRecords.weightKg,
  recordedAt: goatWeightRecords.recordedAt,
  notes: goatWeightRecords.notes,
  createdAt: goatWeightRecords.createdAt,
};

export const matingSelect = {
  id: goatMatingRecords.id,
  doeId: goatMatingRecords.doeId,
  buckId: goatMatingRecords.buckId,
  matingDate: goatMatingRecords.matingDate,
  method: goatMatingRecords.method,
  notes: goatMatingRecords.notes,
  createdAt: goatMatingRecords.createdAt,
};

export const pregnancyCheckSelect = {
  id: goatPregnancyChecks.id,
  goatId: goatPregnancyChecks.goatId,
  checkDate: goatPregnancyChecks.checkDate,
  result: goatPregnancyChecks.result,
  expectedKiddingDate: goatPregnancyChecks.expectedKiddingDate,
  notes: goatPregnancyChecks.notes,
  createdAt: goatPregnancyChecks.createdAt,
};

export const kiddingSelect = {
  id: goatKiddingEvents.id,
  doeId: goatKiddingEvents.doeId,
  kiddingDate: goatKiddingEvents.kiddingDate,
  kidsAlive: goatKiddingEvents.kidsAlive,
  kidsDead: goatKiddingEvents.kidsDead,
  notes: goatKiddingEvents.notes,
  createdAt: goatKiddingEvents.createdAt,
};

export const milkSelect = {
  id: goatDailyMilk.id,
  goatId: goatDailyMilk.goatId,
  recordDate: goatDailyMilk.recordDate,
  morningLitres: goatDailyMilk.morningLitres,
  eveningLitres: goatDailyMilk.eveningLitres,
  totalLitres: goatDailyMilk.totalLitres,
  createdAt: goatDailyMilk.createdAt,
};

export const shearingSelect = {
  id: goatShearingRecords.id,
  goatId: goatShearingRecords.goatId,
  shearingDate: goatShearingRecords.shearingDate,
  fleeceWeightKg: goatShearingRecords.fleeceWeightKg,
  notes: goatShearingRecords.notes,
  createdAt: goatShearingRecords.createdAt,
};

export const healthSelect = {
  id: goatHealthEvents.id,
  goatId: goatHealthEvents.goatId,
  eventDate: goatHealthEvents.eventDate,
  eventType: goatHealthEvents.eventType,
  diagnosis: goatHealthEvents.diagnosis,
  treatment: goatHealthEvents.treatment,
  outcome: goatHealthEvents.outcome,
  notes: goatHealthEvents.notes,
  createdAt: goatHealthEvents.createdAt,
};

export const medicationSelect = {
  id: goatMedicationLogs.id,
  goatId: goatMedicationLogs.goatId,
  medicationName: goatMedicationLogs.medicationName,
  dosage: goatMedicationLogs.dosage,
  administeredAt: goatMedicationLogs.administeredAt,
  administeredBy: goatMedicationLogs.administeredBy,
  notes: goatMedicationLogs.notes,
  createdAt: goatMedicationLogs.createdAt,
};

export const vaccinationSelect = {
  id: goatVaccinations.id,
  goatId: goatVaccinations.goatId,
  vaccineName: goatVaccinations.vaccineName,
  vaccinationDate: goatVaccinations.vaccinationDate,
  nextDueDate: goatVaccinations.nextDueDate,
  batchNumber: goatVaccinations.batchNumber,
  notes: goatVaccinations.notes,
  createdAt: goatVaccinations.createdAt,
};

export const saleSelect = {
  id: goatSaleRecords.id,
  goatId: goatSaleRecords.goatId,
  saleDate: goatSaleRecords.saleDate,
  buyerName: goatSaleRecords.buyerName,
  salePrice: goatSaleRecords.salePrice,
  notes: goatSaleRecords.notes,
  createdAt: goatSaleRecords.createdAt,
};

export const feedSelect = {
  id: goatFeedRecords.id,
  goatId: goatFeedRecords.goatId,
  feedType: goatFeedRecords.feedType,
  quantityKg: goatFeedRecords.quantityKg,
  feedDate: goatFeedRecords.feedDate,
  notes: goatFeedRecords.notes,
  createdAt: goatFeedRecords.createdAt,
};

export const pastureSelect = {
  id: goatPastureRecords.id,
  pastureId: goatPastureRecords.pastureId,
  pastureName: goatPastureRecords.pastureName,
  moveDate: goatPastureRecords.moveDate,
  notes: goatPastureRecords.notes,
  createdAt: goatPastureRecords.createdAt,
};

export const famachaSelect = {
  id: goatFamachaRecords.id,
  goatId: goatFamachaRecords.goatId,
  score: goatFamachaRecords.score,
  recordDate: goatFamachaRecords.recordDate,
  notes: goatFamachaRecords.notes,
  createdAt: goatFamachaRecords.createdAt,
};

export const bcsSelect = {
  id: goatBcsRecords.id,
  goatId: goatBcsRecords.goatId,
  score: goatBcsRecords.score,
  recordDate: goatBcsRecords.recordDate,
  notes: goatBcsRecords.notes,
  createdAt: goatBcsRecords.createdAt,
};
