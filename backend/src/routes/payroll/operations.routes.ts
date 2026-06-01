import { Router } from "express";
import { payrollController } from "../../controllers/payroll/payroll.controller";
import { validate } from "../../middleware/validate.middleware";
import {
    createAttendanceRecordSchema,
    createShiftSchema,
    createTaskAssignmentSchema,
    updateAttendanceRecordSchema,
    updateShiftSchema,
    updateTaskAssignmentSchema,
    upsertEmployerConfigSchema,
} from "../../validators/payroll/payroll.validator";

export const operationsRouter = Router();

// ── Shifts ────────────────────────────────────────────────────────────────────
operationsRouter.get("/shifts", payrollController.listShifts);
operationsRouter.post("/shifts", validate(createShiftSchema), payrollController.createShift);
operationsRouter.get("/shifts/:id", payrollController.getShift);
operationsRouter.put("/shifts/:id", validate(updateShiftSchema), payrollController.updateShift);
operationsRouter.delete("/shifts/:id", payrollController.deleteShift);

// ── Task Assignments ──────────────────────────────────────────────────────────
operationsRouter.get("/task-assignments", payrollController.listTaskAssignments);
operationsRouter.post("/task-assignments", validate(createTaskAssignmentSchema), payrollController.createTaskAssignment);
operationsRouter.put("/task-assignments/:id", validate(updateTaskAssignmentSchema), payrollController.updateTaskAssignment);
operationsRouter.delete("/task-assignments/:id", payrollController.deleteTaskAssignment);

// ── Attendance ────────────────────────────────────────────────────────────────
operationsRouter.get("/attendance", payrollController.listAttendance);
operationsRouter.post("/attendance", validate(createAttendanceRecordSchema), payrollController.createAttendance);
operationsRouter.put("/attendance/:id", validate(updateAttendanceRecordSchema), payrollController.updateAttendance);

// ── Employer Config ───────────────────────────────────────────────────────────
operationsRouter.get("/employer-config", payrollController.getConfig);
operationsRouter.put("/employer-config", validate(upsertEmployerConfigSchema), payrollController.upsertConfig);
