import { Router } from "express";
import { farmController } from "../controllers/farm.controller";
import { authenticate } from "../middleware/auth.middleware";
import { validate } from "../middleware/validate.middleware";
import {
  inviteStaffSchema,
  updateStaffSchema,
} from "../validators/farm.validator";

export const farmRouter = Router();

farmRouter.use(authenticate);

// GET /v1/farm/team — list all staff for the authenticated farm owner
farmRouter.get("/team", farmController.getTeam);

// POST   /v1/farm/staff       — invite a new staff member
// PUT    /v1/farm/staff/:id   — update an existing staff member
// DELETE /v1/farm/staff/:id   — deactivate a staff member
farmRouter.post("/staff", validate(inviteStaffSchema), farmController.inviteStaff);
farmRouter.put("/staff/:id", validate(updateStaffSchema), farmController.updateStaff);
farmRouter.delete("/staff/:id", farmController.deactivateStaff);
