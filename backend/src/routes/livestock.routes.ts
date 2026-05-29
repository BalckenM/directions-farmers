import { Router } from "express";
import { livestockController } from "../controllers/livestock.controller";
import { authenticate } from "../middleware/auth.middleware";
import { validate } from "../middleware/validate.middleware";
import {
  createLivestockGroupSchema,
  updateLivestockGroupSchema,
} from "../validators/livestock.validator";

export const livestockRouter = Router();

livestockRouter.use(authenticate);

livestockRouter.get("/animals", livestockController.getAnimals);
livestockRouter.get("/groups", livestockController.getGroups);
livestockRouter.post(
  "/groups",
  validate(createLivestockGroupSchema),
  livestockController.createGroup,
);
livestockRouter.put(
  "/groups/:id",
  validate(updateLivestockGroupSchema),
  livestockController.updateGroup,
);
livestockRouter.delete("/groups/:id", livestockController.deleteGroup);
