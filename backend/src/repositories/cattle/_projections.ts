import { and, desc, eq } from "drizzle-orm";
import { db } from "../../config/database";
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

// SELECT projections (return Flutter field names)

export const animalSelect = {
  id: cattleAnimals.id,
  farmId: cattleAnimals.farmOwnerId,
  tagNumber: cattleAnimals.tagNumber,
  name: cattleAnimals.name,
  breed: cattleAnimals.breed,
  productionType: cattleAnimals.productionType,
  sex: cattleAnimals.sex,
  status: cattleAnimals.status,
  herdId: cattleAnimals.herdId,
  dateOfBirth: cattleAnimals.dateOfBirth,
  isPregnant: cattleAnimals.isPregnant,
  isLactating: cattleAnimals.isLactating,
  notes: cattleAnimals.notes,
  createdAt: cattleAnimals.createdAt,
  updatedAt: cattleAnimals.updatedAt,
};

export const weightSelect = {
  id: cattleWeightRecords.id,
  animalId: cattleWeightRecords.animalId,
  date: cattleWeightRecords.date,
  weightKg: cattleWeightRecords.weightKg,
  bodyConditionScore: cattleWeightRecords.bodyConditionScore,
  notes: cattleWeightRecords.notes,
};

export const breedingSelect = {
  id: cattleBreedingRecords.id,
  cowId: cattleBreedingRecords.cowId,
  bullId: cattleBreedingRecords.bullId,
  serviceDate: cattleBreedingRecords.serviceDate,
  serviceMethod: cattleBreedingRecords.serviceMethod,
  semenSource: cattleBreedingRecords.semenSource,
  technician: cattleBreedingRecords.technician,
  expectedCalvingDate: cattleBreedingRecords.expectedCalvingDate,
  outcome: cattleBreedingRecords.outcome,
  notes: cattleBreedingRecords.notes,
};

export const pregnancyCheckSelect = {
  id: cattlePregnancyChecks.id,
  animalId: cattlePregnancyChecks.animalId,
  date: cattlePregnancyChecks.date,
  method: cattlePregnancyChecks.method,
  result: cattlePregnancyChecks.result,
  expectedCalvingDate: cattlePregnancyChecks.expectedCalvingDate,
  daysPregnant: cattlePregnancyChecks.daysPregnant,
  checkedBy: cattlePregnancyChecks.checkedBy,
  notes: cattlePregnancyChecks.notes,
};

export const calvingSelect = {
  id: cattleCalvingEvents.id,
  damId: cattleCalvingEvents.damId,
  calvingDate: cattleCalvingEvents.calvingDate,
  calvingEase: cattleCalvingEvents.calvingEase,
  calfAlive: cattleCalvingEvents.calfAlive,
  calfId: cattleCalvingEvents.calfId,
  calfSex: cattleCalvingEvents.calfSex,
  calfWeightKg: cattleCalvingEvents.calfWeightKg,
  complications: cattleCalvingEvents.complications,
  notes: cattleCalvingEvents.notes,
};

export const milkSelect = {
  id: cattleDailyMilk.id,
  animalId: cattleDailyMilk.animalId,
  date: cattleDailyMilk.date,
  morningLitres: cattleDailyMilk.morningLitres,
  eveningLitres: cattleDailyMilk.eveningLitres,
  lactationDay: cattleDailyMilk.lactationDay,
  qualityFlag: cattleDailyMilk.qualityFlag,
  notes: cattleDailyMilk.notes,
};

export const healthSelect = {
  id: cattleHealthEvents.id,
  animalId: cattleHealthEvents.animalId,
  date: cattleHealthEvents.date,
  eventType: cattleHealthEvents.eventType,
  diagnosis: cattleHealthEvents.diagnosis,
  severity: cattleHealthEvents.severity,
  treatedBy: cattleHealthEvents.treatedBy,
  isNotifiable: cattleHealthEvents.isNotifiable,
  outcome: cattleHealthEvents.outcome,
  notes: cattleHealthEvents.notes,
};

export const medicationSelect = {
  id: cattleMedicationLogs.id,
  animalId: cattleMedicationLogs.animalId,
  date: cattleMedicationLogs.date,
  medicationName: cattleMedicationLogs.medicationName,
  route: cattleMedicationLogs.route,
  doseMg: cattleMedicationLogs.doseMg,
  withdrawalDaysMeat: cattleMedicationLogs.withdrawalDaysMeat,
  withdrawalDaysMilk: cattleMedicationLogs.withdrawalDaysMilk,
  veterinarianApproved: cattleMedicationLogs.veterinarianApproved,
  administeredBy: cattleMedicationLogs.administeredBy,
  notes: cattleMedicationLogs.notes,
};

export const vaccinationSelect = {
  id: cattleVaccinations.id,
  animalId: cattleVaccinations.animalId,
  vaccineName: cattleVaccinations.vaccineName,
  dueDate: cattleVaccinations.dueDate,
  givenDate: cattleVaccinations.givenDate,
  batchNumber: cattleVaccinations.batchNumber,
  nextDueDate: cattleVaccinations.nextDueDate,
  route: cattleVaccinations.route,
  siteOnBody: cattleVaccinations.siteOnBody,
  administeredBy: cattleVaccinations.administeredBy,
};

export const saleSelect = {
  id: cattleSaleRecords.id,
  animalId: cattleSaleRecords.animalId,
  saleDate: cattleSaleRecords.saleDate,
  buyerName: cattleSaleRecords.buyerName,
  saleWeightKg: cattleSaleRecords.saleWeightKg,
  pricePerKg: cattleSaleRecords.pricePerKg,
  totalAmount: cattleSaleRecords.totalAmount,
  transportCost: cattleSaleRecords.transportCost,
  permitNumber: cattleSaleRecords.permitNumber,
  invoiceRef: cattleSaleRecords.invoiceRef,
  notes: cattleSaleRecords.notes,
};

export const feedSelect = {
  id: cattleFeedRecords.id,
  animalId: cattleFeedRecords.animalId,
  date: cattleFeedRecords.date,
  feedType: cattleFeedRecords.feedType,
  quantityKg: cattleFeedRecords.quantityKg,
  costPerKg: cattleFeedRecords.costPerKg,
  feedlotPenId: cattleFeedRecords.feedlotPenId,
  rationName: cattleFeedRecords.rationName,
  notes: cattleFeedRecords.notes,
};

export const pastureSelect = {
  id: cattlePastureRecords.id,
  herdId: cattlePastureRecords.herdId,
  campId: cattlePastureRecords.campId,
  entryDate: cattlePastureRecords.entryDate,
  exitDate: cattlePastureRecords.exitDate,
  estimatedHa: cattlePastureRecords.estimatedHa,
  veldCondition: cattlePastureRecords.veldCondition,
  notes: cattlePastureRecords.notes,
};

export const bcsSelect = {
  id: cattleBcsRecords.id,
  animalId: cattleBcsRecords.animalId,
  date: cattleBcsRecords.date,
  score: cattleBcsRecords.score,
  assessedBy: cattleBcsRecords.assessedBy,
  notes: cattleBcsRecords.notes,
};

export const dippingSelect = {
  id: cattleDippingRecords.id,
  animalId: cattleDippingRecords.animalId,
  dippingDate: cattleDippingRecords.dippingDate,
  productUsed: cattleDippingRecords.productUsed,
  concentration: cattleDippingRecords.concentration,
  method: cattleDippingRecords.method,
  nextDueDays: cattleDippingRecords.nextDueDays,
  veterinarianApproved: cattleDippingRecords.veterinarianApproved,
  notes: cattleDippingRecords.notes,
};
