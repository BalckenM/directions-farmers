import { Router } from "express";
import { cropController } from "../../controllers/crop/crop.controller";
import { authenticate } from "../../middleware/auth.middleware";
import { requireModule } from "../../middleware/module-guard.middleware";
import { validate } from "../../middleware/validate.middleware";
import {
    createCalendarEventSchema,
    createExpenseSchema,
    createFieldSchema,
    createHarvestRecordSchema,
    createPestObservationSchema,
    createPlantingPlanSchema,
    createSaleSchema,
    createSeasonSchema,
    createSprayRecordSchema,
    createTaskSchema,
    updateCalendarEventSchema,
    updateExpenseSchema,
    updateFieldSchema,
    updateHarvestRecordSchema,
    updatePestObservationSchema,
    updatePlantingPlanSchema,
    updateSaleSchema,
    updateSeasonSchema,
    updateSprayRecordSchema,
    updateTaskSchema,
} from "../../validators/crop/crop.validator";

export const cropRouter = Router();

cropRouter.use(authenticate, requireModule("crop"));

// Categories & Crops (read-only reference data)
cropRouter.get("/categories", cropController.listCategories);
cropRouter.get("/crops", cropController.listCrops);

// Fields CRUD
cropRouter.get("/fields", cropController.listFields);
cropRouter.post(
  "/fields",
  validate(createFieldSchema),
  cropController.createField,
);
cropRouter.get("/fields/:id", cropController.getField);
cropRouter.put(
  "/fields/:id",
  validate(updateFieldSchema),
  cropController.updateField,
);
cropRouter.delete("/fields/:id", cropController.deleteField);

// Seasons CRUD
cropRouter.get("/seasons", cropController.listSeasons);
cropRouter.post(
  "/seasons",
  validate(createSeasonSchema),
  cropController.createSeason,
);
cropRouter.put(
  "/seasons/:id",
  validate(updateSeasonSchema),
  cropController.updateSeason,
);
cropRouter.delete("/seasons/:id", cropController.deleteSeason);

// Planting plans CRUD
cropRouter.get("/planting-plans", cropController.listPlans);
cropRouter.post(
  "/planting-plans",
  validate(createPlantingPlanSchema),
  cropController.createPlan,
);
cropRouter.get("/planting-plans/:id", cropController.getPlan);
cropRouter.put(
  "/planting-plans/:id",
  validate(updatePlantingPlanSchema),
  cropController.updatePlan,
);
cropRouter.delete("/planting-plans/:id", cropController.deletePlan);

// Tasks CRUD
cropRouter.get("/tasks", cropController.listTasks);
cropRouter.post(
  "/tasks",
  validate(createTaskSchema),
  cropController.createTask,
);
cropRouter.put(
  "/tasks/:id",
  validate(updateTaskSchema),
  cropController.updateTask,
);
cropRouter.delete("/tasks/:id", cropController.deleteTask);

// Pest observations CRUD
cropRouter.get("/pest-observations", cropController.listPestObservations);
cropRouter.post(
  "/pest-observations",
  validate(createPestObservationSchema),
  cropController.createPestObservation,
);
cropRouter.put(
  "/pest-observations/:id",
  validate(updatePestObservationSchema),
  cropController.updatePestObservation,
);
cropRouter.delete("/pest-observations/:id", cropController.deletePestObservation);

// Spray records CRUD
cropRouter.get("/spray-records", cropController.listSprayRecords);
cropRouter.post(
  "/spray-records",
  validate(createSprayRecordSchema),
  cropController.addSprayRecord,
);
cropRouter.put(
  "/spray-records/:id",
  validate(updateSprayRecordSchema),
  cropController.updateSprayRecord,
);
cropRouter.delete("/spray-records/:id", cropController.deleteSprayRecord);

// Expenses CRUD
cropRouter.get("/expenses", cropController.listExpenses);
cropRouter.post(
  "/expenses",
  validate(createExpenseSchema),
  cropController.createExpense,
);
cropRouter.put(
  "/expenses/:id",
  validate(updateExpenseSchema),
  cropController.updateExpense,
);
cropRouter.delete("/expenses/:id", cropController.deleteExpense);

// Harvest records CRUD
cropRouter.get("/harvest-records", cropController.listHarvest);
cropRouter.post(
  "/harvest-records",
  validate(createHarvestRecordSchema),
  cropController.addHarvest,
);
cropRouter.put(
  "/harvest-records/:id",
  validate(updateHarvestRecordSchema),
  cropController.updateHarvest,
);
cropRouter.delete("/harvest-records/:id", cropController.deleteHarvest);

// Calendar events CRUD
cropRouter.get("/calendar-events", cropController.listCalendarEvents);
cropRouter.post(
  "/calendar-events",
  validate(createCalendarEventSchema),
  cropController.createCalendarEvent,
);
cropRouter.put(
  "/calendar-events/:id",
  validate(updateCalendarEventSchema),
  cropController.updateCalendarEvent,
);
cropRouter.delete("/calendar-events/:id", cropController.deleteCalendarEvent);

// Sales CRUD
cropRouter.get("/sales", cropController.listSales);
cropRouter.post(
  "/sales",
  validate(createSaleSchema),
  cropController.createSale,
);
cropRouter.put(
  "/sales/:id",
  validate(updateSaleSchema),
  cropController.updateSale,
);
cropRouter.delete("/sales/:id", cropController.deleteSale);

// Advisory content (read-only)
cropRouter.get("/advisory-content", cropController.listAdvisoryContent);
