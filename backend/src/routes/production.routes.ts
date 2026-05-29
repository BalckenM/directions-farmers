import { Router } from "express";
import { productionController } from "../controllers/production.controller";
import { authenticate } from "../middleware/auth.middleware";
import { validate } from "../middleware/validate.middleware";
import {
  addEggRecordSchema,
  addMilkRecordSchema,
  addWoolRecordSchema,
} from "../validators/production.validator";

export const productionRouter = Router();

productionRouter.use(authenticate);

productionRouter.get("/milk", productionController.listMilk);
productionRouter.post("/milk", validate(addMilkRecordSchema), productionController.addMilk);
productionRouter.get("/eggs", productionController.listEggs);
productionRouter.post("/eggs", validate(addEggRecordSchema), productionController.addEggs);
productionRouter.get("/wool", productionController.listWool);
productionRouter.post("/wool", validate(addWoolRecordSchema), productionController.addWool);
