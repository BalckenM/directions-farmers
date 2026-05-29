import { Router } from "express";
import { financialController } from "../controllers/financial.controller";
import { authenticate } from "../middleware/auth.middleware";
import { validate } from "../middleware/validate.middleware";
import {
    createTransactionSchema,
    updateTransactionSchema,
} from "../validators/financial.validator";

export const financialRouter = Router();

financialRouter.use(authenticate);

financialRouter.get("/", financialController.list);
financialRouter.post(
  "/",
  validate(createTransactionSchema),
  financialController.create,
);
financialRouter.get("/:id", financialController.get);
financialRouter.put(
  "/:id",
  validate(updateTransactionSchema),
  financialController.update,
);
financialRouter.delete("/:id", financialController.delete);
