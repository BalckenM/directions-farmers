import { Router } from "express";
import { cattleController } from "../controllers/cattle/cattle.controller";
import { authenticate } from "../middleware/auth.middleware";
import { requireModule } from "../middleware/module-guard.middleware";
import { validate } from "../middleware/validate.middleware";
import {
  createBcsRecordSchema,
  createBreedingRecordSchema,
  createCalvingEventSchema,
  createCattleSchema,
  createDailyMilkSchema,
  createDippingRecordSchema,
  createFeedRecordSchema,
  createHealthEventSchema,
  createMedicationLogSchema,
  createPastureRecordSchema,
  createPregnancyCheckSchema,
  createSaleRecordSchema,
  createVaccinationSchema,
  createWeightRecordSchema,
  exitPastureSchema,
  markVaccinationGivenSchema,
  updateBreedingRecordSchema,
  updateCattleSchema,
  updateHealthEventSchema,
  updateSaleRecordSchema,
} from "../validators/cattle.validator";

export const cattleRouter = Router();

cattleRouter.use(authenticate, requireModule("cattle"));

// ── Animals ─────────────────────────────────────────────────────────────────
cattleRouter.get("/", cattleController.list);
cattleRouter.post("/", validate(createCattleSchema), cattleController.create);

// ── Sub-resources (MUST be before /:id) ─────────────────────────────────────

cattleRouter.get("/weights", cattleController.listWeights);
cattleRouter.post("/weights", validate(createWeightRecordSchema), cattleController.addWeight);
cattleRouter.delete("/weights/:id", cattleController.deleteWeight);

cattleRouter.get("/breeding-records", cattleController.listBreeding);
cattleRouter.post("/breeding-records", validate(createBreedingRecordSchema), cattleController.addBreeding);
cattleRouter.put("/breeding-records/:id", validate(updateBreedingRecordSchema), cattleController.updateBreeding);

cattleRouter.get("/pregnancy-checks", cattleController.listPregnancyChecks);
cattleRouter.post("/pregnancy-checks", validate(createPregnancyCheckSchema), cattleController.addPregnancyCheck);

cattleRouter.get("/calving-events", cattleController.listCalvingEvents);
cattleRouter.post("/calving-events", validate(createCalvingEventSchema), cattleController.addCalvingEvent);

cattleRouter.get("/milk", cattleController.listMilk);
cattleRouter.post("/milk", validate(createDailyMilkSchema), cattleController.addMilk);
cattleRouter.delete("/milk/:id", cattleController.deleteMilk);

cattleRouter.get("/health", cattleController.listHealth);
cattleRouter.post("/health", validate(createHealthEventSchema), cattleController.addHealth);
cattleRouter.put("/health/:id", validate(updateHealthEventSchema), cattleController.updateHealth);

cattleRouter.get("/medications", cattleController.listMedications);
cattleRouter.post("/medications", validate(createMedicationLogSchema), cattleController.addMedication);

cattleRouter.get("/vaccinations", cattleController.listVaccinations);
cattleRouter.post("/vaccinations", validate(createVaccinationSchema), cattleController.addVaccination);
cattleRouter.patch("/vaccinations/:id/given", validate(markVaccinationGivenSchema), cattleController.markVaccinationGiven);

cattleRouter.get("/sales", cattleController.listSales);
cattleRouter.post("/sales", validate(createSaleRecordSchema), cattleController.addSale);
cattleRouter.put("/sales/:id", validate(updateSaleRecordSchema), cattleController.updateSale);
cattleRouter.delete("/sales/:id", cattleController.deleteSale);

cattleRouter.get("/feed", cattleController.listFeed);
cattleRouter.post("/feed", validate(createFeedRecordSchema), cattleController.addFeed);
cattleRouter.delete("/feed/:id", cattleController.deleteFeed);

cattleRouter.get("/pasture", cattleController.listPasture);
cattleRouter.post("/pasture", validate(createPastureRecordSchema), cattleController.addPasture);
cattleRouter.patch("/pasture/:id/exit", validate(exitPastureSchema), cattleController.exitPasture);

cattleRouter.get("/bcs", cattleController.listBcs);
cattleRouter.post("/bcs", validate(createBcsRecordSchema), cattleController.addBcs);

cattleRouter.get("/dipping", cattleController.listDipping);
cattleRouter.post("/dipping", validate(createDippingRecordSchema), cattleController.addDipping);

// ── Single animal (AFTER all sub-resources) ──────────────────────────────────
cattleRouter.get("/:id", cattleController.get);
cattleRouter.put("/:id", validate(updateCattleSchema), cattleController.update);
cattleRouter.delete("/:id", cattleController.delete);
