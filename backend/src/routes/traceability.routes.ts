import { Router } from "express";
import { traceabilityController } from "../controllers/traceability.controller";
import { authenticate } from "../middleware/auth.middleware";
import { validate } from "../middleware/validate.middleware";
import { addMovementSchema } from "../validators/traceability.validator";

export const traceabilityRouter = Router();

traceabilityRouter.use(authenticate);

traceabilityRouter.get("/movements", traceabilityController.listMovements);
traceabilityRouter.post(
  "/movements",
  validate(addMovementSchema),
  traceabilityController.addMovement,
);
