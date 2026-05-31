import { Router } from "express";
import { goatController } from "../../controllers/goat/goat.controller";
import { authenticate } from "../../middleware/auth.middleware";
import { requireModule } from "../../middleware/module-guard.middleware";
import { validate } from "../../middleware/validate.middleware";
import {
  createBcsRecordSchema,
  createDailyMilkSchema,
  createFamachaRecordSchema,
  createFeedRecordSchema,
  createGoatSchema,
  createHealthEventSchema,
  createKiddingEventSchema,
  createMatingSchema,
  createMedicationLogSchema,
  createPastureRecordSchema,
  createPregnancyCheckSchema,
  createSaleRecordSchema,
  createShearingRecordSchema,
  createVaccinationSchema,
  createWeightRecordSchema,
  exitPastureSchema,
  markVaccinationGivenSchema,
  updateGoatSchema,
  updateHealthEventSchema,
  updateMatingSchema,
  updateSaleRecordSchema,
} from "../../validators/goat/goat.validator";

export const goatRouter = Router();

goatRouter.use(authenticate, requireModule("goat"));

// ── Weight Records (flat — must be before /:id) ───────────────────────────
goatRouter.get("/weights", goatController.listWeights);
goatRouter.post(
  "/weights",
  validate(createWeightRecordSchema),
  goatController.createWeight,
);
goatRouter.delete("/weights/:id", goatController.deleteWeight);

// ── Mating Records ────────────────────────────────────────────────────────
goatRouter.get("/matings", goatController.listMatings);
goatRouter.post(
  "/matings",
  validate(createMatingSchema),
  goatController.createMating,
);
goatRouter.put(
  "/matings/:id",
  validate(updateMatingSchema),
  goatController.updateMating,
);

// ── Pregnancy Checks ──────────────────────────────────────────────────────
goatRouter.get("/pregnancy-checks", goatController.listPregnancyChecks);
goatRouter.post(
  "/pregnancy-checks",
  validate(createPregnancyCheckSchema),
  goatController.createPregnancyCheck,
);

// ── Kidding Events ────────────────────────────────────────────────────────
goatRouter.get("/kidding", goatController.listKidding);
goatRouter.post(
  "/kidding",
  validate(createKiddingEventSchema),
  goatController.createKidding,
);

// ── Daily Milk ────────────────────────────────────────────────────────────
goatRouter.get("/milk", goatController.listMilk);
goatRouter.post(
  "/milk",
  validate(createDailyMilkSchema),
  goatController.createMilk,
);
goatRouter.delete("/milk/:id", goatController.deleteMilk);

// ── Shearing Records ──────────────────────────────────────────────────────
goatRouter.get("/shearing", goatController.listShearing);
goatRouter.post(
  "/shearing",
  validate(createShearingRecordSchema),
  goatController.createShearing,
);

// ── Health Events ─────────────────────────────────────────────────────────
goatRouter.get("/health", goatController.listHealth);
goatRouter.post(
  "/health",
  validate(createHealthEventSchema),
  goatController.createHealth,
);
goatRouter.put(
  "/health/:id",
  validate(updateHealthEventSchema),
  goatController.updateHealth,
);

// ── Medication Logs ───────────────────────────────────────────────────────
goatRouter.get("/medications", goatController.listMedications);
goatRouter.post(
  "/medications",
  validate(createMedicationLogSchema),
  goatController.createMedication,
);

// ── Vaccinations ──────────────────────────────────────────────────────────
goatRouter.get("/vaccinations", goatController.listVaccinations);
goatRouter.post(
  "/vaccinations",
  validate(createVaccinationSchema),
  goatController.createVaccination,
);
goatRouter.patch(
  "/vaccinations/:id/given",
  validate(markVaccinationGivenSchema),
  goatController.markVaccinationGiven,
);

// ── Sale Records ──────────────────────────────────────────────────────────
goatRouter.get("/sales", goatController.listSales);
goatRouter.post(
  "/sales",
  validate(createSaleRecordSchema),
  goatController.createSale,
);
goatRouter.put(
  "/sales/:id",
  validate(updateSaleRecordSchema),
  goatController.updateSale,
);
goatRouter.delete("/sales/:id", goatController.deleteSale);

// ── Feed Records ──────────────────────────────────────────────────────────
goatRouter.get("/feed", goatController.listFeed);
goatRouter.post(
  "/feed",
  validate(createFeedRecordSchema),
  goatController.createFeed,
);
goatRouter.delete("/feed/:id", goatController.deleteFeed);

// ── Pasture Records ───────────────────────────────────────────────────────
goatRouter.get("/pasture", goatController.listPasture);
goatRouter.post(
  "/pasture",
  validate(createPastureRecordSchema),
  goatController.createPasture,
);
goatRouter.patch(
  "/pasture/:id/exit",
  validate(exitPastureSchema),
  goatController.exitPasture,
);

// ── FAMACHA Records ───────────────────────────────────────────────────────
goatRouter.get("/famacha", goatController.listFamacha);
goatRouter.post(
  "/famacha",
  validate(createFamachaRecordSchema),
  goatController.createFamacha,
);

// ── BCS Records ───────────────────────────────────────────────────────────
goatRouter.get("/bcs", goatController.listBcs);
goatRouter.post(
  "/bcs",
  validate(createBcsRecordSchema),
  goatController.createBcs,
);

// ── Animal CRUD (parameterized — MUST be registered last) ─────────────────
goatRouter.get("/", goatController.list);
goatRouter.post("/", validate(createGoatSchema), goatController.create);
goatRouter.get("/:id", goatController.get);
goatRouter.put("/:id", validate(updateGoatSchema), goatController.update);
goatRouter.delete("/:id", goatController.delete);
