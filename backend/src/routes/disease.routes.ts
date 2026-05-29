import { Router } from "express";
import { diseaseController } from "../controllers/disease.controller";
import { authenticate } from "../middleware/auth.middleware";

export const diseaseRouter = Router();

diseaseRouter.use(authenticate);

diseaseRouter.get("/library", diseaseController.getLibrary);
diseaseRouter.post("/detect", diseaseController.detect);
