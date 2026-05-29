import { and, count, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
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
  tagNumber: goatAnimals.tagNumber,
  name: goatAnimals.name,
  breed: goatAnimals.breed,
  productionType: goatAnimals.productionType,
  sex: goatAnimals.sex,
  status: goatAnimals.status,
  herdId: goatAnimals.herdId,
  dateOfBirth: goatAnimals.dateOfBirth,
  damId: goatAnimals.damId,
  sireId: goatAnimals.sireId,
  registrationNumber: goatAnimals.registrationNumber,
  purchaseDate: goatAnimals.purchaseDate,
  purchasePrice: goatAnimals.purchasePrice,
  isPregnant: goatAnimals.isPregnant,
  isLactating: goatAnimals.isLactating,
  notes: goatAnimals.notes,
  createdAt: goatAnimals.createdAt,
  updatedAt: goatAnimals.updatedAt,
};

export const weightSelect = {
  id: goatWeightRecords.id,
  animalId: goatWeightRecords.animalId,
  date: goatWeightRecords.date,
  weightKg: goatWeightRecords.weightKg,
  bodyConditionScore: goatWeightRecords.bodyConditionScore,
  notes: goatWeightRecords.notes,
};

export const matingSelect = {
  id: goatMatingRecords.id,
  doeId: goatMatingRecords.doeId,
  buckId: goatMatingRecords.buckId,
  serviceDate: goatMatingRecords.serviceDate,
  serviceMethod: goatMatingRecords.serviceMethod,
  expectedKiddingDate: goatMatingRecords.expectedKiddingDate,
  outcome: goatMatingRecords.outcome,
  notes: goatMatingRecords.notes,
};

export const pregnancyCheckSelect = {
  id: goatPregnancyChecks.id,
  animalId: goatPregnancyChecks.animalId,
  date: goatPregnancyChecks.date,
  method: goatPregnancyChecks.method,
  result: goatPregnancyChecks.result,
  expectedKiddingDate: goatPregnancyChecks.expectedKiddingDate,
  daysPregnant: goatPregnancyChecks.daysPregnant,
  notes: goatPregnancyChecks.notes,
};

export const kiddingSelect = {
  id: goatKiddingEvents.id,
  damId: goatKiddingEvents.damId,
  kiddingDate: goatKiddingEvents.kiddingDate,
  totalKidsBorn: goatKiddingEvents.totalKidsBorn,
  kidsAliveBorn: goatKiddingEvents.kidsAliveBorn,
  kidsStillborn: goatKiddingEvents.kidsStillborn,
  birthWeights: goatKiddingEvents.birthWeights,
  kidIds: goatKiddingEvents.kidIds,
  assisted: goatKiddingEvents.assisted,
  complications: goatKiddingEvents.complications,
  notes: goatKiddingEvents.notes,
};

export const milkSelect = {
  id: goatDailyMilk.id,
  animalId: goatDailyMilk.animalId,
  date: goatDailyMilk.date,
  morningLitres: goatDailyMilk.morningLitres,
  eveningLitres: goatDailyMilk.eveningLitres,
  lactationDay: goatDailyMilk.lactationDay,
  notes: goatDailyMilk.notes,
};

export const shearingSelect = {
  id: goatShearingRecords.id,
  animalId: goatShearingRecords.animalId,
  shearingDate: goatShearingRecords.shearingDate,
  fleeceWeightKg: goatShearingRecords.fleeceWeightKg,
  stapleLength: goatShearingRecords.stapleLength,
  micron: goatShearingRecords.micron,
  colorGrade: goatShearingRecords.colorGrade,
  pricePerKg: goatShearingRecords.pricePerKg,
  notes: goatShearingRecords.notes,
};

export const healthSelect = {
  id: goatHealthEvents.id,
  animalId: goatHealthEvents.animalId,
  date: goatHealthEvents.date,
  condition: goatHealthEvents.condition,
  severity: goatHealthEvents.severity,
  treatment: goatHealthEvents.treatment,
  vet: goatHealthEvents.vet,
  outcome: goatHealthEvents.outcome,
  notes: goatHealthEvents.notes,
};

export const medicationSelect = {
  id: goatMedicationLogs.id,
  animalId: goatMedicationLogs.animalId,
  date: goatMedicationLogs.date,
  drug: goatMedicationLogs.drug,
  dose: goatMedicationLogs.dose,
  route: goatMedicationLogs.route,
  reason: goatMedicationLogs.reason,
  withdrawalDays: goatMedicationLogs.withdrawalDays,
  administeredBy: goatMedicationLogs.administeredBy,
  notes: goatMedicationLogs.notes,
};

export const vaccinationSelect = {
  id: goatVaccinations.id,
  animalId: goatVaccinations.animalId,
  vaccineName: goatVaccinations.vaccineName,
  dueDate: goatVaccinations.dueDate,
  givenDate: goatVaccinations.givenDate,
  batchNumber: goatVaccinations.batchNumber,
  nextDueDate: goatVaccinations.nextDueDate,
  administeredBy: goatVaccinations.administeredBy,
};

export const saleSelect = {
  id: goatSaleRecords.id,
  animalId: goatSaleRecords.animalId,
  saleDate: goatSaleRecords.saleDate,
  buyerName: goatSaleRecords.buyerName,
  saleWeightKg: goatSaleRecords.saleWeightKg,
  pricePerKg: goatSaleRecords.pricePerKg,
  totalRevenue: goatSaleRecords.totalRevenue,
  invoiceRef: goatSaleRecords.invoiceRef,
  notes: goatSaleRecords.notes,
};

export const feedSelect = {
  id: goatFeedRecords.id,
  herdId: goatFeedRecords.herdId,
  date: goatFeedRecords.date,
  feedType: goatFeedRecords.feedType,
  quantityKg: goatFeedRecords.quantityKg,
  costPerKg: goatFeedRecords.costPerKg,
  notes: goatFeedRecords.notes,
};

export const pastureSelect = {
  id: goatPastureRecords.id,
  herdId: goatPastureRecords.herdId,
  campId: goatPastureRecords.campId,
  entryDate: goatPastureRecords.entryDate,
  exitDate: goatPastureRecords.exitDate,
  estimatedHa: goatPastureRecords.estimatedHa,
  veldCondition: goatPastureRecords.veldCondition,
  notes: goatPastureRecords.notes,
};

export const famachaSelect = {
  id: goatFamachaRecords.id,
  animalId: goatFamachaRecords.animalId,
  date: goatFamachaRecords.date,
  score: goatFamachaRecords.score,
  actionTaken: goatFamachaRecords.actionTaken,
  notes: goatFamachaRecords.notes,
};

export const bcsSelect = {
  id: goatBcsRecords.id,
  animalId: goatBcsRecords.animalId,
  date: goatBcsRecords.date,
  score: goatBcsRecords.score,
  notes: goatBcsRecords.notes,
};
