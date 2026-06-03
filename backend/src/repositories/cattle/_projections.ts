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

export const animalSelect = {
  id: cattleAnimals.id,
  farmOwnerId: cattleAnimals.farmOwnerId,
  tagNumber: cattleAnimals.tagNumber,
  name: cattleAnimals.name,
  breed: cattleAnimals.breed,
  sex: cattleAnimals.sex,
  dateOfBirth: cattleAnimals.dateOfBirth,
  color: cattleAnimals.color,
  status: cattleAnimals.status,
  productionType: cattleAnimals.productionType,
  herdId: cattleAnimals.herdId,
  sireId: cattleAnimals.sireId,
  damId: cattleAnimals.damId,
  isPregnant: cattleAnimals.isPregnant,
  isLactating: cattleAnimals.isLactating,
  purchaseDate: cattleAnimals.purchaseDate,
  purchasePrice: cattleAnimals.purchasePrice,
  notes: cattleAnimals.notes,
  createdAt: cattleAnimals.createdAt,
  updatedAt: cattleAnimals.updatedAt,
};

export const weightSelect = {
  id: cattleWeightRecords.id,
  animalId: cattleWeightRecords.animalId,
  weightKg: cattleWeightRecords.weightKg,
  date: cattleWeightRecords.date,
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
  status: cattlePregnancyChecks.status,
  method: cattlePregnancyChecks.method,
  dayspregnant: cattlePregnancyChecks.dayspregnant,
  checkedBy: cattlePregnancyChecks.checkedBy,
  expectedCalvingDate: cattlePregnancyChecks.expectedCalvingDate,
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
  calvesAlive: cattleCalvingEvents.calvesAlive,
  calvesDead: cattleCalvingEvents.calvesDead,
  notes: cattleCalvingEvents.notes,
};

export const milkSelect = {
  id: cattleDailyMilk.id,
  animalId: cattleDailyMilk.animalId,
  date: cattleDailyMilk.date,
  morningLitres: cattleDailyMilk.morningLitres,
  eveningLitres: cattleDailyMilk.eveningLitres,
  totalLitres: cattleDailyMilk.totalLitres,
  lactationDay: cattleDailyMilk.lactationDay,
  qualityFlag: cattleDailyMilk.qualityFlag,
};

export const healthSelect = {
  id: cattleHealthEvents.id,
  animalId: cattleHealthEvents.animalId,
  date: cattleHealthEvents.date,
  eventType: cattleHealthEvents.eventType,
  diagnosis: cattleHealthEvents.diagnosis,
  treatment: cattleHealthEvents.treatment,
  severity: cattleHealthEvents.severity,
  treatedBy: cattleHealthEvents.treatedBy,
  isNotifiable: cattleHealthEvents.isNotifiable,
  outcome: cattleHealthEvents.outcome,
  notes: cattleHealthEvents.notes,
};

export const medicationSelect = {
  id: cattleMedicationLogs.id,
  animalId: cattleMedicationLogs.animalId,
  medicationName: cattleMedicationLogs.medicationName,
  doseMg: cattleMedicationLogs.doseMg,
  date: cattleMedicationLogs.date,
  route: cattleMedicationLogs.route,
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
  route: cattleVaccinations.route,
  siteOnBody: cattleVaccinations.siteOnBody,
  administeredBy: cattleVaccinations.administeredBy,
  nextDueDate: cattleVaccinations.nextDueDate,
  batchNumber: cattleVaccinations.batchNumber,
  notes: cattleVaccinations.notes,
};

export const saleSelect = {
  id: cattleSaleRecords.id,
  animalId: cattleSaleRecords.animalId,
  saleDate: cattleSaleRecords.saleDate,
  buyerName: cattleSaleRecords.buyerName,
  totalAmount: cattleSaleRecords.totalAmount,
  saleWeightKg: cattleSaleRecords.saleWeightKg,
  pricePerKg: cattleSaleRecords.pricePerKg,
  transportCost: cattleSaleRecords.transportCost,
  permitNumber: cattleSaleRecords.permitNumber,
  invoiceRef: cattleSaleRecords.invoiceRef,
  notes: cattleSaleRecords.notes,
};

export const feedSelect = {
  id: cattleFeedRecords.id,
  animalId: cattleFeedRecords.animalId,
  feedType: cattleFeedRecords.feedType,
  quantityKg: cattleFeedRecords.quantityKg,
  date: cattleFeedRecords.date,
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
  score: cattleBcsRecords.score,
  date: cattleBcsRecords.date,
  assessedBy: cattleBcsRecords.assessedBy,
  notes: cattleBcsRecords.notes,
};

export const dippingSelect = {
  id: cattleDippingRecords.id,
  animalId: cattleDippingRecords.animalId,
  dippingDate: cattleDippingRecords.dippingDate,
  productUsed: cattleDippingRecords.productUsed,
  method: cattleDippingRecords.method,
  concentration: cattleDippingRecords.concentration,
  nextDueDays: cattleDippingRecords.nextDueDays,
  veterinarianApproved: cattleDippingRecords.veterinarianApproved,
  notes: cattleDippingRecords.notes,
};