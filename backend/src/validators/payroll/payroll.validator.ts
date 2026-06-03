import { z } from "zod";

export const createEmployeeSchema = z
  .object({
    employeeNumber: z.string().min(1).max(50),
    firstName: z.string().min(1).max(100),
    lastName: z.string().min(1).max(100),
    idNumber: z.string().max(50).optional(),
    taxNumber: z.string().max(50).optional(),
    email: z.string().email().max(255).optional(),
    phone: z.string().max(20).optional(),
    dateOfBirth: z.string().date().optional(),
    sex: z.enum(["male", "female", "other"]).optional(),
    nationality: z.string().max(50).optional(),
    bankName: z.string().max(100).optional(),
    bankAccountNumber: z.string().max(50).optional(),
    bankBranchCode: z.string().max(20).optional(),
    startDate: z.string().date(),
    endDate: z.string().date().optional(),
    isActive: z.boolean().optional(),
    notes: z.string().max(2000).optional(),
  })
  .strict();

export const updateEmployeeSchema = createEmployeeSchema.partial();

export const createContractSchema = z
  .object({
    employeeId: z.string().uuid(),
    contractType: z.enum(["permanent", "fixed_term", "seasonal", "casual"]),
    payFrequency: z.enum(["weekly", "bi_weekly", "monthly"]),
    baseSalary: z.number().positive(),
    currency: z.string().length(3).default("ZAR"),
    startDate: z.string().date(),
    endDate: z.string().date().optional(),
  })
  .strict();

export const createPayRunSchema = z
  .object({
    payGroupId: z.string().uuid().optional(),
    periodStart: z.string().date(),
    periodEnd: z.string().date(),
    payDate: z.string().date(),
    notes: z.string().max(500).optional(),
  })
  .strict();

export const createLeaveRequestSchema = z
  .object({
    employeeId: z.string().uuid(),
    leaveTypeId: z.string().uuid(),
    startDate: z.string().date(),
    endDate: z.string().date(),
    daysRequested: z.number().positive(),
    reason: z.string().max(1000).optional(),
  })
  .strict();

export const createPieceworkLogSchema = z
  .object({
    employeeId: z.string().uuid(),
    taskName: z.string().min(1).max(255),
    quantity: z.number().positive(),
    ratePerUnit: z.number().positive(),
    totalAmount: z.number().positive(),
    workDate: z.string().date(),
    notes: z.string().max(500).optional(),
  })
  .strict();

export const createPayGroupSchema = z
  .object({
    name: z.string().min(1).max(100),
    payFrequency: z.enum(["weekly", "bi_weekly", "monthly"]),
    payDay: z.number().int().min(1).max(31).optional(),
    isActive: z.boolean().optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

export const updatePayGroupSchema = createPayGroupSchema.partial();

export const createPayStructureSchema = z
  .object({
    name: z.string().min(1).max(100),
    components: z.string().min(1),
  })
  .strict();

export const updatePayStructureSchema = createPayStructureSchema.partial();

export const createDeductionRuleSchema = z
  .object({
    name: z.string().min(1).max(100),
    type: z.string().min(1).max(50),
    calculationMethod: z.enum(["percentage", "fixed"]),
    value: z.number().positive(),
  })
  .strict();

export const updateDeductionRuleSchema = createDeductionRuleSchema.partial();

export const createGarnisheeOrderSchema = z
  .object({
    employeeId: z.string().uuid(),
    caseNumber: z.string().max(100).optional(),
    amount: z.number().positive(),
    creditorName: z.string().max(255).optional(),
    startDate: z.string().date(),
    endDate: z.string().date().optional(),
    notes: z.string().max(500).optional(),
  })
  .strict();

export const updateGarnisheeOrderSchema = createGarnisheeOrderSchema.partial();

export const createIncidentSchema = z
  .object({
    employeeId: z.string().uuid().optional(),
    incidentDate: z.string().date(),
    type: z.string().min(1).max(50),
    description: z.string().min(1),
    status: z
      .enum(["open", "under_investigation", "resolved", "closed"])
      .optional(),
  })
  .strict();

export const updateIncidentSchema = createIncidentSchema.partial();

export const sendCommunicationSchema = z
  .object({
    employeeId: z.string().uuid().optional(),
    subject: z.string().min(1).max(255),
    message: z.string().min(1),
  })
  .strict();

// ── Shifts ────────────────────────────────────────────────────────────────────
export const createShiftSchema = z
  .object({
    employeeId: z.string().uuid(),
    shiftDate: z.string().date(),
    startTime: z.string().max(10),
    endTime: z.string().max(10),
    breakMinutes: z.number().int().min(0).optional(),
    shiftType: z.string().max(50).optional(),
    status: z.enum(["scheduled", "completed", "cancelled"]).optional(),
    notes: z.string().max(2000).optional(),
  })
  .strict();

export const updateShiftSchema = createShiftSchema.partial();

// ── Task Assignments ──────────────────────────────────────────────────────────
export const createTaskAssignmentSchema = z
  .object({
    employeeId: z.string().uuid(),
    taskName: z.string().min(1).max(255),
    assignedDate: z.string().date(),
    dueDate: z.string().date().optional(),
    status: z
      .enum(["assigned", "in_progress", "completed", "cancelled"])
      .optional(),
    priority: z.enum(["low", "normal", "high", "urgent"]).optional(),
    notes: z.string().max(2000).optional(),
  })
  .strict();

export const updateTaskAssignmentSchema = createTaskAssignmentSchema.partial();

// ── Attendance ────────────────────────────────────────────────────────────────
export const createAttendanceRecordSchema = z
  .object({
    employeeId: z.string().uuid(),
    attendanceDate: z.string().date(),
    clockIn: z.string().max(10).optional(),
    clockOut: z.string().max(10).optional(),
    hoursWorked: z.number().min(0).optional(),
    status: z.enum(["present", "absent", "late", "leave"]).optional(),
    notes: z.string().max(2000).optional(),
  })
  .strict();

export const updateAttendanceRecordSchema =
  createAttendanceRecordSchema.partial();

// ── Employer Config ───────────────────────────────────────────────────────────
export const upsertEmployerConfigSchema = z
  .object({
    companyName: z.string().max(255).optional(),
    taxNumber: z.string().max(50).optional(),
    uifNumber: z.string().max(50).optional(),
    sdlNumber: z.string().max(50).optional(),
    payDay: z.number().int().min(1).max(31).optional(),
    overtimeMultiplier: z.number().min(1).max(5).optional(),
    currency: z.string().length(3).optional(),
    notes: z.string().max(2000).optional(),
  })
  .strict();

export type CreateEmployeeInput = z.infer<typeof createEmployeeSchema>;
export type UpdateEmployeeInput = z.infer<typeof updateEmployeeSchema>;
export type CreateContractInput = z.infer<typeof createContractSchema>;
