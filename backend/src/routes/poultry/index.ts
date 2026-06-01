import { Router } from "express";
import { poultryController } from "../../controllers/poultry/poultry.controller";
import { authenticate } from "../../middleware/auth.middleware";
import { requireModule } from "../../middleware/module-guard.middleware";
import { validate } from "../../middleware/validate.middleware";
import {
    createChickSaleSchema,
    createDailyRecordSchema,
    createDiseaseEventSchema,
    createEggSaleSchema,
    createEnvironmentReadingSchema,
    createFeedPhaseSchema,
    createFlockSchema,
    createHarvestRecordSchema,
    createInventoryItemSchema,
    createMedicationLogSchema,
    createVaccinationScheduleSchema,
    updateFlockSchema,
} from "../../validators/poultry/poultry.validator";

export const poultryRouter = Router();

poultryRouter.use(authenticate, requireModule("poultry"));

// Flocks CRUD
poultryRouter.get("/flocks", poultryController.list);
poultryRouter.post(
  "/flocks",
  validate(createFlockSchema),
  poultryController.create,
);
poultryRouter.get("/flocks/:id", poultryController.get);
poultryRouter.put(
  "/flocks/:id",
  validate(updateFlockSchema),
  poultryController.update,
);
poultryRouter.delete("/flocks/:id", poultryController.delete);

// Daily records
poultryRouter.get("/daily-records", poultryController.listDaily);
poultryRouter.post(
  "/daily-records",
  validate(createDailyRecordSchema),
  poultryController.addDaily,
);

// Vaccination schedules
poultryRouter.get("/vaccination-schedules", poultryController.listVaccinations);
poultryRouter.post(
  "/vaccination-schedules",
  validate(createVaccinationScheduleSchema),
  poultryController.addVaccination,
);

// Feed phases
poultryRouter.get("/feed-phases", poultryController.listFeedPhases);
poultryRouter.post(
  "/feed-phases",
  validate(createFeedPhaseSchema),
  poultryController.addFeedPhase,
);

// Harvest records
poultryRouter.get("/harvest-records", poultryController.listHarvest);
poultryRouter.post(
  "/harvest-records",
  validate(createHarvestRecordSchema),
  poultryController.addHarvest,
);

// Medication logs
poultryRouter.get("/medication-logs", poultryController.listMedicationLogs);
poultryRouter.post(
  "/medication-logs",
  validate(createMedicationLogSchema),
  poultryController.addMedicationLog,
);

// Disease events
poultryRouter.get("/disease-events", poultryController.listDiseaseEvents);
poultryRouter.post(
  "/disease-events",
  validate(createDiseaseEventSchema),
  poultryController.addDiseaseEvent,
);

// Environment readings
poultryRouter.get(
  "/environment-readings",
  poultryController.listEnvironmentReadings,
);
poultryRouter.post(
  "/environment-readings",
  validate(createEnvironmentReadingSchema),
  poultryController.addEnvironmentReading,
);

// Inventory
poultryRouter.get("/inventory-items", poultryController.listInventory);
poultryRouter.post(
  "/inventory-items",
  validate(createInventoryItemSchema),
  poultryController.addInventoryItem,
);

// Egg sales
poultryRouter.get("/egg-sales", poultryController.listEggSales);
poultryRouter.post(
  "/egg-sales",
  validate(createEggSaleSchema),
  poultryController.addEggSale,
);

// Chick sales
poultryRouter.get("/chick-sales", poultryController.listChickSales);
poultryRouter.post(
  "/chick-sales",
  validate(createChickSaleSchema),
  poultryController.addChickSale,
);
