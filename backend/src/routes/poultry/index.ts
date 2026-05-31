import { Router } from "express";
import { poultryController } from "../../controllers/poultry/poultry.controller";
import { authenticate } from "../../middleware/auth.middleware";
import { requireModule } from "../../middleware/module-guard.middleware";
import { validate } from "../../middleware/validate.middleware";
import {
    createDailyRecordSchema,
    createFlockSchema,
    createHarvestRecordSchema,
    createVaccinationScheduleSchema,
    updateFlockSchema,
} from "../../validators/poultry/poultry.validator";

export const poultryRouter = Router();

poultryRouter.use(authenticate, requireModule("poultry"));

poultryRouter.get("/", poultryController.list);
poultryRouter.post("/", validate(createFlockSchema), poultryController.create);
poultryRouter.get("/:id", poultryController.get);
poultryRouter.put(
  "/:id",
  validate(updateFlockSchema),
  poultryController.update,
);
poultryRouter.delete("/:id", poultryController.delete);

poultryRouter.get("/:id/daily-records", poultryController.listDaily);
poultryRouter.post(
  "/:id/daily-records",
  validate(createDailyRecordSchema),
  poultryController.addDaily,
);

poultryRouter.get("/:id/vaccinations", poultryController.listVaccinations);
poultryRouter.post(
  "/:id/vaccinations",
  validate(createVaccinationScheduleSchema),
  poultryController.addVaccination,
);

poultryRouter.get("/:id/harvest-records", poultryController.listHarvest);
poultryRouter.post(
  "/:id/harvest-records",
  validate(createHarvestRecordSchema),
  poultryController.addHarvest,
);
