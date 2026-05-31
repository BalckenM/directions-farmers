import { Router } from "express";
import { cropController } from "../../controllers/crop/crop.controller";
import { authenticate } from "../../middleware/auth.middleware";
import { requireModule } from "../../middleware/module-guard.middleware";
import { validate } from "../../middleware/validate.middleware";
import {
  createFieldSchema,
  createHarvestRecordSchema,
  createPlantingPlanSchema,
  createSprayRecordSchema,
  createTaskSchema,
  updateFieldSchema,
  updatePlantingPlanSchema,
} from "../../validators/crop/crop.validator";

export const cropRouter = Router();

cropRouter.use(authenticate, requireModule("crop"));

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

cropRouter.get("/fields/:id/harvest-records", cropController.listHarvest);
cropRouter.post(
  "/fields/:id/harvest-records",
  validate(createHarvestRecordSchema),
  cropController.addHarvest,
);

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

cropRouter.get("/tasks", cropController.listTasks);
cropRouter.post(
  "/tasks",
  validate(createTaskSchema),
  cropController.createTask,
);

cropRouter.get("/spray-records", cropController.listSprayRecords);
cropRouter.post(
  "/spray-records",
  validate(createSprayRecordSchema),
  cropController.addSprayRecord,
);
