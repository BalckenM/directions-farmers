import { Router } from "express";
import { payrollController } from "../../controllers/payroll/payroll.controller";
import { validate } from "../../middleware/validate.middleware";
import { sendCommunicationSchema } from "../../validators/payroll/payroll.validator";

export const communicationsRouter = Router();

communicationsRouter.get("/communications", payrollController.listCommunications);
communicationsRouter.post("/communications", validate(sendCommunicationSchema), payrollController.sendCommunication);
